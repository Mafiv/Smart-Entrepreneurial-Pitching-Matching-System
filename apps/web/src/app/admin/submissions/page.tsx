"use client";

import {
	ArrowUpDown,
	CheckCircle2,
	ClipboardList,
	Clock,
	Eye,
	FileText,
	Loader2,
	Search,
	XCircle,
} from "lucide-react";
import { useRouter } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import DashboardLayout from "@/components/DashboardLayout";
import ProtectedRoute from "@/components/ProtectedRoute";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/ui/select";
import { Separator } from "@/components/ui/separator";
import {
	Table,
	TableBody,
	TableCell,
	TableHead,
	TableHeader,
	TableRow,
} from "@/components/ui/table";
import { ADMIN_NAV } from "@/constants/navigation";
import { useAuth } from "@/context/AuthContext";
import { useLanguage } from "@/i18n/LanguageContext";

interface Submission {
	_id: string;
	title: string;
	sector: string;
	stage: string;
	status: string;
	targetAmount: number;
	aiScore?: number;
	entrepreneurId?: { fullName?: string; email?: string };
	submittedAt?: string;
	updatedAt: string;
	createdAt: string;
}



function statusBadge(status: string) {
	switch (status) {
		case "approved":
		case "matched":
			return "default" as const;
		case "submitted":
		case "under_review":
			return "secondary" as const;
		case "rejected":
		case "suspended":
			return "destructive" as const;
		default:
			return "outline" as const;
	}
}

function statusIcon(status: string) {
	switch (status) {
		case "approved":
		case "matched":
			return <CheckCircle2 className="h-3.5 w-3.5" />;
		case "rejected":
		case "suspended":
			return <XCircle className="h-3.5 w-3.5" />;
		case "submitted":
		case "under_review":
			return <Clock className="h-3.5 w-3.5" />;
		default:
			return <FileText className="h-3.5 w-3.5" />;
	}
}

function sectorLabel(value: string, t: any) {
	const SECTOR_OPTIONS = [
		{ value: "all", label: t.adminSubmissions.allSectors },
		{ value: "technology", label: t.adminSubmissions.technology },
		{ value: "healthcare", label: t.adminSubmissions.healthcare },
		{ value: "fintech", label: t.adminSubmissions.fintech },
		{ value: "education", label: t.adminSubmissions.education },
		{ value: "agriculture", label: t.adminSubmissions.agriculture },
		{ value: "energy", label: t.adminSubmissions.energy },
		{ value: "real_estate", label: t.adminSubmissions.realEstate },
		{ value: "manufacturing", label: t.adminSubmissions.manufacturing },
		{ value: "retail", label: t.adminSubmissions.retail },
		{ value: "other", label: t.adminSubmissions.other },
	];
	return SECTOR_OPTIONS.find((s) => s.value === value)?.label || value;
}

export default function AdminSubmissionsPage() {
	const { user } = useAuth();
	const router = useRouter();
	const { t } = useLanguage();

	const STATUS_OPTIONS = [
		{ value: "all", label: t.adminSubmissions.allStatuses },
		{ value: "draft", label: t.adminSubmissions.draft },
		{ value: "submitted", label: t.adminSubmissions.submitted },
		{ value: "under_review", label: t.adminSubmissions.underReview },
		{ value: "approved", label: t.adminSubmissions.approved },
		{ value: "rejected", label: t.adminSubmissions.rejected },
		{ value: "suspended", label: t.adminSubmissions.suspended },
		{ value: "matched", label: t.adminSubmissions.matched },
		{ value: "closed", label: t.adminSubmissions.closed },
	];

	const SECTOR_OPTIONS = [
		{ value: "all", label: t.adminSubmissions.allSectors },
		{ value: "technology", label: t.adminSubmissions.technology },
		{ value: "healthcare", label: t.adminSubmissions.healthcare },
		{ value: "fintech", label: t.adminSubmissions.fintech },
		{ value: "education", label: t.adminSubmissions.education },
		{ value: "agriculture", label: t.adminSubmissions.agriculture },
		{ value: "energy", label: t.adminSubmissions.energy },
		{ value: "real_estate", label: t.adminSubmissions.realEstate },
		{ value: "manufacturing", label: t.adminSubmissions.manufacturing },
		{ value: "retail", label: t.adminSubmissions.retail },
		{ value: "other", label: t.adminSubmissions.other },
	];

	const [submissions, setSubmissions] = useState<Submission[]>([]);
	const [loading, setLoading] = useState(true);
	const [statusFilter, setStatusFilter] = useState("all");
	const [sectorFilter, setSectorFilter] = useState("all");
	const [searchQuery, setSearchQuery] = useState("");
	const [page, setPage] = useState(1);
	const [totalPages, setTotalPages] = useState(1);
	const [total, setTotal] = useState(0);
	const [stats, setStats] = useState<Record<string, number>>({});

	const api = (
		process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api"
	).replace(/\/+$/, "");

	const fetchSubmissions = useCallback(async () => {
		if (!user) return;
		setLoading(true);
		try {
			const token = await user.getIdToken();
			const params = new URLSearchParams({ page: String(page), limit: "20" });
			if (statusFilter !== "all") params.set("status", statusFilter);
			if (sectorFilter !== "all") params.set("sector", sectorFilter);

			const res = await fetch(`${api}/submissions/admin/all?${params}`, {
				headers: { Authorization: `Bearer ${token}` },
			});
			if (res.ok) {
				const data = await res.json();
				setSubmissions(data.submissions || []);
				setTotal(data.total || 0);
				setTotalPages(data.totalPages || 1);
				if (data.stats) setStats(data.stats);
			}
		} catch (err) {
			console.error(t.adminSubmissions.failedToFetchSubmissions, err);
		} finally {
			setLoading(false);
		}
	}, [user, api, page, statusFilter, sectorFilter]);

	useEffect(() => {
		fetchSubmissions();
	}, [fetchSubmissions]);

	// Client-side search filter
	const filtered = submissions.filter((s) => {
		if (!searchQuery.trim()) return true;
		const q = searchQuery.toLowerCase();
		return (
			s.title.toLowerCase().includes(q) ||
			s.entrepreneurId?.fullName?.toLowerCase().includes(q) ||
			s.entrepreneurId?.email?.toLowerCase().includes(q) ||
			s.sector.toLowerCase().includes(q)
		);
	});

	return (
		<ProtectedRoute allowedRoles={["admin"]}>
			<DashboardLayout navItems={ADMIN_NAV} title="SEPMS">
				<div className="admin-greeting-card bg-card mb-8 p-6 sm:p-8 admin-content-fade">
					<div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
						<div>
							<h1 className="text-2xl font-bold tracking-tight sm:text-3xl admin-header-gradient">
								{t.adminSubmissions.pitchSubmissions}
							</h1>
							<p className="mt-1.5 text-muted-foreground text-sm sm:text-base">
								{t.adminSubmissions.pitchSubmissionsDesc}
							</p>
						</div>
						<Badge
							variant="outline"
							className="text-xs font-medium gap-1.5 py-1 px-3 w-fit"
						>
							<FileText className="h-3.5 w-3.5" />
							{total} {t.adminSubmissions.total}
						</Badge>
					</div>
				</div>

				{/* Stat Cards */}
				<div className="admin-stat-grid grid gap-4 sm:grid-cols-2 lg:grid-cols-4 mb-8">
					<div className="admin-stat-card bg-card">
						<div className="p-5">
							<div className="flex items-center gap-3">
								<div className="admin-icon-glow admin-icon-blue rounded-xl p-2.5 flex items-center justify-center shadow-sm">
									<FileText className="h-4.5 w-4.5 text-white" />
								</div>
								<div className="min-w-0 flex-1">
									<p className="text-[11px] uppercase tracking-wider font-semibold text-muted-foreground/70">
										{t.adminSubmissions.total}
									</p>
									<p className="text-2xl font-bold tracking-tight">{total}</p>
								</div>
							</div>
						</div>
					</div>
					<div className="admin-stat-card bg-card">
						<div className="p-5">
							<div className="flex items-center gap-3">
								<div className="admin-icon-glow admin-icon-amber rounded-xl p-2.5 flex items-center justify-center shadow-sm">
									<Clock className="h-4.5 w-4.5 text-white" />
								</div>
								<div className="min-w-0 flex-1">
									<p className="text-[11px] uppercase tracking-wider font-semibold text-muted-foreground/70">
										{t.adminSubmissions.pendingReview}
									</p>
									<div className="flex items-baseline gap-2">
										<p className="text-2xl font-bold tracking-tight">
											{(stats.submitted || 0) + (stats.under_review || 0)}
										</p>
										{(stats.submitted || 0) + (stats.under_review || 0) > 0 && (
											<span className="text-[10px] font-semibold text-amber-500 bg-amber-500/10 px-1.5 py-0.5 rounded-full">
												{t.adminSubmissions.needsReview}
											</span>
										)}
									</div>
								</div>
							</div>
						</div>
					</div>
					<div className="admin-stat-card bg-card">
						<div className="p-5">
							<div className="flex items-center gap-3">
								<div className="admin-icon-glow admin-icon-emerald rounded-xl p-2.5 flex items-center justify-center shadow-sm">
									<CheckCircle2 className="h-4.5 w-4.5 text-white" />
								</div>
								<div className="min-w-0 flex-1">
									<p className="text-[11px] uppercase tracking-wider font-semibold text-muted-foreground/70">
										{t.adminSubmissions.approved}
									</p>
									<p className="text-2xl font-bold tracking-tight">
										{stats.approved || 0}
									</p>
								</div>
							</div>
						</div>
					</div>
					<div className="admin-stat-card bg-card">
						<div className="p-5">
							<div className="flex items-center gap-3">
								<div className="admin-icon-glow admin-icon-rose rounded-xl p-2.5 flex items-center justify-center shadow-sm">
									<XCircle className="h-4.5 w-4.5 text-white" />
								</div>
								<div className="min-w-0 flex-1">
									<p className="text-[11px] uppercase tracking-wider font-semibold text-muted-foreground/70">
										{t.adminSubmissions.rejected}
									</p>
									<p className="text-2xl font-bold tracking-tight">
										{(stats.rejected || 0) + (stats.suspended || 0)}
									</p>
								</div>
							</div>
						</div>
					</div>
				</div>

				{/* Filters */}
				<div className="flex flex-col gap-3 sm:flex-row sm:items-center mb-6">
					<div className="relative flex-1 max-w-sm">
						<Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
						<Input
							placeholder={t.adminSubmissions.searchPlaceholder}
							value={searchQuery}
							onChange={(e) => setSearchQuery(e.target.value)}
							className="pl-9"
						/>
					</div>
					<Select
						value={statusFilter}
						onValueChange={(v) => {
							setStatusFilter(v);
							setPage(1);
						}}
					>
						<SelectTrigger className="w-full sm:w-44">
							<SelectValue placeholder={t.adminSubmissions.status} />
						</SelectTrigger>
						<SelectContent>
							{STATUS_OPTIONS.map((o) => (
								<SelectItem key={o.value} value={o.value}>
									{o.label}
								</SelectItem>
							))}
						</SelectContent>
					</Select>
					<Select
						value={sectorFilter}
						onValueChange={(v) => {
							setSectorFilter(v);
							setPage(1);
						}}
					>
						<SelectTrigger className="w-full sm:w-44">
							<SelectValue placeholder={t.adminSubmissions.sector} />
						</SelectTrigger>
						<SelectContent>
							{SECTOR_OPTIONS.map((o) => (
								<SelectItem key={o.value} value={o.value}>
									{o.label}
								</SelectItem>
							))}
						</SelectContent>
					</Select>
				</div>

				<Separator className="mb-6" />

				{/* Table */}
				{loading ? (
					<div className="flex items-center justify-center py-20">
						<Loader2 className="h-8 w-8 animate-spin text-primary" />
					</div>
				) : filtered.length === 0 ? (
					<Card className="border-dashed">
						<CardContent className="flex flex-col items-center justify-center py-16">
							<ClipboardList className="h-10 w-10 text-muted-foreground mb-4" />
							<h3 className="text-lg font-semibold mb-2">
								{t.adminSubmissions.noSubmissionsFound}
							</h3>
							<p className="text-muted-foreground text-center max-w-md text-sm">
								{searchQuery || statusFilter !== "all" || sectorFilter !== "all"
									? t.adminSubmissions.tryAdjustingFilters
									: t.adminSubmissions.noPitchesSubmittedYet}
							</p>
						</CardContent>
					</Card>
				) : (
					<>
						<div className="rounded-lg border bg-card overflow-hidden">
							<Table>
								<TableHeader>
									<TableRow className="bg-muted/30">
										<TableHead className="font-semibold">{t.adminSubmissions.pitch}</TableHead>
										<TableHead className="font-semibold hidden md:table-cell">
											{t.adminSubmissions.founder}
										</TableHead>
										<TableHead className="font-semibold hidden lg:table-cell">
											{t.adminSubmissions.sector}
										</TableHead>
										<TableHead className="font-semibold">
											<div className="flex items-center gap-1">
												{t.adminSubmissions.status} <ArrowUpDown className="h-3 w-3" />
											</div>
										</TableHead>
										<TableHead className="font-semibold hidden sm:table-cell text-right">
											{t.adminSubmissions.amount}
										</TableHead>
										<TableHead className="font-semibold hidden lg:table-cell">
											{t.adminSubmissions.aiScore}
										</TableHead>
										<TableHead className="font-semibold text-right">
											{t.adminSubmissions.action}
										</TableHead>
									</TableRow>
								</TableHeader>
								<TableBody>
									{filtered.map((sub) => (
										<TableRow
											key={sub._id}
											className="group hover:bg-muted/30 transition-colors"
										>
											<TableCell>
												<div>
													<p className="font-medium text-sm truncate max-w-[200px]">
														{sub.title}
													</p>
													<p className="text-xs text-muted-foreground mt-0.5">
														{new Date(
															sub.submittedAt || sub.createdAt,
														).toLocaleDateString()}
													</p>
												</div>
											</TableCell>
											<TableCell className="hidden md:table-cell">
												<div>
													<p className="text-sm truncate max-w-[150px]">
														{sub.entrepreneurId?.fullName || "—"}
													</p>
													<p className="text-xs text-muted-foreground truncate max-w-[150px]">
														{sub.entrepreneurId?.email || ""}
													</p>
												</div>
											</TableCell>
											<TableCell className="hidden lg:table-cell">
												<Badge variant="outline" className="text-xs capitalize">
													{sectorLabel(sub.sector, t)}
												</Badge>
											</TableCell>
											<TableCell>
												<Badge
													variant={statusBadge(sub.status)}
													className="text-xs gap-1 capitalize"
												>
													{statusIcon(sub.status)}
													{(t.adminSubmissions as Record<string, string>)[sub.status.replace("_", "")] || sub.status.replace("_", " ")}
												</Badge>
											</TableCell>
											<TableCell className="hidden sm:table-cell text-right">
												<span className="text-sm font-semibold">
													${sub.targetAmount?.toLocaleString() || "0"}
												</span>
											</TableCell>
											<TableCell className="hidden lg:table-cell">
												{sub.aiScore !== undefined && sub.aiScore !== null ? (
													<Badge variant="outline" className="text-xs">
														{sub.aiScore}/100
													</Badge>
												) : (
													<span className="text-xs text-muted-foreground">
														—
													</span>
												)}
											</TableCell>
											<TableCell className="text-right">
												<Button
													variant="ghost"
													size="sm"
													className="gap-1.5 text-xs"
													onClick={() => router.push(`/admin/pitch/${sub._id}`)}
												>
													<Eye className="h-3.5 w-3.5" />
													{t.adminSubmissions.review}
												</Button>
											</TableCell>
										</TableRow>
									))}
								</TableBody>
							</Table>
						</div>

						{/* Pagination */}
						{totalPages > 1 && (
							<div className="flex items-center justify-between mt-6">
								<p className="text-sm text-muted-foreground">
									{t.adminSubmissions.page} {page} {t.adminSubmissions.of} {totalPages} · {total} {t.adminSubmissions.total.toLowerCase()}
								</p>
								<div className="flex items-center gap-1">
									<Button
										variant="outline"
										size="sm"
										disabled={page <= 1}
										onClick={() => setPage((p) => Math.max(1, p - 1))}
										className="h-8 px-3"
									>
										{t.adminSubmissions.previous}
									</Button>
									{Array.from({ length: Math.min(totalPages, 5) }, (_, i) => {
										let pg: number;
										if (totalPages <= 5) {
											pg = i + 1;
										} else if (page <= 3) {
											pg = i + 1;
										} else if (page >= totalPages - 2) {
											pg = totalPages - 4 + i;
										} else {
											pg = page - 2 + i;
										}
										return (
											<Button
												key={pg}
												variant={pg === page ? "default" : "outline"}
												size="sm"
												onClick={() => setPage(pg)}
												className="h-8 w-8 p-0"
											>
												{pg}
											</Button>
										);
									})}
									<Button
										variant="outline"
										size="sm"
										disabled={page >= totalPages}
										onClick={() => setPage((p) => p + 1)}
										className="h-8 px-3"
									>
										{t.adminSubmissions.next}
									</Button>
								</div>
							</div>
						)}
					</>
				)}
			</DashboardLayout>
		</ProtectedRoute>
	);
}
