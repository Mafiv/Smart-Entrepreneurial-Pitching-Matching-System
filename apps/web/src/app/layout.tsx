import type { Metadata } from "next";
import { Outfit } from "next/font/google";
import { SmoothScroll } from "@/components/SmoothScroll";
import { Toaster } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { AuthProvider } from "@/context/AuthContext";
import "./globals.css";

const outfit = Outfit({
	subsets: ["latin"],
	variable: "--font-outfit",
});

export const metadata: Metadata = {
	title: "SEPMS — Smart Entrepreneurial Pitching & Matching System",
	description:
		"AI-powered platform connecting entrepreneurs with investors through intelligent pitch analysis and semantic matching.",
};

export default function RootLayout({
	children,
}: Readonly<{
	children: React.ReactNode;
}>) {
	return (
		<html lang="en" className="dark" suppressHydrationWarning>
			<head>
				<script
					dangerouslySetInnerHTML={{
						__html: `(function(){try{var t=localStorage.getItem('theme');if(t==='light'){document.documentElement.classList.remove('dark')}else{document.documentElement.classList.add('dark')}}catch(e){}})();`,
					}}
				/>
			</head>
			<body className={`${outfit.variable} font-sans antialiased`}>
				<SmoothScroll>
					<TooltipProvider>
						<AuthProvider>
							{children}
							<Toaster richColors position="top-center" />
						</AuthProvider>
					</TooltipProvider>
				</SmoothScroll>
			</body>
		</html>
	);
}
