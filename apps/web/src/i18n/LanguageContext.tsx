"use client";

import {
	createContext,
	type ReactNode,
	useCallback,
	useContext,
	useEffect,
	useState,
} from "react";
import am from "./locales/am";
import en, { type TranslationDictionary } from "./locales/en";

export type Locale = "en" | "am";

const dictionaries: Record<Locale, TranslationDictionary> = { en, am };

interface LanguageContextValue {
	locale: Locale;
	setLocale: (locale: Locale) => void;
	t: TranslationDictionary;
}

const LanguageContext = createContext<LanguageContextValue>({
	locale: "en",
	setLocale: () => {},
	t: en,
});

const STORAGE_KEY = "sepms_locale";

export function LanguageProvider({ children }: { children: ReactNode }) {
	const [locale, setLocaleState] = useState<Locale>("en");

	// Hydrate from localStorage on mount
	useEffect(() => {
		const stored = localStorage.getItem(STORAGE_KEY) as Locale | null;
		if (stored && dictionaries[stored]) {
			setLocaleState(stored);
			document.documentElement.lang = stored === "am" ? "am" : "en";
		}
	}, []);

	const setLocale = useCallback((newLocale: Locale) => {
		setLocaleState(newLocale);
		localStorage.setItem(STORAGE_KEY, newLocale);
		document.documentElement.lang = newLocale === "am" ? "am" : "en";
	}, []);

	return (
		<LanguageContext.Provider
			value={{ locale, setLocale, t: dictionaries[locale] }}
		>
			{children}
		</LanguageContext.Provider>
	);
}

/**
 * Hook to access the current translation dictionary and locale controls.
 *
 * Usage:
 * ```tsx
 * const { t, locale, setLocale } = useLanguage();
 * <h1>{t.dashboard.welcome}</h1>
 * ```
 */
export function useLanguage() {
	return useContext(LanguageContext);
}
