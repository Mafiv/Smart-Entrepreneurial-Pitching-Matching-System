import { Router } from "express";
import { FinanceController } from "../controllers/finance.controller";
import { authenticate, authorize } from "../middleware/auth";

const router = Router();

router.use(authenticate);

/**
 * @openapi
 * tags:
 *   - name: Finance
 *     description: Financial summaries and milestone disbursement
 */

/**
 * @openapi
 * /api/finance/investor-summary:
 *   get:
 *     tags: [Finance]
 *     summary: Get investor finance summary
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: investorId
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Investor summary fetched
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               required: [status, summary]
 *               properties:
 *                 status: { type: string, enum: [success] }
 *                 summary:
 *                   type: object
 */
router.get(
	"/investor-summary",
	authorize("investor", "admin"),
	FinanceController.getInvestorSummary,
);
/**
 * @openapi
 * /api/finance/entrepreneur-summary:
 *   get:
 *     tags: [Finance]
 *     summary: Get entrepreneur finance summary
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: entrepreneurId
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Entrepreneur summary fetched
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               required: [status, summary]
 *               properties:
 *                 status: { type: string, enum: [success] }
 *                 summary:
 *                   type: object
 */
router.get(
	"/entrepreneur-summary",
	authorize("entrepreneur", "admin"),
	FinanceController.getEntrepreneurSummary,
);
/**
 * @openapi
 * /api/finance/admin-ledger:
 *   get:
 *     tags: [Finance]
 *     summary: Get admin finance ledger summary
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Admin ledger fetched
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               required: [status, summary]
 *               properties:
 *                 status: { type: string, enum: [success] }
 *                 summary:
 *                   type: object
 */
router.get(
	"/admin-ledger",
	authorize("admin"),
	FinanceController.getAdminLedger,
);
/**
 * @openapi
 * /api/finance/disburse:
 *   post:
 *     tags: [Finance]
 *     summary: Disburse a verified milestone
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [milestoneId]
 *             properties:
 *               milestoneId:
 *                 type: string
 *               paymentReference:
 *                 type: string
 *               notes:
 *                 type: string
 *     responses:
 *       200:
 *         description: Milestone disbursed
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               required: [status, milestone]
 *               properties:
 *                 status: { type: string, enum: [success] }
 *                 milestone:
 *                   type: object
 */
router.post(
	"/disburse",
	authorize("admin"),
	FinanceController.disburseMilestone,
);

/**
 * POST /api/finance/request-payout
 * Entrepreneur requests payout for a verified milestone. Stores bank details and notifies admin.
 */
router.post(
	"/request-payout",
	authorize("entrepreneur"),
	FinanceController.requestPayout,
);

// Admin: list payout requests
router.get(
	"/payout-requests",
	authorize("admin"),
	FinanceController.getPayoutRequests,
);

// Admin: get individual payout request (detail)
router.get(
	"/payout-requests/:id",
	authorize("admin"),
	FinanceController.getPayoutRequestDetail,
);

// Admin: process a payout request (approve/reject)
router.post(
	"/payout-requests/:id/process",
	authorize("admin"),
	FinanceController.processPayoutRequest,
);

export default router;
