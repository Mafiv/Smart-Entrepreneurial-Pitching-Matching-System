"use client";

import { CheckCircle2, Loader2, Lock, Save, Shield } from "lucide-react";
import { useEffect, useState } from "react";
import DashboardLayout from "@/components/DashboardLayout";
import ProfilePictureUpload from "@/components/ProfilePictureUpload";
import ProtectedRoute from "@/components/ProtectedRoute";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
	Card,
	CardContent,
	CardDescription,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/components/ui/card";
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogFooter,
	DialogHeader,
	DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Separator } from "@/components/ui/separator";
import { ADMIN_NAV } from "@/constants/navigation";
import { useAuth } from "@/context/AuthContext";
import { useLanguage } from "@/i18n/LanguageContext";
import { showErrorToast, showSuccessToast } from "@/lib/toast-messages";

export default function AdminProfilePage() {
	const { user, userProfile, refreshUserProfile, signOut } = useAuth();
	const { t } = useLanguage();

	const API_URL = (
		process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api"
	).replace(/\/+$/, "");

	// Account editing
	const [editName, setEditName] = useState(userProfile?.displayName || "");
	const [savingProfile, setSavingProfile] = useState(false);

	// Confirmation dialog
	const [confirmSignout, setConfirmSignout] = useState(false);

	useEffect(() => {
		if (userProfile?.displayName) setEditName(userProfile.displayName);
	}, [userProfile?.displayName]);

	const handleUpdateProfile = async () => {
		if (!user || !editName.trim()) return;
		setSavingProfile(true);
		try {
			const token = await user.getIdToken();
			const res = await fetch(`${API_URL}/users/me`, {
				method: "PATCH",
				headers: {
					Authorization: `Bearer ${token}`,
					"Content-Type": "application/json",
				},
				body: JSON.stringify({ fullName: editName.trim() }),
			});
			if (!res.ok) throw new Error("Failed to update profile");
			await refreshUserProfile();
			showSuccessToast("Profile updated successfully!");
		} catch (err) {
			showErrorToast(
				err instanceof Error ? err.message : "Failed to update profile",
			);
		} finally {
			setSavingProfile(false);
		}
	};

	const displayName = userProfile?.displayName || "Admin";
	const email = userProfile?.email || "";
	const adminLevel = userProfile?.adminLevel || "admin";

	return (
		<ProtectedRoute allowedRoles={["admin"]}>
			<DashboardLayout navItems={ADMIN_NAV} title={t.common.profile}>
				<div className="admin-greeting-card bg-card mb-8 p-6 sm:p-8 admin-content-fade">
					<div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
						<div>
							<h1 className="text-2xl font-bold tracking-tight sm:text-3xl admin-header-gradient">
								{t.adminProfile.myProfile}
							</h1>
							<p className="mt-1.5 text-muted-foreground text-sm sm:text-base">
								{t.adminProfile.manageAdminAccount}
							</p>
						</div>
					</div>
				</div>

				<div className="space-y-6">
					{/* Editable Profile */}
					<Card>
						<CardHeader>
							<CardTitle className="text-base flex items-center gap-2">
								<Shield className="h-4 w-4 text-primary" />
								{t.adminProfile.personalDetails}
							</CardTitle>
							<CardDescription>
								{t.adminProfile.updatePersonalInfo}
							</CardDescription>
						</CardHeader>
						<CardContent className="space-y-6">
							<div className="flex flex-col sm:flex-row items-start gap-6 pb-2">
								<div className="shrink-0">
									<Label className="text-sm text-muted-foreground block mb-3">
										{t.adminProfile.profilePicture}
									</Label>
									<ProfilePictureUpload size="h-20 w-20" />
								</div>
								<Separator
									orientation="vertical"
									className="hidden sm:block h-28"
								/>
								<Separator className="sm:hidden" />
								<div className="flex-1 grid gap-4 sm:grid-cols-2 w-full">
									<div className="space-y-2">
										<Label htmlFor="admin-edit-name" className="text-sm">
											{t.adminProfile.fullName}
										</Label>
										<Input
											id="admin-edit-name"
											value={editName}
											onChange={(e) => setEditName(e.target.value)}
											placeholder={t.adminProfile.yourFullName}
										/>
									</div>
									<div className="space-y-2">
										<Label className="text-sm text-muted-foreground">
											{t.adminProfile.emailAddress}
										</Label>
										<div className="flex items-center gap-1.5 pt-2">
											<p className="text-sm font-medium">{email}</p>
											{userProfile?.emailVerified && (
												<CheckCircle2 className="h-3.5 w-3.5 text-green-500" />
											)}
										</div>
										<p className="text-xs text-muted-foreground">
											{t.adminProfile.emailManagedByGoogle}
										</p>
									</div>
									<div className="space-y-2">
										<Label className="text-sm text-muted-foreground">
											{t.adminProfile.role}
										</Label>
										<div className="flex items-center gap-2 pt-2">
											<Badge
												variant="destructive"
												className="text-xs capitalize"
											>
												{adminLevel === "super_admin"
													? t.adminProfile.superAdmin
													: t.adminProfile.admin}
											</Badge>
										</div>
									</div>
									<div className="space-y-2">
										<Label className="text-sm text-muted-foreground">
											{t.adminProfile.accountStatus}
										</Label>
										<div className="pt-2">
											<Badge
												variant="default"
												className="text-xs capitalize bg-green-500/10 text-green-600 border-green-500/20"
											>
												{userProfile?.status}
											</Badge>
										</div>
									</div>
								</div>
							</div>
						</CardContent>
						<CardFooter className="flex justify-end border-t pt-4">
							<Button
								onClick={handleUpdateProfile}
								disabled={
									savingProfile ||
									editName.trim() === (userProfile?.displayName || "")
								}
								className="gap-2"
							>
								{savingProfile ? (
									<>
										<Loader2 className="h-4 w-4 animate-spin" />{" "}
										{t.adminProfile.saving}
									</>
								) : (
									<>
										<Save className="h-4 w-4" /> {t.adminProfile.saveChanges}
									</>
								)}
							</Button>
						</CardFooter>
					</Card>

					{/* Session Info */}
					<Card>
						<CardHeader>
							<CardTitle className="text-base flex items-center gap-2">
								<Lock className="h-4 w-4 text-primary" />
								{t.adminProfile.session}
							</CardTitle>
						</CardHeader>
						<CardContent className="space-y-3">
							<div className="grid gap-3 sm:grid-cols-2">
								<div className="rounded-lg border p-3">
									<p className="text-xs text-muted-foreground">Firebase UID</p>
									<p className="text-xs font-mono mt-1 truncate">
										{user?.uid || "—"}
									</p>
								</div>
								<div className="rounded-lg border p-3">
									<p className="text-xs text-muted-foreground">
										{t.adminProfile.provider}
									</p>
									<p className="text-xs font-medium mt-1">
										{t.adminProfile.googleAuth}
									</p>
								</div>
							</div>
							<Separator />
							<Button
								variant="outline"
								onClick={() => setConfirmSignout(true)}
								className="gap-2 text-destructive hover:text-destructive"
							>
								{t.adminProfile.signOutOfAccount}
							</Button>
						</CardContent>
					</Card>
				</div>

				{/* Signout Confirmation Dialog */}
				<Dialog open={confirmSignout} onOpenChange={setConfirmSignout}>
					<DialogContent className="sm:max-w-md">
						<DialogHeader>
							<DialogTitle className="text-destructive">
								{t.adminProfile.confirmAction}
							</DialogTitle>
							<DialogDescription>
								{t.adminProfile.signOutConfirm}
							</DialogDescription>
						</DialogHeader>
						<DialogFooter className="gap-2 sm:gap-0">
							<Button
								variant="outline"
								onClick={() => setConfirmSignout(false)}
							>
								{t.common.cancel}
							</Button>
							<Button variant="destructive" onClick={() => signOut()}>
								{t.common.signOut}
							</Button>
						</DialogFooter>
					</DialogContent>
				</Dialog>
			</DashboardLayout>
		</ProtectedRoute>
	);
}
