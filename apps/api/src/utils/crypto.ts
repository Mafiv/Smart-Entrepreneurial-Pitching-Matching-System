import {
	createCipheriv,
	createDecipheriv,
	createHash,
	randomBytes,
} from "crypto";

const KEY_ENV = process.env.PAYOUT_ENCRYPTION_KEY ?? "";
if (!KEY_ENV) {
	console.warn(
		"PAYOUT_ENCRYPTION_KEY not set — payout account encryption disabled",
	);
}

const getKey = () => {
	// derive 32-byte key from provided passphrase
	return createHash("sha256").update(KEY_ENV).digest();
};

export function encryptText(plain: string): string {
	if (!KEY_ENV) return plain;
	const key = getKey();
	const iv = randomBytes(12);
	const cipher = createCipheriv("aes-256-gcm", key, iv);
	const encrypted = Buffer.concat([
		cipher.update(plain, "utf8"),
		cipher.final(),
	]);
	const tag = cipher.getAuthTag();
	// store as base64 iv:cipher:tag
	return `${iv.toString("base64")}::${encrypted.toString("base64")}::${tag.toString("base64")}`;
}

export function decryptText(token: string): string {
	if (!KEY_ENV) return token;
	try {
		const key = getKey();
		const [ivB64, encryptedB64, tagB64] = token.split("::");
		if (!ivB64 || !encryptedB64 || !tagB64) return token;
		const iv = Buffer.from(ivB64, "base64");
		const encrypted = Buffer.from(encryptedB64, "base64");
		const tag = Buffer.from(tagB64, "base64");
		const decipher = createDecipheriv("aes-256-gcm", key, iv);
		decipher.setAuthTag(tag);
		const decrypted = Buffer.concat([
			decipher.update(encrypted),
			decipher.final(),
		]);
		return decrypted.toString("utf8");
	} catch (err) {
		console.error("Failed to decrypt token", err);
		return token;
	}
}
