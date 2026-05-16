import {
	BarChart3,
	CalendarDays,
	Compass,
	FileText,
	Gauge,
	Heart,
	Mail,
	MessageCircle,
	PenTool,
	PieChart,
	Settings,
	ShieldAlert,
	Sparkles,
	UserCircle,
	Users,
	Wallet,
} from "lucide-react";

/** Translation key path within t.nav.* */
type NavKey =
	| "dashboard"
	| "newPitch"
	| "messages"
	| "meetings"
	| "milestones"
	| "earnings"
	| "invitations"
	| "profile"
	| "feed"
	| "myMatches"
	| "portfolio"
	| "saved"
	| "overview"
	| "finance"
	| "users"
	| "submissions"
	| "reports"
	| "settings";

export interface NavItem {
	/** English fallback label */
	label: string;
	/** i18n key in t.nav.* (used when language context is available) */
	labelKey: NavKey;
	href: string;
	icon: string | React.ReactNode;
}

/* ── Entrepreneur Sidebar Navigation ── */
export const ENTREPRENEUR_NAV: NavItem[] = [
	{
		label: "Dashboard",
		labelKey: "dashboard",
		href: "/entrepreneur/dashboard",
		icon: <Gauge className="h-4 w-4" />,
	},
	{
		label: "New Pitch",
		labelKey: "newPitch",
		href: "/entrepreneur/pitch/new",
		icon: <PenTool className="h-4 w-4" />,
	},
	{
		label: "Messages",
		labelKey: "messages",
		href: "/entrepreneur/messages",
		icon: <MessageCircle className="h-4 w-4" />,
	},
	{
		label: "Meetings",
		labelKey: "meetings",
		href: "/entrepreneur/meetings",
		icon: <CalendarDays className="h-4 w-4" />,
	},
	{
		label: "Milestones",
		labelKey: "milestones",
		href: "/entrepreneur/milestones",
		icon: <FileText className="h-4 w-4" />,
	},
	{
		label: "Earnings",
		labelKey: "earnings",
		href: "/entrepreneur/earnings",
		icon: <Wallet className="h-4 w-4" />,
	},
	{
		label: "Invitations",
		labelKey: "invitations",
		href: "/entrepreneur/invitations",
		icon: <Mail className="h-4 w-4" />,
	},
	{
		label: "Profile",
		labelKey: "profile",
		href: "/entrepreneur/profile",
		icon: <UserCircle className="h-4 w-4" />,
	},
];

/* ── Investor Sidebar Navigation ── */
export const INVESTOR_NAV: NavItem[] = [
	{
		label: "Feed",
		labelKey: "feed",
		href: "/investor/feed",
		icon: <Compass className="h-4 w-4" />,
	},
	{
		label: "My Matches",
		labelKey: "myMatches",
		href: "/investor/matches",
		icon: <Sparkles className="h-4 w-4" />,
	},
	{
		label: "Portfolio",
		labelKey: "portfolio",
		href: "/investor/portfolio",
		icon: <PieChart className="h-4 w-4" />,
	},
	{
		label: "Milestones",
		labelKey: "milestones",
		href: "/investor/milestones",
		icon: <FileText className="h-4 w-4" />,
	},
	{
		label: "Invitations",
		labelKey: "invitations",
		href: "/investor/invitations",
		icon: <Mail className="h-4 w-4" />,
	},
	{
		label: "Saved",
		labelKey: "saved",
		href: "/investor/saved",
		icon: <Heart className="h-4 w-4" />,
	},
	{
		label: "Messages",
		labelKey: "messages",
		href: "/investor/messages",
		icon: <MessageCircle className="h-4 w-4" />,
	},
	{
		label: "Profile",
		labelKey: "profile",
		href: "/investor/profile",
		icon: <UserCircle className="h-4 w-4" />,
	},
];

/* ── Admin Sidebar Navigation ── */
export const ADMIN_NAV: NavItem[] = [
	{
		label: "Overview",
		labelKey: "overview",
		href: "/admin/oversight",
		icon: <Gauge className="h-4 w-4" />,
	},
	{
		label: "Finance",
		labelKey: "finance",
		href: "/admin/finance",
		icon: <BarChart3 className="h-4 w-4" />,
	},
	{
		label: "Users",
		labelKey: "users",
		href: "/admin/users",
		icon: <Users className="h-4 w-4" />,
	},
	{
		label: "Submissions",
		labelKey: "submissions",
		href: "/admin/submissions",
		icon: <FileText className="h-4 w-4" />,
	},
	{
		label: "Reports",
		labelKey: "reports",
		href: "/admin/reports",
		icon: <ShieldAlert className="h-4 w-4" />,
	},
	{
		label: "Messages",
		labelKey: "messages",
		href: "/admin/messages",
		icon: <MessageCircle className="h-4 w-4" />,
	},
	{
		label: "Settings",
		labelKey: "settings",
		href: "/admin/settings",
		icon: <Settings className="h-4 w-4" />,
	},
];
