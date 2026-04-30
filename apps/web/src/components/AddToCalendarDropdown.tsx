"use client";

import { Calendar, ChevronDown, Download, ExternalLink } from "lucide-react";
import { useCallback, useState } from "react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { useAuth } from "@/context/AuthContext";

interface CalendarMeeting {
	_id: string;
	title: string;
	scheduledAt: string;
	durationMinutes: number;
	notes?: string;
}

const API = (
	process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:5000/api"
).replace(/\/+$/, "");

/**
 * Build a Google Calendar "Add Event" URL entirely on the client.
 * This opens Google Calendar with a pre-filled event creation form.
 */
function buildGoogleCalendarUrl(meeting: CalendarMeeting): string {
	const start = new Date(meeting.scheduledAt);
	const end = new Date(start.getTime() + meeting.durationMinutes * 60 * 1000);

	const fmt = (d: Date) =>
		d
			.toISOString()
			.replace(/[-:]/g, "")
			.replace(/\.\d{3}/, "");

	const params = new URLSearchParams({
		action: "TEMPLATE",
		text: meeting.title,
		dates: `${fmt(start)}/${fmt(end)}`,
		details: meeting.notes ?? "SEPMS Video Meeting",
		location: "Online (SEPMS Video Call)",
		sf: "true",
		output: "xml",
	});

	return `https://calendar.google.com/calendar/render?${params.toString()}`;
}

/**
 * Build an Outlook Web "Add Event" URL.
 */
function buildOutlookCalendarUrl(meeting: CalendarMeeting): string {
	const start = new Date(meeting.scheduledAt);
	const end = new Date(start.getTime() + meeting.durationMinutes * 60 * 1000);

	const params = new URLSearchParams({
		rru: "addevent",
		subject: meeting.title,
		startdt: start.toISOString(),
		enddt: end.toISOString(),
		body: meeting.notes ?? "SEPMS Video Meeting",
		location: "Online (SEPMS Video Call)",
		path: "/calendar/action/compose",
	});

	return `https://outlook.live.com/calendar/0/action/compose?${params.toString()}`;
}

export default function AddToCalendarDropdown({
	meeting,
}: {
	meeting: CalendarMeeting;
}) {
	const { user } = useAuth();
	const [open, setOpen] = useState(false);
	const [downloading, setDownloading] = useState(false);

	const handleDownloadIcs = useCallback(async () => {
		if (!user) return;
		setDownloading(true);
		try {
			const token = await user.getIdToken();
			const res = await fetch(`${API}/meetings/${meeting._id}/calendar.ics`, {
				headers: { Authorization: `Bearer ${token}` },
			});

			if (!res.ok) {
				toast.error("Failed to download calendar file");
				return;
			}

			const blob = await res.blob();
			const url = URL.createObjectURL(blob);
			const a = document.createElement("a");
			a.href = url;
			a.download = `meeting-${meeting._id}.ics`;
			document.body.appendChild(a);
			a.click();
			document.body.removeChild(a);
			URL.revokeObjectURL(url);
			toast.success("Calendar file downloaded!");
		} catch {
			toast.error("Failed to download calendar file");
		} finally {
			setDownloading(false);
			setOpen(false);
		}
	}, [user, meeting._id]);

	return (
		<div className="relative">
			<Button
				type="button"
				variant="outline"
				size="sm"
				className="gap-1.5 text-xs"
				onClick={() => setOpen(!open)}
			>
				<Calendar className="h-3.5 w-3.5" />
				Add to Calendar
				<ChevronDown className="h-3 w-3" />
			</Button>

			{open && (
				<>
					{/* Backdrop to close dropdown */}
					<button
						type="button"
						className="fixed inset-0 z-40 cursor-default"
						onClick={() => setOpen(false)}
						aria-label="Close calendar menu"
					/>

					<div className="absolute right-0 top-full mt-1.5 z-50 w-56 rounded-lg border bg-popover shadow-lg p-1.5 animate-in fade-in-0 zoom-in-95">
						{/* Google Calendar */}
						<a
							href={buildGoogleCalendarUrl(meeting)}
							target="_blank"
							rel="noopener noreferrer"
							className="flex items-center gap-2.5 px-3 py-2 text-sm rounded-md hover:bg-accent transition-colors"
							onClick={() => setOpen(false)}
						>
							<svg
								viewBox="0 0 24 24"
								className="h-4 w-4"
								fill="none"
								aria-hidden="true"
							>
								<title>Google Calendar</title>
								<rect x="5" y="10" width="14" height="9" rx="1" fill="white" />
								<rect x="7" y="5" width="2" height="4" rx="0.5" fill="white" />
								<rect x="15" y="5" width="2" height="4" rx="0.5" fill="white" />
								<rect
									x="7"
									y="12"
									width="3"
									height="2"
									rx="0.5"
									fill="#4285F4"
								/>
								<rect
									x="11"
									y="12"
									width="3"
									height="2"
									rx="0.5"
									fill="#EA4335"
								/>
								<rect
									x="7"
									y="15"
									width="3"
									height="2"
									rx="0.5"
									fill="#34A853"
								/>
								<rect
									x="11"
									y="15"
									width="3"
									height="2"
									rx="0.5"
									fill="#FBBC04"
								/>
							</svg>
							<span>Google Calendar</span>
							<ExternalLink className="h-3 w-3 ml-auto text-muted-foreground" />
						</a>

						{/* Outlook Calendar */}
						<a
							href={buildOutlookCalendarUrl(meeting)}
							target="_blank"
							rel="noopener noreferrer"
							className="flex items-center gap-2.5 px-3 py-2 text-sm rounded-md hover:bg-accent transition-colors"
							onClick={() => setOpen(false)}
						>
							<svg
								viewBox="0 0 24 24"
								className="h-4 w-4"
								fill="none"
								aria-hidden="true"
							>
								<title>Outlook Calendar</title>
								<rect x="5" y="10" width="14" height="9" rx="1" fill="white" />
								<rect x="7" y="5" width="2" height="4" rx="0.5" fill="white" />
								<rect x="15" y="5" width="2" height="4" rx="0.5" fill="white" />
								<rect
									x="7"
									y="12"
									width="3"
									height="2"
									rx="0.5"
									fill="#0078D4"
								/>
								<rect
									x="11"
									y="12"
									width="3"
									height="2"
									rx="0.5"
									fill="#0078D4"
								/>
								<rect
									x="7"
									y="15"
									width="3"
									height="2"
									rx="0.5"
									fill="#0078D4"
								/>
							</svg>
							<span>Outlook Calendar</span>
							<ExternalLink className="h-3 w-3 ml-auto text-muted-foreground" />
						</a>

						<div className="h-px bg-border my-1" />

						{/* Download .ics */}
						<button
							type="button"
							onClick={handleDownloadIcs}
							disabled={downloading}
							className="flex items-center gap-2.5 px-3 py-2 text-sm rounded-md hover:bg-accent transition-colors w-full text-left"
						>
							<Download className="h-4 w-4 text-muted-foreground" />
							<span>{downloading ? "Downloading…" : "Download .ics file"}</span>
						</button>
					</div>
				</>
			)}
		</div>
	);
}
