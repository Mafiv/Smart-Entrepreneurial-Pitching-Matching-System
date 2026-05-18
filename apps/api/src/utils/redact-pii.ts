/**
 * PII / IP Redaction Utility
 *
 * Scrubs Personally Identifiable Information and sensitive Intellectual
 * Property markers from text before dispatching payloads to external
 * LLM APIs (Gemini, GPT, etc.).
 *
 * This satisfies the Hybrid Validation Chain requirement from SC-16:
 * "sanitize the data by scrubbing PII and IP identifiers before
 *  dispatching a secure, stripped payload to an external LLM API."
 */

/** Patterns that match common PII and sensitive identifiers */
const PII_PATTERNS: Array<{ pattern: RegExp; replacement: string }> = [
	// Email addresses
	{
		pattern: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g,
		replacement: "[EMAIL_REDACTED]",
	},
	// Phone numbers (international and local formats)
	{
		pattern:
			/(?:\+?\d{1,3}[-.\s]?)?(?:\(?\d{2,4}\)?[-.\s]?)?\d{3,4}[-.\s]?\d{3,4}/g,
		replacement: "[PHONE_REDACTED]",
	},
	// Ethiopian TIN numbers (10 digits, often prefixed with "TIN")
	{
		pattern: /\bTIN[-:\s]*\d{10}\b/gi,
		replacement: "[TIN_REDACTED]",
	},
	// National ID / passport numbers (generic patterns)
	{
		pattern:
			/\b(?:passport|national\s*id|id\s*number|license\s*no)[-:\s]*[A-Z0-9]{6,15}\b/gi,
		replacement: "[ID_REDACTED]",
	},
	// Bank account numbers (8-20 digit sequences preceded by keywords)
	{
		pattern:
			/\b(?:account|acct|IBAN|bank\s*account)[-:\s#]*[A-Z]{0,4}\d{8,20}\b/gi,
		replacement: "[ACCOUNT_REDACTED]",
	},
	// Credit card patterns (4 groups of 4 digits)
	{
		pattern: /\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b/g,
		replacement: "[CARD_REDACTED]",
	},
	// IP addresses (IPv4)
	{
		pattern: /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/g,
		replacement: "[IP_REDACTED]",
	},
	// URLs with auth tokens or API keys in query strings
	{
		pattern:
			/(?:https?:\/\/[^\s]+[?&](?:api[_-]?key|token|secret|password|auth)=[^\s&]+)/gi,
		replacement: "[SENSITIVE_URL_REDACTED]",
	},
	// Standalone API keys / secrets (long alphanumeric strings with key labels)
	{
		pattern:
			/\b(?:api[_-]?key|secret[_-]?key|access[_-]?token|private[_-]?key)[-:\s]*[A-Za-z0-9_-]{20,}\b/gi,
		replacement: "[API_KEY_REDACTED]",
	},
];

/**
 * Redact PII and IP-sensitive content from text.
 *
 * @param text - The raw text to sanitize
 * @returns The sanitized text with PII markers replaced
 */
export function redactPII(text: string): string {
	let sanitized = text;

	for (const { pattern, replacement } of PII_PATTERNS) {
		// Reset regex state for global patterns
		pattern.lastIndex = 0;
		sanitized = sanitized.replace(pattern, replacement);
	}

	return sanitized;
}
