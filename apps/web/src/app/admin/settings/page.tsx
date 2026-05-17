"use client";

import {
	CheckCircle2,
	ClipboardList,
	Globe,
	Loader2,
	Lock,
	Save,
	Settings,
	Shield,
	Trash2,
	UserX,
} from "lucide-react";
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
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { ADMIN_NAV } from "@/constants/navigation";
import { useAuth } from "@/context/AuthContext";
import { useLanguage } from "@/i18n/LanguageContext";
import {
	showErrorToast,
	showInfoToast,
	showSuccessToast,
	showWarningToast,
} from "@/lib/toast-messages";

export default function AdminSettingsPage() {
	const { user, userProfile, refreshUserProfile, signOut } = useAuth();
	const { t } = useLanguage();
	const isSuperAdmin = userProfile?.adminLevel === "super_admin";

	const API_URL = (
		process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api"
	).replace(/\/+$/, "");

	// Account editing
	const [editName, setEditName] = useState(userProfile?.displayName || "");
	const [savingProfile, setSavingProfile] = useState(false);

	// Stats for platform info
	const [platformStats, setPlatformStats] = useState<{
		totalUsers: number;
		pendingKyc: number;
		admins: number;
		totalSubmissions: number;
	} | null>(null);
	const [loadingStats, setLoadingStats] = useState(false);

	// Confirmation dialogs
	const [confirmAction, setConfirmAction] = useState<string | null>(null);
	const [actionLoading, setActionLoading] = useState(false);

	useEffect(() => {
		if (userProfile?.displayName) setEditName(userProfile.displayName);
	}, [userProfile?.displayName]);

	// Fetch platform stats
	useEffect(() => {
		async function fetchStats() {
			if (!user) return;
			setLoadingStats(true);
			try {
				const token = await user.getIdToken();
				const res = await fetch(`${API_URL}/auth/admin/users?limit=1`, {
					headers: { Authorization: `Bearer ${token}` },
				});
				const data = await res.json();
				if (data.status === "success") {
					setPlatformStats({
						totalUsers: data.stats?.total || 0,
						pendingKyc: data.stats?.pending || 0,
						admins: data.stats?.admins || 0,
						totalSubmissions: 0,
					});
				}
			} catch {
				console.error("Failed to fetch stats");
			} finally {
				setLoadingStats(false);
			}
		}
		fetchStats();
	}, [user, API_URL]);

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

	const handleBulkAction = async (action: string) => {
		if (!user || !isSuperAdmin) return;
		setActionLoading(true);
		try {
			// These actions work through the existing user status update endpoints
			const token = await user.getIdToken();

			if (action === "reset-kyc") {
				// Reset all non-admin users to unverified
				const res = await fetch(
					`${API_URL}/auth/admin/users?role=entrepreneur&status=verified&limit=100`,
					{
						headers: { Authorization: `Bearer ${token}` },
					},
				);
				const data = await res.json();
				if (data.status === "success") {
					let resetCount = 0;
					for (const u of data.users) {
						try {
							await fetch(`${API_URL}/auth/admin/users/${u._id}/status`, {
								method: "PATCH",
								headers: {
									Authorization: `Bearer ${token}`,
									"Content-Type": "application/json",
								},
								body: JSON.stringify({
									status: "unverified",
									reason: "Bulk KYC reset by admin",
								}),
							});
							resetCount++;
						} catch {
							/* skip failed ones */
						}
					}
					// Also reset investors
					const invRes = await fetch(
						`${API_URL}/auth/admin/users?role=investor&status=verified&limit=100`,
						{
							headers: { Authorization: `Bearer ${token}` },
						},
					);
					const invData = await invRes.json();
					if (invData.status === "success") {
						for (const u of invData.users) {
							try {
								await fetch(`${API_URL}/auth/admin/users/${u._id}/status`, {
									method: "PATCH",
									headers: {
										Authorization: `Bearer ${token}`,
										"Content-Type": "application/json",
									},
									body: JSON.stringify({
										status: "unverified",
										reason: "Bulk KYC reset by admin",
									}),
								});
								resetCount++;
							} catch {
								/* skip */
							}
						}
					}
					showSuccessToast(`Reset KYC for ${resetCount} users`);
				}
			} else if (action === "suspend-unverified") {
				const res = await fetch(
					`${API_URL}/auth/admin/users?status=unverified&limit=100`,
					{
						headers: { Authorization: `Bearer ${token}` },
					},
				);
				const data = await res.json();
				if (data.status === "success") {
					let suspendedCount = 0;
					for (const u of data.users) {
						if (u.role === "admin") continue; // Never suspend admins
						try {
							await fetch(`${API_URL}/auth/admin/users/${u._id}/status`, {
								method: "PATCH",
								headers: {
									Authorization: `Bearer ${token}`,
									"Content-Type": "application/json",
								},
								body: JSON.stringify({ status: "suspended" }),
							});
							suspendedCount++;
						} catch {
							/* skip */
						}
					}
					showSuccessToast(`Suspended ${suspendedCount} unverified accounts`);
				}
			}
		} catch (err) {
			showErrorToast(err instanceof Error ? err.message : "Action failed");
		} finally {
			setActionLoading(false);
			setConfirmAction(null);
		}
	};

	const displayName = userProfile?.displayName || "Admin";
	const email = userProfile?.email || "";
	const adminLevel = userProfile?.adminLevel || "admin";

	const _initials = displayName
		.split(" ")
		.map((n) => n[0])
		.join("")
		.toUpperCase()
		.slice(0, 2);

	return (
		<ProtectedRoute allowedRoles={["admin"]}>
			<DashboardLayout navItems={ADMIN_NAV} title="SEPMS Admin">
				<Tabs defaultValue="account" className="space-y-6">
					<TabsList>
						<TabsTrigger value="account" className="gap-1.5">
							<Shield className="h-3.5 w-3.5" />
							{t.adminSettings.account}
						</TabsTrigger>
						<TabsTrigger value="platform" className="gap-1.5">
							<Globe className="h-3.5 w-3.5" />
							{t.adminSettings.platform}
						</TabsTrigger>
						<TabsTrigger value="security" className="gap-1.5">
							<Lock className="h-3.5 w-3.5" />
							{t.adminSettings.security}
						</TabsTrigger>
					</TabsList>

					{/* ─── Account Tab ─── */}
					<TabsContent value="account" className="space-y-6 mt-0">
						{/* Editable Profile */}
						<Card>
							<CardHeader>
								<CardTitle className="text-base flex items-center gap-2">
									<Shield className="h-4 w-4 text-primary" />
									{t.adminSettings.yourProfile}
								</CardTitle>
								<CardDescription>
									{t.adminSettings.updatePersonalInfo}
								</CardDescription>
							</CardHeader>
							<CardContent className="space-y-6">
								<div className="flex flex-col sm:flex-row items-start gap-6 pb-2">
									<div className="shrink-0">
										<Label className="text-sm text-muted-foreground block mb-3">
											{t.adminSettings.profilePicture}
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
												{t.adminSettings.fullName}
											</Label>
											<Input
												id="admin-edit-name"
												value={editName}
												onChange={(e) => setEditName(e.target.value)}
												placeholder={t.adminSettings.fullNamePlaceholder}
											/>
										</div>
										<div className="space-y-2">
											<Label className="text-sm text-muted-foreground">
												{t.adminSettings.emailAddress}
											</Label>
											<div className="flex items-center gap-1.5 pt-2">
												<p className="text-sm font-medium">{email}</p>
												{userProfile?.emailVerified && (
													<CheckCircle2 className="h-3.5 w-3.5 text-green-500" />
												)}
											</div>
											<p className="text-xs text-muted-foreground">
												{t.adminSettings.emailManagedByGoogle}
											</p>
										</div>
										<div className="space-y-2">
											<Label className="text-sm text-muted-foreground">
												{t.admin.role}
											</Label>
											<div className="flex items-center gap-2 pt-2">
												<Badge
													variant="destructive"
													className="text-xs capitalize"
												>
													{adminLevel === "super_admin"
														? t.adminUsers.superAdmin
														: t.adminUsers.roleAdmin}
												</Badge>
											</div>
										</div>
										<div className="space-y-2">
											<Label className="text-sm text-muted-foreground">
												{t.adminSettings.accountStatus}
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
											<Loader2 className="h-4 w-4 animate-spin" /> {t.adminSettings.saving}
										</>
									) : (
										<>
											<Save className="h-4 w-4" /> {t.adminSettings.saveChanges}
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
									{t.adminSettings.session}
								</CardTitle>
							</CardHeader>
							<CardContent className="space-y-3">
								<div className="grid gap-3 sm:grid-cols-2">
									<div className="rounded-lg border p-3">
										<p className="text-xs text-muted-foreground">
											Firebase UID
										</p>
										<p className="text-xs font-mono mt-1 truncate">
											{user?.uid || "—"}
										</p>
									</div>
									<div className="rounded-lg border p-3">
										<p className="text-xs text-muted-foreground">{t.adminSettings.provider}</p>
										<p className="text-xs font-medium mt-1">
											Google Authentication
										</p>
									</div>
								</div>
								<Separator />
								<Button
									variant="outline"
									onClick={() => setConfirmAction("signout")}
									className="gap-2 text-destructive hover:text-destructive"
								>
									{t.adminSettings.signOutOfAccount}
								</Button>
							</CardContent>
						</Card>
					</TabsContent>

					{/* ─── Platform Tab ─── */}
					<TabsContent value="platform" className="space-y-6 mt-0">
						{/* Platform Overview - Real stats */}
						<Card>
							<CardHeader>
								<CardTitle className="text-base flex items-center gap-2">
									<Globe className="h-4 w-4 text-primary" />
									{t.adminSettings.platformOverview}
								</CardTitle>
								<CardDescription>
									{t.adminSettings.platformOverviewDesc}
								</CardDescription>
							</CardHeader>
							<CardContent>
								{loadingStats ? (
									<div className="flex items-center gap-2 py-4">
										<Loader2 className="h-4 w-4 animate-spin text-primary" />
										<p className="text-sm text-muted-foreground">
											{t.adminSettings.loadingStats}
										</p>
									</div>
								) : platformStats ? (
									<div className="grid gap-4 sm:grid-cols-4">
										<div className="rounded-lg border p-4 text-center">
											<p className="text-2xl font-bold">
												{platformStats.totalUsers}
											</p>
											<p className="text-xs text-muted-foreground mt-1">
												{t.adminSettings.totalUsers}
											</p>
										</div>
										<div className="rounded-lg border p-4 text-center">
											<p className="text-2xl font-bold text-amber-600">
												{platformStats.pendingKyc}
											</p>
											<p className="text-xs text-muted-foreground mt-1">
												{t.adminSettings.pendingKyc}
											</p>
										</div>
										<div className="rounded-lg border p-4 text-center">
											<p className="text-2xl font-bold text-primary">
												{platformStats.admins}
											</p>
											<p className="text-xs text-muted-foreground mt-1">
												{t.adminSettings.admins}
											</p>
										</div>
										<div className="rounded-lg border p-4 text-center">
											<p className="text-2xl font-bold text-green-600">
												{platformStats.totalUsers -
													platformStats.pendingKyc -
													platformStats.admins}
											</p>
											<p className="text-xs text-muted-foreground mt-1">
												{t.adminSettings.activeUsers}
											</p>
										</div>
									</div>
								) : (
									<p className="text-sm text-muted-foreground">
										{t.adminSettings.unableToLoadStats}
									</p>
								)}
							</CardContent>
						</Card>

						{/* Platform Info */}
						<Card>
							<CardHeader>
								<CardTitle className="text-base flex items-center gap-2">
									<Settings className="h-4 w-4 text-primary" />
									{t.adminSettings.platformInfo}
								</CardTitle>
							</CardHeader>
							<CardContent>
								<div className="grid gap-4 sm:grid-cols-2">
									<div className="rounded-lg border p-3">
										<p className="text-xs text-muted-foreground">
											{t.adminSettings.platformName}
										</p>
										<p className="text-sm font-medium mt-1">SEPMS</p>
									</div>
									<div className="rounded-lg border p-3">
										<p className="text-xs text-muted-foreground">{t.adminSettings.version}</p>
										<p className="text-sm font-medium mt-1">1.0.0</p>
									</div>
									<div className="rounded-lg border p-3">
										<p className="text-xs text-muted-foreground">
											{t.adminSettings.apiEndpoint}
										</p>
										<p className="text-xs font-mono mt-1 truncate">{API_URL}</p>
									</div>
									<div className="rounded-lg border p-3">
										<p className="text-xs text-muted-foreground">{t.adminSettings.environment}</p>
										<p className="text-sm font-medium mt-1">
											{API_URL.includes("localhost")
												? t.adminSettings.development
												: t.adminSettings.production}
										</p>
									</div>
									<div className="rounded-lg border p-3">
										<p className="text-xs text-muted-foreground">
											{t.adminSettings.kycVerification}
										</p>
										<div className="flex items-center gap-1.5 mt-1">
											<CheckCircle2 className="h-3.5 w-3.5 text-green-500" />
											<span className="text-sm font-medium">
												{t.adminSettings.requiredManualReview}
											</span>
										</div>
									</div>
									<div className="rounded-lg border p-3">
										<p className="text-xs text-muted-foreground">
											{t.adminSettings.authentication}
										</p>
										<div className="flex items-center gap-1.5 mt-1">
											<Shield className="h-3.5 w-3.5 text-primary" />
											<span className="text-sm font-medium">
												Firebase / Google
											</span>
										</div>
									</div>
								</div>
							</CardContent>
						</Card>

						{/* Accepted File Types */}
						<Card>
							<CardHeader>
								<CardTitle className="text-base flex items-center gap-2">
									<ClipboardList className="h-4 w-4 text-primary" />
									{t.adminSettings.kycDocRequirements}
								</CardTitle>
								<CardDescription>
									{t.adminSettings.kycDocRequirementsDesc}
								</CardDescription>
							</CardHeader>
							<CardContent>
								<div className="space-y-3">
									<div className="rounded-lg border p-3">
										<div className="flex items-center justify-between">
											<div>
												<p className="text-sm font-medium">{t.admin.entrepreneurs}</p>
												<p className="text-xs text-muted-foreground mt-0.5">
													{t.adminSettings.entrepreneurDocs}
												</p>
											</div>
											<Badge variant="secondary" className="text-xs">
												{t.adminSettings.threeDocuments}
											</Badge>
										</div>
									</div>
									<div className="rounded-lg border p-3">
										<div className="flex items-center justify-between">
											<div>
												<p className="text-sm font-medium">{t.admin.investors}</p>
												<p className="text-xs text-muted-foreground mt-0.5">
													{t.adminSettings.investorDocs}
												</p>
											</div>
											<Badge variant="secondary" className="text-xs">
												{t.adminSettings.twoDocuments}
											</Badge>
										</div>
									</div>
									<div className="rounded-lg border p-3">
										<div className="flex items-center justify-between">
											<div>
												<p className="text-sm font-medium">{t.adminSettings.acceptedFormats}</p>
												<div className="flex flex-wrap gap-1.5 mt-1">
													{["PDF", "JPG", "PNG", "WEBP"].map((fmt) => (
														<Badge
															key={fmt}
															variant="outline"
															className="text-xs"
														>
															{fmt}
														</Badge>
													))}
												</div>
											</div>
											<Badge variant="secondary" className="text-xs">
												Max 10MB
											</Badge>
										</div>
									</div>
								</div>
							</CardContent>
						</Card>
					</TabsContent>

					{/* ─── Security Tab ─── */}
					<TabsContent value="security" className="space-y-6 mt-0">
						<Card>
							<CardHeader>
								<CardTitle className="text-base flex items-center gap-2">
									<Shield className="h-4 w-4 text-primary" />
									{t.adminSettings.authDetails}
								</CardTitle>
								<CardDescription>
									{t.adminSettings.authDetailsDesc}
								</CardDescription>
							</CardHeader>
							<CardContent className="space-y-4">
								<div className="rounded-lg border bg-muted/30 p-4 space-y-3">
									<div className="flex items-center gap-3">
										<div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
											<Shield className="h-5 w-5 text-primary" />
										</div>
										<div>
											<p className="text-sm font-medium">
												{t.adminSettings.googleAuth}
											</p>
											<p className="text-xs text-muted-foreground">
												{t.adminSettings.googleAuthDesc}
											</p>
										</div>
										<Badge
											variant="default"
											className="ml-auto text-xs bg-green-500/10 text-green-600 border-green-500/20"
										>
											{t.adminSettings.active}
										</Badge>
									</div>
								</div>

								<Separator />

								<div className="space-y-2">
									<p className="text-sm font-medium">{t.adminSettings.accessControlSummary}</p>
									<div className="space-y-2">
										<div className="flex items-center justify-between rounded-lg border p-3">
											<div>
												<p className="text-sm">{t.adminSettings.roleBasedAccess}</p>
												<p className="text-xs text-muted-foreground">
													{t.adminSettings.roleBasedAccessDesc}
												</p>
											</div>
											<Badge
												variant="default"
												className="text-xs bg-green-500/10 text-green-600 border-green-500/20"
											>
												{t.adminSettings.enabled}
											</Badge>
										</div>
										<div className="flex items-center justify-between rounded-lg border p-3">
											<div>
												<p className="text-sm">{t.adminSettings.superAdminProtection}</p>
												<p className="text-xs text-muted-foreground">
													{t.adminSettings.superAdminProtectionDesc}
												</p>
											</div>
											<Badge
												variant="default"
												className="text-xs bg-green-500/10 text-green-600 border-green-500/20"
											>
												{t.adminSettings.enabled}
											</Badge>
										</div>
										<div className="flex items-center justify-between rounded-lg border p-3">
											<div>
												<p className="text-sm">{t.adminSettings.apiRateLimiting}</p>
												<p className="text-xs text-muted-foreground">
													{t.adminSettings.apiRateLimitingDesc}
												</p>
											</div>
											<Badge
												variant="default"
												className="text-xs bg-green-500/10 text-green-600 border-green-500/20"
											>
												{t.adminSettings.enabled}
											</Badge>
										</div>
										<div className="flex items-center justify-between rounded-lg border p-3">
											<div>
												<p className="text-sm">{t.adminSettings.jwtAuth}</p>
												<p className="text-xs text-muted-foreground">
													{t.adminSettings.jwtAuthDesc}
												</p>
											</div>
											<Badge
												variant="default"
												className="text-xs bg-green-500/10 text-green-600 border-green-500/20"
											>
												{t.adminSettings.enabled}
											</Badge>
										</div>
										<div className="flex items-center justify-between rounded-lg border p-3">
											<div>
												<p className="text-sm">{t.adminSettings.mongoProtection}</p>
												<p className="text-xs text-muted-foreground">
													{t.adminSettings.mongoProtectionDesc}
												</p>
											</div>
											<Badge
												variant="default"
												className="text-xs bg-green-500/10 text-green-600 border-green-500/20"
											>
												{t.adminSettings.enabled}
											</Badge>
										</div>
									</div>
								</div>
							</CardContent>
						</Card>

						{/* Danger Zone - Super Admin Only */}
						{isSuperAdmin && (
							<Card className="border-destructive/20">
								<CardHeader>
									<CardTitle className="text-base flex items-center gap-2 text-destructive">
										<Shield className="h-4 w-4" />
										{t.adminSettings.dangerZone}
									</CardTitle>
									<CardDescription>
										{t.adminSettings.dangerZoneDesc}
									</CardDescription>
								</CardHeader>
								<CardContent className="space-y-3">
									<div className="flex items-center justify-between rounded-lg border border-destructive/20 p-4">
										<div>
											<p className="text-sm font-medium">{t.adminSettings.resetAllKyc}</p>
											<p className="text-xs text-muted-foreground">
												{t.adminSettings.resetAllKycDesc}
											</p>
										</div>
										<Button
											variant="outline"
											size="sm"
											className="text-destructive border-destructive/30 hover:bg-destructive/10 shrink-0"
											onClick={() => setConfirmAction("reset-kyc")}
										>
											<Trash2 className="h-3.5 w-3.5 mr-1.5" />
											{t.adminSettings.resetAll}
										</Button>
									</div>
									<div className="flex items-center justify-between rounded-lg border border-destructive/20 p-4">
										<div>
											<p className="text-sm font-medium">
												{t.adminSettings.suspendUnverified}
											</p>
											<p className="text-xs text-muted-foreground">
												{t.adminSettings.suspendUnverifiedDesc}
											</p>
										</div>
										<Button
											variant="outline"
											size="sm"
											className="text-destructive border-destructive/30 hover:bg-destructive/10 shrink-0"
											onClick={() => setConfirmAction("suspend-unverified")}
										>
											<UserX className="h-3.5 w-3.5 mr-1.5" />
											{t.admin.suspend}
										</Button>
									</div>
								</CardContent>
							</Card>
						)}
					</TabsContent>
				</Tabs>

				{/* Confirmation Dialog */}
				<Dialog
					open={!!confirmAction}
					onOpenChange={() => setConfirmAction(null)}
				>
					<DialogContent className="sm:max-w-md">
						<DialogHeader>
							<DialogTitle className="text-destructive">
								{t.adminSettings.confirmAction}
							</DialogTitle>
							<DialogDescription>
								{confirmAction === "reset-kyc"
									? t.adminSettings.confirmResetKyc
									: confirmAction === "signout"
										? t.adminSettings.confirmSignout
										: t.adminSettings.confirmSuspendUnverified}
							</DialogDescription>
						</DialogHeader>
						<DialogFooter className="gap-2 sm:gap-0">
							<Button variant="outline" onClick={() => setConfirmAction(null)}>
								{t.common.cancel}
							</Button>
							<Button
								variant="destructive"
								onClick={() =>
									confirmAction === "signout"
										? signOut()
										: confirmAction && handleBulkAction(confirmAction)
								}
								disabled={actionLoading}
								className="gap-2"
							>
								{actionLoading ? (
									<>
										<Loader2 className="h-4 w-4 animate-spin" /> {t.adminSettings.processing}
									</>
								) : (
									t.common.confirm
								)}
							</Button>
						</DialogFooter>
					</DialogContent>
				</Dialog>
			</DashboardLayout>
		</ProtectedRoute>
	);
}
