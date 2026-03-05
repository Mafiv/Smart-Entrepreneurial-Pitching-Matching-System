import type * as express from "express";

export async function expressAuthentication(
	_request: express.Request,
	_securityName: string,
	_scopes?: string[],
): Promise<unknown> {
	// Placeholder: In a real app, you'd check JWTs or API keys here
	return Promise.resolve({ id: "123", name: "Placeholder User" });
}
