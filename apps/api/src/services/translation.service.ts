import { GoogleGenAI } from "@google/genai";

/**
 * Lightweight translation service using Gemini as a zero-shot translator.
 * This avoids adding a separate Google Cloud Translation API dependency
 * by reusing the existing Gemini API key already configured for the project.
 *
 * Supported target languages: English (en), Amharic (am)
 */

const SUPPORTED_LANGUAGES: Record<string, string> = {
	en: "English",
	am: "Amharic",
};

let genaiClient: InstanceType<typeof GoogleGenAI> | null = null;

function getGenAI(): InstanceType<typeof GoogleGenAI> {
	if (genaiClient) return genaiClient;
	const apiKey = process.env.GEMINI_API_KEY;
	if (!apiKey) {
		throw new Error("GEMINI_API_KEY is not configured");
	}
	genaiClient = new GoogleGenAI({ apiKey });
	return genaiClient;
}

export async function translateText(
	text: string,
	targetLang: string,
): Promise<{ translated: string; detectedSourceLang: string }> {
	const langName = SUPPORTED_LANGUAGES[targetLang];
	if (!langName) {
		throw new Error(
			`Unsupported target language: ${targetLang}. Supported: ${Object.keys(SUPPORTED_LANGUAGES).join(", ")}`,
		);
	}

	if (!text || text.trim().length === 0) {
		return { translated: text, detectedSourceLang: "unknown" };
	}

	const ai = getGenAI();
	const response = await ai.models.generateContent({
		model: "gemini-2.0-flash-lite",
		contents: `You are a professional translator. Translate the following text to ${langName}. 
Return ONLY the translated text, nothing else. No explanations, no quotes, no labels.
If the text is already in ${langName}, return it as-is.

Text to translate:
${text}`,
	});

	const translated = response.text?.trim() || text;

	// Detect source language heuristically
	const hasAmharic = /[\u1200-\u137F]/.test(text);
	const detectedSourceLang = hasAmharic ? "am" : "en";

	return { translated, detectedSourceLang };
}

export function isSupportedLanguage(lang: string): boolean {
	return lang in SUPPORTED_LANGUAGES;
}

export function getSupportedLanguages(): Record<string, string> {
	return { ...SUPPORTED_LANGUAGES };
}
