import { type Document, model, Schema, type Types } from "mongoose";

export type DayOfWeek =
	| "monday"
	| "tuesday"
	| "wednesday"
	| "thursday"
	| "friday"
	| "saturday"
	| "sunday";

export interface IAvailabilitySlot {
	day: DayOfWeek;
	startTime: string; // "09:00" (HH:mm, 24-hr)
	endTime: string; // "17:00"
}

export interface IAvailability extends Document {
	userId: Types.ObjectId;
	timezone: string;
	slots: IAvailabilitySlot[];
	isPublic: boolean;
	createdAt: Date;
	updatedAt: Date;
}

const AvailabilitySlotSchema = new Schema<IAvailabilitySlot>(
	{
		day: {
			type: String,
			enum: [
				"monday",
				"tuesday",
				"wednesday",
				"thursday",
				"friday",
				"saturday",
				"sunday",
			] satisfies DayOfWeek[],
			required: true,
		},
		startTime: {
			type: String,
			required: true,
			match: /^([01]\d|2[0-3]):[0-5]\d$/,
		},
		endTime: {
			type: String,
			required: true,
			match: /^([01]\d|2[0-3]):[0-5]\d$/,
		},
	},
	{ _id: false },
);

const AvailabilitySchema = new Schema<IAvailability>(
	{
		userId: {
			type: Schema.Types.ObjectId,
			ref: "User",
			required: true,
			unique: true,
			index: true,
		},
		timezone: {
			type: String,
			default: "Africa/Addis_Ababa",
			trim: true,
		},
		slots: {
			type: [AvailabilitySlotSchema],
			default: [],
		},
		isPublic: {
			type: Boolean,
			default: true,
		},
	},
	{ timestamps: true },
);

export const Availability = model<IAvailability>(
	"Availability",
	AvailabilitySchema,
);
