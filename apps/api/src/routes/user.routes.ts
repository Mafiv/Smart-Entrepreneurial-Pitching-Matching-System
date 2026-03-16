import { type Request, type Response, Router } from "express";
import { authenticate } from "../middleware/auth";
import { EntrepreneurProfile } from "../models/EntrepreneurProfile";
import { InvestorProfile } from "../models/InvestorProfile";
import { User } from "../models/User";

const router = Router();

/**
 * GET /api/users/me/profile
 * Get the current user's profile and KYC status
 */
router.get(
	"/me/profile",
	authenticate,
	async (req: Request, res: Response): Promise<void> => {
		try {
			if (!req.user) {
				res.status(404).json({ status: "error", message: "User not found" });
				return;
			}

			let profile = null;
			if (req.user.role === "entrepreneur") {
				profile = await EntrepreneurProfile.findOne({ userId: req.user._id });
			} else if (req.user.role === "investor") {
				profile = await InvestorProfile.findOne({ userId: req.user._id });
			}

			res.status(200).json({
				status: "success",
				user: {
					id: req.user._id,
					email: req.user.email,
					fullName: req.user.fullName,
					role: req.user.role,
					status: req.user.status,
				},
				profile: profile || {},
			});
		} catch (error) {
			console.error("Fetch profile error:", error);
			res
				.status(500)
				.json({ status: "error", message: "Failed to fetch profile" });
		}
	},
);

/**
 * PUT /api/users/me/profile
 * Update profile and submit KYC documents
 */
router.put(
	"/me/profile",
	authenticate,
	async (req: Request, res: Response): Promise<void> => {
		try {
			if (!req.user) {
				res.status(404).json({ status: "error", message: "User not found" });
				return;
			}

			const role = req.user.role;
			const updateData = req.body;
			let updatedProfile = null;
			let isKycComplete = false;

			if (role === "entrepreneur") {
				updatedProfile = await EntrepreneurProfile.findOneAndUpdate(
					{ userId: req.user._id },
					{ $set: updateData },
					{ new: true, upsert: true },
				);

				if (updatedProfile.businessLicenseUrl && updatedProfile.tinNumber && updatedProfile.nationalIdUrl) {
					isKycComplete = true;
				}
			} else if (role === "investor") {
				updatedProfile = await InvestorProfile.findOneAndUpdate(
					{ userId: req.user._id },
					{ $set: updateData },
					{ new: true, upsert: true },
				);

				if (updatedProfile.accreditationDocumentUrl && updatedProfile.nationalIdUrl) {
					isKycComplete = true;
				}
			} else {
				res
					.status(400)
					.json({ status: "error", message: "Invalid role for profile" });
				return;
			}

			// Move status to pending if KYC info provided and user is currently unverified
			if (isKycComplete && req.user.status === "unverified") {
				await User.findByIdAndUpdate(req.user._id, { status: "pending" });
				req.user.status = "pending";
			}

			res.status(200).json({
				status: "success",
				message: "Profile updated successfully",
				user: {
					id: req.user._id,
					role: req.user.role,
					status: req.user.status,
				},
				profile: updatedProfile,
			});
		} catch (error) {
			console.error("Update profile error:", error);
			res
				.status(500)
				.json({ status: "error", message: "Failed to update profile" });
		}
	},
);

/**
 * PATCH /api/users/me
 * Update basic user info (fullName only — role/status/adminLevel are protected)
 */
router.patch(
	"/me",
	authenticate,
	async (req: Request, res: Response): Promise<void> => {
		try {
			if (!req.user) {
				res.status(404).json({ status: "error", message: "User not found" });
				return;
			}

			const { fullName } = req.body;
			const updateData: Record<string, unknown> = {};

			if (fullName && typeof fullName === "string" && fullName.trim().length >= 2) {
				updateData.fullName = fullName.trim();
			}

			if (Object.keys(updateData).length === 0) {
				res.status(400).json({ status: "error", message: "No valid fields to update" });
				return;
			}

			const updatedUser = await User.findByIdAndUpdate(
				req.user._id,
				{ $set: updateData },
				{ new: true },
			);

			if (!updatedUser) {
				res.status(404).json({ status: "error", message: "User not found" });
				return;
			}

			res.status(200).json({
				status: "success",
				message: "Profile updated successfully",
				user: {
					id: updatedUser._id,
					fullName: updatedUser.fullName,
					email: updatedUser.email,
					role: updatedUser.role,
					status: updatedUser.status,
				},
			});
		} catch (error) {
			console.error("Update user error:", error);
			res.status(500).json({ status: "error", message: "Failed to update profile" });
		}
	},
);

export default router;
