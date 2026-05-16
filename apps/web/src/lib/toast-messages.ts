/**
 * Centralized toast message utilities for SEPMS.
 *
 * Converts raw Firebase / backend error strings into polished, user-friendly
 * messages following industry-standard UX copy.  All consumer code should call
 * `showErrorToast` / `showSuccessToast` / `showInfoToast` instead of
 * importing `toast` from sonner directly — this keeps every notification
 * consistent across the entire app.
 */

import { toast } from "sonner";

// ─── Firebase Error → Friendly Message Map ─────────────────────────────────

const FIREBASE_ERROR_MAP: Record<
	string,
	{ title: string; description?: string }
> = {
	// Sign-in / credential errors
	"auth/invalid-credential": {
		title: "Invalid email or password",
		description: "Please check your credentials and try again.",
	},
	"auth/wrong-password": {
		title: "Incorrect password",
		description:
			"The password you entered is incorrect. Try again or reset it.",
	},
	"auth/user-not-found": {
		title: "Account not found",
		description: "No account exists with this email address. Please sign up.",
	},
	"auth/invalid-email": {
		title: "Invalid email address",
		description: "Please enter a valid email address.",
	},
	"auth/user-disabled": {
		title: "Account disabled",
		description: "This account has been suspended. Contact support for help.",
	},

	// Sign-up errors
	"auth/email-already-in-use": {
		title: "Email already registered",
		description:
			"An account with this email already exists. Try signing in instead.",
	},
	"auth/weak-password": {
		title: "Password too weak",
		description:
			"Please choose a stronger password with at least 6 characters.",
	},
	"auth/operation-not-allowed": {
		title: "Sign-up unavailable",
		description:
			"This sign-up method is currently disabled. Please try another option.",
	},

	// Rate-limiting / abuse
	"auth/too-many-requests": {
		title: "Too many attempts",
		description:
			"Access temporarily blocked due to too many failed attempts. Try again later.",
	},

	// Google / OAuth
	"auth/popup-closed-by-user": {
		title: "Sign-in cancelled",
		description:
			"The sign-in popup was closed before completing. Please try again.",
	},
	"auth/popup-blocked": {
		title: "Popup blocked",
		description:
			"Your browser blocked the sign-in popup. Please allow popups and try again.",
	},
	"auth/cancelled-popup-request": {
		title: "Sign-in cancelled",
		description: "Only one sign-in window can be open at a time.",
	},
	"auth/account-exists-with-different-credential": {
		title: "Account already exists",
		description:
			"An account with this email already exists using a different sign-in method.",
	},

	// Network & general
	"auth/network-request-failed": {
		title: "Connection error",
		description: "Please check your internet connection and try again.",
	},
	"auth/internal-error": {
		title: "Something went wrong",
		description: "An unexpected error occurred. Please try again later.",
	},
	"auth/requires-recent-login": {
		title: "Session expired",
		description: "For security, please sign in again to complete this action.",
	},

	// Phone / SMS
	"auth/invalid-phone-number": {
		title: "Invalid phone number",
		description:
			"Please enter a valid phone number with country code (e.g., +251...).",
	},
	"auth/missing-phone-number": {
		title: "Phone number required",
		description: "Please enter your phone number to continue.",
	},
	"auth/invalid-verification-code": {
		title: "Invalid verification code",
		description:
			"The code you entered is incorrect. Please check and try again.",
	},
	"auth/code-expired": {
		title: "Code expired",
		description:
			"Your verification code has expired. Please request a new one.",
	},
	"auth/credential-already-in-use": {
		title: "Phone number in use",
		description: "This phone number is already linked to another account.",
	},
};

// ─── General error phrases to catch ─────────────────────────────────────────

const GENERAL_ERROR_MAP: Array<{
	pattern: RegExp;
	title: string;
	description?: string;
}> = [
	{
		pattern: /Firebase.*not initialized/i,
		title: "Service unavailable",
		description:
			"Authentication service is loading. Please try again in a moment.",
	},
	{
		pattern: /Failed to fetch|NetworkError|fetch failed/i,
		title: "Connection error",
		description: "Unable to reach the server. Please check your connection.",
	},
	{
		pattern: /No user logged in/i,
		title: "Session expired",
		description: "Please sign in again to continue.",
	},
	{
		pattern: /Failed to (create|fetch) (user )?profile/i,
		title: "Profile error",
		description: "We couldn't load your profile. Please try again.",
	},
	{
		pattern: /already exists.*sign in/i,
		title: "Account already exists",
		description:
			"An account with this email already exists. Please sign in instead.",
	},
	{
		pattern: /password does not match.*sign in or reset/i,
		title: "Incorrect password",
		description:
			"The password doesn't match the existing account. Try signing in or resetting your password.",
	},
];

// ─── Error code extractor ────────────────────────────────────────────────────

function extractFirebaseCode(error: unknown): string | null {
	if (typeof error === "object" && error !== null && "code" in error) {
		return (error as { code: string }).code;
	}
	const message = error instanceof Error ? error.message : String(error);
	// Firebase errors in message format: "Firebase: Error (auth/xxx)."
	const match = message.match(/\(auth\/[\w-]+\)/);
	if (match) return match[0].slice(1, -1);
	return null;
}

// ─── Friendly message resolver ──────────────────────────────────────────────

interface FriendlyMessage {
	title: string;
	description?: string;
}

function getFriendlyMessage(
	error: unknown,
	fallbackTitle = "Something went wrong",
	fallbackDescription = "An unexpected error occurred. Please try again.",
): FriendlyMessage {
	// 1. Try Firebase error code
	const code = extractFirebaseCode(error);
	if (code && FIREBASE_ERROR_MAP[code]) {
		return FIREBASE_ERROR_MAP[code];
	}

	// 2. Try matching against the error message text
	const message = error instanceof Error ? error.message : String(error);
	for (const entry of GENERAL_ERROR_MAP) {
		if (entry.pattern.test(message)) {
			return { title: entry.title, description: entry.description };
		}
	}

	// 3. If the message looks like it's already user-friendly (no "auth/" or technical jargon)
	if (
		message &&
		!message.includes("auth/") &&
		!message.includes("Firebase") &&
		!message.includes("firestore") &&
		message.length < 120
	) {
		return { title: message };
	}

	// 4. Ultimate fallback
	return { title: fallbackTitle, description: fallbackDescription };
}

// ─── Public API ──────────────────────────────────────────────────────────────

/**
 * Show an error toast with a user-friendly message.
 * Automatically translates Firebase / backend errors into clean copy.
 */
export function showErrorToast(
	error: unknown,
	fallbackTitle?: string,
	fallbackDescription?: string,
) {
	const { title, description } = getFriendlyMessage(
		error,
		fallbackTitle,
		fallbackDescription,
	);
	toast.error(title, { description });
}

/**
 * Show a success toast.
 */
export function showSuccessToast(title: string, description?: string) {
	toast.success(title, { description });
}

/**
 * Show an info toast.
 */
export function showInfoToast(title: string, description?: string) {
	toast.info(title, { description });
}

/**
 * Show a warning toast.
 */
export function showWarningToast(title: string, description?: string) {
	toast.warning(title, { description });
}

/**
 * Show a promise toast for async operations.
 */
export function showPromiseToast<T>(
	promise: Promise<T>,
	options: {
		loading: string;
		success: string | ((data: T) => string);
		error?: string;
		description?: {
			loading?: string;
			success?: string;
			error?: string;
		};
	},
) {
	return toast.promise(promise, {
		loading: options.loading,
		success: options.success,
		error: options.error ?? "Something went wrong. Please try again.",
	});
}
