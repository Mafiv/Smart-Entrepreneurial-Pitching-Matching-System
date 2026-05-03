"use client";

import {
	createUserWithEmailAndPassword,
	signOut as firebaseSignOut,
	onAuthStateChanged,
	signInWithEmailAndPassword,
	signInWithPopup,
	type User,
	updateProfile,
} from "firebase/auth";
import {
	createContext,
	type ReactNode,
	useCallback,
	useContext,
	useEffect,
	useState,
} from "react";
import { auth, googleProvider } from "@/lib/firebase";

// ---------------------
// Types
// ---------------------
export type UserRole = "admin" | "entrepreneur" | "investor" | null;

export interface UserProfile {
	_id?: string;
	uid: string;
	email: string | null;
	displayName: string | null;
	role: UserRole;
	adminLevel?: "super_admin" | "admin" | null;
	status: "unverified" | "pending" | "verified" | "suspended";
	kycRejectionReason?: string | null;
	photoURL: string | null;
	phoneNumber?: string | null;
	phoneVerified?: boolean;
	emailVerified: boolean;
}

interface AuthContextType {
	user: User | null;
	userProfile: UserProfile | null;
	loading: boolean;
	signUp: (
		email: string,
		password: string,
		fullName: string,
		additionalData?: { role: string; companyName?: string; fundName?: string },
	) => Promise<UserProfile>;
	signIn: (email: string, password: string) => Promise<UserProfile>;
	signInWithGoogle: (additionalData?: {
		role: string;
		companyName?: string;
		fundName?: string;
	}) => Promise<UserProfile>;
	signOut: () => Promise<void>;
	resendVerificationEmail: () => Promise<void>;
	requestEmailOtp: () => Promise<void>;
	verifyEmailOtp: (code: string) => Promise<void>;
	requestPasswordResetOtp: (email: string) => Promise<void>;
	confirmPasswordReset: (options: {
		email: string;
		code: string;
		newPassword: string;
	}) => Promise<void>;
	refreshUserProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

// ---------------------
// Provider
// ---------------------
export function AuthProvider({ children }: { children: ReactNode }) {
	const [user, setUser] = useState<User | null>(null);
	const [userProfile, setUserProfile] = useState<UserProfile | null>(null);
	const [loading, setLoading] = useState(true);

	const API_URL = (
		process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api"
	).replace(/\/+$/, "");

	// Fetch user profile from our backend
	const fetchUserProfile = useCallback(
		async (firebaseUser: User): Promise<UserProfile | null> => {
			try {
				const token = await firebaseUser.getIdToken(true); // Force refresh to get latest email_verified
				const res = await fetch(`${API_URL}/auth/me`, {
					headers: { Authorization: `Bearer ${token}` },
				});

				if (res.ok) {
					const data = await res.json();
					return data.user;
				}

				return null;
			} catch (error) {
				console.error("Error fetching user profile:", error);
				return null;
			}
		},
		[API_URL],
	);

	// Register user in backend
	const syncUserWithBackend = async (
		firebaseUser: User,
		isNewUser: boolean = false,
		additionalData?: { role?: string; companyName?: string; fundName?: string },
	): Promise<UserProfile | null> => {
		try {
			const token = await firebaseUser.getIdToken();

			if (isNewUser) {
				const res = await fetch(`${API_URL}/auth/register`, {
					method: "POST",
					headers: {
						"Content-Type": "application/json",
						Authorization: `Bearer ${token}`,
					},
					body: JSON.stringify({
						fullName: firebaseUser.displayName || "New User",
						email: firebaseUser.email,
						...additionalData,
					}),
				});

				if (res.ok) {
					const data = await res.json();
					return data.user;
				}
			}

			return await fetchUserProfile(firebaseUser);
		} catch (error) {
			console.error("Error syncing user with backend:", error);
			return null;
		}
	};

	// Listen for Firebase auth state changes
	useEffect(() => {
		if (!auth) {
			// eslint-disable-next-line react-hooks/set-state-in-effect
			setLoading(false);
			return;
		}

		const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
			setUser(firebaseUser);

			if (firebaseUser) {
				const profile = await fetchUserProfile(firebaseUser);
				setUserProfile(profile);
			} else {
				setUserProfile(null);
			}

			setLoading(false);
		});

		return () => unsubscribe();
	}, [fetchUserProfile]);

	// ---------------------
	// Auth Methods
	// ---------------------
	const signUp = async (
		email: string,
		password: string,
		fullName: string,
		additionalData?: { role: string; companyName?: string; fundName?: string },
	): Promise<UserProfile> => {
		if (!auth) throw new Error("Firebase not initialized");
		const credential = await createUserWithEmailAndPassword(
			auth,
			email,
			password,
		);
		await updateProfile(credential.user, { displayName: fullName });

		// Register in backend
		const profile = await syncUserWithBackend(
			credential.user,
			true,
			additionalData,
		);

		if (!profile) throw new Error("Failed to create profile in backend");

		setUserProfile(profile);
		await requestEmailOtp();
		return profile;
	};

	const signIn = async (
		email: string,
		password: string,
	): Promise<UserProfile> => {
		try {
			if (!auth) throw new Error("Firebase not initialized");
			const credential = await signInWithEmailAndPassword(
				auth,
				email,
				password,
			);
			const profile = await fetchUserProfile(credential.user);

			if (!profile) throw new Error("Failed to fetch user profile");

			setUserProfile(profile);
			return profile;
		} catch (error) {
			console.error("AuthContext signIn error:", error);
			throw error;
		}
	};

	const signInWithGoogle = async (additionalData?: {
		role: string;
		companyName?: string;
		fundName?: string;
	}): Promise<UserProfile> => {
		try {
			if (!auth || !googleProvider) throw new Error("Firebase not initialized");
			const credential = await signInWithPopup(auth, googleProvider);

			let profile = await fetchUserProfile(credential.user);

			if (!profile) {
				profile = await syncUserWithBackend(
					credential.user,
					true,
					additionalData,
				);
			}

			if (!profile) throw new Error("Failed to authenticate with backend");

			console.log("🔑 signInWithGoogle — profile:", {
				role: profile.role,
				email: profile.email,
				uid: profile.uid,
			});

			setUserProfile(profile);
			return profile;
		} catch (error) {
			console.error("AuthContext signInWithGoogle error:", error);
			throw error;
		}
	};

	const signOut = async () => {
		if (!auth) throw new Error("Firebase not initialized");
		await firebaseSignOut(auth);
		setUser(null);
		setUserProfile(null);
	};

	const requestEmailOtp = useCallback(async (): Promise<void> => {
		if (!auth?.currentUser) throw new Error("No user logged in");
		const token = await auth.currentUser.getIdToken();
		const res = await fetch(`${API_URL}/auth/otp/request`, {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
				Authorization: `Bearer ${token}`,
			},
			body: JSON.stringify({ channel: "email", purpose: "verify" }),
		});

		if (!res.ok) {
			const data = await res.json().catch(() => null);
			throw new Error(data?.message || "Failed to send OTP");
		}
	}, [API_URL]);

	const verifyEmailOtp = useCallback(
		async (code: string): Promise<void> => {
			if (!auth?.currentUser) throw new Error("No user logged in");
			const token = await auth.currentUser.getIdToken();
			const res = await fetch(`${API_URL}/auth/otp/verify`, {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					Authorization: `Bearer ${token}`,
				},
				body: JSON.stringify({
					channel: "email",
					purpose: "verify",
					code,
				}),
			});

			if (!res.ok) {
				const data = await res.json().catch(() => null);
				throw new Error(data?.message || "Failed to verify OTP");
			}
		},
		[API_URL],
	);

	const resendVerificationEmail = async () => {
		await requestEmailOtp();
	};

	const requestPasswordResetOtp = useCallback(
		async (email: string): Promise<void> => {
			const res = await fetch(`${API_URL}/auth/password-reset/request`, {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
				},
				body: JSON.stringify({ email }),
			});

			if (!res.ok) {
				const data = await res.json().catch(() => null);
				throw new Error(data?.message || "Failed to send password reset OTP");
			}
		},
		[API_URL],
	);

	const confirmPasswordReset = useCallback(
		async (options: {
			email: string;
			code: string;
			newPassword: string;
		}): Promise<void> => {
			const res = await fetch(`${API_URL}/auth/password-reset/confirm`, {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
				},
				body: JSON.stringify(options),
			});

			if (!res.ok) {
				const data = await res.json().catch(() => null);
				throw new Error(data?.message || "Failed to reset password");
			}
		},
		[API_URL],
	);

	// Reload Firebase user and refresh profile from backend
	const refreshUserProfile = useCallback(async () => {
		if (!auth?.currentUser) return;

		// Reload Firebase user to get latest emailVerified status
		await auth.currentUser.reload();

		// Force token refresh so the backend middleware gets the updated email_verified claim
		const profile = await fetchUserProfile(auth.currentUser);
		setUserProfile(profile);
	}, [fetchUserProfile]);

	return (
		<AuthContext.Provider
			value={{
				user,
				userProfile,
				loading,
				signUp,
				signIn,
				signInWithGoogle,
				signOut,
				resendVerificationEmail,
				requestEmailOtp,
				verifyEmailOtp,
				requestPasswordResetOtp,
				confirmPasswordReset,
				refreshUserProfile,
			}}
		>
			{children}
		</AuthContext.Provider>
	);
}

// ---------------------
// Hook
// ---------------------
export function useAuth() {
	const context = useContext(AuthContext);
	if (context === undefined) {
		throw new Error("useAuth must be used within an AuthProvider");
	}
	return context;
}
