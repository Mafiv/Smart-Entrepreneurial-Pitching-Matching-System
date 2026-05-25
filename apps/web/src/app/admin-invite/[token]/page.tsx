"use client";

import {
	signOut as firebaseSignOut,
	GoogleAuthProvider,
	signInWithPopup,
} from "firebase/auth";
import {
	CheckCircle2,
	Crown,
	Loader2,
	ShieldAlert,
	ShieldCheck,
	XCircle,
} from "lucide-react";
import { useParams, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/components/ui/card";
import { useAuth } from "@/context/AuthContext";
import { useLanguage } from "@/i18n/LanguageContext";

interface InviteData {
	createdBy?: string;
}

import { auth } from "@/lib/firebase";

export default function AdminInvitePage() {
	const params = useParams();
	const router = useRouter();
	const { refreshUserProfile } = useAuth();
	const { t } = useLanguage();
	const token = params.token as string;

	const [status, setStatus] = useState<
		"loading" | "valid" | "invalid" | "accepting" | "done"
	>("loading");
	const [inviteData, setInviteData] = useState<InviteData | null>(null);
	const [error, setError] = useState("");

	const API_URL = (
		process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api"
	).replace(/\/+$/, "");

	// Validate token on load
	useEffect(() => {
		async function validate() {
			try {
				const res = await fetch(`${API_URL}/auth/admin/invite/${token}`);
				const data = await res.json();
				if (data.status === "success") {
					setInviteData(data.invite);
					setStatus("valid");
				} else {
					setError(data.message);
					setStatus("invalid");
				}
			} catch {
				setError("Failed to validate invite link.");
				setStatus("invalid");
			}
		}
		validate();
	}, [token, API_URL]);

	const acceptInvite = async () => {
		setStatus("accepting");
		try {
			if (!auth) throw new Error("Firebase not initialized");

			// Always sign out first so the Google account chooser appears,
			// preventing auto-selection of a wrong/random account.
			await firebaseSignOut(auth);

			// Force account selection so the user explicitly picks which
			// Google account should become admin.
			const provider = new GoogleAuthProvider();
			provider.setCustomParameters({ prompt: "select_account" });
			const result = await signInWithPopup(auth, provider);
			const currentUser = result.user;

			const idToken = await currentUser.getIdToken();
			const res = await fetch(`${API_URL}/auth/admin/invite/${token}/accept`, {
				method: "POST",
				headers: { Authorization: `Bearer ${idToken}` },
			});
			const data = await res.json();

			if (data.status === "success") {
				await refreshUserProfile();
				setStatus("done");
				setTimeout(() => router.push("/admin/oversight"), 2000);
			} else {
				setError(data.message);
				setStatus("invalid");
			}
		} catch (err) {
			setError(err instanceof Error ? err.message : "Failed to accept invite.");
			setStatus("invalid");
		}
	};

	return (
		<div className="min-h-screen bg-background flex items-center justify-center p-4">
			<Card className="w-full max-w-md">
				<CardHeader className="text-center pb-4">
					<div className="flex justify-center mb-4">
						{status === "loading" && (
							<div className="h-16 w-16 rounded-full bg-muted flex items-center justify-center">
								<Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
							</div>
						)}
						{status === "valid" && (
							<div className="h-16 w-16 rounded-full bg-primary/10 flex items-center justify-center">
								<Crown className="h-8 w-8 text-primary" />
							</div>
						)}
						{status === "invalid" && (
							<div className="h-16 w-16 rounded-full bg-destructive/10 flex items-center justify-center">
								<XCircle className="h-8 w-8 text-destructive" />
							</div>
						)}
						{status === "accepting" && (
							<div className="h-16 w-16 rounded-full bg-primary/10 flex items-center justify-center">
								<Loader2 className="h-8 w-8 animate-spin text-primary" />
							</div>
						)}
						{status === "done" && (
							<div className="h-16 w-16 rounded-full bg-green-500/10 flex items-center justify-center">
								<CheckCircle2 className="h-8 w-8 text-green-500" />
							</div>
						)}
					</div>

					{status === "loading" && (
						<>
							<CardTitle>{t.auth.adminInviteLoading}</CardTitle>
							<CardDescription>{t.auth.adminInviteLoadingDesc}</CardDescription>
						</>
					)}

					{status === "valid" && (
						<>
							<CardTitle className="flex items-center justify-center gap-2">
								<ShieldAlert className="h-5 w-5 text-primary" />
								{t.auth.adminInviteTitle}
							</CardTitle>
							<CardDescription>
								{t.auth.adminInviteDesc}{" "}
								<strong className="text-foreground">
									{inviteData?.createdBy}
								</strong>{" "}
								{t.auth.adminInviteDesc2}
							</CardDescription>
						</>
					)}

					{status === "invalid" && (
						<>
							<CardTitle className="text-destructive">
								{t.auth.invalidInvite}
							</CardTitle>
							<CardDescription>{error}</CardDescription>
						</>
					)}

					{status === "accepting" && (
						<>
							<CardTitle>{t.auth.settingUpAdmin}</CardTitle>
							<CardDescription>{t.auth.settingUpAdminDesc}</CardDescription>
						</>
					)}

					{status === "done" && (
						<>
							<CardTitle className="text-green-600 dark:text-green-400 flex items-center justify-center gap-2">
								<ShieldCheck className="h-5 w-5" />
								{t.auth.adminDone}
							</CardTitle>
							<CardDescription>{t.auth.adminDoneDesc}</CardDescription>
						</>
					)}
				</CardHeader>

				{status === "valid" && (
					<CardContent className="space-y-4">
						<div className="rounded-lg border bg-muted/30 p-4 space-y-2 text-sm">
							<p className="text-muted-foreground">
								{t.auth.adminAbilitiesTitle}
							</p>
							<ul className="space-y-1 text-muted-foreground">
								<li className="flex items-center gap-2">
									<CheckCircle2 className="h-3.5 w-3.5 text-green-500 shrink-0" />
									{t.auth.adminAbility1}
								</li>
								<li className="flex items-center gap-2">
									<CheckCircle2 className="h-3.5 w-3.5 text-green-500 shrink-0" />
									{t.auth.adminAbility2}
								</li>
								<li className="flex items-center gap-2">
									<CheckCircle2 className="h-3.5 w-3.5 text-green-500 shrink-0" />
									{t.auth.adminAbility3}
								</li>
							</ul>
						</div>

						<Button onClick={acceptInvite} className="w-full gap-2" size="lg">
							<ShieldCheck className="h-4 w-4" />
							{t.auth.acceptAdminInviteButton}
						</Button>

						<p className="text-xs text-muted-foreground text-center">
							{t.auth.adminGooglePrompt}
						</p>
					</CardContent>
				)}

				{status === "invalid" && (
					<CardContent>
						<Button
							variant="outline"
							className="w-full"
							onClick={() => router.push("/")}
						>
							{t.auth.goToHome}
						</Button>
					</CardContent>
				)}
			</Card>
		</div>
	);
}
