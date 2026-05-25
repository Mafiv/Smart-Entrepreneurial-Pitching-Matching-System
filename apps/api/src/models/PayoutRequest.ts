import { type Document, model, Schema, type Types } from "mongoose";

export type PayoutRequestStatus =
	| "requested"
	| "approved"
	| "rejected"
	| "paid";

export interface IPayoutRequest extends Document {
	entrepreneurId: Types.ObjectId;
	milestoneId: Types.ObjectId;
	amount: number;
	currency: string;
	bankName: string;
	accountName: string;
	accountNumber: string | null;
	accountNumberEncrypted?: string | null;
	accountNumberLast4?: string | null;
	bankBranch?: string | null;
	notes?: string | null;
	status: PayoutRequestStatus;
	processedBy?: Types.ObjectId | null;
	processedAt?: Date | null;
	createdAt: Date;
	updatedAt: Date;
}

const PayoutRequestSchema = new Schema<IPayoutRequest>(
	{
		entrepreneurId: {
			type: Schema.Types.ObjectId,
			ref: "User",
			required: true,
			index: true,
		},
		milestoneId: {
			type: Schema.Types.ObjectId,
			ref: "Milestone",
			required: true,
			index: true,
		},
		amount: { type: Number, required: true },
		currency: { type: String, required: true, default: "ETB" },
		bankName: { type: String, required: true },
		accountName: { type: String, required: true },
		accountNumber: { type: String, default: null },
		accountNumberEncrypted: { type: String, default: null },
		accountNumberLast4: { type: String, default: null },
		bankBranch: { type: String, default: null },
		notes: { type: Schema.Types.Mixed, default: null },
		status: {
			type: String,
			enum: ["requested", "approved", "rejected", "paid"],
			default: "requested",
		},
		processedBy: { type: Schema.Types.ObjectId, ref: "User", default: null },
		processedAt: { type: Date, default: null },
	},
	{ timestamps: true },
);

PayoutRequestSchema.index({ entrepreneurId: 1, milestoneId: 1 });

export const PayoutRequest = model<IPayoutRequest>(
	"PayoutRequest",
	PayoutRequestSchema,
);
