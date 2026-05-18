"use client";

import {
	Banknote,
	CheckCircle2,
	Clock,
	FileText,
	History,
	Loader2,
	Wallet,
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
import { ENTREPRENEUR_NAV } from "@/constants/navigation";
import { useAuth } from "@/context/AuthContext";
import {
	showErrorToast,
	showInfoToast,
	showSuccessToast,
	showWarningToast,
} from "@/lib/toast-messages";

// ── Types ──────────────────────────────────────────────────────────────────────

interface PayoutEntry {
	_id: string;
	transactionId: string;
	amount: number;
	currency: string;
	status: string;
	description: string;
	milestoneId?: { _id: string; title: string };
	submissionId?: { _id: string; title: string };
	occurredAt: string;
}

interface PendingMilestone {
	id: string;
	title: string;
	amount: number;
	projectTitle: string;
}

interface EntrepreneurSummary {
	totalReceived: number;
	pendingRelease: number;
	recentPayouts: PayoutEntry[];
	pendingMilestones: PendingMilestone[];
}

// ── Helpers ───────────────────────────────────────────────────────────────────

const API = (
	process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:5000/api"
).replace(/\/+$/, "");

// ── Page ──────────────────────────────────────────────────────────────────────

export default function EntrepreneurEarningsPage() {
	const { user } = useAuth();
	const [summary, setSummary] = useState<EntrepreneurSummary | null>(null);
	const [loading, setLoading] = useState(true);

	const fetchSummary = useCallback(async () => {
		if (!user) return;
		setLoading(true);
		try {
			const token = await user.getIdToken();
			const res = await fetch(`${API}/finance/entrepreneur-summary`, {
				headers: { Authorization: `Bearer ${token}` },
			});
			const data = await res.json();
			if (data.status === "success") {
				setSummary(data.summary);
			} else {
				showErrorToast("Failed to load earnings summary");
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
			<DashboardLayout navItems={ENTREPRENEUR_NAV} title="Earnings">
				<div className="flex items-center justify-center min-h-[60vh]">
					<Loader2 className="h-8 w-8 animate-spin text-primary" />
				</div>
			</DashboardLayout>
		);
	}

	if (!summary) return null;

	return (
		<ProtectedRoute allowedRoles={["entrepreneur"]}>
			<DashboardLayout navItems={ENTREPRENEUR_NAV} title="Earnings">
				<>
					{/* Header */}
					<div className="admin-greeting-card bg-card mb-8 p-6 sm:p-8 admin-content-fade">
						<div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
							<div>
								<h1 className="text-2xl font-bold tracking-tight sm:text-3xl admin-header-gradient flex items-center gap-2">
									<Wallet className="h-8 w-8 text-primary" />
									My Earnings
								</h1>
								<p className="mt-1.5 text-muted-foreground text-sm sm:text-base">
									Monitor your received payouts and funds awaiting release.
								</p>
							</div>
							<Badge
								variant="outline"
								className="text-xs font-medium gap-1.5 py-1 px-3 w-fit"
							>
								<Banknote className="h-3.5 w-3.5" />
								{summary.recentPayouts.length} Payouts
							</Badge>
						</div>
					</div>

					{/* Stats Cards */}
					<div className="admin-stat-grid grid gap-4 sm:grid-cols-2 mb-8">
						<div className="admin-stat-card bg-card">
							<div className="p-5">
								<div className="flex items-center gap-3">
									<div className="admin-icon-glow admin-icon-emerald rounded-xl p-2.5 flex items-center justify-center shadow-sm">
										<Banknote className="h-4.5 w-4.5 text-white" />
									</div>
									<div className="min-w-0 flex-1">
										<p className="text-[11px] uppercase tracking-wider font-semibold text-muted-foreground/70">
											Total Received
										</p>
										<p className="text-2xl font-bold tracking-tight truncate">
											ETB {summary.totalReceived.toLocaleString()}
										</p>
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
											Pending Release
										</p>
										<p className="text-2xl font-bold tracking-tight truncate">
											ETB {summary.pendingRelease.toLocaleString()}
										</p>
									</div>
								</div>
							</div>
						</div>
					</div>

					{/* Awaiting Release Section */}
					{summary.pendingMilestones.length > 0 && (
						<>
							<div className="mb-3">
								<h2 className="text-lg font-semibold tracking-tight text-amber-600">
									Awaiting Disbursement
								</h2>
							</div>
							<div className="rounded-lg border border-amber-200/50 bg-amber-50/30 p-4 mb-8">
								<div className="space-y-3">
									{summary.pendingMilestones.map((m) => (
										<div
											key={m.id}
											className="flex flex-col sm:flex-row sm:items-center justify-between p-4 bg-card rounded-xl border shadow-sm group hover:border-amber-200 transition-colors"
										>
											<div>
												<p className="font-medium text-sm text-foreground">
													{m.title}
												</p>
												<p className="text-xs text-muted-foreground mt-0.5">
													{m.projectTitle}
												</p>
											</div>
											<div className="mt-2 sm:mt-0 text-right">
												<p className="text-sm font-semibold text-amber-600">
													ETB {m.amount.toLocaleString()}
												</p>
												<Badge
													variant="outline"
													className="text-[10px] uppercase font-semibold text-amber-500 border-amber-200 mt-1"
												>
													Verified & Escrow Held
												</Badge>
											</div>
										</div>
									))}
								</div>
							</div>
						</>
					)}

					{/* Payout History */}
					<div className="mb-3">
						<h2 className="text-lg font-semibold tracking-tight">
							Payout History
						</h2>
					</div>
					<div className="rounded-lg border bg-card overflow-hidden">
						<Table>
							<TableHeader>
								<TableRow className="bg-muted/30">
									<TableHead className="font-semibold">Date</TableHead>
									<TableHead className="font-semibold">Reference</TableHead>
									<TableHead className="font-semibold">Description</TableHead>
									<TableHead className="font-semibold text-right">
										Amount
									</TableHead>
									<TableHead className="font-semibold text-right">
										Status
									</TableHead>
								</TableRow>
							</TableHeader>
							<TableBody>
								{summary.recentPayouts.length === 0 ? (
									<TableRow>
										<TableCell
											colSpan={5}
											className="text-center py-12 text-muted-foreground"
										>
											No payout history found yet.
										</TableCell>
									</TableRow>
								) : (
									summary.recentPayouts.map((payout) => (
										<TableRow
											key={payout._id}
											className="group hover:bg-muted/30 transition-colors"
										>
											<TableCell className="text-xs text-muted-foreground truncate">
												{new Date(payout.occurredAt).toLocaleDateString()}
											</TableCell>
											<TableCell className="font-mono text-xs text-muted-foreground">
												{payout.transactionId.substring(0, 12)}...
											</TableCell>
											<TableCell>
												<div className="font-medium text-sm text-foreground">
													{payout.description}
												</div>
												{payout.milestoneId && (
													<div className="text-xs text-muted-foreground flex items-center gap-1 mt-0.5">
														<FileText className="h-3 w-3 shrink-0" />
														<span className="truncate max-w-[150px]">
															{payout.milestoneId.title}
														</span>
													</div>
												)}
											</TableCell>
											<TableCell className="text-right text-sm font-semibold text-emerald-600">
												+ ETB {payout.amount.toLocaleString()}
											</TableCell>
											<TableCell className="text-right">
												<div className="flex items-center justify-end gap-1.5 capitalize text-xs">
													<CheckCircle2 className="h-3.5 w-3.5 text-emerald-500" />
													{payout.status}
												</div>
											</TableCell>
										</TableRow>
									))
								)}
							</TableBody>
						</Table>
					</div>
				</>
			</DashboardLayout>
		</ProtectedRoute>
	);
}
