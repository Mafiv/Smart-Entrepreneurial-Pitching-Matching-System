"use client";

import {
	AlertTriangle,
	BarChart3,
	CheckCircle2,
	ChevronDown,
	ChevronUp,
	Globe,
	Loader2,
	Pause,
	Play,
	RefreshCw,
	ShieldCheck,
	Sparkles,
	Volume2,
} from "lucide-react";
import { useCallback, useEffect, useRef, useState } from "react";
import { toast } from "sonner";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useAuth } from "@/context/AuthContext";

interface AiSummaryData {
	executiveSummary: string;
	keyStrengths: string[];
	keyRisks: string[];
	investmentReadiness: string;
	marketOpportunity: string;
	generatedAt: string;
	model: string;
}

interface AiPitchSummaryProps {
	submissionId: string;
	aiSummary?: AiSummaryData | null;
	voiceSummaryUrl?: string | null;
	/** If true, show the regenerate button (admin only) */
	showRegenerate?: boolean;
	/** Callback after regeneration to refresh parent state */
	onRegenerated?: () => void;
}

// ── Readiness helpers ───────────────────────────────────────────────────────

function getReadinessLevel(readiness: string): "High" | "Medium" | "Low" {
	const lower = readiness.toLowerCase();
	if (lower.startsWith("high")) return "High";
	if (lower.startsWith("low")) return "Low";
	return "Medium";
}

function readinessColor(level: "High" | "Medium" | "Low") {
	switch (level) {
		case "High":
			return "bg-emerald-500/10 text-emerald-600 border-emerald-500/30";
		case "Medium":
			return "bg-amber-500/10 text-amber-600 border-amber-500/30";
		case "Low":
			return "bg-red-500/10 text-red-600 border-red-500/30";
	}
}

function readinessDot(level: "High" | "Medium" | "Low") {
	switch (level) {
		case "High":
			return "bg-emerald-500";
		case "Medium":
			return "bg-amber-500";
		case "Low":
			return "bg-red-500";
	}
}

// ── Voice Player ────────────────────────────────────────────────────────────

function VoicePlayer({ url }: { url: string }) {
	const audioRef = useRef<HTMLAudioElement | null>(null);
	const [playing, setPlaying] = useState(false);
	const [progress, setProgress] = useState(0);
	const [duration, setDuration] = useState(0);

	const toggle = useCallback(() => {
		const audio = audioRef.current;
		if (!audio) return;
		if (playing) {
			audio.pause();
		} else {
			audio.play();
		}
		setPlaying(!playing);
	}, [playing]);

	useEffect(() => {
		const audio = new Audio(url);
		audioRef.current = audio;

		audio.addEventListener("loadedmetadata", () => setDuration(audio.duration));
		audio.addEventListener("timeupdate", () => setProgress(audio.currentTime));
		audio.addEventListener("ended", () => {
			setPlaying(false);
			setProgress(0);
		});

		return () => {
			audio.pause();
			audio.removeAttribute("src");
		};
	}, [url]);

	const pct = duration > 0 ? (progress / duration) * 100 : 0;
	const fmt = (s: number) => {
		const m = Math.floor(s / 60);
		const sec = Math.floor(s % 60);
		return `${m}:${sec.toString().padStart(2, "0")}`;
	};

	return (
		<div className="flex items-center gap-3 rounded-xl border bg-muted/30 px-4 py-3 mt-4">
			<Button
				size="icon"
				variant="ghost"
				className="h-9 w-9 rounded-full bg-primary/10 hover:bg-primary/20 text-primary shrink-0"
				onClick={toggle}
			>
				{playing ? (
					<Pause className="h-4 w-4" />
				) : (
					<Play className="h-4 w-4 ml-0.5" />
				)}
			</Button>

			<div className="flex-1 min-w-0">
				<div className="flex items-center gap-2 mb-1">
					<Volume2 className="h-3.5 w-3.5 text-primary" />
					<span className="text-xs font-semibold text-primary">
						AI Voice Summary
					</span>
				</div>
				<div className="h-1.5 w-full rounded-full bg-muted overflow-hidden">
					<div
						className="h-full rounded-full bg-primary transition-all duration-200"
						style={{ width: `${pct}%` }}
					/>
				</div>
			</div>

			<span className="text-[11px] text-muted-foreground font-mono shrink-0 tabular-nums">
				{fmt(progress)} / {fmt(duration)}
			</span>
		</div>
	);
}

// ── Shimmer skeleton ────────────────────────────────────────────────────────

function SummarySkeleton() {
	return (
		<Card className="overflow-hidden rounded-2xl border-primary/20 shadow-lg shadow-primary/5">
			<CardHeader className="bg-gradient-to-r from-primary/10 to-transparent pb-4 pt-6">
				<div className="flex items-center gap-2.5">
					<div className="h-5 w-5 rounded bg-primary/20 animate-pulse" />
					<div className="h-5 w-40 rounded bg-primary/20 animate-pulse" />
				</div>
			</CardHeader>
			<CardContent className="space-y-6 pt-6">
				<div className="space-y-2">
					<div className="h-4 w-full rounded bg-muted animate-pulse" />
					<div className="h-4 w-5/6 rounded bg-muted animate-pulse" />
					<div className="h-4 w-4/6 rounded bg-muted animate-pulse" />
				</div>
				<div className="grid grid-cols-2 gap-4">
					<div className="space-y-2">
						<div className="h-3 w-20 rounded bg-muted animate-pulse" />
						<div className="h-3 w-full rounded bg-muted animate-pulse" />
						<div className="h-3 w-full rounded bg-muted animate-pulse" />
					</div>
					<div className="space-y-2">
						<div className="h-3 w-20 rounded bg-muted animate-pulse" />
						<div className="h-3 w-full rounded bg-muted animate-pulse" />
						<div className="h-3 w-full rounded bg-muted animate-pulse" />
					</div>
				</div>
			</CardContent>
		</Card>
	);
}

// ── Main Component ──────────────────────────────────────────────────────────

export default function AiPitchSummary({
	submissionId,
	aiSummary,
	voiceSummaryUrl,
	showRegenerate = false,
	onRegenerated,
}: AiPitchSummaryProps) {
	const { user } = useAuth();
	const [regenerating, setRegenerating] = useState(false);
	const [expanded, setExpanded] = useState(true);

	const api = (
		process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api"
	).replace(/\/+$/, "");

	const handleRegenerate = async () => {
		if (!user || regenerating) return;
		setRegenerating(true);
		try {
			const token = await user.getIdToken();
			const res = await fetch(
				`${api}/submissions/${submissionId}/generate-summary`,
				{
					method: "POST",
					headers: { Authorization: `Bearer ${token}` },
				},
			);
			if (res.ok) {
				toast.success("AI summary regenerated successfully");
				onRegenerated?.();
			} else {
				const data = await res.json();
				toast.error(data.message || "Failed to regenerate summary");
			}
		} catch {
			toast.error("Network error");
		} finally {
			setRegenerating(false);
		}
	};

	// Show skeleton when no summary exists yet
	if (!aiSummary || !aiSummary.executiveSummary) {
		return <SummarySkeleton />;
	}

	const readinessLevel = getReadinessLevel(aiSummary.investmentReadiness);

	return (
		<Card className="overflow-hidden rounded-2xl border-primary/20 shadow-lg shadow-primary/5 bg-gradient-to-br from-primary/[0.03] to-background transition-all">
			{/* Header */}
			<CardHeader className="bg-gradient-to-r from-primary/10 to-transparent pb-4 pt-6 border-b border-primary/10">
				<div className="flex items-center justify-between">
					<CardTitle className="flex items-center gap-2.5 text-lg">
						<div className="flex items-center justify-center h-8 w-8 rounded-lg bg-primary/10">
							<Sparkles className="h-4.5 w-4.5 text-primary" />
						</div>
						<span className="admin-header-gradient font-bold">
							Gemini AI Pitch Summary
						</span>
					</CardTitle>

					<div className="flex items-center gap-2">
						{showRegenerate && (
							<Button
								variant="outline"
								size="sm"
								className="gap-1.5 text-xs rounded-lg h-8"
								onClick={handleRegenerate}
								disabled={regenerating}
							>
								{regenerating ? (
									<Loader2 className="h-3 w-3 animate-spin" />
								) : (
									<RefreshCw className="h-3 w-3" />
								)}
								{regenerating ? "Generating..." : "Regenerate"}
							</Button>
						)}
						<Button
							variant="ghost"
							size="icon"
							className="h-8 w-8"
							onClick={() => setExpanded((v) => !v)}
						>
							{expanded ? (
								<ChevronUp className="h-4 w-4" />
							) : (
								<ChevronDown className="h-4 w-4" />
							)}
						</Button>
					</div>
				</div>
			</CardHeader>

			{expanded && (
				<CardContent className="pt-6 space-y-6">
					{/* Executive Summary */}
					<div>
						<p className="text-sm leading-relaxed text-foreground/90">
							{aiSummary.executiveSummary}
						</p>
					</div>

					{/* Voice Player */}
					{voiceSummaryUrl && <VoicePlayer url={voiceSummaryUrl} />}

					{/* Investment Readiness Badge */}
					<div className="flex items-center gap-3">
						<div
							className={`flex items-center gap-2 px-4 py-2 rounded-xl border ${readinessColor(readinessLevel)}`}
						>
							<div
								className={`h-2.5 w-2.5 rounded-full ${readinessDot(readinessLevel)}`}
							/>
							<ShieldCheck className="h-4 w-4" />
							<span className="text-sm font-bold">
								Investment Readiness: {readinessLevel}
							</span>
						</div>
					</div>
					{aiSummary.investmentReadiness.includes("—") && (
						<p className="text-xs text-muted-foreground -mt-3 ml-1">
							{aiSummary.investmentReadiness.split("—")[1]?.trim()}
						</p>
					)}

					{/* Strengths & Risks Grid */}
					<div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
						{/* Strengths */}
						<div className="rounded-xl border border-emerald-500/20 bg-emerald-500/[0.03] p-4">
							<div className="flex items-center gap-2 mb-3">
								<CheckCircle2 className="h-4 w-4 text-emerald-500" />
								<h4 className="text-sm font-bold text-emerald-600">
									Key Strengths
								</h4>
							</div>
							<ul className="space-y-2">
								{aiSummary.keyStrengths.map((s) => (
									<li
										key={s}
										className="flex items-start gap-2 text-xs text-muted-foreground leading-relaxed"
									>
										<span className="mt-1.5 h-1.5 w-1.5 rounded-full bg-emerald-500 shrink-0" />
										{s}
									</li>
								))}
							</ul>
						</div>

						{/* Risks */}
						<div className="rounded-xl border border-amber-500/20 bg-amber-500/[0.03] p-4">
							<div className="flex items-center gap-2 mb-3">
								<AlertTriangle className="h-4 w-4 text-amber-500" />
								<h4 className="text-sm font-bold text-amber-600">Key Risks</h4>
							</div>
							<ul className="space-y-2">
								{aiSummary.keyRisks.map((r) => (
									<li
										key={r}
										className="flex items-start gap-2 text-xs text-muted-foreground leading-relaxed"
									>
										<span className="mt-1.5 h-1.5 w-1.5 rounded-full bg-amber-500 shrink-0" />
										{r}
									</li>
								))}
							</ul>
						</div>
					</div>

					{/* Market Opportunity */}
					<div className="rounded-xl border bg-muted/20 p-4">
						<div className="flex items-center gap-2 mb-2">
							<Globe className="h-4 w-4 text-blue-500" />
							<h4 className="text-sm font-bold text-foreground">
								Market Opportunity
							</h4>
						</div>
						<p className="text-xs text-muted-foreground leading-relaxed">
							{aiSummary.marketOpportunity}
						</p>
					</div>

					{/* Footer */}
					<div className="flex items-center justify-between border-t border-border/40 pt-3">
						<div className="flex items-center gap-1.5">
							<BarChart3 className="h-3 w-3 text-muted-foreground" />
							<span className="text-[10px] text-muted-foreground font-medium">
								Powered by Google Gemini ({aiSummary.model})
							</span>
						</div>
						{aiSummary.generatedAt && (
							<span className="text-[10px] text-muted-foreground">
								Generated {new Date(aiSummary.generatedAt).toLocaleDateString()}
							</span>
						)}
					</div>
				</CardContent>
			)}
		</Card>
	);
}
