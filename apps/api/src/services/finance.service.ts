import mongoose from "mongoose";
import { LedgerEntry } from "../models/LedgerEntry";
import { Milestone } from "../models/Milestone";
import { PayoutRequest } from "../models/PayoutRequest";
import { PendingPayment } from "../models/PendingPayment";
import { User } from "../models/User";
import { decryptText, encryptText } from "../utils/crypto";
import { NotificationService } from "./notification.service";
import { sendEmail } from "./sendgrid.service";

const getPopulatedSubmission = (value: unknown) => {
	if (!value || typeof value !== "object") {
		return null;
	}

	if (!("_id" in value)) {
		return null;
	}

	const submissionId = (
		value as { _id: { toString(): string } }
	)._id.toString();
	const title =
		"title" in value && typeof value.title === "string"
			? value.title
			: "Unknown Project";

	return { submissionId, title };
};

export const FinanceService = {
	/**
	 * Get financial summary for an investor
	 */
	async getInvestorSummary(investorId: string) {
		const investorObjectId = new mongoose.Types.ObjectId(investorId);

		const ledgerEntries = await LedgerEntry.find({
			fromUserId: investorObjectId,
		})
			.populate("milestoneId", "title")
			.populate("submissionId", "title")
			.sort({ createdAt: -1 });

		const stats = ledgerEntries.reduce(
			(acc, entry) => {
				if (entry.type === "escrow_hold" && entry.status === "completed") {
					acc.totalCommitted += entry.amount;
				} else if (
					entry.type === "escrow_release" &&
					entry.status === "completed"
				) {
					acc.totalReleased += entry.amount;
				} else if (
					entry.type === "platform_fee" &&
					entry.status === "completed"
				) {
					acc.platformFeesPaid += entry.amount;
				}
				return acc;
			},
			{ totalCommitted: 0, totalReleased: 0, platformFeesPaid: 0 },
		);

		// Group by project
		const perProjectMap = new Map<
			string,
			{
				title: string;
				milestoneCount: number;
				paidMilestones: number;
				totalInvested: number;
				escrowStatus: "none";
			}
		>();
		for (const entry of ledgerEntries) {
			if (!entry.submissionId) continue;
			const sub = getPopulatedSubmission(entry.submissionId);
			if (!sub) continue;
			const subId = sub.submissionId;
			if (!perProjectMap.has(subId)) {
				perProjectMap.set(subId, {
					title: sub.title,
					milestoneCount: 0,
					paidMilestones: 0,
					totalInvested: 0,
					escrowStatus: "none",
				});
			}
			const project = perProjectMap.get(subId);
			if (!project) continue;
			if (entry.type === "escrow_hold") {
				project.totalInvested += entry.amount;
			}
		}

		return {
			...stats,
			perProject: Array.from(perProjectMap.values()),
			recentLedger: ledgerEntries.slice(0, 20),
		};
	},

	/**
	 * Get financial summary for an entrepreneur
	 */
	async getEntrepreneurSummary(entrepreneurId: string) {
		const entrepreneurObjectId = new mongoose.Types.ObjectId(entrepreneurId);

		const payoutEntries = await LedgerEntry.find({
			toUserId: entrepreneurObjectId,
			type: "milestone_payout",
		})
			.populate("milestoneId", "title")
			.populate("submissionId", "title")
			.sort({ createdAt: -1 });

		const totalReceived = payoutEntries
			.filter((e) => e.status === "completed")
			.reduce((sum, e) => sum + e.amount, 0);

		// Fetch milestones awaiting disbursement
		const pendingMilestones = await Milestone.find({
			entrepreneurId: entrepreneurObjectId,
			escrowStatus: "held",
			status: "verified_paid",
		}).populate("submissionId", "title");

		const pendingRelease = pendingMilestones.reduce(
			(sum, m) => sum + m.amount,
			0,
		);

		return {
			totalReceived,
			pendingRelease,
			recentPayouts: payoutEntries.slice(0, 20).map((e) => ({
				_id: e._id,
				transactionId: e.transactionId,
				amount: e.amount,
				status: e.status,
				description: e.description,
				occurredAt: e.occurredAt,
				milestoneId: e.milestoneId,
			})),
			pendingMilestones: pendingMilestones.map((m) => ({
				id: m._id,
				title: m.title,
				amount: m.amount,
				projectTitle: getPopulatedSubmission(m.submissionId)?.title,
			})),
		};
	},

	/**
	 * Get platform-wide financial summary for admin
	 */
	async getAdminLedger() {
		const allEntries = await LedgerEntry.find()
			.sort({ createdAt: -1 })
			.limit(100);

		const stats = await LedgerEntry.aggregate([
			{
				$group: {
					_id: "$type",
					total: { $sum: "$amount" },
				},
			},
		]);

		const statMap = stats.reduce(
			(acc: Record<string, number>, curr: { _id: string; total: number }) => {
				acc[curr._id] = curr.total;
				return acc;
			},
			{},
		);

		const totalEscrowHeld =
			(statMap.escrow_hold || 0) - (statMap.escrow_release || 0);
		const totalDisbursed = statMap.milestone_payout || 0;
		const totalFees = statMap.platform_fee || 0;

		const awaitingDisbursement = await Milestone.find({
			escrowStatus: "held",
			status: "verified_paid",
		})
			.populate("entrepreneurId", "fullName email")
			.populate("investorId", "fullName email")
			.populate("submissionId", "title");

		const pendingChapa = await PendingPayment.find({
			status: "pending",
			createdAt: { $lt: new Date(Date.now() - 24 * 60 * 60 * 1000) },
		}).populate("userId", "fullName email");

		return {
			totalEscrowHeld,
			totalDisbursed,
			totalFees,
			ledger: allEntries,
			awaitingDisbursement,
			pendingChapa,
		};
	},

	/**
	 * Entrepreneur requests payout for a verified milestone.
	 */
	async requestPayout(payload: {
		entrepreneurId: string;
		milestoneId: string;
		bankName: string;
		accountName: string;
		accountNumber: string;
		bankBranch?: string;
		notes?: string;
	}) {
		const milestone = await Milestone.findById(payload.milestoneId);
		if (!milestone) throw new Error("Milestone not found");

		if (milestone.entrepreneurId?.toString() !== payload.entrepreneurId) {
			throw new Error("Not authorized to request payout for this milestone");
		}

		if (
			milestone.escrowStatus !== "held" ||
			milestone.status !== "verified_paid"
		) {
			throw new Error("Milestone is not eligible for payout request");
		}

		// Prevent duplicate active requests
		const existing = await PayoutRequest.findOne({
			milestoneId: milestone._id,
			status: "requested",
		});
		if (existing) {
			throw new Error("A payout request for this milestone is already pending");
		}

		const encrypted = encryptText(payload.accountNumber);
		const last4 = payload.accountNumber.slice(-4);
		const pr = await PayoutRequest.create({
			entrepreneurId: payload.entrepreneurId,
			milestoneId: milestone._id,
			amount: milestone.amount,
			currency: milestone.currency || "ETB",
			bankName: payload.bankName,
			accountName: payload.accountName,
			accountNumber: null,
			accountNumberEncrypted: encrypted,
			accountNumberLast4: last4,
			bankBranch: payload.bankBranch ?? null,
			notes: payload.notes ?? null,
			status: "requested",
		});

		// Notify entrepreneur (confirmation)
		try {
			await NotificationService.createNotification({
				userId: payload.entrepreneurId,
				type: "milestone_updated",
				title: "Payout requested",
				body: `You have requested payout for milestone: ${milestone.title}. An admin will review this request.`,
				metadata: { milestoneId: milestone._id, payoutRequestId: pr._id },
			});

			// send confirmation email
			const entrepreneur = await User.findById(payload.entrepreneurId).select(
				"email fullName",
			);
			if (entrepreneur?.email) {
				await sendEmail({
					to: entrepreneur.email,
					subject: "Payout request received",
					html: `<p>Dear ${entrepreneur.fullName ?? "user"},</p><p>Your payout request for milestone <strong>${milestone.title}</strong> has been received and is awaiting admin review.</p>`,
				});
			}
		} catch (err) {
			console.error("Failed to send confirmation notification:", err);
		}

		// Notify admins
		try {
			const admins = await User.find({ role: "admin", isActive: true }).limit(
				20,
			);
			for (const admin of admins) {
				await NotificationService.createNotification({
					userId: admin._id.toString(),
					type: "admin_action",
					title: "Payout request pending",
					body: `Payout request for milestone "${milestone.title}" is awaiting review.`,
					metadata: { payoutRequestId: pr._id, milestoneId: milestone._id },
				});

				// send email to admin
				if (admin.email) {
					await sendEmail({
						to: admin.email,
						subject: "Payout request pending review",
						html: `<p>Payout request for milestone <strong>${milestone.title}</strong> is awaiting review. Payout request id: ${pr._id}</p>`,
					});
				}
			}
		} catch (err) {
			console.error("Failed to notify admins of payout request:", err);
		}

		return pr;
	},

	/**
	 * List payout requests for admin overview
	 */
	async listPayoutRequests() {
		const requests = await PayoutRequest.find()
			.sort({ createdAt: -1 })
			.populate("entrepreneurId", "fullName email")
			.populate("milestoneId", "title amount currency submissionId");
		// map to include masked account number
		return requests.map((r) => {
			const obj = r.toObject ? r.toObject() : r;
			return {
				...obj,
				accountNumberMasked: obj.accountNumberLast4
					? `****${obj.accountNumberLast4}`
					: null,
			};
		});
	},

	/**
	 * Process (approve/reject) a payout request
	 */
	async processPayoutRequest(payload: {
		payoutRequestId: string;
		action: "approve" | "reject";
		adminId: string;
		notes?: string;
	}) {
		const pr = await PayoutRequest.findById(payload.payoutRequestId)
			.populate("entrepreneurId", "fullName email")
			.populate("milestoneId", "title amount");

		const milestoneTitle = (pr.milestoneId as any)?.title ?? "";

		if (!pr) throw new Error("Payout request not found");
		if (pr.status !== "requested")
			throw new Error("Payout request is not pending");

		pr.status = payload.action === "approve" ? "approved" : "rejected";
		pr.processedBy = new mongoose.Types.ObjectId(payload.adminId);
		pr.processedAt = new Date();
		await pr.save();

		// Notify entrepreneur
		try {
			const entrepreneur = pr.entrepreneurId as {
				fullName?: string;
				email?: string;
			};
			await NotificationService.createNotification({
				userId:
					(pr.entrepreneurId as any)._id?.toString() ??
					pr.entrepreneurId.toString(),
				type: "milestone_updated",
				title:
					payload.action === "approve" ? "Payout approved" : "Payout rejected",
				body:
					payload.action === "approve"
						? `Your payout request for "${milestoneTitle}" has been approved by admin.`
						: `Your payout request for "${milestoneTitle}" was rejected. ${payload.notes ?? ""}`,
				metadata: { payoutRequestId: pr._id, milestoneId: pr.milestoneId },
			});

			// Send email to entrepreneur
			if (entrepreneur?.email) {
				await sendEmail({
					to: entrepreneur.email,
					subject:
						payload.action === "approve"
							? "Payout request approved"
							: "Payout request rejected",
					html: `<p>Dear ${entrepreneur.fullName ?? "user"},</p><p>Your payout request for milestone <strong>${milestoneTitle}</strong> has been <strong>${payload.action}</strong>.</p><p>${payload.notes ?? ""}</p>`,
				});
			}
		} catch (err) {
			console.error(
				"Failed to notify entrepreneur about payout processing:",
				err,
			);
		}

		// Notify admin actors (confirmation)
		try {
			const admins = await User.find({ role: "admin", isActive: true }).limit(
				10,
			);
			for (const admin of admins) {
				await NotificationService.createNotification({
					userId: admin._id.toString(),
					type: "admin_action",
					title: `Payout request ${payload.action}`,
					body: `Payout request for ${(pr.milestoneId as any).title} was ${payload.action} by admin.`,
					metadata: { payoutRequestId: pr._id },
				});
			}
		} catch (err) {
			console.error(
				"Failed to notify admins after processing payout request:",
				err,
			);
		}

		return pr;
	},

	/**
	 * Get payout request detail; if reveal=true, decrypt account number.
	 */
	async getPayoutRequestDetail(payoutRequestId: string, reveal = false) {
		const pr = await PayoutRequest.findById(payoutRequestId)
			.populate("entrepreneurId", "fullName email")
			.populate("milestoneId", "title amount");
		if (!pr) throw new Error("Payout request not found");
		const obj = pr.toObject ? pr.toObject() : pr;
		const detail: any = { ...obj };
		detail.accountNumberMasked = obj.accountNumberLast4
			? `****${obj.accountNumberLast4}`
			: null;
		if (reveal && obj.accountNumberEncrypted) {
			try {
				detail.accountNumber = decryptText(obj.accountNumberEncrypted);
			} catch (err) {
				console.error("Failed to decrypt account number:", err);
			}
		}
		return detail;
	},

	/**
	 * Disburse funds for a milestone
	 */
	async disburseMilestone(payload: {
		milestoneId: string;
		paymentReference?: string;
		notes?: string;
	}) {
		const session = await mongoose.startSession();
		session.startTransaction();

		try {
			const milestone = await Milestone.findById(payload.milestoneId).session(
				session,
			);

			if (!milestone) throw new Error("Milestone not found");
			if (
				milestone.escrowStatus !== "held" ||
				milestone.status !== "verified_paid"
			) {
				throw new Error("Milestone is not eligible for disbursement");
			}

			// Update milestone
			milestone.escrowStatus = "released";
			milestone.paymentReleasedAt = new Date();
			milestone.paymentReference = payload.paymentReference;
			await milestone.save({ session });

			// Ledger: Release from Escrow
			await LedgerEntry.create(
				[
					{
						transactionId: `REL-${milestone._id}-${Date.now()}`,
						type: "escrow_release",
						status: "completed",
						amount: milestone.amount,
						currency: milestone.currency,
						toUserId: milestone.entrepreneurId,
						fromUserId: milestone.investorId,
						milestoneId: milestone._id,
						submissionId: milestone.submissionId,
						description: `Escrow release for milestone: ${milestone.title}`,
						occurredAt: new Date(),
					},
				],
				{ session },
			);

			// Ledger: Milestone Payout to Entrepreneur
			await LedgerEntry.create(
				[
					{
						transactionId: `PAY-${milestone._id}-${Date.now()}`,
						type: "milestone_payout",
						status: "completed",
						amount: milestone.amount,
						currency: milestone.currency,
						toUserId: milestone.entrepreneurId,
						milestoneId: milestone._id,
						submissionId: milestone.submissionId,
						description: `Payout for milestone: ${milestone.title}`,
						occurredAt: new Date(),
					},
				],
				{ session },
			);

			await session.commitTransaction();
			return milestone;
		} catch (error) {
			await session.abortTransaction();
			throw error;
		} finally {
			session.endSession();
		}
	},
};
