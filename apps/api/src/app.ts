import cors from "cors";
import express, {
	type NextFunction,
	type Request,
	type Response,
} from "express";
import mongoSanitize from "express-mongo-sanitize";
import rateLimit from "express-rate-limit";
import helmet from "helmet";
import swaggerUi from "swagger-ui-express";

import { RegisterRoutes } from "./routes";

const app = express();

app.use(helmet());
app.use(cors());
app.use(
	rateLimit({
		windowMs: 15 * 60 * 1000,
		max: 100,
	}),
);
app.use(mongoSanitize());
app.use(express.json({ limit: "2mb" }));
app.use(express.urlencoded({ extended: true }));

// Swagger UI
app.use("/docs", swaggerUi.serve, async (_req: Request, res: Response) => {
	return res.send(swaggerUi.generateHTML(await import("./swagger.json")));
});

// Register tsoa routes
RegisterRoutes(app);

app.use((_req: Request, res: Response) => {
	res.status(404).json({ message: "Not found" });
});

app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
	console.error("Unhandled error:", err);
	res.status(500).json({ message: "Internal server error" });
});

export default app;
