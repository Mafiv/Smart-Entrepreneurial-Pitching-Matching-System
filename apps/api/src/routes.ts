/* tslint:disable */
/* eslint-disable */
// WARNING: This file was auto-generated with tsoa. Please do not modify it. Re-run tsoa to re-generate this file: https://github.com/lukeautry/tsoa
import type { TsoaRoute } from "@tsoa/runtime";
import { ExpressTemplateService, fetchMiddlewares } from "@tsoa/runtime";
// @ts-expect-error - no great way to install types from subpackage
import type {
	Request as ExRequest,
	Response as ExResponse,
	RequestHandler,
	Router,
} from "express";
// WARNING: This file was auto-generated with tsoa. Please do not modify it. Re-run tsoa to re-generate this file: https://github.com/lukeautry/tsoa
import { HealthController } from "./controllers/health.controller";
import { expressAuthentication } from "./middleware/auth";

const expressAuthenticationRecasted = expressAuthentication as (
	req: ExRequest,
	securityName: string,
	scopes?: string[],
	res?: ExResponse,
) => Promise<unknown>;

// WARNING: This file was auto-generated with tsoa. Please do not modify it. Re-run tsoa to re-generate this file: https://github.com/lukeautry/tsoa

const models: TsoaRoute.Models = {};
const templateService = new ExpressTemplateService(models, {
	noImplicitAdditionalProperties: "throw-on-extras",
	bodyCoercion: true,
});

// WARNING: This file was auto-generated with tsoa. Please do not modify it. Re-run tsoa to re-generate this file: https://github.com/lukeautry/tsoa

export function RegisterRoutes(app: Router) {
	// ###########################################################################################################
	//  NOTE: If you do not see routes for all of your controllers in this file, then you might not have informed tsoa of where to look
	//      Please look into the "controllerPathGlobs" config option described in the readme: https://github.com/lukeautry/tsoa
	// ###########################################################################################################

	const argsHealthController_getHealth: Record<
		string,
		TsoaRoute.ParameterSchema
	> = {};
	app.get(
		"/health",
		...fetchMiddlewares<RequestHandler>(HealthController),
		...fetchMiddlewares<RequestHandler>(HealthController.prototype.getHealth),

		async function HealthController_getHealth(
			request: ExRequest,
			response: ExResponse,
			next: unknown,
		) {
			// WARNING: This file was auto-generated with tsoa. Please do not modify it. Re-run tsoa to re-generate this file: https://github.com/lukeautry/tsoa

			let validatedArgs: unknown[] = [];
			try {
				validatedArgs = templateService.getValidatedArgs({
					args: argsHealthController_getHealth,
					request,
					response,
				});

				const controller = new HealthController();

				await templateService.apiHandler({
					methodName: "getHealth",
					controller,
					response,
					next,
					validatedArgs,
					successStatus: undefined,
				});
			} catch (err) {
				return next(err);
			}
		},
	);
	// WARNING: This file was auto-generated with tsoa. Please do not modify it. Re-run tsoa to re-generate this file: https://github.com/lukeautry/tsoa

	// WARNING: This file was auto-generated with tsoa. Please do not modify it. Re-run tsoa to re-generate this file: https://github.com/lukeautry/tsoa

	// WARNING: This file was auto-generated with tsoa. Please do not modify it. Re-run tsoa to re-generate this file: https://github.com/lukeautry/tsoa
}

// WARNING: This file was auto-generated with tsoa. Please do not modify it. Re-run tsoa to re-generate this file: https://github.com/lukeautry/tsoa
