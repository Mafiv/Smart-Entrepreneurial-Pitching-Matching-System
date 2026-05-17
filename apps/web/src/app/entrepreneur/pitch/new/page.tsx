"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import {
	BarChart3,
	CheckCircle2,
	ClipboardList,
	DollarSign,
	FileUp,
	Lightbulb,
	Loader2,
	Search,
	Trash2,
	XCircle,
	Info,
} from "lucide-react";
import { useRouter, useSearchParams } from "next/navigation";
import { Suspense, useCallback, useEffect, useState } from "react";
import { Controller, useForm } from "react-hook-form";
import DashboardLayout from "@/components/DashboardLayout";
import ProtectedRoute from "@/components/ProtectedRoute";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import en from "@/i18n/locales/en";
import { Progress } from "@/components/ui/progress";
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { ENTREPRENEUR_NAV } from "@/constants/navigation";
import { useAuth } from "@/context/AuthContext";
import { useLanguage } from "@/i18n/LanguageContext";
import {
	showErrorToast,
	showInfoToast,
	showSuccessToast,
	showWarningToast,
} from "@/lib/toast-messages";
import {
	type BusinessModelData,
	businessModelSchema,
	type FinancialsData,
	financialsSchema,
	getDocCategories,
	getDocLabel,
	type MetadataData,
	metadataSchema,
	type ProblemData,
	problemSchema,
	SECTORS,
	type SolutionData,
	STAGES,
	solutionSchema,
} from "@/lib/validations/submission";

interface UploadedDoc {
	_id: string;
	filename: string;
	type: string;
	status: string;
	url: string;
	processingError?: string;
}

const STEPS = [
	{ id: 1, title: "Overview", icon: <ClipboardList className="h-5 w-5" /> },
	{ id: 2, title: "Problem", icon: <Search className="h-5 w-5" /> },
	{ id: 3, title: "Solution", icon: <Lightbulb className="h-5 w-5" /> },
	{ id: 4, title: "Business Model", icon: <BarChart3 className="h-5 w-5" /> },
	{ id: 5, title: "Financials", icon: <DollarSign className="h-5 w-5" /> },
	{ id: 6, title: "Documents", icon: <FileUp className="h-5 w-5" /> },
];

function NewPitchPageInner() {
	const { user, userProfile } = useAuth();
	const { t, locale } = useLanguage();
	const DualLabel = ({ htmlFor, labelKey }: { htmlFor?: string, labelKey: keyof typeof t.pitchNew }) => (
		<Label htmlFor={htmlFor} className="flex items-center flex-wrap gap-1.5">
			<span>{t.pitchNew[labelKey]}</span>
			{locale !== "en" && (
				<span className="text-muted-foreground/70 font-normal text-xs mt-0.5">
					({en.pitchNew[labelKey]?.replace(" *", "")})
				</span>
			)}
		</Label>
	);
	const router = useRouter();
	const searchParams = useSearchParams();
	const editId = searchParams.get("id");

	// Block unverified users from creating pitches
	useEffect(() => {
		if (
			userProfile &&
			userProfile.status !== "verified" &&
			userProfile.role !== "admin"
		) {
			showErrorToast(
				t.pitchNew.kycRequired,
			);
			router.push("/entrepreneur/dashboard");
		}
	}, [userProfile, router]);

	const [currentStep, setCurrentStep] = useState(1);
	const [submissionId, setSubmissionId] = useState<string | null>(editId);
	const [saving, setSaving] = useState(false);
	const [saveMessage, setSaveMessage] = useState("");

	// Document upload state
	const [uploadedDocs, setUploadedDocs] = useState<UploadedDoc[]>([]);
	const [uploading, setUploading] = useState(false);
	const [uploadProgress, setUploadProgress] = useState(0);
	const [uploadingFileName, setUploadingFileName] = useState<string | null>(
		null,
	);
	const [selectedDocType, setSelectedDocType] = useState("pitch_deck");

	const API_URL = (
		process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api"
	).replace(/\/+$/, "");

	// Form instances per step
	const metadataForm = useForm<MetadataData>({
		resolver: zodResolver(metadataSchema),
		defaultValues: {
			title: "",
			sector: "technology",
			stage: "mvp",
			targetAmount: 0,
			summary: "",
			pitchVideoUrl: "",
		},
	});

	const selectedStage = metadataForm.watch("stage");
	const docCategories = getDocCategories(selectedStage);

	const problemForm = useForm<ProblemData>({
		resolver: zodResolver(problemSchema),
		defaultValues: { statement: "", targetMarket: "", marketSize: "" },
	});

	const solutionForm = useForm<SolutionData>({
		resolver: zodResolver(solutionSchema),
		defaultValues: {
			description: "",
			uniqueValue: "",
			competitiveAdvantage: "",
		},
	});

	const businessForm = useForm<BusinessModelData>({
		resolver: zodResolver(businessModelSchema),
		defaultValues: {
			revenueStreams: "",
			pricingStrategy: "",
			customerAcquisition: "",
		},
	});

	const financialsForm = useForm<FinancialsData>({
		resolver: zodResolver(financialsSchema),
		defaultValues: {
			currentRevenue: "",
			projectedRevenue: "",
			burnRate: "",
			runway: "",
		},
	});

	// Load existing draft if editing
	const loadDraft = useCallback(async () => {
		if (!editId || !user) return;
		try {
			const token = await user.getIdToken();
			const res = await fetch(`${API_URL}/submissions/${editId}`, {
				headers: { Authorization: `Bearer ${token}` },
			});
			if (res.ok) {
				const { submission } = await res.json();
				metadataForm.reset({
					title: submission.title || "",
					sector: submission.sector || "technology",
					stage: submission.stage || "idea",
					targetAmount: submission.targetAmount || 0,
					summary: submission.summary || "",
					pitchVideoUrl: submission.pitchVideoUrl || "",
				});
				if (submission.problem) problemForm.reset(submission.problem);
				if (submission.solution) solutionForm.reset(submission.solution);
				if (submission.businessModel)
					businessForm.reset(submission.businessModel);
				if (submission.financials) financialsForm.reset(submission.financials);
				setCurrentStep(submission.currentStep || 1);
			}

			// Load associated documents
			const docRes = await fetch(
				`${API_URL}/documents?submissionId=${editId}`,
				{
					headers: { Authorization: `Bearer ${await user.getIdToken()}` },
				},
			);
			if (docRes.ok) {
				const { documents } = await docRes.json();
				if (Array.isArray(documents)) {
					setUploadedDocs(
						documents.filter(
							(d: UploadedDoc) => d._id && (d.filename || d.url),
						),
					);
				}
			}
		} catch (err) {
			console.error("Failed to load draft:", err);
		}
	}, [
		editId,
		user,
		API_URL,
		metadataForm,
		problemForm,
		solutionForm,
		businessForm,
		financialsForm,
	]);

	useEffect(() => {
		loadDraft();
	}, [loadDraft]);

	// Save draft to backend
	const saveDraft = async (stepData?: Record<string, unknown>) => {
		if (!user) return;
		setSaving(true);
		setSaveMessage("");

		try {
			const token = await user.getIdToken();

			// Create submission if it doesn't exist
			if (!submissionId) {
				const metaValues = metadataForm.getValues();
				const res = await fetch(`${API_URL}/submissions`, {
					method: "POST",
					headers: {
						"Content-Type": "application/json",
						Authorization: `Bearer ${token}`,
					},
					body: JSON.stringify({
						title: metaValues.title || "Untitled Pitch",
						sector: metaValues.sector,
						stage: metaValues.stage,
					}),
				});
				if (res.ok) {
					const { submission } = await res.json();
					setSubmissionId(submission._id);
					// Now update with current step data
					await updateDraft(submission._id, token, stepData);
				}
			} else {
				await updateDraft(submissionId, token, stepData);
			}

			setSaveMessage(t.pitchNew.draftSaved);
			setTimeout(() => setSaveMessage(""), 2000);
		} catch (err) {
			console.error("Save error:", err);
			setSaveMessage(t.pitchNew.failedToSave);
		} finally {
			setSaving(false);
		}
	};

	const updateDraft = async (
		id: string,
		token: string,
		extraData?: Record<string, unknown>,
	) => {
		const payload = {
			...metadataForm.getValues(),
			problem: problemForm.getValues(),
			solution: solutionForm.getValues(),
			businessModel: businessForm.getValues(),
			financials: financialsForm.getValues(),
			currentStep,
			...extraData,
		};

		await fetch(`${API_URL}/submissions/${id}`, {
			method: "PATCH",
			headers: {
				"Content-Type": "application/json",
				Authorization: `Bearer ${token}`,
			},
			body: JSON.stringify(payload),
		});
	};

	// Document upload handler
	const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
		const files = e.target.files;
		if (!files || files.length === 0 || !user || !submissionId) return;

		setUploading(true);
		setUploadProgress(0);
		setUploadingFileName(files[0]?.name ?? null);
		try {
			const token = await user.getIdToken();

			const uploadWithProgress = (
				file: File,
				signature: {
					apiKey: string;
					timestamp: number;
					signature: string;
					folder: string;
					publicId: string;
					chunkSize: number;
					uploadUrl: string;
				},
			) =>
				new Promise<{
					public_id: string;
					secure_url: string;
					bytes: number;
					format: string;
				}>((resolve, reject) => {
					const formData = new FormData();
					formData.append("file", file);
					formData.append("api_key", signature.apiKey);
					formData.append("timestamp", signature.timestamp.toString());
					formData.append("signature", signature.signature);
					formData.append("folder", signature.folder);
					formData.append("public_id", signature.publicId);
					formData.append("resource_type", "auto");
					formData.append("chunk_size", signature.chunkSize.toString());
					formData.append("use_filename", "true");
					formData.append("unique_filename", "false");

					const xhr = new XMLHttpRequest();
					xhr.open("POST", signature.uploadUrl, true);
					xhr.upload.onprogress = (event) => {
						if (!event.lengthComputable) return;
						setUploadProgress(Math.round((event.loaded / event.total) * 100));
					};
					xhr.onload = () => {
						if (xhr.status >= 200 && xhr.status < 300) {
							try {
								resolve(JSON.parse(xhr.responseText));
							} catch {
								reject(new Error("Invalid Cloudinary response"));
							}
							return;
						}

						try {
							const data = JSON.parse(xhr.responseText) as {
								error?: { message?: string };
							};
							reject(new Error(data.error?.message || "Upload failed"));
						} catch {
							reject(new Error("Upload failed"));
						}
					};
					xhr.onerror = () => reject(new Error("Upload failed"));
					xhr.send(formData);
				});

			for (let i = 0; i < files.length; i++) {
				const file = files[i];
				setUploadingFileName(file.name);
				setUploadProgress(0);

				if (file.size > 70 * 1024 * 1024) {
					showErrorToast(`${file.name} ${t.pitchNew.uploadExceedsLimit}`);
					continue;
				}

				const signatureRes = await fetch(
					`${API_URL}/documents/direct-upload/signature`,
					{
						method: "POST",
						headers: {
							"Content-Type": "application/json",
							Authorization: `Bearer ${token}`,
						},
						body: JSON.stringify({
							type: selectedDocType,
							submissionId,
							filename: file.name,
							fileSize: file.size,
						}),
					},
				);

				if (!signatureRes.ok) {
					const data = await signatureRes.json();
					console.error("Signature fetch failed:", signatureRes.status, data);
					showErrorToast(data.message || `${t.pitchNew.failedToPrepare} ${file.name}`);
					continue;
				}

				const signature = (await signatureRes.json()) as {
					cloudName: string;
					apiKey: string;
					timestamp: number;
					signature: string;
					folder: string;
					publicId: string;
					chunkSize: number;
					uploadUrl: string;
				};

				const cloudinaryResult = (await uploadWithProgress(
					file,
					signature,
				)) as {
					public_id: string;
					secure_url: string;
					bytes: number;
					format: string;
				};

				const registerRes = await fetch(
					`${API_URL}/documents/direct-upload/complete`,
					{
						method: "POST",
						headers: {
							"Content-Type": "application/json",
							Authorization: `Bearer ${token}`,
						},
						body: JSON.stringify({
							type: selectedDocType,
							submissionId,
							cloudinaryPublicId: cloudinaryResult.public_id,
							url: cloudinaryResult.secure_url,
							sizeBytes: cloudinaryResult.bytes,
							mimeType: file.type || "application/octet-stream",
							filename: file.name,
						}),
					},
				);

				if (registerRes.ok) {
					const { document } = await registerRes.json();
					setUploadedDocs((prev) => [...prev, document]);
					setUploadProgress(100);
					showSuccessToast(`${t.pitchNew.uploaded}: ${file.name}`);
				} else {
					const data = await registerRes.json();
					console.error(
						"Direct upload completion failed:",
						registerRes.status,
						data,
					);
					showErrorToast(data.message || `${t.pitchNew.failedToRegister} ${file.name}`);
				}
			}
		} catch (err) {
			console.error("Upload error:", err);
			showErrorToast(t.pitchNew.uploadFailed);
		} finally {
			setUploading(false);
			setUploadProgress(0);
			setUploadingFileName(null);
			// Reset input
			e.target.value = "";
		}
	};

	// Delete document
	const handleDeleteDoc = async (docId: string) => {
		if (!user) return;
		try {
			const token = await user.getIdToken();
			const res = await fetch(`${API_URL}/documents/${docId}`, {
				method: "DELETE",
				headers: { Authorization: `Bearer ${token}` },
			});
			if (res.ok) {
				setUploadedDocs((prev) => prev.filter((d) => d._id !== docId));
				showSuccessToast(t.pitchNew.documentRemoved);
			}
		} catch (err) {
			console.error("Delete error:", err);
		}
	};

	// Step navigation
	const goNext = async () => {
		let isValid = false;

		switch (currentStep) {
			case 1:
				isValid = await metadataForm.trigger();
				break;
			case 2:
				isValid = await problemForm.trigger();
				break;
			case 3:
				isValid = await solutionForm.trigger();
				break;
			case 4:
				isValid = await businessForm.trigger();
				break;
			case 5:
				isValid = await financialsForm.trigger();
				break;
			case 6:
				// Documents step — no form validation, just proceed
				isValid = true;
				break;
		}

		if (isValid) {
			await saveDraft();
			if (currentStep < 6) {
				setCurrentStep((prev) => prev + 1);
			} else {
				// Go to review page
				router.push(`/entrepreneur/pitch/review?id=${submissionId}`);
			}
		}
	};

	const goBack = () => {
		if (currentStep > 1) setCurrentStep((prev) => prev - 1);
	};

	const _progress = (currentStep / STEPS.length) * 100;

	const getDocStatusBadge = (status: string) => {
		switch (status) {
			case "processed":
				return (
					<Badge variant="default" className="gap-1 bg-emerald-600">
						<CheckCircle2 className="h-3 w-3" /> {t.pitchNew.verified}
					</Badge>
				);
			case "processing":
				return (
					<Badge variant="secondary" className="gap-1">
						<Loader2 className="h-3 w-3 animate-spin" /> {t.pitchNew.processing}
					</Badge>
				);
			case "failed":
				return (
					<Badge variant="destructive" className="gap-1">
						<XCircle className="h-3 w-3" /> {t.pitchNew.failed}
					</Badge>
				);
			case "flagged":
				return (
					<Badge
						variant="destructive"
						className="gap-1 bg-amber-600 hover:bg-amber-700"
					>
						<XCircle className="h-3 w-3" /> {t.pitchNew.suspicious}
					</Badge>
				);
			default:
				return <Badge variant="outline">{t.pitchNew.uploaded}</Badge>;
		}
	};

	return (
		<ProtectedRoute allowedRoles={["entrepreneur"]}>
			<DashboardLayout navItems={ENTREPRENEUR_NAV} title="SEPMS">
				<div className="w-full flex flex-col admin-content-fade">
					{/* Dashboard-Style Header Wrapper */}
					<div className="admin-greeting-card bg-card mb-8 p-6 sm:p-8 shrink-0 rounded-2xl shadow-sm border border-border">
						<div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
							<div className="flex items-center gap-4">
								<div className="admin-icon-glow admin-icon-purple rounded-2xl p-3 flex items-center justify-center shadow-lg transform hover:scale-105 transition-transform">
									<Lightbulb className="h-6 w-6 text-white" />
								</div>
								<div>
									<h1 className="text-2xl sm:text-3xl font-bold tracking-tight admin-header-gradient pb-1">
										{t.nav.newPitch}
									</h1>
									<p className="text-sm text-muted-foreground font-medium">
										{t.pitchNew.tellInvestors}
									</p>
								</div>
							</div>

							<div className="flex items-center justify-start sm:justify-end gap-4 w-full sm:w-auto mt-4 sm:mt-0">
								{saveMessage && (
									<span className="text-xs font-medium text-muted-foreground animate-in fade-in zoom-in duration-300 whitespace-nowrap">
										{saveMessage}
									</span>
								)}
								<Button
									variant="outline"
									size="sm"
									className="h-9 gap-2 px-4 shadow-sm hover:bg-muted"
									onClick={() => saveDraft()}
									disabled={saving}
								>
									{saving ? (
										<>
											<Loader2 className="h-4 w-4 animate-spin text-muted-foreground" />
											<span className="inline">{t.pitchNew.saving}</span>
										</>
									) : (
										<>
											<ClipboardList className="h-4 w-4 text-foreground" />
											<span className="inline">{t.pitchNew.saveDraft}</span>
										</>
									)}
								</Button>
							</div>
						</div>
					</div>

					{/* Main Layout: Left Stepper & Right Content */}
					<div className="w-full flex flex-col md:flex-row bg-card rounded-2xl border border-border shadow-sm mb-12">
						{/* Vertical Stepper Sidebar */}
						<aside className="w-full md:w-72 lg:w-80 border-b md:border-b-0 md:border-r border-border/50 shrink-0">
							<div className="p-6 md:p-8 sticky top-6">
								<h3 className="text-xs font-bold text-foreground/50 mb-8 uppercase tracking-widest">
									{t.pitchNew.progressTracker}
								</h3>
								<div className="flex flex-col gap-8 relative">
									{/* The vertical connecting line */}
									<div className="absolute left-[15px] top-4 bottom-4 w-0.5 bg-border/50 shadow-sm" />

									{STEPS.map((step) => {
										const isCompleted = currentStep > step.id;
										const isActive = currentStep === step.id;

										return (
											<div
												key={step.id}
												className="flex gap-4 relative z-10 transition-all duration-300 group"
											>
												{/* Marker Node */}
												<div
													className={`h-8 w-8 rounded-full border-2 flex items-center justify-center shrink-0 transition-all duration-500 bg-background ${
														isCompleted
															? "border-primary bg-primary shadow-lg shadow-primary/20 text-primary-foreground"
															: isActive
																? "border-primary ring-4 ring-primary/10 shadow-sm"
																: "border-muted-foreground/30 text-muted-foreground"
													}`}
												>
													{isCompleted ? (
														<CheckCircle2 className="h-4 w-4 animate-in zoom-in" />
													) : (
														<div className="scale-75 opacity-70">
															{step.icon}
														</div>
													)}
												</div>

												{/* Step Text Container */}
												<div className="flex flex-col pt-1">
													<p
														className={`text-sm font-semibold transition-colors duration-300 ${isActive ? "text-foreground" : isCompleted ? "text-foreground/80" : "text-muted-foreground/60"}`}
													>
														{step.id === 1 ? t.pitchNew.overview : step.id === 2 ? t.pitchNew.problem : step.id === 3 ? t.pitchNew.solution : step.id === 4 ? t.pitchNew.businessModel : step.id === 5 ? t.pitchNew.financials : t.pitchNew.documents}
													</p>
													{isActive && (
														<p className="text-xs text-muted-foreground font-medium animate-in fade-in slide-in-from-left-1 mt-0.5">
															{t.pitchNew.inProgress}
														</p>
													)}
												</div>
											</div>
										);
									})}
								</div>
							</div>
						</aside>

						{/* Right Content Area */}
						<div className="flex-1 flex flex-col bg-background/50 relative rounded-b-2xl md:rounded-b-none md:rounded-r-2xl">
							{/* Form Content Area */}
							<div className="p-4 sm:p-6 lg:p-10 max-w-4xl w-full mx-auto">
								
								{/* English Only Requirement Banner */}
								<div className="mb-6 rounded-lg border border-blue-200 bg-blue-50 p-4 text-sm text-blue-800 dark:border-blue-900/50 dark:bg-blue-950/50 dark:text-blue-200 flex items-start gap-3">
									<Info className="h-5 w-5 shrink-0 text-blue-600 dark:text-blue-400 mt-0.5" />
									<p>{t.pitchNew.englishOnlyWarning}</p>
								</div>

								{/* Step 1: Overview / Metadata */}
								{currentStep === 1 && (
									<Card className="bg-card animate-in fade-in slide-in-from-bottom-4 duration-500 overflow-hidden border border-border/50 shadow-sm rounded-2xl">
										<CardHeader className="bg-background border-b border-border/40 pb-6 pt-8 px-6 sm:px-10">
											<CardTitle className="text-xl sm:text-2xl font-bold flex items-center gap-3 text-foreground pb-1">
												<ClipboardList className="h-6 w-6 text-primary" /> {t.pitchNew.pitchOverview}
											</CardTitle>
											<CardDescription>
												{t.pitchNew.startWithBasics}
											</CardDescription>
										</CardHeader>
										<CardContent className="px-6 sm:px-10 py-8 max-w-3xl space-y-8">
											<div className="space-y-2">
												<DualLabel htmlFor="title" labelKey="pitchTitle" />
												<Input
													id="title"
													placeholder={t.pitchNew.pitchTitlePlaceholder}
													{...metadataForm.register("title")}
												/>
												{metadataForm.formState.errors.title && (
													<p className="text-sm text-destructive">
														{metadataForm.formState.errors.title.message}
													</p>
												)}
											</div>

											<div className="grid gap-6 sm:grid-cols-2">
												<div className="space-y-2">
													<DualLabel htmlFor="sector" labelKey="industrySector" />
													<Controller
														name="sector"
														control={metadataForm.control}
														render={({ field }) => (
															<Select
																value={field.value}
																onValueChange={field.onChange}
															>
																<SelectTrigger className="w-full">
																	<SelectValue placeholder={t.pitchNew.selectSector} />
																</SelectTrigger>
																<SelectContent>
																	{SECTORS.map((s) => (
																		<SelectItem key={s.value} value={s.value}>
																			{s.label}
																		</SelectItem>
																	))}
																</SelectContent>
															</Select>
														)}
													/>
												</div>

												<div className="space-y-2">
													<DualLabel htmlFor="stage" labelKey="startupStage" />
													<Controller
														name="stage"
														control={metadataForm.control}
														render={({ field }) => (
															<Select
																value={field.value}
																onValueChange={field.onChange}
															>
																<SelectTrigger className="w-full">
																	<SelectValue placeholder={t.pitchNew.selectStage} />
																</SelectTrigger>
																<SelectContent>
																	{STAGES.map((s) => (
																		<SelectItem key={s.value} value={s.value}>
																			{s.label}
																		</SelectItem>
																	))}
																</SelectContent>
															</Select>
														)}
													/>
												</div>
											</div>

											<div className="space-y-2">
												<Label htmlFor="targetAmount">
													{t.pitchNew.targetAmount}
												</Label>
												<Input
													id="targetAmount"
													type="number"
													placeholder={t.pitchNew.targetAmountPlaceholder}
													{...metadataForm.register("targetAmount", {
														valueAsNumber: true,
													})}
												/>
												{metadataForm.formState.errors.targetAmount && (
													<p className="text-sm text-destructive">
														{metadataForm.formState.errors.targetAmount.message}
													</p>
												)}
											</div>

											<div className="space-y-2">
												<DualLabel htmlFor="summary" labelKey="executiveSummary" />
												<Textarea
													id="summary"
													placeholder={t.pitchNew.summaryPlaceholder}
													rows={5}
													{...metadataForm.register("summary")}
												/>
												{metadataForm.formState.errors.summary && (
													<p className="text-sm text-destructive">
														{metadataForm.formState.errors.summary.message}
													</p>
												)}
											</div>

											<div className="space-y-2">
												<Label htmlFor="pitchVideoUrl">
													{t.pitchNew.pitchVideoUrl}
												</Label>
												<Input
													id="pitchVideoUrl"
													placeholder={t.pitchNew.videoUrlPlaceholder}
													{...metadataForm.register("pitchVideoUrl")}
												/>
												{metadataForm.formState.errors.pitchVideoUrl && (
													<p className="text-sm text-destructive">
														{
															metadataForm.formState.errors.pitchVideoUrl
																.message
														}
													</p>
												)}
											</div>
										</CardContent>
									</Card>
								)}

								{/* Step 2: Problem */}
								{currentStep === 2 && (
									<Card className="bg-card animate-in fade-in slide-in-from-bottom-4 duration-500 overflow-hidden border border-border/50 shadow-sm rounded-2xl">
										<CardHeader className="bg-background border-b border-border/40 pb-6 pt-8 px-6 sm:px-10">
											<CardTitle className="text-xl sm:text-2xl font-bold flex items-center gap-3 text-foreground pb-1">
												<Search className="h-6 w-6 text-primary" /> {t.pitchNew.theProblem}
											</CardTitle>
											<CardDescription>
												{t.pitchNew.describeProblem}
											</CardDescription>
										</CardHeader>
										<CardContent className="px-6 sm:px-10 py-8 max-w-3xl space-y-8">
											<div className="space-y-2">
												<DualLabel htmlFor="statement" labelKey="problemStatement" />
												<Textarea
													id="statement"
													placeholder={t.pitchNew.problemPlaceholder}
													rows={5}
													{...problemForm.register("statement")}
												/>
												{problemForm.formState.errors.statement && (
													<p className="text-sm text-destructive">
														{problemForm.formState.errors.statement.message}
													</p>
												)}
											</div>

											<div className="space-y-2">
												<DualLabel htmlFor="targetMarket" labelKey="targetMarket" />
												<Textarea
													id="targetMarket"
													placeholder={t.pitchNew.targetMarketPlaceholder}
													rows={3}
													{...problemForm.register("targetMarket")}
												/>
												{problemForm.formState.errors.targetMarket && (
													<p className="text-sm text-destructive">
														{problemForm.formState.errors.targetMarket.message}
													</p>
												)}
											</div>

											<div className="space-y-2">
												<DualLabel htmlFor="marketSize" labelKey="marketSize" />
												<Textarea
													id="marketSize"
													placeholder={t.pitchNew.marketSizePlaceholder}
													rows={3}
													{...problemForm.register("marketSize")}
												/>
												{problemForm.formState.errors.marketSize && (
													<p className="text-sm text-destructive">
														{problemForm.formState.errors.marketSize.message}
													</p>
												)}
											</div>
										</CardContent>
									</Card>
								)}

								{/* Step 3: Solution */}
								{currentStep === 3 && (
									<Card className="bg-card animate-in fade-in slide-in-from-bottom-4 duration-500 overflow-hidden border border-border/50 shadow-sm rounded-2xl">
										<CardHeader className="bg-background border-b border-border/40 pb-6 pt-8 px-6 sm:px-10">
											<CardTitle className="text-xl sm:text-2xl font-bold flex items-center gap-3 text-foreground pb-1">
												<Lightbulb className="h-6 w-6 text-primary" /> {t.pitchNew.yourSolution}
											</CardTitle>
											<CardDescription>
												{t.pitchNew.howSolves}
											</CardDescription>
										</CardHeader>
										<CardContent className="px-6 sm:px-10 py-8 max-w-3xl space-y-8">
											<div className="space-y-2">
												<Label htmlFor="description">
													{t.pitchNew.solutionDescription}
												</Label>
												<Textarea
													id="description"
													placeholder={t.pitchNew.solutionPlaceholder}
													rows={5}
													{...solutionForm.register("description")}
												/>
												{solutionForm.formState.errors.description && (
													<p className="text-sm text-destructive">
														{solutionForm.formState.errors.description.message}
													</p>
												)}
											</div>

											<div className="space-y-2">
												<Label htmlFor="uniqueValue">
													{t.pitchNew.uniqueValue}
												</Label>
												<Textarea
													id="uniqueValue"
													placeholder={t.pitchNew.uniqueValuePlaceholder}
													rows={3}
													{...solutionForm.register("uniqueValue")}
												/>
												{solutionForm.formState.errors.uniqueValue && (
													<p className="text-sm text-destructive">
														{solutionForm.formState.errors.uniqueValue.message}
													</p>
												)}
											</div>

											<div className="space-y-2">
												<Label htmlFor="competitiveAdvantage">
													{t.pitchNew.competitiveAdvantage}
												</Label>
												<Textarea
													id="competitiveAdvantage"
													placeholder={t.pitchNew.competitiveAdvantagePlaceholder}
													rows={3}
													{...solutionForm.register("competitiveAdvantage")}
												/>
												{solutionForm.formState.errors.competitiveAdvantage && (
													<p className="text-sm text-destructive">
														{
															solutionForm.formState.errors.competitiveAdvantage
																.message
														}
													</p>
												)}
											</div>
										</CardContent>
									</Card>
								)}

								{/* Step 4: Business Model */}
								{currentStep === 4 && (
									<Card className="bg-card animate-in fade-in slide-in-from-bottom-4 duration-500 overflow-hidden border border-border/50 shadow-sm rounded-2xl">
										<CardHeader className="bg-background border-b border-border/40 pb-6 pt-8 px-6 sm:px-10">
											<CardTitle className="text-xl sm:text-2xl font-bold flex items-center gap-3 text-foreground pb-1">
												<BarChart3 className="h-6 w-6 text-primary" /> {t.pitchNew.businessModelHeader}
											</CardTitle>
											<CardDescription>
												{t.pitchNew.howMakesMoney}
											</CardDescription>
										</CardHeader>
										<CardContent className="px-6 sm:px-10 py-8 max-w-3xl space-y-8">
											<div className="space-y-2">
												<Label htmlFor="revenueStreams">
													{t.pitchNew.revenueStreams}
												</Label>
												<Textarea
													id="revenueStreams"
													placeholder={t.pitchNew.revenuePlaceholder}
													rows={4}
													{...businessForm.register("revenueStreams")}
												/>
												{businessForm.formState.errors.revenueStreams && (
													<p className="text-sm text-destructive">
														{
															businessForm.formState.errors.revenueStreams
																.message
														}
													</p>
												)}
											</div>

											<div className="space-y-2">
												<Label htmlFor="pricingStrategy">
													{t.pitchNew.pricingStrategy}
												</Label>
												<Textarea
													id="pricingStrategy"
													placeholder={t.pitchNew.pricingPlaceholder}
													rows={3}
													{...businessForm.register("pricingStrategy")}
												/>
												{businessForm.formState.errors.pricingStrategy && (
													<p className="text-sm text-destructive">
														{
															businessForm.formState.errors.pricingStrategy
																.message
														}
													</p>
												)}
											</div>

											<div className="space-y-2">
												<Label htmlFor="customerAcquisition">
													{t.pitchNew.customerAcquisition}
												</Label>
												<Textarea
													id="customerAcquisition"
													placeholder={t.pitchNew.acquisitionPlaceholder}
													rows={3}
													{...businessForm.register("customerAcquisition")}
												/>
												{businessForm.formState.errors.customerAcquisition && (
													<p className="text-sm text-destructive">
														{
															businessForm.formState.errors.customerAcquisition
																.message
														}
													</p>
												)}
											</div>
										</CardContent>
									</Card>
								)}

								{/* Step 5: Financials */}
								{currentStep === 5 && (
									<Card className="bg-card animate-in fade-in slide-in-from-bottom-4 duration-500 overflow-hidden border border-border/50 shadow-sm rounded-2xl">
										<CardHeader className="bg-background border-b border-border/40 pb-6 pt-8 px-6 sm:px-10">
											<CardTitle className="text-xl sm:text-2xl font-bold flex items-center gap-3 text-foreground pb-1">
												<DollarSign className="h-6 w-6 text-primary" />{" "}
												{t.pitchNew.financialDetails}
											</CardTitle>
											<CardDescription>
												{t.pitchNew.shareFinancials}
											</CardDescription>
										</CardHeader>
										<CardContent className="px-6 sm:px-10 py-8 max-w-3xl space-y-8">
											<div className="space-y-2">
												<DualLabel htmlFor="currentRevenue" labelKey="currentRevenue" />
												<Input
													id="currentRevenue"
													placeholder={t.pitchNew.currentRevenuePlaceholder}
													{...financialsForm.register("currentRevenue")}
												/>
											</div>

											<div className="space-y-2">
												<Label htmlFor="projectedRevenue">
													{t.pitchNew.projectedRevenue}
												</Label>
												<Input
													id="projectedRevenue"
													placeholder={t.pitchNew.projectedRevenuePlaceholder}
													{...financialsForm.register("projectedRevenue")}
												/>
												{financialsForm.formState.errors.projectedRevenue && (
													<p className="text-sm text-destructive">
														{
															financialsForm.formState.errors.projectedRevenue
																.message
														}
													</p>
												)}
											</div>

											<div className="space-y-2">
												<DualLabel htmlFor="burnRate" labelKey="burnRate" />
												<Input
													id="burnRate"
													placeholder={t.pitchNew.burnRatePlaceholder}
													{...financialsForm.register("burnRate")}
												/>
											</div>

											<div className="space-y-2">
												<DualLabel htmlFor="runway" labelKey="runway" />
												<Input
													id="runway"
													placeholder={t.pitchNew.runwayPlaceholder}
													{...financialsForm.register("runway")}
												/>
											</div>
										</CardContent>
									</Card>
								)}

								{/* Step 6: Documents */}
								{currentStep === 6 && (
									<Card className="bg-card animate-in fade-in slide-in-from-bottom-4 duration-500 overflow-hidden border border-border/50 shadow-sm rounded-2xl">
										<CardHeader className="bg-background border-b border-border/40 pb-6 pt-8 px-6 sm:px-10">
											<CardTitle className="text-xl sm:text-2xl font-bold flex items-center gap-3 text-foreground pb-1">
												<FileUp className="h-6 w-6 text-primary" /> {t.pitchNew.supportingDocs}
											</CardTitle>
											<CardDescription>
												{t.pitchNew.uploadSupporting}
											</CardDescription>
										</CardHeader>
										<CardContent className="px-6 sm:px-10 py-8 max-w-3xl space-y-8">
											{!submissionId && (
												<div className="rounded-lg border border-amber-200 bg-amber-50 p-4 text-sm text-amber-800 dark:border-amber-900 dark:bg-amber-950 dark:text-amber-200">
													{t.pitchNew.saveDraftFirst}
												</div>
											)}

											{submissionId && (
												<>
													<div className="space-y-4">
														<div className="space-y-2">
															<DualLabel labelKey="selectDocType" />
															<Select
																value={selectedDocType}
																onValueChange={setSelectedDocType}
															>
																<SelectTrigger className="w-full">
																	<SelectValue />
																</SelectTrigger>
																<SelectContent>
																	{docCategories.map((dt) => (
																		<SelectItem key={dt.value} value={dt.value}>
																			{dt.label} {dt.required && "*"}
																		</SelectItem>
																	))}
																</SelectContent>
															</Select>
														</div>

														<div className="space-y-2">
															<DualLabel labelKey="uploadFiles" />
															<label
																htmlFor="file-upload"
																className="flex flex-col items-center justify-center w-full h-32 border-2 border-dashed rounded-lg cursor-pointer bg-muted/20 hover:bg-muted/50 border-muted-foreground/30 hover:border-primary/50 transition-all"
															>
																<div className="flex flex-col items-center justify-center pt-5 pb-6">
																	{uploading ? (
																		<Loader2 className="w-8 h-8 mb-3 text-primary animate-spin" />
																	) : (
																		<FileUp className="w-8 h-8 mb-3 text-muted-foreground" />
																	)}
																	<p className="mb-2 text-sm text-foreground font-medium">
																		{uploading
																			? t.pitchNew.uploadingCarefully
																			: t.pitchNew.clickToBrowse}
																	</p>
																	<p className="text-xs text-muted-foreground">
																		{t.pitchNew.maxSize}
																	</p>
																</div>
																<Input
																	id="file-upload"
																	type="file"
																	multiple
																	className="hidden"
																	accept=".pdf,.pptx,.ppt,.doc,.docx,.xls,.xlsx,.jpg,.jpeg,.png,.webp"
																	onChange={handleFileUpload}
																	disabled={uploading}
																/>
															</label>
															{uploading && (
																<div className="space-y-2 rounded-lg border border-border/60 bg-muted/20 p-3">
																	<div className="flex items-center justify-between text-xs text-muted-foreground">
																		<span className="truncate pr-2">
																			{t.pitchNew.uploadingFile} {uploadingFileName || "file"}
																		</span>
																		<span>{uploadProgress}%</span>
																	</div>
																	<Progress
																		value={uploadProgress}
																		className="h-2"
																	/>
																</div>
															)}
														</div>
													</div>

													{/* Uploaded documents list */}
													{uploadedDocs.length > 0 && (
														<div className="space-y-3">
															<h4 className="font-medium text-sm">
																{t.pitchNew.uploadedDocs} ({uploadedDocs.length})
															</h4>
															{uploadedDocs.map((doc) => (
																<div
																	key={doc._id}
																	className="flex items-center justify-between rounded-lg border bg-card p-3"
																>
																	<div className="flex items-center gap-3 min-w-0">
																		<FileUp className="h-4 w-4 shrink-0 text-muted-foreground" />
																		<div className="min-w-0">
																			<p className="text-sm font-medium truncate">
																				{doc.filename}
																			</p>
																			<p className="text-xs text-muted-foreground">
																				{getDocLabel(doc.type)}
																			</p>
																			{doc.processingError && (
																				<p className="text-xs text-destructive mt-1">
																					{doc.processingError}
																				</p>
																			)}
																		</div>
																	</div>
																	<div className="flex items-center gap-2 shrink-0">
																		{getDocStatusBadge(doc.status)}
																		<Button
																			variant="ghost"
																			size="icon"
																			className="h-8 w-8 text-muted-foreground hover:text-destructive"
																			onClick={() => handleDeleteDoc(doc._id)}
																		>
																			<Trash2 className="h-4 w-4" />
																		</Button>
																	</div>
																</div>
															))}
														</div>
													)}

													{uploadedDocs.length === 0 && (
														<div className="rounded-lg border-2 border-dashed border-border p-8 text-center">
															<FileUp className="mx-auto h-10 w-10 text-muted-foreground/50 mb-3" />
															<p className="text-sm text-muted-foreground">
																{t.pitchNew.noDocsYet}
															</p>
														</div>
													)}
												</>
											)}
										</CardContent>
									</Card>
								)}
							</div>

							{/* Floating Modern Footer */}
							<footer className="flex items-center justify-between px-6 sm:px-10 py-5 border-t border-border/50 bg-background/95 backdrop-blur mt-8 shrink-0 transition-all duration-300 rounded-b-2xl md:rounded-b-none md:rounded-br-2xl">
								<Button
									variant="ghost"
									onClick={goBack}
									disabled={currentStep === 1}
									className="shadow-sm border border-border/60 hover:bg-muted font-medium hover:shadow-md transition-all h-10 px-6"
								>
									{t.pitchNew.back}
								</Button>

								<Button
									onClick={goNext}
									className="shadow-lg shadow-primary/20 hover:shadow-primary/30 hover:-translate-y-0.5 transition-all duration-300 h-10 px-8 bg-primary hover:bg-primary/90 text-primary-foreground font-semibold"
								>
									{currentStep === STEPS.length
										? t.pitchNew.reviewPitch
										: t.pitchNew.continue}
								</Button>
							</footer>
						</div>
					</div>
				</div>
			</DashboardLayout>
		</ProtectedRoute>
	);
}

export default function NewPitchPage() {
	return (
		<Suspense
			fallback={
				<div className="flex min-h-screen items-center justify-center">
					<div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
				</div>
			}
		>
			<NewPitchPageInner />
		</Suspense>
	);
}
