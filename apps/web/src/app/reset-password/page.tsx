"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { Suspense, useState } from "react";
import { Logo } from "@/components/Logo";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useAuth } from "@/context/AuthContext";
import { useLanguage } from "@/i18n/LanguageContext";
import {
	showErrorToast,
	showSuccessToast,
	showWarningToast,
} from "@/lib/toast-messages";

export default function ResetPasswordPage() {
	return (
		<Suspense
			fallback={
				<div className="flex min-h-screen w-full items-center justify-center bg-background">
					<p className="text-muted-foreground">Loading...</p>
				</div>
			}
		>
			<ResetPasswordContent />
		</Suspense>
	);
}

function ResetPasswordContent() {
	const router = useRouter();
	const searchParams = useSearchParams();
	const { confirmPasswordReset } = useAuth();
	const { t } = useLanguage();

	const [email, setEmail] = useState(searchParams.get("email") ?? "");
	const [code, setCode] = useState("");
	const [password, setPassword] = useState("");
	const [confirmPassword, setConfirmPassword] = useState("");
	const [loading, setLoading] = useState(false);

	const handleSubmit = async (event: React.FormEvent) => {
		event.preventDefault();

		if (!email.trim()) {
			showWarningToast("Email required", "Please enter your email address.");
			return;
		}
		if (!code.trim()) {
			showWarningToast(
				"Code required",
				"Please enter the 6-digit code from your email.",
			);
			return;
		}
		if (password.length < 6) {
			showWarningToast(
				"Password too short",
				"Your password must be at least 6 characters long.",
			);
			return;
		}
		if (password !== confirmPassword) {
			showWarningToast(
				"Passwords don't match",
				"Please make sure both password fields are identical.",
			);
			return;
		}

		setLoading(true);
		try {
			await confirmPasswordReset({
				email: email.trim(),
				code: code.trim(),
				newPassword: password,
			});
			showSuccessToast(
				"Password reset successful",
				"You can now sign in with your new password.",
			);
			router.push("/sign-in");
		} catch (err: unknown) {
			showErrorToast(
				err,
				"Password reset failed",
				"The code may be incorrect or expired. Please try again.",
			);
		} finally {
			setLoading(false);
		}
	};

	return (
		<div className="flex min-h-screen w-full bg-background flex-col lg:flex-row">
			<div className="relative hidden w-1/2 flex-col justify-center border-r border-border/50 p-12 lg:flex xl:p-24 overflow-hidden">
				<div className="pointer-events-none absolute inset-0 bg-[linear-gradient(rgba(255,255,255,0.02)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.02)_1px,transparent_1px)] bg-[size:64px_64px] dark:block hidden" />
				<div className="pointer-events-none absolute inset-0 bg-[linear-gradient(rgba(0,0,0,0.03)_1px,transparent_1px),linear-gradient(90deg,rgba(0,0,0,0.03)_1px,transparent_1px)] bg-[size:64px_64px] dark:hidden block" />

				<div className="relative z-10 flex flex-col gap-8">
					<Link href="/" className="flex items-center gap-3 w-fit">
						<Logo className="h-10 w-10" />
						<span className="text-xl font-bold tracking-tight">SEPMS</span>
					</Link>
					<div className="space-y-4">
						<h1 className="text-4xl font-bold tracking-tight sm:text-5xl xl:text-6xl leading-[1.1]">
							{t.auth.setNewPasswordTitle}
						</h1>
						<p className="text-lg text-muted-foreground max-w-md leading-relaxed">
							{t.auth.setNewPasswordSubtitle}
						</p>
					</div>
				</div>
			</div>

			<div className="flex w-full flex-col justify-center p-8 sm:p-12 lg:w-1/2 lg:px-16 xl:px-24">
				<div className="mx-auto lg:mx-0 w-full max-w-sm space-y-6">
					<div className="space-y-2 text-center lg:text-left">
						<div className="mx-auto mb-6 flex h-12 w-12 lg:hidden">
							<Logo className="h-12 w-12" />
						</div>
						<h2 className="text-3xl font-bold tracking-tight">
							{t.auth.resetPasswordFormTitle}
						</h2>
						<p className="text-muted-foreground">
							{t.auth.resetPasswordFormSubtitle}
						</p>
					</div>

					<form className="space-y-4" onSubmit={handleSubmit}>
						<div className="space-y-2">
							<Label htmlFor="email">{t.auth.email}</Label>
							<Input
								id="email"
								type="email"
								required
								value={email}
								onChange={(event) => setEmail(event.target.value)}
								placeholder={t.auth.emailPlaceholder}
							/>
						</div>
						<div className="space-y-2">
							<Label htmlFor="code">{t.auth.otpCode}</Label>
							<Input
								id="code"
								required
								value={code}
								onChange={(event) => setCode(event.target.value)}
								placeholder={t.auth.otpPlaceholder}
								inputMode="numeric"
								maxLength={6}
							/>
						</div>
						<div className="space-y-2">
							<Label htmlFor="password">{t.auth.newPassword}</Label>
							<Input
								id="password"
								type="password"
								required
								value={password}
								onChange={(event) => setPassword(event.target.value)}
								placeholder={t.auth.newPasswordPlaceholder}
							/>
						</div>
						<div className="space-y-2">
							<Label htmlFor="confirmPassword">{t.auth.confirmPassword}</Label>
							<Input
								id="confirmPassword"
								type="password"
								required
								value={confirmPassword}
								onChange={(event) => setConfirmPassword(event.target.value)}
								placeholder={t.auth.confirmPasswordPlaceholder}
							/>
						</div>
						<Button type="submit" className="w-full h-11" disabled={loading}>
							{loading ? t.auth.resetting : t.auth.resetPasswordButton}
						</Button>
					</form>

					<p className="text-sm text-muted-foreground text-center lg:text-left">
						{t.auth.needNewOtp}{" "}
						<Link
							href="/forgot-password"
							className="text-primary font-semibold"
						>
							{t.auth.requestAgain}
						</Link>
					</p>
				</div>
			</div>
		</div>
	);
}
