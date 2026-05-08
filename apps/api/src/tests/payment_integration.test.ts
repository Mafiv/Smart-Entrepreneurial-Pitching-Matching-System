import mongoose from "mongoose";
import { Milestone } from "../models/Milestone";
import { PendingPayment } from "../models/PendingPayment";
import { TransactionLog } from "../models/TransactionLog";
import { PaymentService } from "../services/payment.service";

jest.mock("../utils/chapa", () => ({
	chapa: {
		initialize: jest.fn(async () => ({
			data: { checkout_url: "https://checkout.test/chapa" },
		})),
		genTxRef: jest.fn(async () => "tx-mock-123"),
	},
}));

describe("Chapa Payment Integration Service", () => {
	const mockMilestoneId = new mongoose.Types.ObjectId();
	const mockUserId = new mongoose.Types.ObjectId();
	const mockProjectId = new mongoose.Types.ObjectId();

	beforeAll(() => {
		process.env.CHAPA_WEBHOOK_SECRET = "test_secret";
	});

	it("verifies chapa webhook signature correctly", () => {
		const body = { tx_ref: "tx-123", status: "success" };
		const crypto = require("node:crypto");
		const expectedSignature = crypto
			.createHmac("sha256", "test_secret")
			.update(JSON.stringify(body))
			.digest("hex");

		expect(PaymentService.verifyWebhookSignature(body, expectedSignature)).toBe(
			true,
		);
		expect(PaymentService.verifyWebhookSignature(body, "wrong_signature")).toBe(
			false,
		);
	});

	it("arranges payment data from a milestone", async () => {
		// Mock Milestone.findById
		const mockMilestone = {
			_id: mockMilestoneId,
			amount: 5000,
			currency: "ETB",
			submissionId: mockProjectId,
			matchResultId: new mongoose.Types.ObjectId(),
		};

		const spy = jest
			.spyOn(Milestone, "findById")
			.mockResolvedValue(mockMilestone as any);
		const pendingSpy = jest
			.spyOn(PendingPayment, "create")
			.mockResolvedValue({} as any);

		const result = await PaymentService.arrangePayment({
			type: "milestone",
			milestoneId: mockMilestoneId.toString(),
			userId: mockUserId.toString(),
			userEmail: "investor@example.com",
			userFullName: "Investor Test",
			userPhoneNumber: null,
		});

		expect(result.success).toBe(true);
		expect(result.amount).toBe(5000);
		expect(result.currency).toBe("ETB");
		expect(result.checkout_url).toBe("https://checkout.test/chapa");
		expect(result.tx_ref).toBe("tx-mock-123");

		spy.mockRestore();
		pendingSpy.mockRestore();
	});

	it("processes successful payment and updates milestone", async () => {
		const tx_ref = "tx-success-123";

		// 1. Mock PendingPayment.findOne
		const mockPending = {
			tx_ref,
			status: "pending",
			milestoneId: mockMilestoneId,
			userId: mockUserId,
			save: jest.fn().mockResolvedValue(true),
		};
		const pendingSpy = jest
			.spyOn(PendingPayment, "findOne")
			.mockResolvedValue(mockPending as any);

		// 2. Mock Milestone.findById
		const mockMilestone = {
			_id: mockMilestoneId,
			status: "submitted_for_review",
			projectId: mockProjectId,
			amount: 5000,
			currency: "ETB",
			paymentReference: null as string | null,
			save: jest.fn().mockResolvedValue(true),
		};
		const milestoneSpy = jest
			.spyOn(Milestone, "findById")
			.mockResolvedValue(mockMilestone as any);

		// 3. Mock TransactionLog.create
		const logSpy = jest
			.spyOn(TransactionLog, "create")
			.mockResolvedValue({} as any);

		// Execute
		const result = await PaymentService.processSuccessfulPayment(tx_ref, {
			status: "success",
		});

		expect(result.success).toBe(true);
		expect(mockPending.status).toBe("completed");
		expect(mockMilestone.status).toBe("verified_paid");
		expect(mockMilestone.paymentReference).toBe(tx_ref);
		expect(logSpy).toHaveBeenCalled();

		pendingSpy.mockRestore();
		milestoneSpy.mockRestore();
		logSpy.mockRestore();
	});

	it("prevents duplicate processing of the same transaction", async () => {
		const tx_ref = "tx-already-done";

		const mockPending = {
			tx_ref,
			status: "completed",
		};
		const spy = jest
			.spyOn(PendingPayment, "findOne")
			.mockResolvedValue(mockPending as any);

		const result = await PaymentService.processSuccessfulPayment(tx_ref, {});
		expect(result.alreadyProcessed).toBe(true);

		spy.mockRestore();
	});
});
