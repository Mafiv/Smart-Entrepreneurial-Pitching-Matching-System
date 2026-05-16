"use client";

import { Languages } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
	DropdownMenu,
	DropdownMenuContent,
	DropdownMenuItem,
	DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { type Locale, useLanguage } from "@/i18n/LanguageContext";

const LANGUAGES: { code: Locale; label: string; flag: string }[] = [
	{ code: "en", label: "English", flag: "🇬🇧" },
	{ code: "am", label: "አማርኛ", flag: "🇪🇹" },
];

export default function LanguageSwitcher() {
	const { locale, setLocale, t } = useLanguage();

	return (
		<DropdownMenu>
			<DropdownMenuTrigger asChild>
				<Button
					variant="ghost"
					size="icon"
					className="h-9 w-9 rounded-lg"
					title={t.language.switchLanguage}
				>
					<Languages className="h-4 w-4" />
				</Button>
			</DropdownMenuTrigger>
			<DropdownMenuContent align="end" className="min-w-[140px]">
				{LANGUAGES.map((lang) => (
					<DropdownMenuItem
						key={lang.code}
						onClick={() => setLocale(lang.code)}
						className={`cursor-pointer gap-2 ${
							locale === lang.code ? "font-semibold bg-accent" : ""
						}`}
					>
						<span className="text-base">{lang.flag}</span>
						<span className="text-sm">{lang.label}</span>
					</DropdownMenuItem>
				))}
			</DropdownMenuContent>
		</DropdownMenu>
	);
}
