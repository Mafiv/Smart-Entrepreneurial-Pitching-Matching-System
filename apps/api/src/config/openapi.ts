import path from "node:path";
import swaggerJsdoc from "swagger-jsdoc";

const swaggerDefinition = {
	openapi: "3.0.3",
	info: {
		title: "SEPMS API",
		version: "1.0.0",
		description:
			"Smart Entrepreneurial Pitching & Matching System API documentation.",
	},
	tags: [
		{ name: "System", description: "Health, stats, and system endpoints" },
		{ name: "Auth", description: "Authentication and account management" },
	],
	servers: [
		{
			url: process.env.API_BASE_URL || "http://localhost:5000",
			description: process.env.API_BASE_URL
				? "Production server"
				: "Local development server",
		},
	],
	components: {
		securitySchemes: {
			bearerAuth: {
				type: "http",
				scheme: "bearer",
				bearerFormat: "JWT",
			},
		},
		schemas: {
			AuthUser: {
				type: "object",
				required: ["_id", "uid", "email", "displayName", "role", "status"],
				properties: {
					_id: { type: "string" },
					uid: { type: "string" },
					email: { type: "string", format: "email" },
					displayName: { type: "string" },
					role: { type: "string", enum: ["admin", "entrepreneur", "investor"] },
					adminLevel: { type: "string", nullable: true },
					status: { type: "string" },
					photoURL: { type: "string", nullable: true },
					phoneNumber: { type: "string", nullable: true },
					phoneVerified: { type: "boolean" },
					emailVerified: { type: "boolean" },
				},
			},
			AuthUserEnvelope: {
				type: "object",
				required: ["status", "message", "user"],
				properties: {
					status: { type: "string", enum: ["success"] },
					message: { type: "string" },
					user: { $ref: "#/components/schemas/AuthUser" },
				},
			},
			AuthUserEnvelopeWithKycReason: {
				type: "object",
				required: ["status", "user"],
				properties: {
					status: { type: "string", enum: ["success"] },
					message: { type: "string" },
					user: {
						allOf: [
							{ $ref: "#/components/schemas/AuthUser" },
							{
								type: "object",
								properties: {
									kycRejectionReason: { type: "string", nullable: true },
								},
							},
						],
					},
				},
			},
			DocumentType: {
				type: "string",
				enum: ["pitch_deck", "financial_model", "legal", "other"],
				description: "Supported document categories for uploads",
			},
			InvestmentStage: {
				type: "string",
				enum: ["idea", "mvp", "early-revenue", "scaling"],
				description:
					"Startup maturity stage used by entrepreneur/investor profiles",
			},
			ValidationStatusResponse: {
				type: "object",
				required: ["status", "validation"],
				properties: {
					status: { type: "string", example: "success" },
					validation: {
						type: "object",
						required: ["documentId", "status"],
						properties: {
							documentId: {
								type: "string",
								example: "65f4cbf24f8d64a8d1f918a2",
							},
							status: {
								type: "string",
								enum: ["uploaded", "processing", "processed", "failed"],
							},
							confidence: {
								type: "number",
								minimum: 0,
								maximum: 1,
								nullable: true,
							},
							processingError: { type: "string", nullable: true },
							processedAt: {
								type: "string",
								format: "date-time",
								nullable: true,
							},
							updatedAt: {
								type: "string",
								format: "date-time",
								nullable: true,
							},
						},
					},
				},
			},
		},
	},
	paths: {
		"/health": {
			get: {
				tags: ["System"],
				summary: "Health check",
				responses: {
					200: {
						description: "Server is healthy",
						content: {
							"application/json": {
								schema: {
									type: "object",
									properties: { status: { type: "string", example: "ok" } },
								},
							},
						},
					},
				},
			},
		},
	},
};

const routesTs = path.resolve(process.cwd(), "src/routes/*.ts");
const routesJs = path.resolve(process.cwd(), "dist/routes/*.js");
const recommendationRoutesTs = path.resolve(
	process.cwd(),
	"src/recommendation/*.routes.ts",
);
const recommendationRoutesJs = path.resolve(
	process.cwd(),
	"dist/recommendation/*.routes.js",
);

export const openApiSpec = swaggerJsdoc({
	swaggerDefinition,
	apis: [routesTs, routesJs, recommendationRoutesTs, recommendationRoutesJs],
});
