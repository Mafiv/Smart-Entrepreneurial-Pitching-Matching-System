"use client";

import {
	AlertCircle,
	ArrowRight,
	Building2,
	CheckCircle2,
	Clock,
	FileCheck,
	IdCard,
	Loader2,
	Save,
	ShieldCheck,
	Upload,
	UploadCloud,
	User as UserIcon,
	X,
} from "lucide-react";
import { useSearchParams } from "next/navigation";
import { Suspense, useCallback, useEffect, useState } from "react";
import DashboardLayout from "@/components/DashboardLayout";
import ProfilePictureUpload from "@/components/ProfilePictureUpload";
import ProtectedRoute from "@/components/ProtectedRoute";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
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
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Progress } from "@/components/ui/progress";
import { Separator } from "@/components/ui/separator";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { ENTREPRENEUR_NAV } from "@/constants/navigation";
import { useAuth } from "@/context/AuthContext";
import { useLanguage } from "@/i18n/LanguageContext";
import {
	showErrorToast,
	showInfoToast,
	showSuccessToast,
	showWarningToast,
} from "@/lib/toast-messages";

// ─── File Upload Card ───
function FileUploadCard({
	id,
	label,
	description,
	file,
	existingUrl,
	onChange,
	onRemove,
	required,
}: {
	id: string;
	label: string;
	description: string;
	file?: File;
	existingUrl?: string;
	onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
	onRemove: () => void;
	required?: boolean;
}) {
	const { t } = useLanguage();
	const hasFile = !!file;
	const hasExisting = !!existingUrl;
	const isComplete = hasFile || hasExisting;

	return (
		<div
			className={`group relative rounded-xl border-2 border-dashed p-4 transition-all ${
				isComplete
					? "border-green-500/30 bg-green-500/5"
					: "border-border hover:border-primary/30 hover:bg-muted/20"
			}`}
		>
			{hasFile ? (
				<div className="flex items-center gap-3">
					<div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-green-500/10 text-green-600 dark:text-green-400">
						<FileCheck className="h-5 w-5" />
					</div>
					<div className="flex-1 min-w-0">
						<p className="text-sm font-medium truncate">{file.name}</p>
						<p className="text-xs text-muted-foreground">
							{(file.size / 1024 / 1024).toFixed(2)} MB —{" "}
							{t.profile.readyToUploadLabel}
						</p>
					</div>
					<Button
						type="button"
						variant="ghost"
						size="sm"
						className="h-8 w-8 p-0 text-muted-foreground hover:text-destructive"
						onClick={onRemove}
					>
						<X className="h-4 w-4" />
					</Button>
				</div>
			) : hasExisting ? (
				<div className="flex items-center gap-3">
					<div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-green-500/10 text-green-600 dark:text-green-400">
						<CheckCircle2 className="h-5 w-5" />
					</div>
					<div className="flex-1 min-w-0">
						<p className="text-sm font-medium">{label}</p>
						<p className="text-xs text-green-600 dark:text-green-400">
							{t.profile.uploaded} ✓
						</p>
					</div>
					<Label htmlFor={id} className="cursor-pointer">
						<Badge
							variant="outline"
							className="text-xs cursor-pointer hover:bg-muted"
						>
							{t.investorProfile.replace}
						</Badge>
						<Input
							id={id}
							type="file"
							accept="application/pdf,image/*"
							onChange={onChange}
							className="hidden"
						/>
					</Label>
				</div>
			) : (
				<Label htmlFor={id} className="cursor-pointer block">
					<div className="flex items-center gap-3">
						<div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-muted text-muted-foreground group-hover:bg-primary/10 group-hover:text-primary transition-colors">
							<Upload className="h-5 w-5" />
						</div>
						<div className="flex-1 min-w-0">
							<p className="text-sm font-medium">
								{label}
								{required && <span className="text-destructive ml-1">*</span>}
							</p>
							<p className="text-xs text-muted-foreground">{description}</p>
						</div>
						<ArrowRight className="h-4 w-4 text-muted-foreground/30 group-hover:text-primary/50 transition-colors" />
					</div>
					<Input
						id={id}
						type="file"
						accept="application/pdf,image/*"
						onChange={onChange}
						className="hidden"
					/>
				</Label>
			)}
		</div>
	);
}

// ─── Verification Progress Card ───
function VerificationProgress({
	status,
	hasGovId,
	hasBusinessDocs,
	emailVerified,
	rejectionReason,
}: {
	status: string;
	hasGovId: boolean;
	hasBusinessDocs: boolean;
	emailVerified: boolean;
	rejectionReason?: string;
}) {
	const { t } = useLanguage();
	const steps = [
		{ label: t.profile.emailVerified, done: emailVerified },
		{ label: t.profile.governmentId, done: hasGovId },
		{ label: t.profile.businessDocuments, done: hasBusinessDocs },
		{ label: t.profile.adminApproved, done: status === "verified" },
	];
	const completedCount = steps.filter((s) => s.done).length;
	const progress = (completedCount / steps.length) * 100;

	const bgGradient =
		status === "verified"
			? "bg-gradient-to-br from-green-500/5 via-transparent to-transparent border-green-500/20"
			: status === "pending"
				? "bg-gradient-to-br from-blue-500/5 via-transparent to-transparent border-blue-500/20"
				: "bg-gradient-to-br from-primary/5 via-transparent to-transparent border-primary/10";

	return (
		<Card className={`relative overflow-hidden ${bgGradient}`}>
			{status === "pending" && (
				<div className="absolute -top-4 -right-4 p-4 opacity-5 pointer-events-none">
					<Clock className="h-32 w-32 animate-pulse text-blue-500" />
				</div>
			)}
			<CardHeader className="pb-3 relative z-10">
				<div className="flex items-center justify-between">
					<CardTitle className="text-base flex items-center gap-2">
						<ShieldCheck className="h-5 w-5 text-primary" />
						{t.profile.verificationStatus}
					</CardTitle>
					<Badge
						variant={status === "verified" ? "default" : "outline"}
						className={`uppercase text-[10px] font-bold tracking-wider px-2 py-0.5 ${
							status === "verified"
								? "bg-green-500 hover:bg-green-600 text-white border-transparent shadow-sm"
								: status === "pending"
									? "bg-blue-500/10 text-blue-600 border-blue-500/30"
									: "bg-muted text-muted-foreground border-muted-foreground/20"
						}`}
					>
						{status === "verified"
							? t.profile.verifiedLabel
							: status === "pending"
								? t.profile.underReviewBadge
								: t.profile.incompleteBadge}
					</Badge>
				</div>
			</CardHeader>
			<CardContent className="space-y-6 relative z-10">
				<div className="space-y-2">
					<div className="flex justify-between text-xs font-medium">
						<span className="text-muted-foreground">
							{t.profile.overallProgress}
						</span>
						<span
							className={
								status === "verified" ? "text-green-600" : "text-primary"
							}
						>
							{Math.round(progress)}%
						</span>
					</div>
					<Progress
						value={progress}
						className={`h-2.5 rounded-full ${status === "verified" ? "[&>div]:bg-green-500" : ""}`}
					/>
				</div>

				<div className="relative pl-2">
					<div className="absolute left-[19px] top-3 bottom-3 w-px bg-border/60" />

					<div className="space-y-4">
						{steps.map((step) => {
							const isPending =
								status === "pending" && step.label === "Admin Approved";
							const isDone = step.done;

							return (
								<div
									key={step.label}
									className="relative z-10 flex items-start gap-3"
								>
									<div
										className={`mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-background ${
											isDone
												? "text-green-500"
												: isPending
													? "text-blue-500 shadow-[0_0_0_3px_rgba(59,130,246,0.15)] ring-1 ring-blue-500/30"
													: "text-muted-foreground ring-1 ring-muted-foreground/20"
										}`}
									>
										{isDone ? (
											<CheckCircle2 className="h-7 w-7 bg-background rounded-full" />
										) : isPending ? (
											<Clock className="h-4 w-4 animate-pulse" />
										) : (
											<div className="h-2 w-2 rounded-full bg-muted-foreground/30" />
										)}
									</div>
									<div className="flex flex-col pt-1">
										<span
											className={`text-sm font-semibold ${isDone || isPending ? "text-foreground" : "text-muted-foreground"}`}
										>
											{step.label}
										</span>
										{isPending && (
											<span className="text-[10px] text-blue-500 font-bold tracking-wide uppercase mt-0.5">
												{t.profile.underReviewLabel}
											</span>
										)}
										{isDone && (
											<span className="text-[10px] text-green-500 font-bold tracking-wide uppercase mt-0.5">
												{t.profile.completed}
											</span>
										)}
									</div>
								</div>
							);
						})}
					</div>
				</div>

				{rejectionReason && (
					<Alert
						variant="destructive"
						className="mt-3 border-destructive/30 bg-destructive/5"
					>
						<AlertCircle className="h-4 w-4" />
						<AlertTitle className="text-xs font-semibold">
							{t.profile.rejected}
						</AlertTitle>
						<AlertDescription className="text-xs">
							{rejectionReason}
						</AlertDescription>
					</Alert>
				)}
			</CardContent>
		</Card>
	);
}

// ─── Main Profile Page ───
function EntrepreneurProfilePageInner() {
	const { user, userProfile, refreshUserProfile } = useAuth();
	const { t } = useLanguage();
	const [profileData, setProfileData] = useState<any>(null);
	const [loading, setLoading] = useState(true);
	const [saving, setSaving] = useState(false);
	const [error, setError] = useState<string | null>(null);
	const [activeTab, setActiveTab] = useState("overview");
	const searchParams = useSearchParams();

	useEffect(() => {
		const tab = searchParams.get("tab");
		if (tab === "verification" || tab === "personal" || tab === "overview") {
			setActiveTab(tab);
		}
	}, [searchParams]);

	// Form fields
	const [_fullName, setFullName] = useState("");
	const [companyName, setCompanyName] = useState("");
	const [companyDescription, setCompanyDescription] = useState("");

	// File states
	const [files, setFiles] = useState<{
		governmentId?: File;
		businessLicense?: File;
		tinCertificate?: File;
	}>({});

	// Edit profile
	const [editName, setEditName] = useState(userProfile?.displayName || "");
	const [savingProfile, setSavingProfile] = useState(false);

	const API_URL = (
		process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api"
	).replace(/\/+$/, "");

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
		} catch (err: any) {
			showErrorToast(err.message || "Failed to update profile");
		} finally {
			setSavingProfile(false);
		}
	};

	// Fetch profile
	const fetchProfile = useCallback(async () => {
		if (!user) return;
		setLoading(true);
		try {
			const token = await user.getIdToken();
			const res = await fetch(`${API_URL}/users/me/profile`, {
				headers: { Authorization: `Bearer ${token}` },
			});
			if (res.ok) {
				const data = await res.json();
				setProfileData(data.profile);
				if (data.profile?.companyName) setCompanyName(data.profile.companyName);
				if (data.profile?.description)
					setCompanyDescription(data.profile.description);
			}
		} catch (err) {
			console.error("Error fetching profile:", err);
		} finally {
			setLoading(false);
		}
	}, [user, API_URL]);

	useEffect(() => {
		fetchProfile();
		if (userProfile?.displayName) setFullName(userProfile.displayName);
	}, [fetchProfile, userProfile?.displayName]);

	const handleFileChange = (
		e: React.ChangeEvent<HTMLInputElement>,
		key: string,
	) => {
		if (e.target.files?.[0]) {
			setFiles((prev) => ({ ...prev, [key]: e.target.files?.[0] }));
		}
	};

	const removeFile = (key: string) => {
		setFiles((prev) => {
			const next = { ...prev };
			delete (next as Record<string, File | undefined>)[key];
			return next;
		});
	};

	const uploadDoc = async (file: File, typeName: string) => {
		const formData = new FormData();
		formData.append("file", file);
		formData.append("type", typeName);
		const token = await user?.getIdToken();
		const res = await fetch(`${API_URL}/upload`, {
			method: "POST",
			headers: { Authorization: `Bearer ${token}` },
			body: formData,
		});
		if (!res.ok) {
			const data = await res.json();
			throw new Error(data.message || `Failed to upload ${typeName}`);
		}
		const data = await res.json();
		return data.file.url;
	};

	const updateProfile = async (payload: Record<string, string>) => {
		const token = await user?.getIdToken();
		const res = await fetch(`${API_URL}/users/me/profile`, {
			method: "PUT",
			headers: {
				"Content-Type": "application/json",
				Authorization: `Bearer ${token}`,
			},
			body: JSON.stringify(payload),
		});
		if (!res.ok) {
			const data = await res.json();
			throw new Error(data.message || "Failed to save profile");
		}
		return res.json();
	};

	// Save all documents + profile
	const handleSaveDocuments = async () => {
		setError(null);
		setSaving(true);
		try {
			const payload: Record<string, string> = {};

			// Upload new files
			if (files.governmentId) {
				payload.nationalIdUrl = await uploadDoc(
					files.governmentId,
					"national_id",
				);
			} else if (profileData?.nationalIdUrl) {
				payload.nationalIdUrl = profileData.nationalIdUrl;
			}

			if (files.businessLicense) {
				payload.businessLicenseUrl = await uploadDoc(
					files.businessLicense,
					"legal",
				);
			} else if (profileData?.businessLicenseUrl) {
				payload.businessLicenseUrl = profileData.businessLicenseUrl;
			}

			if (files.tinCertificate) {
				payload.tinNumber = await uploadDoc(files.tinCertificate, "legal");
			} else if (profileData?.tinNumber) {
				payload.tinNumber = profileData.tinNumber;
			}

			if (companyName) payload.companyName = companyName;
			if (companyDescription) payload.description = companyDescription;

			await updateProfile(payload);
			setProfileData((prev: any) => ({ ...prev, ...payload }));
			setFiles({});
			await refreshUserProfile();
			showSuccessToast("Documents saved successfully!");
		} catch (err: any) {
			setError(err.message);
			showErrorToast(err.message);
		} finally {
			setSaving(false);
		}
	};

	// Computed states
	const hasGovId = !!files.governmentId || !!profileData?.nationalIdUrl;
	const hasBusinessLicense =
		!!files.businessLicense || !!profileData?.businessLicenseUrl;
	const hasTin = !!files.tinCertificate || !!profileData?.tinNumber;
	const _hasAllDocs = hasGovId && hasBusinessLicense && hasTin;
	const _hasNewFiles =
		Object.keys(files).length > 0 ||
		(!profileData?.nationalIdUrl && !profileData?.businessLicenseUrl);
	const isVerified = userProfile?.status === "verified";
	const _initials = (userProfile?.displayName || "U")
		.split(" ")
		.map((n) => n[0])
		.join("")
		.toUpperCase()
		.slice(0, 2);

	if (loading) {
		return (
			<ProtectedRoute allowedRoles={["entrepreneur"]}>
				<DashboardLayout navItems={ENTREPRENEUR_NAV} title="SEPMS">
					<div className="flex items-center justify-center py-20">
						<Loader2 className="h-8 w-8 animate-spin text-primary" />
					</div>
				</DashboardLayout>
			</ProtectedRoute>
		);
	}

	return (
		<ProtectedRoute allowedRoles={["entrepreneur"]}>
			<DashboardLayout navItems={ENTREPRENEUR_NAV} title="SEPMS">
				{/* Header */}
				<div className="admin-greeting-card bg-card mb-8 p-6 sm:p-8 admin-content-fade">
					<div>
						<h1 className="text-2xl font-bold tracking-tight sm:text-3xl admin-header-gradient">
							{t.profile.profileSettings}
						</h1>
						<p className="mt-1.5 text-muted-foreground text-sm sm:text-base">
							{t.profile.managePersonalAndDocs}
						</p>
					</div>
				</div>

				<div>
					<Tabs value={activeTab} onValueChange={setActiveTab}>
						<TabsList className="w-full justify-start h-auto flex-wrap sm:h-10 mb-6">
							<TabsTrigger value="overview" className="gap-1.5 text-xs">
								<Building2 className="h-3.5 w-3.5" />
								{t.pitchNew.overview}
							</TabsTrigger>
							<TabsTrigger value="personal" className="gap-1.5 text-xs">
								<UserIcon className="h-3.5 w-3.5" />
								{t.investorProfile.personalInfoTab}
							</TabsTrigger>
							<TabsTrigger value="verification" className="gap-1.5 text-xs">
								<ShieldCheck className="h-3.5 w-3.5" />
								{t.profile.verification}
								{userProfile?.status !== "verified" && (
									<span className="ml-1 h-2 w-2 rounded-full bg-amber-500 animate-pulse" />
								)}
								{userProfile?.status === "verified" && (
									<CheckCircle2 className="ml-1 h-3 w-3 text-green-500" />
								)}
							</TabsTrigger>
						</TabsList>

						{/* ─── Overview Tab ─── */}
						<TabsContent value="overview" className="space-y-6 mt-0">
							<Card>
								<CardHeader className="pb-3">
									<CardTitle className="text-base flex items-center gap-2">
										<Building2 className="h-4 w-4 text-primary" />
										{t.profile.businessOverview}
									</CardTitle>
									<CardDescription>
										{t.profile.publicProfileAndStats}
									</CardDescription>
								</CardHeader>
								<CardContent className="space-y-6">
									<div className="grid gap-4 sm:grid-cols-2">
										<div className="space-y-2">
											<Label className="text-sm text-muted-foreground">
												{t.profile.companyName}
											</Label>
											<p className="font-medium">
												{profileData?.companyName || t.profile.notProvided}
											</p>
										</div>
										<div className="space-y-2">
											<Label className="text-sm text-muted-foreground">
												{t.profile.businessSector}
											</Label>
											<p className="font-medium capitalize">
												{profileData?.businessSector || "Other"}
											</p>
										</div>
										<div className="space-y-2">
											<Label className="text-sm text-muted-foreground">
												{t.profile.businessStage}
											</Label>
											<p className="font-medium capitalize">
												{profileData?.businessStage || t.profile.notSpecified}
											</p>
										</div>
										<div className="space-y-2">
											<Label className="text-sm text-muted-foreground">
												{t.profile.foundedYear}
											</Label>
											<p className="font-medium">
												{profileData?.foundedYear || t.profile.notSpecified}
											</p>
										</div>
									</div>
									{profileData?.description && (
										<div className="space-y-2">
											<Label className="text-sm text-muted-foreground">
												{t.profile.companyDescriptionLabel}
											</Label>
											<p className="text-sm">{profileData.description}</p>
										</div>
									)}
								</CardContent>
							</Card>

							<div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
								<Card className="bg-primary/5 border-primary/10">
									<CardHeader className="pb-2">
										<CardTitle className="text-sm text-muted-foreground">
											{t.dashboard.totalPitches}
										</CardTitle>
									</CardHeader>
									<CardContent>
										<div className="text-2xl font-bold">
											{profileData?.totalPitches || 0}
										</div>
									</CardContent>
								</Card>
								<Card className="bg-blue-500/5 border-blue-500/10">
									<CardHeader className="pb-2">
										<CardTitle className="text-sm text-muted-foreground">
											{t.dashboard.activePitches}
										</CardTitle>
									</CardHeader>
									<CardContent>
										<div className="text-2xl font-bold text-blue-600 dark:text-blue-400">
											{profileData?.activePitches || 0}
										</div>
									</CardContent>
								</Card>
								<Card className="bg-amber-500/5 border-amber-500/10">
									<CardHeader className="pb-2">
										<CardTitle className="text-sm text-muted-foreground">
											{t.profile.interestedInvestors}
										</CardTitle>
									</CardHeader>
									<CardContent>
										<div className="text-2xl font-bold text-amber-600 dark:text-amber-400">
											{profileData?.interestedInvestors || 0}
										</div>
									</CardContent>
								</Card>
								<Card className="bg-green-500/5 border-green-500/10">
									<CardHeader className="pb-2">
										<CardTitle className="text-sm text-muted-foreground">
											{t.profile.totalViews}
										</CardTitle>
									</CardHeader>
									<CardContent>
										<div className="text-2xl font-bold text-green-600 dark:text-green-400">
											{profileData?.totalViews || 0}
										</div>
									</CardContent>
								</Card>
							</div>
						</TabsContent>

						{/* ─── Verification Tab ─── */}
						<TabsContent value="verification" className="mt-0">
							<div className="grid gap-6 lg:grid-cols-[1fr_320px]">
								<div className="space-y-6">
									{isVerified && (
										<div className="rounded-xl border border-green-500/20 bg-green-500/5 p-4 flex items-center gap-3">
											<div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-green-500/10">
												<CheckCircle2 className="h-5 w-5 text-green-500" />
											</div>
											<div>
												<p className="text-sm font-semibold text-green-700 dark:text-green-400">
													{t.investorProfile.verificationComplete}
												</p>
												<p className="text-xs text-muted-foreground">
													{t.profile.identityAndBusinessVerified}
												</p>
											</div>
										</div>
									)}

									{error && (
										<Alert variant="destructive">
											<AlertCircle className="h-4 w-4" />
											<AlertDescription>{error}</AlertDescription>
										</Alert>
									)}

									{/* Identity Verification */}
									<Card>
										<CardHeader className="pb-3">
											<CardTitle className="text-base flex items-center gap-2">
												<IdCard className="h-4 w-4 text-primary" />
												{t.investorProfile.identityVerification}
											</CardTitle>
											<CardDescription>{t.profile.uploadGovId}</CardDescription>
										</CardHeader>
										<CardContent>
											<FileUploadCard
												id="gov-id"
												label={t.profile.governmentIssuedIdLabel}
												description={t.profile.pdfOrImageMax10}
												file={files.governmentId}
												existingUrl={profileData?.nationalIdUrl}
												onChange={(e) => handleFileChange(e, "governmentId")}
												onRemove={() => removeFile("governmentId")}
												required
											/>
										</CardContent>
									</Card>

									{/* Business Documents */}
									<Card>
										<CardHeader className="pb-3">
											<CardTitle className="text-base flex items-center gap-2">
												<Building2 className="h-4 w-4 text-primary" />
												{t.profile.businessDocuments}
											</CardTitle>
											<CardDescription>
												{t.profile.uploadBusinessDocs}
											</CardDescription>
										</CardHeader>
										<CardContent className="space-y-3">
											<FileUploadCard
												id="biz-license"
												label={t.profile.businessRegCertificate}
												description={t.profile.pdfOrImageCertificate}
												file={files.businessLicense}
												existingUrl={profileData?.businessLicenseUrl}
												onChange={(e) => handleFileChange(e, "businessLicense")}
												onRemove={() => removeFile("businessLicense")}
												required
											/>
											<FileUploadCard
												id="tin-cert"
												label={t.profile.tinCertificate}
												description={t.profile.pdfOrImageTin}
												file={files.tinCertificate}
												existingUrl={profileData?.tinNumber}
												onChange={(e) => handleFileChange(e, "tinCertificate")}
												onRemove={() => removeFile("tinCertificate")}
												required
											/>
										</CardContent>
									</Card>

									{/* Company Details */}
									<Card>
										<CardHeader className="pb-3">
											<CardTitle className="text-base flex items-center gap-2">
												<Building2 className="h-4 w-4 text-primary" />
												{t.profile.companyDetails}
											</CardTitle>
										</CardHeader>
										<CardContent className="space-y-4">
											<div className="space-y-2">
												<Label htmlFor="company-name" className="text-sm">
													{t.profile.companyNameRequired}{" "}
													<span className="text-destructive">*</span>
												</Label>
												<Input
													id="company-name"
													placeholder="e.g. Ethio Tech Solutions PLC"
													value={companyName}
													onChange={(e) => setCompanyName(e.target.value)}
													className="h-10"
													disabled={isVerified}
												/>
											</div>
											<div className="space-y-2">
												<Label htmlFor="company-desc" className="text-sm">
													{t.profile.briefDescription}
												</Label>
												<Input
													id="company-desc"
													placeholder={t.profile.whatDoesCompanyDoPlaceholder}
													value={companyDescription}
													onChange={(e) =>
														setCompanyDescription(e.target.value)
													}
													className="h-10"
													disabled={isVerified}
												/>
											</div>
										</CardContent>
										{!isVerified && (
											<CardFooter className="flex justify-end border-t pt-4">
												<Button
													onClick={handleSaveDocuments}
													disabled={saving}
													className="gap-2"
												>
													{saving ? (
														<>
															<Loader2 className="h-4 w-4 animate-spin" />
															{t.investorProfile.saving}
														</>
													) : (
														<>
															<UploadCloud className="h-4 w-4" />
															{userProfile?.status === "unverified"
																? t.profile.saveSubmitReview
																: t.profile.saveChanges}
														</>
													)}
												</Button>
											</CardFooter>
										)}
									</Card>
								</div>

								{/* Right Column: Verification Progress */}
								<div className="space-y-6">
									<VerificationProgress
										status={userProfile?.status || "unverified"}
										hasGovId={!!profileData?.nationalIdUrl}
										hasBusinessDocs={
											!!(
												profileData?.businessLicenseUrl &&
												profileData?.tinNumber
											)
										}
										emailVerified={!!userProfile?.emailVerified}
										rejectionReason={
											userProfile?.kycRejectionReason ?? undefined
										}
									/>

									{userProfile?.status === "pending" && (
										<Card className="border-blue-500/20 bg-blue-500/5">
											<CardContent className="p-4 text-center space-y-3">
												<Clock className="h-8 w-8 text-blue-500 mx-auto" />
												<p className="text-sm font-medium">
													{t.investorProfile.underReview}
												</p>
												<p className="text-xs text-muted-foreground">
													{t.profile.docsBeingReviewedNotified}
												</p>
												<Button
													variant="outline"
													size="sm"
													className="w-full text-xs"
													onClick={refreshUserProfile}
												>
													{t.profile.checkStatus}
												</Button>
											</CardContent>
										</Card>
									)}
								</div>
							</div>
						</TabsContent>

						{/* ─── Personal Info Tab ─── */}
						<TabsContent value="personal" className="space-y-6 mt-0">
							<Card>
								<CardHeader className="pb-3">
									<CardTitle className="text-base">
										{t.investorProfile.personalInformation}
									</CardTitle>
									<CardDescription>
										{t.profile.updateAccountDetailsBelow}
									</CardDescription>
								</CardHeader>
								<CardContent className="space-y-6">
									<div className="flex flex-col sm:flex-row items-start gap-6 pb-2">
										<div className="shrink-0">
											<Label className="text-sm text-muted-foreground block mb-3">
												{t.investorProfile.profilePicture}
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
												<Label htmlFor="ent-edit-name" className="text-sm">
													{t.investorProfile.fullName}
												</Label>
												<Input
													id="ent-edit-name"
													value={editName}
													onChange={(e) => setEditName(e.target.value)}
													placeholder="Your full name"
												/>
											</div>
											<div className="space-y-2">
												<Label className="text-sm text-muted-foreground">
													{t.investorProfile.emailAddress}
												</Label>
												<p className="text-sm font-medium flex items-center gap-1.5 pt-2">
													{userProfile?.email}
													{userProfile?.emailVerified && (
														<CheckCircle2 className="h-3.5 w-3.5 text-green-500" />
													)}
												</p>
												<p className="text-xs text-muted-foreground">
													{t.investorProfile.emailCannotChange}
												</p>
											</div>
											<div className="space-y-2">
												<Label className="text-sm text-muted-foreground">
													{t.investorProfile.role}
												</Label>
												<p className="text-sm font-medium capitalize pt-2">
													{userProfile?.role}
												</p>
											</div>
											<div className="space-y-2">
												<Label className="text-sm text-muted-foreground">
													{t.investorProfile.accountStatus}
												</Label>
												<div className="pt-2">
													<Badge
														variant="outline"
														className={`capitalize text-xs ${
															userProfile?.status === "verified"
																? "bg-green-500/10 text-green-600 border-green-500/20"
																: userProfile?.status === "pending"
																	? "bg-blue-500/10 text-blue-600 border-blue-500/20"
																	: ""
														}`}
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
												{t.investorProfile.saving}
											</>
										) : (
											<>
												<Save className="h-4 w-4" />{" "}
												{t.investorProfile.saveChanges}
											</>
										)}
									</Button>
								</CardFooter>
							</Card>

							{companyName && (
								<Card>
									<CardHeader className="pb-3">
										<CardTitle className="text-base">
											{t.profile.businessInformation}
										</CardTitle>
									</CardHeader>
									<CardContent>
										<div className="grid gap-4 sm:grid-cols-2">
											<div className="space-y-2">
												<Label className="text-sm text-muted-foreground">
													{t.profile.company}
												</Label>
												<p className="text-sm font-medium">{companyName}</p>
											</div>
											{companyDescription && (
												<div className="space-y-2">
													<Label className="text-sm text-muted-foreground">
														{t.portfolio.description}
													</Label>
													<p className="text-sm text-muted-foreground">
														{companyDescription}
													</p>
												</div>
											)}
										</div>
									</CardContent>
								</Card>
							)}
						</TabsContent>
					</Tabs>
				</div>
			</DashboardLayout>
		</ProtectedRoute>
	);
}

export default function EntrepreneurProfilePage() {
	return (
		<Suspense
			fallback={
				<div className="flex min-h-screen items-center justify-center">
					<div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
				</div>
			}
		>
			<EntrepreneurProfilePageInner />
		</Suspense>
	);
}
