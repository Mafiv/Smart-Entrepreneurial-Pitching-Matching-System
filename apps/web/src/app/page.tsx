"use client";

import { motion, useScroll, useTransform } from "framer-motion";
import {
	BarChart3,
	Link as LinkIcon,
	MessageSquare,
	Radio,
	ShieldCheck,
	Zap,
} from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useRef } from "react";
import { Logo } from "@/components/Logo";
import Navbar from "@/components/Navbar";
import {
	Accordion,
	AccordionContent,
	AccordionItem,
	AccordionTrigger,
} from "@/components/ui/accordion";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { useAuth } from "@/context/AuthContext";
import { useLanguage } from "@/i18n/LanguageContext";

/* ──────────────────────────────────────────────
   ICONS (language-independent)
   ────────────────────────────────────────────── */

const FEATURE_ICONS = [
	<Zap key="zap" className="w-5 h-5 text-foreground drop-shadow-[0_0_8px_rgba(0,0,0,0.1)] dark:drop-shadow-[0_0_8px_rgba(255,255,255,0.2)]" />,
	<LinkIcon key="link" className="w-5 h-5 text-foreground drop-shadow-[0_0_8px_rgba(0,0,0,0.1)] dark:drop-shadow-[0_0_8px_rgba(255,255,255,0.2)]" />,
	<ShieldCheck key="shield" className="w-5 h-5 text-foreground drop-shadow-[0_0_8px_rgba(0,0,0,0.1)] dark:drop-shadow-[0_0_8px_rgba(255,255,255,0.2)]" />,
	<BarChart3 key="chart" className="w-5 h-5 text-foreground drop-shadow-[0_0_8px_rgba(0,0,0,0.1)] dark:drop-shadow-[0_0_8px_rgba(255,255,255,0.2)]" />,
	<Radio key="radio" className="w-5 h-5 text-foreground drop-shadow-[0_0_8px_rgba(0,0,0,0.1)] dark:drop-shadow-[0_0_8px_rgba(255,255,255,0.2)]" />,
	<MessageSquare key="msg" className="w-5 h-5 text-foreground drop-shadow-[0_0_8px_rgba(0,0,0,0.1)] dark:drop-shadow-[0_0_8px_rgba(255,255,255,0.2)]" />,
];

const STEP_NUMBERS = ["01", "02", "03", "04"];

/* ──────────────────────────────────────────────
   COMPONENT
   ────────────────────────────────────────────── */

export default function Home() {
	const { user, userProfile } = useAuth();
	const router = useRouter();
	const { t } = useLanguage();

	// Build translated data
	const FEATURES = [
		{ icon: FEATURE_ICONS[0], title: t.landing.feature1Title, desc: t.landing.feature1Desc },
		{ icon: FEATURE_ICONS[1], title: t.landing.feature2Title, desc: t.landing.feature2Desc },
		{ icon: FEATURE_ICONS[2], title: t.landing.feature3Title, desc: t.landing.feature3Desc },
		{ icon: FEATURE_ICONS[3], title: t.landing.feature4Title, desc: t.landing.feature4Desc },
		{ icon: FEATURE_ICONS[4], title: t.landing.feature5Title, desc: t.landing.feature5Desc },
		{ icon: FEATURE_ICONS[5], title: t.landing.feature6Title, desc: t.landing.feature6Desc },
	];

	const PLATFORM_FEATURES = [
		{
			title: t.landing.platformEntrepreneurTitle,
			subtitle: t.landing.platformEntrepreneurSubtitle,
			items: t.landing.platformEntrepreneurItems,
		},
		{
			title: t.landing.platformInvestorTitle,
			subtitle: t.landing.platformInvestorSubtitle,
			items: t.landing.platformInvestorItems,
		},
	];

	const STEPS = [
		{ step: "01", title: t.landing.step1Title, desc: t.landing.step1Desc },
		{ step: "02", title: t.landing.step2Title, desc: t.landing.step2Desc },
		{ step: "03", title: t.landing.step3Title, desc: t.landing.step3Desc },
		{ step: "04", title: t.landing.step4Title, desc: t.landing.step4Desc },
	];

	const FAQ = [
		{ q: t.landing.faq1Q, a: t.landing.faq1A },
		{ q: t.landing.faq2Q, a: t.landing.faq2A },
		{ q: t.landing.faq3Q, a: t.landing.faq3A },
		{ q: t.landing.faq4Q, a: t.landing.faq4A },
		{ q: t.landing.faq5Q, a: t.landing.faq5A },
	];

	// Dashboard Mockup setup
	const dashboardRef = useRef<HTMLDivElement>(null);

	const getDashboardRoute = () => {
		if (userProfile?.role) {
			const redirects: Record<string, string> = {
				admin: "/admin/oversight",
				entrepreneur: "/entrepreneur/dashboard",
				investor: "/investor/feed",
			};
			return redirects[userProfile.role] || "/";
		}
		return null;
	};

	const dashboardRoute = getDashboardRoute();

	return (
		<div className="flex min-h-screen flex-col relative overflow-hidden bg-background">
			{/* Modern SaaS Background */}
			<div className="pointer-events-none fixed inset-0 z-[-1]">
				{/* Grid Pattern */}
				<div className="absolute inset-0 bg-[linear-gradient(to_right,#80808012_1px,transparent_1px),linear-gradient(to_bottom,#80808012_1px,transparent_1px)] bg-[size:40px_40px] [mask-image:radial-gradient(ellipse_80%_80%_at_50%_0%,#000_70%,transparent_100%)]" />
				{/* Ambient Glows */}
				<motion.div
					className="absolute top-[-10%] left-1/2 -translate-x-1/2 w-[800px] h-[500px] bg-indigo-500/20 dark:bg-indigo-500/20 rounded-full blur-[120px] mix-blend-normal"
					animate={{
						scale: [1, 1.1, 1],
						opacity: [0.4, 0.6, 0.4],
					}}
					transition={{ duration: 8, repeat: Infinity, ease: "easeInOut" }}
				/>
				<motion.div
					className="absolute top-[20%] left-[-10%] w-[500px] h-[500px] bg-blue-500/10 dark:bg-blue-500/10 rounded-full blur-[100px]"
					animate={{
						x: [0, 50, 0],
						y: [0, -50, 0],
					}}
					transition={{ duration: 10, repeat: Infinity, ease: "easeInOut" }}
				/>
				<motion.div
					className="absolute top-[10%] right-[-10%] w-[600px] h-[600px] bg-purple-500/10 dark:bg-purple-500/10 rounded-full blur-[120px]"
					animate={{
						x: [0, -50, 0],
						y: [0, 50, 0],
					}}
					transition={{ duration: 12, repeat: Infinity, ease: "easeInOut" }}
				/>
			</div>

			<Navbar />
			{/* ─── Hero ─── */}
			<section className="relative overflow-hidden pt-32 pb-20 sm:pt-40 sm:pb-32 lg:pt-48 lg:pb-40">
				<div className="relative w-full px-4 sm:px-8 lg:px-16">
					<motion.div
						className="mx-auto max-w-3xl text-center"
						initial="hidden"
						animate="visible"
						variants={{
							hidden: { opacity: 0 },
							visible: {
								opacity: 1,
								transition: {
									staggerChildren: 0.15,
									delayChildren: 0.1,
								},
							},
						}}
					>
						<motion.div
							variants={{
								hidden: { opacity: 0, y: 20, filter: "blur(10px)" },
								visible: {
									opacity: 1,
									y: 0,
									filter: "blur(0px)",
									transition: { type: "spring", bounce: 0, duration: 1 },
								},
							}}
							className="mb-8 flex justify-center"
						>
							<div className="inline-flex items-center rounded-full border border-indigo-500/30 bg-indigo-500/10 px-4 py-1.5 text-sm font-medium text-indigo-600 dark:text-indigo-400 backdrop-blur-sm transition-all hover:bg-indigo-500/20 cursor-default">
								<span className="relative flex h-2 w-2 mr-2.5">
									<span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-indigo-400 opacity-75" />
									<span className="relative inline-flex rounded-full h-2 w-2 bg-indigo-500" />
								</span>
								{t.landing.heroBadge}
							</div>
						</motion.div>

						<h1
							className="text-5xl font-extrabold tracking-tight sm:text-6xl lg:text-7xl xl:text-[5rem] leading-[1.05]"
							style={{ perspective: 1000 }}
						>
							<motion.span
								className="block"
								variants={{
									hidden: {
										opacity: 0,
										y: 40,
										filter: "blur(10px)",
										rotateX: -30,
									},
									visible: {
										opacity: 1,
										y: 0,
										filter: "blur(0px)",
										rotateX: 0,
										transition: { type: "spring", bounce: 0.3, duration: 1.2 },
									},
								}}
							>
								{t.landing.heroTitle1}
							</motion.span>
							<motion.span
								className="block relative bg-gradient-to-r from-blue-500 via-indigo-500 to-purple-500 bg-clip-text text-transparent pb-4 inline-block mx-auto"
								variants={{
									hidden: {
										opacity: 0,
										y: 40,
										filter: "blur(10px)",
										rotateX: -30,
									},
									visible: {
										opacity: 1,
										y: 0,
										filter: "blur(0px)",
										rotateX: 0,
										transition: { type: "spring", bounce: 0.3, duration: 1.2 },
									},
								}}
							>
								{t.landing.heroTitle2}
								{/* Animated under-line */}
								<motion.svg
									className="absolute -bottom-1 left-0 w-full h-5 overflow-visible"
									viewBox="0 0 100 20"
									preserveAspectRatio="none"
									initial={{ opacity: 0 }}
									animate={{ opacity: 1 }}
									transition={{ delay: 1, duration: 0.5 }}
								>
									<motion.path
										d="M0,10 Q25,20 50,10 T100,10"
										fill="none"
										stroke="url(#title-underline-grad)"
										strokeWidth="5"
										strokeLinecap="round"
										initial={{ pathLength: 0 }}
										animate={{ pathLength: 1 }}
										transition={{
											duration: 1.5,
											ease: "easeInOut",
											delay: 1.2,
										}}
									/>
									<defs>
										<linearGradient
											id="title-underline-grad"
											x1="0"
											y1="0"
											x2="1"
											y2="0"
										>
											<stop offset="0%" stopColor="#3b82f6" />
											<stop offset="50%" stopColor="#8b5cf6" />
											<stop offset="100%" stopColor="#ec4899" />
										</linearGradient>
									</defs>
								</motion.svg>
							</motion.span>
						</h1>

						<motion.p
							className="mx-auto mt-8 max-w-2xl text-lg sm:text-xl text-muted-foreground leading-relaxed"
							variants={{
								hidden: { opacity: 0, y: 20, filter: "blur(10px)" },
								visible: {
									opacity: 1,
									y: 0,
									filter: "blur(0px)",
									transition: { type: "spring", bounce: 0, duration: 1 },
								},
							}}
						>
							{t.landing.heroSubtitle}
						</motion.p>

						<motion.div
							className="mt-10 flex flex-col items-center gap-4 sm:flex-row sm:justify-center"
							variants={{
								hidden: { opacity: 0, y: 20, filter: "blur(10px)" },
								visible: {
									opacity: 1,
									y: 0,
									filter: "blur(0px)",
									transition: { type: "spring", bounce: 0, duration: 1 },
								},
							}}
						>
							{user && dashboardRoute ? (
								<Button
									size="lg"
									className="h-12 px-8 text-sm font-semibold rounded-full group relative overflow-hidden"
									onClick={() => router.push(dashboardRoute as string)}
								>
									<span className="relative z-10 transition-transform duration-300 group-hover:scale-105 inline-block">
										{t.landing.heroCtaDashboard}
									</span>
									<motion.div
										className="absolute inset-0 bg-white/20"
										initial={{ x: "-100%" }}
										whileHover={{ x: "100%" }}
										transition={{ duration: 0.5, ease: "easeInOut" }}
									/>
								</Button>
							) : (
								<>
									<Button
										size="lg"
										className="h-12 px-8 text-sm font-semibold rounded-full group relative overflow-hidden"
										onClick={() => router.push("/sign-up?role=entrepreneur")}
									>
										<span className="relative z-10 transition-transform duration-300 group-hover:scale-105 inline-block">
											{t.landing.heroCtaPitch}
										</span>
										<motion.div
											className="absolute inset-0 bg-white/20"
											initial={{ x: "-100%" }}
											whileHover={{ x: "100%" }}
											transition={{ duration: 0.5, ease: "easeInOut" }}
										/>
									</Button>
									<Button
										size="lg"
										variant="outline"
										className="h-12 px-8 text-sm font-semibold rounded-full hover:bg-muted transition-transform duration-300 hover:scale-105"
										onClick={() => router.push("/sign-up?role=investor")}
									>
										{t.landing.heroCtaInvestor}
									</Button>
								</>
							)}
						</motion.div>

						<motion.p
							className="mt-4 text-xs text-muted-foreground/60"
							variants={{
								hidden: { opacity: 0 },
								visible: { opacity: 1, transition: { duration: 1 } },
							}}
						>
							{t.landing.heroFootnote}
						</motion.p>
					</motion.div>
				</div>

				{/* ─── Modern Dashboard Mockup Reveal ─── */}
				<div
					ref={dashboardRef}
					className="relative mx-auto max-w-6xl px-4 sm:px-8 pb-32 pt-10"
				>
					<motion.div
						initial={{ opacity: 0, y: 40 }}
						whileInView={{ opacity: 1, y: 0 }}
						viewport={{ once: true, margin: "-100px" }}
						transition={{ duration: 1, type: "spring", bounce: 0 }}
						className="w-full relative rounded-2xl sm:rounded-[2rem] border border-white/20 dark:border-white/10 bg-white/50 dark:bg-black/50 shadow-2xl p-2 sm:p-4 backdrop-blur-md z-10"
					>
						{/* Subtle top reflection line */}
						<div className="absolute top-0 inset-x-4 h-px bg-gradient-to-r from-transparent via-white/50 dark:via-white/20 to-transparent" />

						{/* The Image */}
						<div className="relative w-full aspect-[16/9] overflow-hidden rounded-xl sm:rounded-2xl border border-border/50 bg-muted/50">
							{/* Light Mode Mockup */}
							<Image
								src="/light-dashboard.png"
								alt="SEPMS Platform Dashboard Mockup Light"
								fill
								className="object-cover object-left-top dark:hidden block transition-transform duration-700 hover:scale-[1.02]"
								priority
							/>
							{/* Dark Mode Mockup */}
							<Image
								src="/dark-dashboard.png"
								alt="SEPMS Platform Dashboard Mockup Dark"
								fill
								className="object-cover object-left-top hidden dark:block transition-transform duration-700 hover:scale-[1.02]"
								priority
							/>
						</div>
					</motion.div>
				</div>
			</section>

			{/* ─── Core Features ─── */}
			<section id="features" className="py-20 sm:py-28">
				<div className="w-full px-4 sm:px-8 lg:px-16">
					<motion.div
						className="mx-auto max-w-2xl text-center mb-16"
						initial={{ opacity: 0, y: 20 }}
						whileInView={{ opacity: 1, y: 0 }}
						viewport={{ once: true }}
						transition={{ duration: 0.5 }}
					>
						<Badge variant="secondary" className="mb-4 px-3 py-1 text-xs">
							{t.landing.featuresBadge}
						</Badge>
						<h2 className="text-3xl font-bold tracking-tight sm:text-4xl">
							{t.landing.featuresTitle}
						</h2>
						<p className="mt-4 text-muted-foreground">
							{t.landing.featuresSubtitle}
						</p>
					</motion.div>
					<div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
						{FEATURES.map((feature, i) => (
							<motion.div
								key={feature.title}
								initial={{ opacity: 0, y: 20 }}
								whileInView={{ opacity: 1, y: 0 }}
								viewport={{ once: true }}
								transition={{ duration: 0.5, delay: i * 0.1 }}
							>
								<Card className="relative h-full group border-border/30 bg-background/40 backdrop-blur-md overflow-hidden hover:shadow-[0_0_40px_-10px_rgba(99,102,241,0.15)] dark:hover:shadow-[0_0_40px_-10px_rgba(99,102,241,0.2)] hover:-translate-y-1 hover:border-indigo-500/30 transition-all duration-500">
									<div className="absolute inset-0 bg-gradient-to-br from-indigo-500/5 via-purple-500/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none" />
									<CardContent className="p-6 relative z-10">
										<div className="mb-4 flex h-10 w-10 items-center justify-center rounded-lg bg-muted text-xl group-hover:scale-110 group-hover:bg-primary/10 transition-all duration-300">
											{feature.icon}
										</div>
										<h3 className="font-semibold mb-2">{feature.title}</h3>
										<p className="text-sm text-muted-foreground leading-relaxed">
											{feature.desc}
										</p>
									</CardContent>
								</Card>
							</motion.div>
						))}
					</div>
				</div>
			</section>

			{/* ─── Platform Features (3 columns) ─── */}
			<section
				id="platform"
				className="border-y border-border/30 py-20 sm:py-28 relative bg-background/50 backdrop-blur-sm"
			>
				<div className="absolute inset-0 bg-gradient-to-b from-indigo-500/5 to-transparent pointer-events-none" />
				<div className="w-full px-4 sm:px-8 lg:px-16">
					<motion.div
						className="mx-auto max-w-2xl text-center mb-16"
						initial={{ opacity: 0, y: 20 }}
						whileInView={{ opacity: 1, y: 0 }}
						viewport={{ once: true }}
						transition={{ duration: 0.5 }}
					>
						<Badge variant="secondary" className="mb-4 px-3 py-1 text-xs">
							{t.landing.platformBadge}
						</Badge>
						<h2 className="text-3xl font-bold tracking-tight sm:text-4xl">
							{t.landing.platformTitle}
						</h2>
						<p className="mt-4 text-muted-foreground">
							{t.landing.platformSubtitle}
						</p>
					</motion.div>
					<div className="grid gap-6 sm:grid-cols-2 max-w-4xl mx-auto">
						{PLATFORM_FEATURES.map((role, i) => (
							<motion.div
								key={role.title}
								initial={{ opacity: 0, y: 20 }}
								whileInView={{ opacity: 1, y: 0 }}
								viewport={{ once: true }}
								transition={{ duration: 0.5, delay: i * 0.1 }}
							>
								<Card className="relative h-full border-border/30 bg-background/40 backdrop-blur-md overflow-hidden hover:border-indigo-500/40 dark:hover:border-indigo-500/40 hover:shadow-[0_0_50px_-12px_rgba(99,102,241,0.2)] hover:-translate-y-2 transition-all duration-500">
									<div className="absolute inset-0 bg-gradient-to-br from-blue-500/5 via-indigo-500/5 to-purple-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none" />
									<CardContent className="p-6 h-full flex flex-col relative z-10">
										<h3 className="font-bold text-lg mb-1">{role.title}</h3>
										<p className="text-sm text-muted-foreground mb-5">
											{role.subtitle}
										</p>
										<ul className="space-y-3">
											{role.items.map((item) => (
												<li
													key={item}
													className="flex items-start gap-2.5 text-sm"
												>
													<span className="mt-0.5 text-primary">✓</span>
													<span>{item}</span>
												</li>
											))}
										</ul>
									</CardContent>
								</Card>
							</motion.div>
						))}
					</div>
				</div>
			</section>

			{/* ─── How it works ─── */}
			<section id="how-it-works" className="py-20 sm:py-28">
				<div className="w-full px-4 sm:px-8 lg:px-16">
					<motion.div
						className="mx-auto max-w-2xl text-center mb-16"
						initial={{ opacity: 0, y: 20 }}
						whileInView={{ opacity: 1, y: 0 }}
						viewport={{ once: true }}
						transition={{ duration: 0.5 }}
					>
						<Badge variant="secondary" className="mb-4 px-3 py-1 text-xs">
							{t.landing.howItWorksBadge}
						</Badge>
						<h2 className="text-3xl font-bold tracking-tight sm:text-4xl">
							{t.landing.howItWorksTitle}
						</h2>
						<p className="mt-4 text-muted-foreground">
							{t.landing.howItWorksSubtitle}
						</p>
					</motion.div>
					<div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
						{STEPS.map((step, i) => (
							<motion.div
								key={step.step}
								className="relative"
								initial={{ opacity: 0, x: -20 }}
								whileInView={{ opacity: 1, x: 0 }}
								viewport={{ once: true }}
								transition={{ duration: 0.5, delay: i * 0.15 }}
							>
								<div className="text-5xl font-bold bg-gradient-to-b from-muted-foreground/30 to-muted-foreground/5 bg-clip-text text-transparent mb-4">
									{step.step}
								</div>
								<h3 className="font-semibold mb-2">{step.title}</h3>
								<p className="text-sm text-muted-foreground leading-relaxed">
									{step.desc}
								</p>
								{i < STEPS.length - 1 && (
									<div className="hidden lg:block absolute top-8 -right-4 text-muted-foreground/20 text-2xl">
										→
									</div>
								)}
							</motion.div>
						))}
					</div>
				</div>
			</section>

			{/* ─── FAQ ─── */}
			<section id="faq" className="py-20 sm:py-28 z-20 relative">
				<div className="w-full max-w-5xl mx-auto px-4 sm:px-8 lg:px-16">
					<motion.div
						className="text-center mb-16"
						initial={{ opacity: 0, y: 20 }}
						whileInView={{ opacity: 1, y: 0 }}
						viewport={{ once: true }}
						transition={{ duration: 0.5 }}
					>
						<Badge variant="secondary" className="mb-4 px-3 py-1 text-xs">
							{t.landing.faqBadge}
						</Badge>
						<h2 className="text-3xl font-bold tracking-tight sm:text-4xl">
							{t.landing.faqTitle}
						</h2>
					</motion.div>

					<Accordion type="single" collapsible className="w-full space-y-3">
						{FAQ.map((item, i) => (
							<AccordionItem
								key={item.q}
								value={`item-${i}`}
								className="border-border/30 border rounded-lg px-5 bg-background/40 backdrop-blur-md hover:border-indigo-500/30 transition-all duration-300 shadow-sm hover:shadow-md"
							>
								<AccordionTrigger className="text-left font-medium text-sm py-5 hover:no-underline">
									{item.q}
								</AccordionTrigger>
								<AccordionContent className="text-sm text-muted-foreground leading-relaxed pb-5">
									{item.a}
								</AccordionContent>
							</AccordionItem>
						))}
					</Accordion>
				</div>
			</section>

			{/* ─── CTA ─── */}
			<section className="py-20 sm:py-28 border-t border-border/50 relative overflow-hidden">
				<div className="mx-auto max-w-7xl px-4 relative z-10">
					<motion.div
						initial={{ opacity: 0, scale: 0.95, y: 20 }}
						whileInView={{ opacity: 1, scale: 1, y: 0 }}
						viewport={{ once: true }}
						transition={{ duration: 0.6, type: "spring" }}
					>
						<Card className="overflow-hidden border-border/30 bg-background/40 backdrop-blur-xl relative shadow-[0_0_50px_-10px_rgba(0,0,0,0.1)] dark:shadow-[0_0_50px_-10px_rgba(255,255,255,0.05)]">
							<div className="absolute inset-0 bg-gradient-to-tr from-foreground/5 via-transparent to-foreground/5" />
							<CardContent className="relative p-8 sm:p-12 lg:p-16 text-center z-10">
								<div className="relative">
									<h2 className="text-3xl font-bold tracking-tight sm:text-4xl mb-4">
										{t.landing.ctaTitle}
									</h2>
									<p className="mx-auto max-w-lg text-muted-foreground mb-8">
										{t.landing.ctaSubtitle}
									</p>
									<div className="flex flex-col items-center gap-3 sm:flex-row sm:justify-center">
										{user && dashboardRoute ? (
											<Button
												size="lg"
												className="h-12 px-8 font-semibold hover:scale-105 transition-transform duration-300"
												onClick={() => router.push(dashboardRoute as string)}
											>
												{t.landing.ctaDashboard}
											</Button>
										) : (
											<>
												<Button
													size="lg"
													className="h-12 px-8 font-semibold hover:scale-105 transition-transform duration-300 group relative overflow-hidden"
													onClick={() => router.push("/sign-up")}
												>
													<span className="relative z-10">
														{t.landing.ctaButton}
													</span>
													<motion.div
														className="absolute inset-0 bg-white/20"
														initial={{ x: "-100%" }}
														whileHover={{ x: "100%" }}
														transition={{ duration: 0.5, ease: "easeInOut" }}
													/>
												</Button>
												<Button
													size="lg"
													variant="outline"
													className="h-12 px-8 font-semibold hover:scale-105 hover:bg-muted transition-all duration-300"
													onClick={() => router.push("/sign-in")}
												>
													{t.landing.ctaSignIn}
												</Button>
											</>
										)}
									</div>
								</div>
							</CardContent>
						</Card>
					</motion.div>
				</div>
			</section>

			{/* ─── Footer ─── */}
			<footer className="border-t border-border/50 bg-background">
				<div className="w-full px-4 sm:px-8 lg:px-16 py-12 lg:py-16">
					<div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
						{/* Brand */}
						<div className="lg:col-span-1">
							<div className="flex items-center gap-2 mb-4">
								<Logo className="h-7 w-7" />
								<span className="font-semibold text-sm">SEPMS</span>
							</div>
							<p className="text-sm text-muted-foreground leading-relaxed max-w-xs">
								{t.landing.footerBrand}
							</p>
						</div>

						{/* Product */}
						<div>
							<h4 className="font-semibold text-sm mb-4">{t.landing.footerProduct}</h4>
							<ul className="space-y-2.5">
								{t.landing.footerProductItems.map((item) => (
									<li key={item}>
										<Link
											href="#features"
											className="text-sm text-muted-foreground hover:text-foreground transition-colors"
										>
											{item}
										</Link>
									</li>
								))}
							</ul>
						</div>

						{/* Resources */}
						<div>
							<h4 className="font-semibold text-sm mb-4">{t.landing.footerResources}</h4>
							<ul className="space-y-2.5">
								{t.landing.footerResourceItems.map((item) => (
									<li key={item}>
										<Link
											href="#faq"
											className="text-sm text-muted-foreground hover:text-foreground transition-colors"
										>
											{item}
										</Link>
									</li>
								))}
							</ul>
						</div>

						{/* Company */}
						<div>
							<h4 className="font-semibold text-sm mb-4">{t.landing.footerCompany}</h4>
							<ul className="space-y-2.5">
								{t.landing.footerCompanyItems.map((item) => (
									<li key={item}>
										<Link
											href="#"
											className="text-sm text-muted-foreground hover:text-foreground transition-colors"
										>
											{item}
										</Link>
									</li>
								))}
							</ul>
						</div>
					</div>

					<Separator className="my-8" />

					<div className="flex flex-col items-center justify-between gap-4 sm:flex-row">
						<p className="text-xs text-muted-foreground">
							© {new Date().getFullYear()} {t.landing.footerCopyright}
						</p>
						<div className="flex items-center gap-4">
							<Link
								href="#"
								className="text-muted-foreground hover:text-foreground transition-colors"
								aria-label="GitHub"
							>
								<svg
									xmlns="http://www.w3.org/2000/svg"
									width="18"
									height="18"
									viewBox="0 0 24 24"
									fill="currentColor"
									role="img"
								>
									<title>GitHub</title>
									<path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
								</svg>
							</Link>
							<Link
								href="#"
								className="text-muted-foreground hover:text-foreground transition-colors"
								aria-label="Twitter"
							>
								<svg
									xmlns="http://www.w3.org/2000/svg"
									width="18"
									height="18"
									viewBox="0 0 24 24"
									fill="currentColor"
									role="img"
								>
									<title>X / Twitter</title>
									<path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
								</svg>
							</Link>
							<Link
								href="#"
								className="text-muted-foreground hover:text-foreground transition-colors"
								aria-label="LinkedIn"
							>
								<svg
									xmlns="http://www.w3.org/2000/svg"
									width="18"
									height="18"
									viewBox="0 0 24 24"
									fill="currentColor"
									role="img"
								>
									<title>LinkedIn</title>
									<path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z" />
								</svg>
							</Link>
						</div>
					</div>
				</div>
			</footer>
		</div>
	);
}
