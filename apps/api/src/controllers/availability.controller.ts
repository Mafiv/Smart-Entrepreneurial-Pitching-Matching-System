import type { Request, Response } from "express";
import { AvailabilityService } from "../services/availability.service";

const handleAvailabilityError = (
	res: Response,
	error: unknown,
	fallback: string,
) => {
	if (AvailabilityService.isServiceError(error)) {
		res
			.status(error.statusCode)
			.json({ status: "error", message: error.message });
		return;
	}

	console.error(fallback, error);
	res.status(500).json({ status: "error", message: fallback });
};

export class AvailabilityController {
	/** GET /availability — get my availability */
	static async getMine(req: Request, res: Response): Promise<void> {
		try {
			if (!req.user) {
				res.status(401).json({ status: "error", message: "Unauthorized" });
				return;
			}

			const availability = await AvailabilityService.getForUser(
				req.user._id.toString(),
			);
			res.status(200).json({ status: "success", availability });
		} catch (error) {
			handleAvailabilityError(res, error, "Failed to fetch availability");
		}
	}

	/** PUT /availability — replace my availability slots */
	static async updateMine(req: Request, res: Response): Promise<void> {
		try {
			if (!req.user) {
				res.status(401).json({ status: "error", message: "Unauthorized" });
				return;
			}

			const availability = await AvailabilityService.updateSlots({
				userId: req.user._id.toString(),
				slots: req.body.slots ?? [],
				timezone: req.body.timezone,
				isPublic: req.body.isPublic,
			});

			res.status(200).json({ status: "success", availability });
		} catch (error) {
			handleAvailabilityError(res, error, "Failed to update availability");
		}
	}

	/** GET /availability/user/:userId — view another user's public availability */
	static async getPublic(req: Request, res: Response): Promise<void> {
		try {
			if (!req.user) {
				res.status(401).json({ status: "error", message: "Unauthorized" });
				return;
			}

			const availability = await AvailabilityService.getPublicForUser(
				req.params.userId,
			);

			res.status(200).json({ status: "success", availability });
		} catch (error) {
			handleAvailabilityError(res, error, "Failed to fetch user availability");
		}
	}
}
