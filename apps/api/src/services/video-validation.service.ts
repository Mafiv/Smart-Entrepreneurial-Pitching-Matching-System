import { GoogleGenAI } from "@google/genai";
import { Submission } from "../models/Submission";

/**
 * Service to validate YouTube pitch videos.
 *
 * Pipeline:
 * 1. Verify the video exists via YouTube oEmbed (free, no API key).
 * 2. Run a Gemini content-policy check on the video title + description.
 * 3. Set videoStatus to "approved" or "flagged" with a reason.
 */
export class VideoValidationService {
	/**
	 * Extract the 11-character YouTube video ID from any accepted URL format.
	 */
	static extractVideoId(url: string): string | null {
		const match = url.match(
			/(?:youtu\.be\/|youtube\.com\/(?:watch\?v=|embed\/))([a-zA-Z0-9_-]{11})/,
		);
		return match?.[1] ?? null;
	}

	/**
	 * Fetch video metadata from YouTube oEmbed (free, no API key required).
	 */
	static async fetchVideoMetadata(
		url: string,
	): Promise<{ title: string; author: string } | null> {
		try {
			const oEmbedUrl = `https://www.youtube.com/oembed?url=${encodeURIComponent(url)}&format=json`;
			const res = await fetch(oEmbedUrl);
			if (!res.ok) return null;
			const data = (await res.json()) as {
				title: string;
				author_name: string;
			};
			return { title: data.title, author: data.author_name };
		} catch {
			return null;
		}
	}

	/**
	 * Run Gemini content-policy check on video metadata.
	 * Detects: contact info, external platform links, inappropriate content,
	 * attempts to connect outside the platform.
	 */
	static async checkContentPolicy(
		videoTitle: string,
		videoAuthor: string,
		pitchTitle: string,
	): Promise<{ passed: boolean; reason: string }> {
		const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
		if (!GEMINI_API_KEY) {
			console.warn(
				"[VIDEO:GEMINI] GEMINI_API_KEY not set — auto-approving video",
			);
			return { passed: true, reason: "API key not configured — auto-approved" };
		}

		try {
			const ai = new GoogleGenAI({ apiKey: GEMINI_API_KEY });

			const response = await ai.models.generateContent({
				model: "gemini-2.5-flash",
				contents: `You are a content moderator for an investment matchmaking platform called SEPMS.
Analyse this YouTube video metadata that was submitted as a pitch video for the startup pitch "${pitchTitle}".

Check for the following policy violations:
1. Phone numbers, email addresses, or social media handles in the title
2. URLs or links to external platforms (WhatsApp, Telegram, LinkedIn, etc.)
3. Attempts to bypass the platform's communication system
4. Inappropriate, offensive, or misleading content signals
5. Content completely unrelated to a business pitch or startup

Return ONLY a valid JSON object — no markdown, no explanation:
{"passed": <true if no violations found, false otherwise>, "reason": "<one sentence explanation>"}

Video title: "${videoTitle}"
Video author/channel: "${videoAuthor}"`,
			});

			const rawText = response.text ?? "";
			console.log(`[VIDEO:GEMINI] Raw response: ${rawText.trim()}`);

			const cleaned = rawText
				.replace(/```json\s*/gi, "")
				.replace(/```\s*/g, "")
				.trim();

			const parsed = JSON.parse(cleaned) as {
				passed: boolean;
				reason: string;
			};

			console.log(
				`[VIDEO:GEMINI] passed=${parsed.passed} reason="${parsed.reason}"`,
			);

			return parsed;
		} catch (err) {
			console.error(
				"[VIDEO:GEMINI] Content policy check failed:",
				(err as Error).message,
			);
			// Gemini unreachable — flag for manual review instead of auto-approving
			return {
				passed: false,
				reason:
					"Automated content check unavailable — flagged for manual review",
			};
		}
	}

	/**
	 * Full validation pipeline for a YouTube pitch video.
	 * Called when pitchVideoUrl is set or changed.
	 */
	static async validateVideo(
		submissionId: string,
		videoUrl: string,
	): Promise<void> {
		const submission = await Submission.findById(submissionId);
		if (!submission) return;

		console.log(
			`[VIDEO] Validating video for submission "${submission.title}": ${videoUrl}`,
		);

		// Step 1: Verify video exists via oEmbed
		const metadata = await VideoValidationService.fetchVideoMetadata(videoUrl);
		if (!metadata) {
			submission.videoStatus = "flagged";
			submission.videoFlagReason =
				"Video not found or unavailable on YouTube. Please check the URL.";
			await submission.save();
			console.log("[VIDEO] Video not found — flagged");
			return;
		}

		console.log(
			`[VIDEO] Metadata fetched: title="${metadata.title}", author="${metadata.author}"`,
		);

		// Step 2: Gemini content policy check
		const policyResult = await VideoValidationService.checkContentPolicy(
			metadata.title,
			metadata.author,
			submission.title,
		);

		if (policyResult.passed) {
			submission.videoStatus = "approved";
			submission.videoFlagReason = null as unknown as string;
			console.log("[VIDEO] Video approved automatically");
		} else {
			submission.videoStatus = "flagged";
			submission.videoFlagReason = policyResult.reason;
			console.log(`[VIDEO] Video flagged: ${policyResult.reason}`);
		}

		await submission.save();
	}
}
