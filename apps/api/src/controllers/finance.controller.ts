import type { Request, Response } from "express";
import { AuditLog } from "../models/AuditLog";
import { FinanceService } from "../services/finance.service";

export class FinanceController {
	static async getInvestorSummary(req: Request, res: Response): Promise<void> {
		try {
			const fallbackUserId = req.user?._id?.toString();
			const investorId =
				typeof req.query.investorId === "string"
					? req.query.investorId
					: fallbackUserId;

			if (!investorId) {
				res.status(400).json({
					status: "error",
					message: "Investor ID is required",
				});
				return;
			}

			const summary = await FinanceService.getInvestorSummary(investorId);
			res.status(200).json({ status: "success", summary });
		} catch (error) {
			console.error("Investor finance summary error:", error);
			res.status(500).json({
				status: "error",
				message: "Failed to fetch investor finance summary",
			});
		}
	}

	static async getEntrepreneurSummary(
		req: Request,
		res: Response,
	): Promise<void> {
		try {
			const fallbackUserId = req.user?._id?.toString();
			const entrepreneurId =
				typeof req.query.entrepreneurId === "string"
					? req.query.entrepreneurId
					: fallbackUserId;

			if (!entrepreneurId) {
				res.status(400).json({
					status: "error",
					message: "Entrepreneur ID is required",
				});
				return;
			}

			const summary =
				await FinanceService.getEntrepreneurSummary(entrepreneurId);
			res.status(200).json({ status: "success", summary });
		} catch (error) {
			console.error("Entrepreneur finance summary error:", error);
			res.status(500).json({
				status: "error",
				message: "Failed to fetch entrepreneur finance summary",
			});
		}
	}

	static async getAdminLedger(_req: Request, res: Response): Promise<void> {
		try {
			const summary = await FinanceService.getAdminLedger();
			res.status(200).json({ status: "success", summary });
		} catch (error) {
			console.error("Admin ledger error:", error);
			res.status(500).json({
				status: "error",
				message: "Failed to fetch admin ledger",
			});
		}
	}

	static async disburseMilestone(req: Request, res: Response): Promise<void> {
		try {
			const milestoneId =
				typeof req.body?.milestoneId === "string" ? req.body.milestoneId : "";
			const paymentReference =
				typeof req.body?.paymentReference === "string"
					? req.body.paymentReference
					: undefined;
			const notes =
				typeof req.body?.notes === "string" ? req.body.notes : undefined;

			if (!milestoneId) {
				res.status(400).json({
					status: "error",
					message: "milestoneId is required",
				});
				return;
			}

			const milestone = await FinanceService.disburseMilestone({
				milestoneId,
				paymentReference,
				notes,
			});

			res.status(200).json({ status: "success", milestone });
		} catch (error) {
			const message =
				error instanceof Error ? error.message : "Disbursement failed";
			const statusCode =
				message.includes("not found") || message.includes("eligible")
					? 400
					: 500;
			res.status(statusCode).json({ status: "error", message });
		}
	}

	static async requestPayout(req: Request, res: Response): Promise<void> {
		try {
			if (!req.user) {
				res.status(401).json({ status: "error", message: "Unauthorized" });
				return;
			}

			const body = req.body as Record<string, unknown>;
			const milestoneId =
				typeof body.milestoneId === "string" ? body.milestoneId : "";
			const bankName = typeof body.bankName === "string" ? body.bankName : "";
			const accountName =
				typeof body.accountName === "string" ? body.accountName : "";
			const accountNumber =
				typeof body.accountNumber === "string" ? body.accountNumber : "";
			const bankBranch =
				typeof body.bankBranch === "string" ? body.bankBranch : undefined;
			const notes = typeof body.notes === "string" ? body.notes : undefined;

			if (!milestoneId || !bankName || !accountName || !accountNumber) {
				res.status(400).json({
					status: "error",
					message:
						"milestoneId, bankName, accountName and accountNumber are required",
				});
				return;
			}

			const payout = await FinanceService.requestPayout({
				entrepreneurId: req.user._id.toString(),
				milestoneId,
				bankName,
				accountName,
				accountNumber,
				bankBranch,
				notes,
			});

			res.status(200).json({ status: "success", payout });
		} catch (error) {
			console.error("Request payout error:", error);
			res.status(500).json({
				status: "error",
				message:
					error instanceof Error
						? error.message
						: "Failed to create payout request",
			});
		}
	}

	static async getPayoutRequests(req: Request, res: Response): Promise<void> {
		try {
			const requests = await FinanceService.listPayoutRequests();
			res.status(200).json({ status: "success", requests });
		} catch (error) {
			console.error("Get payout requests error:", error);
			res
				.status(500)
				.json({ status: "error", message: "Failed to fetch payout requests" });
		}
	}

	static async getPayoutRequestDetail(
		req: Request,
		res: Response,
	): Promise<void> {
		try {
			const id = req.params.id;
			const reveal = req.query.reveal === "true";
			const detail = await FinanceService.getPayoutRequestDetail(id, reveal);

			// If reveal was requested, record an audit entry with actor info
			if (reveal) {
				try {
					await AuditLog.create({
						actorId: req.user?._id ?? null,
						actorRole: req.user?.role ?? null,
						action: "reveal_account_number",
						resourceType: "PayoutRequest",
						resourceId: id,
						details: {
							ip: req.ip,
							userAgent: req.headers["user-agent"] ?? null,
						},
					});
				} catch (auditErr) {
					console.error(
						"Failed to write audit log for reveal in controller:",
						auditErr,
					);
				}
			}
			res.status(200).json({ status: "success", detail });
		} catch (error) {
			console.error("Get payout request detail error:", error);
			res.status(500).json({
				status: "error",
				message: "Failed to fetch payout request detail",
			});
		}
	}

	static async processPayoutRequest(
		req: Request,
		res: Response,
	): Promise<void> {
		try {
			const id = req.params.id;
			const action =
				typeof req.body?.action === "string" ? req.body.action : "";
			const notes =
				typeof req.body?.notes === "string" ? req.body.notes : undefined;
			const disburse = req.body?.disburse === true;
			if (!id || (action !== "approve" && action !== "reject")) {
				res.status(400).json({ status: "error", message: "Invalid request" });
				return;
			}

			const result = await FinanceService.processPayoutRequest({
				payoutRequestId: id,
				action: action as "approve" | "reject",
				adminId: req.user?._id?.toString() ?? "",
				notes,
			});

			let disburseResult = null;
			if (action === "approve" && disburse) {
				// attempt to disburse the milestone immediately
				try {
					const milestoneId =
						(result as any).milestoneId?._id || (result as any).milestoneId;
					disburseResult = await FinanceService.disburseMilestone({
						milestoneId: milestoneId.toString(),
						paymentReference: `PR-${result._id}`,
					});
				} catch (err) {
					console.error("Immediate disbursement failed:", err);
				}
			}

			res.status(200).json({ status: "success", result, disburseResult });
		} catch (error) {
			console.error("Process payout request error:", error);
			res.status(500).json({
				status: "error",
				message:
					error instanceof Error
						? error.message
						: "Failed to process payout request",
			});
		}
	}
}
