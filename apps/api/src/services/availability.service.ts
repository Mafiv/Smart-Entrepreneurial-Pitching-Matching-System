import {
	Availability,
	type DayOfWeek,
	type IAvailabilitySlot,
} from "../models/Availability";

class AvailabilityServiceError extends Error {
	statusCode: number;

	constructor(message: string, statusCode: number) {
		super(message);
		this.name = "AvailabilityServiceError";
		this.statusCode = statusCode;
	}
}

const VALID_DAYS: DayOfWeek[] = [
	"monday",
	"tuesday",
	"wednesday",
	"thursday",
	"friday",
	"saturday",
	"sunday",
];

const TIME_RE = /^([01]\d|2[0-3]):[0-5]\d$/;

const timeToMinutes = (t: string): number => {
	const [h, m] = t.split(":").map(Number);
	return h * 60 + m;
};

export const AvailabilityService = {
	createError(message: string, statusCode: number): AvailabilityServiceError {
		return new AvailabilityServiceError(message, statusCode);
	},

	isServiceError(error: unknown): error is AvailabilityServiceError {
		return error instanceof AvailabilityServiceError;
	},

	/** Get or initialise a user's availability document. */
	async getForUser(userId: string) {
		let availability = await Availability.findOne({ userId });
		if (!availability) {
			availability = await Availability.create({
				userId,
				slots: [],
				timezone: "Africa/Addis_Ababa",
			});
		}
		return availability;
	},

	/** Get public availability for another user (e.g. investor views entrepreneur's slots). */
	async getPublicForUser(userId: string) {
		const availability = await Availability.findOne({
			userId,
			isPublic: true,
		});
		if (!availability) {
			return { slots: [], timezone: "Africa/Addis_Ababa" };
		}
		return {
			slots: availability.slots,
			timezone: availability.timezone,
		};
	},

	/** Replace all availability slots for a user. */
	async updateSlots(payload: {
		userId: string;
		slots: IAvailabilitySlot[];
		timezone?: string;
		isPublic?: boolean;
	}) {
		// Validate each slot
		for (const slot of payload.slots) {
			if (!VALID_DAYS.includes(slot.day)) {
				throw AvailabilityService.createError(`Invalid day: ${slot.day}`, 400);
			}
			if (!TIME_RE.test(slot.startTime) || !TIME_RE.test(slot.endTime)) {
				throw AvailabilityService.createError(
					`Invalid time format. Use HH:mm (24-hour): ${slot.startTime} – ${slot.endTime}`,
					400,
				);
			}
			if (timeToMinutes(slot.startTime) >= timeToMinutes(slot.endTime)) {
				throw AvailabilityService.createError(
					`Start time must be before end time: ${slot.startTime} – ${slot.endTime}`,
					400,
				);
			}
		}

		const availability = await AvailabilityService.getForUser(payload.userId);
		availability.slots = payload.slots;
		if (payload.timezone) {
			availability.timezone = payload.timezone;
		}
		if (payload.isPublic !== undefined) {
			availability.isPublic = payload.isPublic;
		}
		await availability.save();
		return availability;
	},
};
