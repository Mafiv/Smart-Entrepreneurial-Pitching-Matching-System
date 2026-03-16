import { type Request, type Response, Router } from "express";
import { authenticate, authorize } from "../middleware/auth";
import { EntrepreneurProfile } from "../models/EntrepreneurProfile";
import { InvestorProfile } from "../models/InvestorProfile";
import { User } from "../models/User";

const router = Router();

/**
 * GET /api/admin/users/:userId/profile
 * Admin view of a specific user's complete profile and KYC data
 */
router.get(
	"/users/:userId/profile",
	authenticate,
	authorize("admin"),
	async (req: Request, res: Response): Promise<void> => {
		try {
			const user = await User.findById(req.params.userId);

			if (!user) {
				res.status(404).json({ status: "error", message: "User not found" });
				return;
			}

			let profile = null;
			if (user.role === "entrepreneur") {
				profile = await EntrepreneurProfile.findOne({ userId: user._id });
			} else if (user.role === "investor") {
				profile = await InvestorProfile.findOne({ userId: user._id });
			}

			res.status(200).json({
				status: "success",
				user: {
					id: user._id,
					email: user.email,
					fullName: user.fullName,
					role: user.role,
					status: user.status,
				},
				profile: profile || {},
			});
		} catch (error) {
			console.error("Fetch profile for admin error:", error);
			res
				.status(500)
				.json({ status: "error", message: "Failed to fetch user profile" });
		}
	},
);

export default router;
