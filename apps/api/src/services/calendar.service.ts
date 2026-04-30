/**
 * CalendarService
 *
 * Generates Google Calendar deep-links and RFC 5545 .ics files so that
 * scheduled meetings can be added to any calendar application.
 */

class CalendarServiceError extends Error {
	statusCode: number;

	constructor(message: string, statusCode: number) {
		super(message);
		this.name = "CalendarServiceError";
		this.statusCode = statusCode;
	}
}

/* ────────────────────────────────────────────────── helpers ── */

/** Format a JS Date to the compact UTC format Google Calendar expects. */
const toGoogleDateUTC = (d: Date): string =>
	d
		.toISOString()
		.replace(/[-:]/g, "")
		.replace(/\.\d{3}/, "");

/** Format a JS Date to the iCalendar DTSTART/DTEND format (UTC). */
const toIcsDateUTC = (d: Date): string =>
	d
		.toISOString()
		.replace(/[-:]/g, "")
		.replace(/\.\d{3}/, "");

/** Escape special chars inside iCalendar TEXT values (RFC 5545 §3.3.11). */
const escapeIcsText = (text: string): string =>
	text
		.replace(/\\/g, "\\\\")
		.replace(/;/g, "\\;")
		.replace(/,/g, "\\,")
		.replace(/\n/g, "\\n");

/** Fold long lines at 75 octets (RFC 5545 §3.1). */
const foldLine = (line: string): string => {
	const parts: string[] = [];
	let remaining = line;
	while (remaining.length > 75) {
		parts.push(remaining.slice(0, 75));
		remaining = ` ${remaining.slice(75)}`;
	}
	parts.push(remaining);
	return parts.join("\r\n");
};

/* ──────────────────────────────────────────── public API ── */

export const CalendarService = {
	createError(message: string, statusCode: number): CalendarServiceError {
		return new CalendarServiceError(message, statusCode);
	},

	isServiceError(error: unknown): error is CalendarServiceError {
		return error instanceof CalendarServiceError;
	},

	/**
	 * Build a Google Calendar "Add Event" URL.
	 *
	 * When opened in the browser the user's Google Calendar shows
	 * a pre-populated event creation form.
	 *
	 * @see https://support.google.com/calendar/answer/41207
	 */
	buildGoogleCalendarUrl(meeting: {
		title: string;
		scheduledAt: Date;
		durationMinutes: number;
		notes?: string | null;
		livekitRoomName?: string | null;
	}): string {
		const start = new Date(meeting.scheduledAt);
		const end = new Date(start.getTime() + meeting.durationMinutes * 60 * 1000);

		const details = [
			meeting.notes ?? "",
			meeting.livekitRoomName
				? `Join video call: In-app meeting room "${meeting.livekitRoomName}"`
				: "",
		]
			.filter(Boolean)
			.join("\n\n");

		const params = new URLSearchParams({
			action: "TEMPLATE",
			text: meeting.title,
			dates: `${toGoogleDateUTC(start)}/${toGoogleDateUTC(end)}`,
			details,
			location: "Online (SEPMS Video Call)",
			sf: "true",
			output: "xml",
		});

		return `https://calendar.google.com/calendar/render?${params.toString()}`;
	},

	/**
	 * Build an Outlook Web "Add Event" URL.
	 */
	buildOutlookCalendarUrl(meeting: {
		title: string;
		scheduledAt: Date;
		durationMinutes: number;
		notes?: string | null;
	}): string {
		const start = new Date(meeting.scheduledAt);
		const end = new Date(start.getTime() + meeting.durationMinutes * 60 * 1000);

		const params = new URLSearchParams({
			rru: "addevent",
			subject: meeting.title,
			startdt: start.toISOString(),
			enddt: end.toISOString(),
			body: meeting.notes ?? "",
			location: "Online (SEPMS Video Call)",
			path: "/calendar/action/compose",
		});

		return `https://outlook.live.com/calendar/0/action/compose?${params.toString()}`;
	},

	/**
	 * Generate an RFC 5545 iCalendar (.ics) string.
	 *
	 * This is a universal format supported by Google Calendar, Apple Calendar,
	 * Outlook, Thunderbird, and virtually every other calendar application.
	 */
	generateIcsFile(meeting: {
		_id?: string;
		title: string;
		scheduledAt: Date;
		durationMinutes: number;
		notes?: string | null;
		livekitRoomName?: string | null;
		organizerEmail?: string;
		attendeeEmails?: string[];
	}): string {
		const start = new Date(meeting.scheduledAt);
		const end = new Date(start.getTime() + meeting.durationMinutes * 60 * 1000);
		const now = new Date();

		const uid = meeting._id
			? `${meeting._id}@sepms.app`
			: `${Date.now()}-${Math.random().toString(36).slice(2)}@sepms.app`;

		const description = [
			meeting.notes ?? "",
			meeting.livekitRoomName
				? `Join video call in-app (room: ${meeting.livekitRoomName})`
				: "",
		]
			.filter(Boolean)
			.join("\\n\\n");

		const lines: string[] = [
			"BEGIN:VCALENDAR",
			"VERSION:2.0",
			"PRODID:-//SEPMS//Meeting Scheduler//EN",
			"CALSCALE:GREGORIAN",
			"METHOD:REQUEST",
			"BEGIN:VEVENT",
			`UID:${uid}`,
			`DTSTAMP:${toIcsDateUTC(now)}`,
			`DTSTART:${toIcsDateUTC(start)}`,
			`DTEND:${toIcsDateUTC(end)}`,
			`SUMMARY:${escapeIcsText(meeting.title)}`,
			`DESCRIPTION:${escapeIcsText(description)}`,
			`LOCATION:${escapeIcsText("Online (SEPMS Video Call)")}`,
			"STATUS:CONFIRMED",
			"SEQUENCE:0",
		];

		if (meeting.organizerEmail) {
			lines.push(`ORGANIZER;CN=SEPMS:mailto:${meeting.organizerEmail}`);
		}

		if (meeting.attendeeEmails) {
			for (const email of meeting.attendeeEmails) {
				lines.push(
					`ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE:mailto:${email}`,
				);
			}
		}

		// 15-minute reminder
		lines.push(
			"BEGIN:VALARM",
			"TRIGGER:-PT15M",
			"ACTION:DISPLAY",
			`DESCRIPTION:${escapeIcsText(meeting.title)} starts in 15 minutes`,
			"END:VALARM",
		);

		lines.push("END:VEVENT", "END:VCALENDAR");

		return lines.map(foldLine).join("\r\n");
	},

	/**
	 * Convenience method — returns all calendar link variants for a meeting.
	 */
	getCalendarLinks(meeting: {
		_id?: string;
		title: string;
		scheduledAt: Date;
		durationMinutes: number;
		notes?: string | null;
		livekitRoomName?: string | null;
	}) {
		return {
			googleCalendarUrl: CalendarService.buildGoogleCalendarUrl(meeting),
			outlookCalendarUrl: CalendarService.buildOutlookCalendarUrl(meeting),
		};
	},
};
