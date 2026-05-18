"use client";

import {
	AlertCircle,
	ArrowRightLeft,
	CheckCircle2,
	DollarSign,
	FileText,
	Loader2,
	Send,
	ShieldCheck,
	TrendingUp,
} from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { toast } from "sonner";
import DashboardLayout from "@/components/DashboardLayout";
import ProtectedRoute from "@/components/ProtectedRoute";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
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

// ── Types ──────────────────────────────────────────────────────────────────────

interface UserSummary {
	fullName: string;
	email: string;
}

interface MilestoneSummary {
	_id: string;
	title: string;
	amount: number;
	currency: string;
	entrepreneurId: UserSummary;
	investorId: UserSummary;
	submissionId: { title: string };
}

interface PendingChapa {
	_id: string;
	tx_ref: string;
	amount: number;
	currency: string;
	userId: UserSummary;
	createdAt: string;
}

interface LedgerEntry {
	_id: string;
	type: string;
	status: string;
	amount: number;
	description: string;
	occurredAt: string;
}

interface AdminFinanceData {
	totalEscrowHeld: number;
	totalDisbursed: number;
	totalFees: number;
	ledger: LedgerEntry[];
	awaitingDisbursement: MilestoneSummary[];
	pendingChapa: PendingChapa[];
}

// ── Helpers ───────────────────────────────────────────────────────────────────

const API = (
	process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:5000/api"
).replace(/\/+$/, "");

function initials(name?: string) {
	if (!name) return "?";
	return name
		.split(" ")
		.map((w) => w[0])
		.join("")
		.toUpperCase()
		.slice(0, 2);
}

// ── Page ──────────────────────────────────────────────────────────────────────

export default function AdminFinancePage() {
	const { user } = useAuth();
	const [data, setData] = useState<AdminFinanceData | null>(null);
	const [loading, setLoading] = useState(true);

	// Action states
	const [disburseTarget, setDisburseTarget] = useState<MilestoneSummary | null>(
		null,
	);
	const [paymentRef, setPaymentRef] = useState("");
	const [acting, setActing] = useState(false);

	const fetchData = useCallback(async () => {
		if (!user) return;
		setLoading(true);
		try {
			const token = await user.getIdToken();
			const res = await fetch(`${API}/finance/admin-ledger`, {
				headers: { Authorization: `Bearer ${token}` },
			});
			const result = await res.json();
			if (result.status === "success") {
				setData(result.summary);
			} else {
				toast.error("Failed to load finance data");
			}
		} catch {
			toast.error("Network error");
		} finally {
			setLoading(false);
		}
	}, [user]);

	useEffect(() => {
		fetchData();
	}, [fetchData]);

	const handleDisburse = async () => {
		if (!user || !disburseTarget) return;
		setActing(true);
		try {
			const token = await user.getIdToken();
			const res = await fetch(`${API}/finance/disburse`, {
				method: "POST",
				headers: {
					Authorization: `Bearer ${token}`,
					"Content-Type": "application/json",
				},
				body: JSON.stringify({
					milestoneId: disburseTarget._id,
					paymentReference: paymentRef,
				}),
			});
			const result = await res.json();
			if (result.status === "success") {
				toast.success("Funds disbursed successfully");
				setDisburseTarget(null);
				setPaymentRef("");
				fetchData(); // Refresh overview
			} else {
				toast.error(result.message || "Disbursement failed");
			}
		} catch {
			toast.error("Network error");
		} finally {
			setActing(false);
		}
	};

	if (loading) {
		return (
			<DashboardLayout navItems={ADMIN_NAV} title="Finance Oversight">
				<div className="flex items-center justify-center min-h-[60vh]">
					<Loader2 className="h-8 w-8 animate-spin text-primary" />
				</div>
			</DashboardLayout>
		);
	}

	if (!data) return null;

	return (
		<ProtectedRoute allowedRoles={["admin"]}>
			<DashboardLayout navItems={ADMIN_NAV} title="Finance Oversight">
				<>
					{/* Header */}
					<div className="admin-greeting-card bg-card mb-8 p-6 sm:p-8 admin-content-fade">
						<div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
							<div>
								<h1 className="text-2xl font-bold tracking-tight sm:text-3xl admin-header-gradient flex items-center gap-2">
									<ShieldCheck className="h-8 w-8 text-primary" />
									Finance Oversight
								</h1>
								<p className="mt-1.5 text-muted-foreground text-sm sm:text-base">
									Manage platform escrow, verify payouts, and monitor the global
									ledger.
								</p>
							</div>
							<Badge
								variant="outline"
								className="text-xs font-medium gap-1.5 py-1 px-3 w-fit"
							>
								<DollarSign className="h-3.5 w-3.5" />
								Active Escrow
							</Badge>
						</div>
					</div>

					{/* Platform Totals */}
					<div className="admin-stat-grid grid gap-4 sm:grid-cols-2 lg:grid-cols-3 mb-8">
						<div className="admin-stat-card bg-card">
							<div className="p-5">
								<div className="flex items-center gap-3">
									<div className="admin-icon-glow admin-icon-amber rounded-xl p-2.5 flex items-center justify-center shadow-sm">
										<DollarSign className="h-4.5 w-4.5 text-white" />
									</div>
									<div className="min-w-0 flex-1">
										<p className="text-[11px] uppercase tracking-wider font-semibold text-muted-foreground/70">
											Held in Escrow
										</p>
										<p className="text-2xl font-bold tracking-tight truncate">
											ETB {data.totalEscrowHeld.toLocaleString()}
										</p>
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
											Total Disbursed
										</p>
										<p className="text-2xl font-bold tracking-tight truncate">
											ETB {data.totalDisbursed.toLocaleString()}
										</p>
									</div>
								</div>
							</div>
						</div>
						<div className="admin-stat-card bg-card">
							<div className="p-5">
								<div className="flex items-center gap-3">
									<div className="admin-icon-glow admin-icon-blue rounded-xl p-2.5 flex items-center justify-center shadow-sm">
										<TrendingUp className="h-4.5 w-4.5 text-white" />
									</div>
									<div className="min-w-0 flex-1">
										<p className="text-[11px] uppercase tracking-wider font-semibold text-muted-foreground/70">
											Platform Revenue
										</p>
										<p className="text-2xl font-bold tracking-tight truncate">
											ETB {data.totalFees.toLocaleString()}
										</p>
									</div>
								</div>
							</div>
						</div>
					</div>

					{/* Disbursement Queue */}
					<div className="mb-4 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
						<div className="space-y-1">
							<h2 className="text-lg font-semibold tracking-tight">
								Awaiting Disbursement
							</h2>
							<p className="text-sm text-muted-foreground">
								Verified milestones ready for payout to entrepreneurs.
							</p>
						</div>
						<Badge
							variant={
								data.awaitingDisbursement.length > 0 ? "default" : "secondary"
							}
							className="px-3 py-1 text-xs"
						>
							{data.awaitingDisbursement.length} Pending Actions
						</Badge>
					</div>

					<div className="rounded-lg border bg-card overflow-hidden mb-8">
						<Table>
							<TableHeader>
								<TableRow className="bg-muted/30">
									<TableHead className="font-semibold">
										Milestone / Project
									</TableHead>
									<TableHead className="font-semibold">Recipients</TableHead>
									<TableHead className="font-semibold text-right">
										Amount
									</TableHead>
									<TableHead className="font-semibold text-right">
										Action
									</TableHead>
								</TableRow>
							</TableHeader>
							<TableBody>
								{data.awaitingDisbursement.length === 0 ? (
									<TableRow>
										<TableCell
											colSpan={4}
											className="text-center py-8 text-muted-foreground italic"
										>
											No milestones are currently awaiting disbursement.
										</TableCell>
									</TableRow>
								) : (
									data.awaitingDisbursement.map((m) => (
										<TableRow key={m._id} className="group hover:bg-muted/30">
											<TableCell>
												<div className="font-medium text-sm truncate max-w-[200px]">
													{m.title}
												</div>
												<div className="text-xs text-muted-foreground flex items-center gap-1 mt-0.5">
													<FileText className="h-3 w-3 shrink-0" />
													<span className="truncate max-w-[150px]">
														{m.submissionId?.title}
													</span>
												</div>
											</TableCell>
											<TableCell>
												<div className="flex flex-col gap-1 text-xs">
													<div className="flex items-center gap-2">
														<Badge
															variant="outline"
															className="text-[10px] scale-90 origin-left px-1"
														>
															FROM
														</Badge>
														<span className="font-medium">
															{m.investorId?.fullName}
														</span>
													</div>
													<div className="flex items-center gap-2">
														<Badge
															variant="outline"
															className="text-[10px] scale-90 origin-left px-1"
														>
															TO
														</Badge>
														<span className="font-semibold text-primary">
															{m.entrepreneurId?.fullName}
														</span>
													</div>
												</div>
											</TableCell>
											<TableCell className="text-right">
												<div className="text-sm font-semibold text-foreground">
													ETB {m.amount.toLocaleString()}
												</div>
											</TableCell>
											<TableCell className="text-right">
												<Button
													size="sm"
													className="bg-emerald-600 hover:bg-emerald-700 shadow-sm"
													onClick={() => setDisburseTarget(m)}
												>
													Pay Out
												</Button>
											</TableCell>
										</TableRow>
									))
								)}
							</TableBody>
						</Table>
					</div>

					{/* Mixed Ledger & Stuck Payments Grid */}
					<div className="grid gap-8 lg:grid-cols-12">
						{/* Ledger Table */}
						<div className="lg:col-span-8">
							<div className="mb-3">
								<h2 className="text-lg font-semibold tracking-tight">
									Global Ledger
								</h2>
							</div>
							<div className="rounded-lg border bg-card overflow-hidden h-[calc(100%-2.5rem)]">
								<Table>
									<TableHeader>
										<TableRow className="bg-muted/30">
											<TableHead className="font-semibold">Date</TableHead>
											<TableHead className="font-semibold">Event</TableHead>
											<TableHead className="font-semibold text-right">
												Amount
											</TableHead>
										</TableRow>
									</TableHeader>
									<TableBody>
										{data.ledger.map((entry) => (
											<TableRow
												key={entry._id}
												className="group hover:bg-muted/30 transition-colors"
											>
												<TableCell className="text-xs text-muted-foreground truncate max-w-[80px]">
													{new Date(entry.occurredAt).toLocaleDateString()}
												</TableCell>
												<TableCell>
													<div className="font-medium text-sm text-foreground">
														{entry.description}
													</div>
													<div className="flex items-center gap-1.5 mt-0.5">
														<Badge
															variant="outline"
															className="text-[9px] uppercase tracking-tighter h-4 px-1"
														>
															{entry.type.replace("_", " ")}
														</Badge>
														{entry.status === "completed" ? (
															<Badge className="bg-emerald-500/10 text-emerald-600 border-emerald-200/50 text-[9px] h-4 px-1">
																Done
															</Badge>
														) : (
															<Badge
																variant="secondary"
																className="text-[9px] h-4 px-1"
															>
																{entry.status}
															</Badge>
														)}
													</div>
												</TableCell>
												<TableCell className="text-right text-sm font-semibold font-mono text-foreground">
													{entry.type.includes("payout") ||
													entry.type.includes("release")
														? "-"
														: "+"}
													{entry.amount.toLocaleString()}
												</TableCell>
											</TableRow>
										))}
									</TableBody>
								</Table>
							</div>
						</div>

						{/* Sidebar Widgets (Stuck Payments) */}
						<div className="lg:col-span-4">
							<div className="mb-3">
								<h2 className="text-lg font-semibold tracking-tight">
									Stuck Payments
								</h2>
							</div>
							<div className="rounded-lg border border-dashed bg-muted/20 p-4">
								{data.pendingChapa.length === 0 ? (
									<p className="text-xs text-muted-foreground py-4 text-center">
										No stuck payments detected.
									</p>
								) : (
									<div className="space-y-3">
										{data.pendingChapa.map((p) => (
											<div
												key={p._id}
												className="p-3 bg-card rounded-lg border text-xs flex justify-between items-center"
											>
												<div>
													<p className="font-medium text-sm">
														{p.userId?.fullName}
													</p>
													<p className="text-[10px] text-muted-foreground font-mono mt-0.5">
														{p.tx_ref}
													</p>
													<p className="font-semibold text-sm mt-1 text-primary">
														ETB {p.amount.toLocaleString()}
													</p>
												</div>
												<Button
													variant="ghost"
													size="icon"
													className="h-7 w-7 text-destructive"
												>
													<AlertCircle className="h-4 w-4" />
												</Button>
											</div>
										))}
									</div>
								)}
							</div>
						</div>
					</div>
				</>

				{/* Disbursement Confirmation Dialog */}
				<Dialog
					open={!!disburseTarget}
					onOpenChange={(o) => !o && setDisburseTarget(null)}
				>
					<DialogContent>
						<DialogHeader>
							<DialogTitle>Confirm Milestone Payout</DialogTitle>
							<DialogDescription>
								You are about to release funds from escrow to the entrepreneur.
								Ensure you have verified any proof of work.
							</DialogDescription>
						</DialogHeader>

						{disburseTarget && (
							<div className="space-y-4 my-4 p-4 bg-muted/50 rounded-xl border border-dashed">
								<div className="grid grid-cols-2 gap-4 text-sm">
									<div>
										<Label className="text-xs uppercase text-muted-foreground">
											Milestone
										</Label>
										<p className="font-semibold">{disburseTarget.title}</p>
									</div>
									<div className="text-right">
										<Label className="text-xs uppercase text-muted-foreground">
											Amount
										</Label>
										<p className="font-bold text-lg text-primary">
											ETB {disburseTarget.amount.toLocaleString()}
										</p>
									</div>
									<div className="col-span-2">
										<Label className="text-xs uppercase text-muted-foreground">
											Recipient
										</Label>
										<div className="flex items-center gap-2 mt-1">
											<Avatar className="h-7 w-7 rounded-md">
												<AvatarFallback className="text-[10px] bg-primary/10 text-primary">
													{initials(disburseTarget.entrepreneurId?.fullName)}
												</AvatarFallback>
											</Avatar>
											<span className="font-medium">
												{disburseTarget.entrepreneurId?.fullName}
											</span>
										</div>
									</div>
								</div>
							</div>
						)}

						<div className="space-y-2">
							<Label htmlFor="payment-ref">
								Payment Reference (e.g. Bank Ref No.)
							</Label>
							<Input
								id="payment-ref"
								placeholder="Optional transaction reference..."
								value={paymentRef}
								onChange={(e) => setPaymentRef(e.target.value)}
							/>
						</div>

						<DialogFooter className="mt-4">
							<Button
								variant="outline"
								onClick={() => setDisburseTarget(null)}
								disabled={acting}
							>
								Cancel
							</Button>
							<Button
								className="bg-emerald-600 hover:bg-emerald-700"
								onClick={handleDisburse}
								disabled={acting}
							>
								{acting ? (
									<Loader2 className="h-4 w-4 animate-spin mr-2" />
								) : (
									<ShieldCheck className="h-4 w-4 mr-2" />
								)}
								Confirm Disbursement
							</Button>
						</DialogFooter>
					</DialogContent>
				</Dialog>
			</DashboardLayout>
		</ProtectedRoute>
	);
}
