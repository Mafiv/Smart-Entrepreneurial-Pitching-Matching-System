import { Controller, Get, Route, Tags } from "tsoa";

@Route("health")
@Tags("System")
export class HealthController extends Controller {
	/**
	 * Health Check
	 * @summary Checks if the API is up and running
	 * @returns {status: string}
	 */
	@Get("/")
	public async getHealth(): Promise<{ status: string }> {
		return { status: "ok" };
	}
}
