"use client";

import {
	BarChart3,
	Briefcase,
	CheckCircle2,
	DollarSign,
	FileText,
	History,
	Loader2,
	PieChart,
	TrendingUp,
} from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import DashboardLayout from "@/components/DashboardLayout";
import ProtectedRoute from "@/components/ProtectedRoute";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
	Table,
	TableBody,
	TableCell,
	TableHead,
	TableHeader,
	TableRow,
} from "@/components/ui/table";
import { INVESTOR_NAV } from "@/constants/navigation";
import { useAuth } from "@/context/AuthContext";
import {
	showErrorToast,
	showInfoToast,
	showSuccessToast,
	showWarningToast,
} from "@/lib/toast-messages";

// ── Types ──────────────────────────────────────────────────────────────────────

interface LedgerEntry {
	_id: string;
	transactionId: string;
	type: string;
	status: string;
	amount: number;
	currency: string;
	description: string;
	milestoneId?: { _id: string; title: string };
	submissionId?: { _id: string; title: string };
	occurredAt: string;
}

interface ProjectSummary {
	title: string;
	milestoneCount: number;
	paidMilestones: number;
	totalInvested: number;
	escrowStatus: string;
}

interface InvestorSummary {
	totalCommitted: number;
	totalReleased: number;
	platformFeesPaid: number;
	perProject: ProjectSummary[];
	recentLedger: LedgerEntry[];
}

// ── Helpers ───────────────────────────────────────────────────────────────────

const API = (
	process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:5000/api"
).replace(/\/+$/, "");

function typeConfig(type: string): {
	label: string;
	variant: "default" | "secondary" | "outline" | "destructive";
} {
	switch (type) {
		case "escrow_hold":
			return { label: "Escrow Hold", variant: "secondary" };
		case "escrow_release":
			return { label: "Escrow Release", variant: "default" };
		case "platform_fee":
			return { label: "Platform Fee", variant: "outline" };
		case "milestone_payout":
			return { label: "Payout", variant: "default" };
		case "milestone_refund":
			return { label: "Refund", variant: "destructive" };
		default:
			return { label: type, variant: "outline" };
	}
}

// ── Page ──────────────────────────────────────────────────────────────────────

export default function InvestorPortfolioPage() {
	const { user } = useAuth();
	const [summary, setSummary] = useState<InvestorSummary | null>(null);
	const [loading, setLoading] = useState(true);

	const fetchSummary = useCallback(async () => {
		if (!user) return;
		setLoading(true);
		try {
			const token = await user.getIdToken();
			const res = await fetch(`${API}/finance/investor-summary`, {
				headers: { Authorization: `Bearer ${token}` },
			});
			const data = await res.json();
			if (data.status === "success") {
				setSummary(data.summary);
			} else {
				showErrorToast("Failed to load portfolio summary");
			}
		} catch {
			showErrorToast("Network error");
		} finally {
			setLoading(false);
		}
	}, [user]);

	useEffect(() => {
		fetchSummary();
	}, [fetchSummary]);

	if (loading) {
		return (
			<DashboardLayout navItems={INVESTOR_NAV} title="Portfolio">
				<div className="flex items-center justify-center min-h-[60vh]">
					<Loader2 className="h-8 w-8 animate-spin text-primary" />
				</div>
			</DashboardLayout>
		);
	}

	if (!summary) return null;

	return (
		<ProtectedRoute allowedRoles={["investor"]}>
			<DashboardLayout navItems={INVESTOR_NAV} title="Portfolio">
				<>
					{/* Header */}
					<div className="admin-greeting-card bg-card mb-8 p-6 sm:p-8 admin-content-fade">
						<div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
							<div>
								<h1 className="text-2xl font-bold tracking-tight sm:text-3xl admin-header-gradient flex items-center gap-2">
									<PieChart className="h-8 w-8 text-primary" />
									Investment Portfolio
								</h1>
								<p className="mt-1.5 text-muted-foreground text-sm sm:text-base">
									Track your commitments, escrow holdings, and investment
									history.
								</p>
							</div>
							<Badge
								variant="outline"
								className="text-xs font-medium gap-1.5 py-1 px-3 w-fit"
							>
								<Briefcase className="h-3.5 w-3.5" />
								{summary.perProject.length} Active Projects
							</Badge>
						</div>
					</div>

					{/* Stats Cards */}
					<div className="admin-stat-grid grid gap-4 sm:grid-cols-2 lg:grid-cols-3 mb-8">
						<div className="admin-stat-card bg-card">
							<div className="p-5">
								<div className="flex items-center gap-3">
									<div className="admin-icon-glow admin-icon-blue rounded-xl p-2.5 flex items-center justify-center shadow-sm">
										<DollarSign className="h-4.5 w-4.5 text-white" />
									</div>
									<div className="min-w-0 flex-1">
										<p className="text-[11px] uppercase tracking-wider font-semibold text-muted-foreground/70">
											Total Committed
										</p>
										<p className="text-2xl font-bold tracking-tight truncate">
											ETB {summary.totalCommitted.toLocaleString()}
										</p>
									</div>
								</div>
							</div>
						</div>
						<div className="admin-stat-card bg-card">
							<div className="p-5">
								<div className="flex items-center gap-3">
									<div className="admin-icon-glow admin-icon-emerald rounded-xl p-2.5 flex items-center justify-center shadow-sm">
										<TrendingUp className="h-4.5 w-4.5 text-white" />
									</div>
									<div className="min-w-0 flex-1">
										<p className="text-[11px] uppercase tracking-wider font-semibold text-muted-foreground/70">
											Total Released
										</p>
										<p className="text-2xl font-bold tracking-tight truncate">
											ETB {summary.totalReleased.toLocaleString()}
										</p>
									</div>
								</div>
							</div>
						</div>
						<div className="admin-stat-card bg-card">
							<div className="p-5">
								<div className="flex items-center gap-3">
									<div className="admin-icon-glow admin-icon-amber rounded-xl p-2.5 flex items-center justify-center shadow-sm">
										<BarChart3 className="h-4.5 w-4.5 text-white" />
									</div>
									<div className="min-w-0 flex-1">
										<p className="text-[11px] uppercase tracking-wider font-semibold text-muted-foreground/70">
											Platform Fees
										</p>
										<p className="text-2xl font-bold tracking-tight truncate">
											ETB {summary.platformFeesPaid.toLocaleString()}
										</p>
									</div>
								</div>
							</div>
						</div>
					</div>

					{/* Projects Breakdown */}
					<div className="mb-3">
						<h2 className="text-lg font-semibold tracking-tight">
							Per-Project Breakdown
						</h2>
					</div>
					<div className="rounded-lg border bg-card overflow-hidden mb-8">
						<Table>
							<TableHeader>
								<TableRow className="bg-muted/30">
									<TableHead className="font-semibold">Project Title</TableHead>
									<TableHead className="font-semibold text-center">
										Milestones
									</TableHead>
									<TableHead className="font-semibold text-right">
										Total Invested
									</TableHead>
									<TableHead className="font-semibold text-right">
										Status
									</TableHead>
								</TableRow>
							</TableHeader>
							<TableBody>
								{summary.perProject.length === 0 ? (
									<TableRow>
										<TableCell
											colSpan={4}
											className="text-center py-8 text-muted-foreground"
										>
											No investment data available for projects.
										</TableCell>
									</TableRow>
								) : (
									summary.perProject.map((project) => (
										<TableRow
											key={project.title}
											className="group hover:bg-muted/30 transition-colors"
										>
											<TableCell>
												<div className="font-medium text-sm text-foreground">
													{project.title}
												</div>
											</TableCell>
											<TableCell className="text-center text-sm text-muted-foreground">
												{project.paidMilestones} / {project.milestoneCount}
											</TableCell>
											<TableCell className="text-right text-sm font-semibold text-foreground">
												ETB {project.totalInvested.toLocaleString()}
											</TableCell>
											<TableCell className="text-right">
												<Badge variant="outline" className="capitalize text-xs">
													{project.escrowStatus === "none"
														? "Active"
														: project.escrowStatus}
												</Badge>
											</TableCell>
										</TableRow>
									))
								)}
							</TableBody>
						</Table>
					</div>

					{/* Recent Ledger Entries */}
					<div className="mb-3">
						<h2 className="text-lg font-semibold tracking-tight">
							Recent Transactions
						</h2>
					</div>
					<div className="rounded-lg border bg-card overflow-hidden">
						<Table>
							<TableHeader>
								<TableRow className="bg-muted/30">
									<TableHead className="font-semibold">Date</TableHead>
									<TableHead className="font-semibold">Description</TableHead>
									<TableHead className="font-semibold">Type</TableHead>
									<TableHead className="font-semibold text-right">
										Amount
									</TableHead>
									<TableHead className="font-semibold text-right">
										Status
									</TableHead>
								</TableRow>
							</TableHeader>
							<TableBody>
								{summary.recentLedger.length === 0 ? (
									<TableRow>
										<TableCell
											colSpan={5}
											className="text-center py-8 text-muted-foreground"
										>
											No transaction history found.
										</TableCell>
									</TableRow>
								) : (
									summary.recentLedger.map((entry) => {
										const cfg = typeConfig(entry.type);
										return (
											<TableRow
												key={entry._id}
												className="group hover:bg-muted/30 transition-colors"
											>
												<TableCell className="text-xs text-muted-foreground truncate">
													{new Date(entry.occurredAt).toLocaleDateString()}
												</TableCell>
												<TableCell>
													<div className="font-medium text-sm text-foreground">
														{entry.description}
													</div>
													{entry.milestoneId && (
														<div className="text-xs text-muted-foreground flex items-center gap-1 mt-0.5">
															<FileText className="h-3 w-3 shrink-0" />
															<span className="truncate max-w-[150px]">
																{entry.milestoneId.title}
															</span>
														</div>
													)}
												</TableCell>
												<TableCell>
													<Badge
														variant={cfg.variant}
														className="whitespace-nowrap font-medium text-xs"
													>
														{cfg.label}
													</Badge>
												</TableCell>
												<TableCell className="text-right text-sm font-semibold text-foreground">
													ETB {entry.amount.toLocaleString()}
												</TableCell>
												<TableCell className="text-right">
													<div className="flex items-center justify-end gap-1.5 capitalize text-xs">
														{entry.status === "completed" ? (
															<CheckCircle2 className="h-3.5 w-3.5 text-emerald-500" />
														) : (
															<Loader2 className="h-3 w-3 animate-spin text-amber-500" />
														)}
														{entry.status}
													</div>
												</TableCell>
											</TableRow>
										);
									})
								)}
							</TableBody>
						</Table>
					</div>
				</>
			</DashboardLayout>
		</ProtectedRoute>
	);
}
