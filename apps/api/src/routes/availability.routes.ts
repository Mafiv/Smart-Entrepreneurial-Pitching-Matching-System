import { Router } from "express";
import { AvailabilityController } from "../controllers/availability.controller";
import { authenticate } from "../middleware/auth";

const router = Router();

/**
 * @openapi
 * /api/availability:
 *   get:
 *     tags: [Communication]
 *     summary: Get my availability slots
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User availability
 */
router.get("/", authenticate, AvailabilityController.getMine);

/**
 * @openapi
 * /api/availability:
 *   put:
 *     tags: [Communication]
 *     summary: Update my availability slots
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               timezone:
 *                 type: string
 *               isPublic:
 *                 type: boolean
 *               slots:
 *                 type: array
 *                 items:
 *                   type: object
 *                   required: [day, startTime, endTime]
 *                   properties:
 *                     day:
 *                       type: string
 *                       enum: [monday, tuesday, wednesday, thursday, friday, saturday, sunday]
 *                     startTime:
 *                       type: string
 *                       example: "09:00"
 *                     endTime:
 *                       type: string
 *                       example: "17:00"
 *     responses:
 *       200:
 *         description: Availability updated
 */
router.put("/", authenticate, AvailabilityController.updateMine);

/**
 * @openapi
 * /api/availability/user/{userId}:
 *   get:
 *     tags: [Communication]
 *     summary: View another user's public availability
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Public availability slots
 */
router.get("/user/:userId", authenticate, AvailabilityController.getPublic);

export default router;
