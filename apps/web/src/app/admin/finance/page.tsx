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
import { useLanguage } from "@/i18n/LanguageContext";
import {
	showErrorToast,
	showInfoToast,
	showSuccessToast,
	showWarningToast,
} from "@/lib/toast-messages";

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

interface LedgerEntry {
	_id: string;
	occurredAt: string;
	description: string;
	type: string;
	status: string;
	amount: number;
}

interface PendingChapa {
	_id: string;
	tx_ref: string;
	amount: number;
	currency: string;
	userId: UserSummary;
	createdAt: string;
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
	const { t } = useLanguage();
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
				showErrorToast(t.adminFinance.failedToLoadFinance);
			}
		} catch {
			showErrorToast(t.adminFinance.networkError);
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
				showSuccessToast(t.adminFinance.fundsDisbursedSuccess);
				setDisburseTarget(null);
				setPaymentRef("");
				fetchData(); // Refresh overview
			} else {
				showErrorToast(result.message || t.adminFinance.disbursementFailed);
			}
		} catch {
			showErrorToast(t.adminFinance.networkError);
		} finally {
			setActing(false);
		}
	};

	if (loading) {
		return (
			<DashboardLayout navItems={ADMIN_NAV} title={t.adminFinance.financeOversight}>
				<div className="flex items-center justify-center min-h-[60vh]">
					<Loader2 className="h-8 w-8 animate-spin text-primary" />
				</div>
			</DashboardLayout>
		);
	}

	if (!data) return null;

	return (
		<ProtectedRoute allowedRoles={["admin"]}>
			<DashboardLayout navItems={ADMIN_NAV} title={t.adminFinance.financeOversight}>
				<div className="space-y-8">
					{/* Header */}
					<div>
						<h1 className="text-3xl font-bold tracking-tight admin-header-gradient flex items-center gap-2">
							<ShieldCheck className="h-8 w-8 text-primary" />
							{t.adminFinance.financeOversight}
						</h1>
						<p className="text-muted-foreground mt-2">
							{t.adminFinance.financeOversightDesc}
						</p>
					</div>

					{/* Platform Totals */}
					<div className="grid gap-4 md:grid-cols-3">
						<Card className="admin-stat-card border-l-4 border-l-amber-500 shadow-sm">
							<CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
								<CardTitle className="text-sm font-medium">
									{t.adminFinance.heldInEscrow}
								</CardTitle>
								<DollarSign className="h-4 w-4 text-amber-500" />
							</CardHeader>
							<CardContent>
								<div className="text-2xl font-bold">
									ETB {data.totalEscrowHeld.toLocaleString()}
								</div>
								<p className="text-xs text-muted-foreground mt-1">
									{t.adminFinance.heldInEscrowDesc}
								</p>
							</CardContent>
						</Card>
						<Card className="admin-stat-card border-l-4 border-l-emerald-500 shadow-sm">
							<CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
								<CardTitle className="text-sm font-medium">
									{t.adminFinance.totalDisbursed}
								</CardTitle>
								<CheckCircle2 className="h-4 w-4 text-emerald-500" />
							</CardHeader>
							<CardContent>
								<div className="text-2xl font-bold">
									ETB {data.totalDisbursed.toLocaleString()}
								</div>
								<p className="text-xs text-muted-foreground mt-1">
									{t.adminFinance.totalDisbursedDesc}
								</p>
							</CardContent>
						</Card>
						<Card className="admin-stat-card border-l-4 border-l-primary shadow-sm">
							<CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
								<CardTitle className="text-sm font-medium">
									{t.adminFinance.platformRevenue}
								</CardTitle>
								<TrendingUp className="h-4 w-4 text-primary" />
							</CardHeader>
							<CardContent>
								<div className="text-2xl font-bold">
									ETB {data.totalFees.toLocaleString()}
								</div>
								<p className="text-xs text-muted-foreground mt-1">
									{t.adminFinance.platformRevenueDesc}
								</p>
							</CardContent>
						</Card>
					</div>

					{/* Disbursement Queue */}
					<Card
						className={
							data.awaitingDisbursement.length > 0
								? "border-primary/20 shadow-md ring-1 ring-primary/5"
								: ""
						}
					>
						<CardHeader className="flex flex-row items-center justify-between">
							<div className="space-y-1">
								<CardTitle className="text-lg flex items-center gap-2">
									<Send className="h-5 w-5 text-primary" />
									{t.adminFinance.awaitingDisbursement}
								</CardTitle>
								<p className="text-xs text-muted-foreground">
									{t.adminFinance.awaitingDisbursementDesc}
								</p>
							</div>
							<Badge
								variant={
									data.awaitingDisbursement.length > 0 ? "default" : "secondary"
								}
							>
								{data.awaitingDisbursement.length} {t.adminFinance.pendingActions}
							</Badge>
						</CardHeader>
						<CardContent>
							<Table>
								<TableHeader>
									<TableRow>
										<TableHead>{t.adminFinance.milestoneProject}</TableHead>
										<TableHead>{t.adminFinance.recipients}</TableHead>
										<TableHead className="text-right">{t.adminFinance.amount}</TableHead>
										<TableHead className="text-right">{t.adminFinance.action}</TableHead>
									</TableRow>
								</TableHeader>
								<TableBody>
									{data.awaitingDisbursement.length === 0 ? (
										<TableRow>
											<TableCell
												colSpan={4}
												className="text-center py-8 text-muted-foreground italic"
											>
												{t.adminFinance.noAwaitingDisbursement}
											</TableCell>
										</TableRow>
									) : (
										data.awaitingDisbursement.map((m) => (
											<TableRow key={m._id} className="group hover:bg-muted/30">
												<TableCell>
													<div className="font-semibold">{m.title}</div>
													<div className="text-xs text-muted-foreground flex items-center gap-1 mt-0.5">
														<FileText className="h-3 w-3" />
														{m.submissionId?.title}
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
													<div className="text-base font-bold text-foreground">
														ETB {m.amount.toLocaleString()}
													</div>
												</TableCell>
												<TableCell className="text-right">
													<Button
														size="sm"
														className="bg-emerald-600 hover:bg-emerald-700 shadow-sm"
														onClick={() => setDisburseTarget(m)}
													>
														{t.adminFinance.payOut}
													</Button>
												</TableCell>
											</TableRow>
										))
									)}
								</TableBody>
							</Table>
						</CardContent>
					</Card>

					{/* Mixed Ledger & Stuck Payments Grid */}
					<div className="grid gap-8 lg:grid-cols-12">
						{/* Ledger Table */}
						<div className="lg:col-span-8">
							<Card className="h-full">
								<CardHeader>
									<CardTitle className="flex items-center gap-2">
										<ArrowRightLeft className="h-5 w-5 text-primary" />
										{t.adminFinance.globalLedger}
									</CardTitle>
								</CardHeader>
								<CardContent>
									<Table>
										<TableHeader>
											<TableRow>
												<TableHead>{t.adminFinance.date}</TableHead>
												<TableHead>{t.adminFinance.event}</TableHead>
												<TableHead className="text-right">{t.adminFinance.amount}</TableHead>
											</TableRow>
										</TableHeader>
										<TableBody>
											{data.ledger.map((entry) => (
												<TableRow key={entry._id} className="text-xs">
													<TableCell className="text-muted-foreground truncate max-w-[80px]">
														{new Date(entry.occurredAt).toLocaleDateString()}
													</TableCell>
													<TableCell>
														<div className="font-medium text-foreground">
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
																	{t.adminFinance.done}
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
													<TableCell className="text-right font-mono font-bold">
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
								</CardContent>
							</Card>
						</div>

						{/* Sidebar Widgets (Stuck Payments) */}
						<div className="lg:col-span-4 space-y-4">
							<Card className="bg-muted/20 border-dashed">
								<CardHeader className="pb-3">
									<CardTitle className="text-sm flex items-center gap-2">
										<AlertCircle className="h-4 w-4 text-amber-500" />
										{t.adminFinance.stuckChapaPayments}
									</CardTitle>
								</CardHeader>
								<CardContent>
									{data.pendingChapa.length === 0 ? (
										<p className="text-xs text-muted-foreground py-4 text-center">
											{t.adminFinance.noStuckPayments}
										</p>
									) : (
										<div className="space-y-3">
											{data.pendingChapa.map((p) => (
												<div
													key={p._id}
													className="p-3 bg-card rounded-lg border text-xs flex justify-between items-center"
												>
													<div>
														<p className="font-semibold">
															{p.userId?.fullName}
														</p>
														<p className="text-[10px] text-muted-foreground font-mono mt-0.5">
															{p.tx_ref}
														</p>
														<p className="font-bold mt-1 text-primary">
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
								</CardContent>
							</Card>
						</div>
					</div>
				</div>

				{/* Disbursement Confirmation Dialog */}
				<Dialog
					open={!!disburseTarget}
					onOpenChange={(o) => !o && setDisburseTarget(null)}
				>
					<DialogContent>
						<DialogHeader>
							<DialogTitle>{t.adminFinance.confirmPayout}</DialogTitle>
							<DialogDescription>
								{t.adminFinance.confirmPayoutDesc}
							</DialogDescription>
						</DialogHeader>

						{disburseTarget && (
							<div className="space-y-4 my-4 p-4 bg-muted/50 rounded-xl border border-dashed">
								<div className="grid grid-cols-2 gap-4 text-sm">
									<div>
										<Label className="text-xs uppercase text-muted-foreground">
											{t.adminFinance.milestone}
										</Label>
										<p className="font-semibold">{disburseTarget.title}</p>
									</div>
									<div className="text-right">
										<Label className="text-xs uppercase text-muted-foreground">
											{t.adminFinance.amount}
										</Label>
										<p className="font-bold text-lg text-primary">
											ETB {disburseTarget.amount.toLocaleString()}
										</p>
									</div>
									<div className="col-span-2">
										<Label className="text-xs uppercase text-muted-foreground">
											{t.adminFinance.recipient}
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
								{t.adminFinance.paymentRef}
							</Label>
							<Input
								id="payment-ref"
								placeholder={t.adminFinance.paymentRefPlaceholder}
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
								{t.common.cancel}
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
								{t.adminFinance.confirmDisbursement}
							</Button>
						</DialogFooter>
					</DialogContent>
				</Dialog>
			</DashboardLayout>
		</ProtectedRoute>
	);
}
