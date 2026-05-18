"use client";

import { CheckCircle2, Loader2, Lock, Save, Shield } from "lucide-react";
import { useEffect, useState } from "react";
import { toast } from "sonner";
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

export default function AdminProfilePage() {
	const { user, userProfile, refreshUserProfile, signOut } = useAuth();

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
			toast.success("Profile updated successfully!");
		} catch (err) {
			toast.error(
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
			<DashboardLayout navItems={ADMIN_NAV} title="Profile">
				<div className="admin-greeting-card bg-card mb-8 p-6 sm:p-8 admin-content-fade">
					<div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
						<div>
							<h1 className="text-2xl font-bold tracking-tight sm:text-3xl admin-header-gradient">
								My Profile
							</h1>
							<p className="mt-1.5 text-muted-foreground text-sm sm:text-base">
								Manage your administrator account and personal details.
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
								Personal Details
							</CardTitle>
							<CardDescription>
								Update your personal information.
							</CardDescription>
						</CardHeader>
						<CardContent className="space-y-6">
							<div className="flex flex-col sm:flex-row items-start gap-6 pb-2">
								<div className="shrink-0">
									<Label className="text-sm text-muted-foreground block mb-3">
										Profile Picture
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
											Full Name
										</Label>
										<Input
											id="admin-edit-name"
											value={editName}
											onChange={(e) => setEditName(e.target.value)}
											placeholder="Your full name"
										/>
									</div>
									<div className="space-y-2">
										<Label className="text-sm text-muted-foreground">
											Email Address
										</Label>
										<div className="flex items-center gap-1.5 pt-2">
											<p className="text-sm font-medium">{email}</p>
											{userProfile?.emailVerified && (
												<CheckCircle2 className="h-3.5 w-3.5 text-green-500" />
											)}
										</div>
										<p className="text-xs text-muted-foreground">
											Email is managed by Google
										</p>
									</div>
									<div className="space-y-2">
										<Label className="text-sm text-muted-foreground">
											Role
										</Label>
										<div className="flex items-center gap-2 pt-2">
											<Badge
												variant="destructive"
												className="text-xs capitalize"
											>
												{adminLevel === "super_admin" ? "Super Admin" : "Admin"}
											</Badge>
										</div>
									</div>
									<div className="space-y-2">
										<Label className="text-sm text-muted-foreground">
											Account Status
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
										<Loader2 className="h-4 w-4 animate-spin" /> Saving...
									</>
								) : (
									<>
										<Save className="h-4 w-4" /> Save Changes
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
								Session
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
									<p className="text-xs text-muted-foreground">Provider</p>
									<p className="text-xs font-medium mt-1">
										Google Authentication
									</p>
								</div>
							</div>
							<Separator />
							<Button
								variant="outline"
								onClick={() => setConfirmSignout(true)}
								className="gap-2 text-destructive hover:text-destructive"
							>
								Sign Out of Account
							</Button>
						</CardContent>
					</Card>
				</div>

				{/* Signout Confirmation Dialog */}
				<Dialog open={confirmSignout} onOpenChange={setConfirmSignout}>
					<DialogContent className="sm:max-w-md">
						<DialogHeader>
							<DialogTitle className="text-destructive">
								Confirm Action
							</DialogTitle>
							<DialogDescription>
								Are you sure you want to sign out of your account?
							</DialogDescription>
						</DialogHeader>
						<DialogFooter className="gap-2 sm:gap-0">
							<Button
								variant="outline"
								onClick={() => setConfirmSignout(false)}
							>
								Cancel
							</Button>
							<Button variant="destructive" onClick={() => signOut()}>
								Sign Out
							</Button>
						</DialogFooter>
					</DialogContent>
				</Dialog>
			</DashboardLayout>
		</ProtectedRoute>
	);
}
