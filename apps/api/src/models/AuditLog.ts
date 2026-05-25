import { type Document, model, Schema, type Types } from "mongoose";

export interface IAuditLog extends Document {
	actorId?: Types.ObjectId | null; // who performed the action
	actorRole?: string | null;
	action: string;
	resourceType?: string | null;
	resourceId?: Types.ObjectId | string | null;
	details?: Record<string, unknown> | null;
	createdAt: Date;
}

const AuditLogSchema = new Schema<IAuditLog>(
	{
		actorId: { type: Schema.Types.ObjectId, ref: "User", default: null },
		actorRole: { type: String, default: null },
		action: { type: String, required: true },
		resourceType: { type: String, default: null },
		resourceId: { type: Schema.Types.Mixed, default: null },
		details: { type: Schema.Types.Mixed, default: null },
	},
	{ timestamps: { createdAt: true, updatedAt: false } },
);

AuditLogSchema.index({ actorId: 1, action: 1, createdAt: -1 });

export const AuditLog = model<IAuditLog>("AuditLog", AuditLogSchema);
