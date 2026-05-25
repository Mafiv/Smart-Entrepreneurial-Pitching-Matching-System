import {
	AlertTriangle,
	Bookmark,
	BriefcaseBusiness,
	CalendarRange,
	CircleDollarSign,
	FileStack,
	Inbox,
	Landmark,
	LayoutDashboard,
	MessageSquare,
	Rocket,
	SlidersHorizontal,
	Target,
	Telescope,
	User,
	UsersRound,
	Zap,
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
		icon: <LayoutDashboard className="h-4 w-4" />,
	},
	{
		label: "New Pitch",
		labelKey: "newPitch",
		href: "/entrepreneur/pitch/new",
		icon: <Rocket className="h-4 w-4" />,
	},
	{
		label: "Messages",
		labelKey: "messages",
		href: "/entrepreneur/messages",
		icon: <MessageSquare className="h-4 w-4" />,
	},
	{
		label: "Meetings",
		labelKey: "meetings",
		href: "/entrepreneur/meetings",
		icon: <CalendarRange className="h-4 w-4" />,
	},
	{
		label: "Milestones",
		labelKey: "milestones",
		href: "/entrepreneur/milestones",
		icon: <Target className="h-4 w-4" />,
	},
	{
		label: "Earnings",
		labelKey: "earnings",
		href: "/entrepreneur/earnings",
		icon: <CircleDollarSign className="h-4 w-4" />,
	},
	{
		label: "Invitations",
		labelKey: "invitations",
		href: "/entrepreneur/invitations",
		icon: <Inbox className="h-4 w-4" />,
	},
	{
		label: "Profile",
		labelKey: "profile",
		href: "/entrepreneur/profile",
		icon: <User className="h-4 w-4" />,
	},
];

/* ── Investor Sidebar Navigation ── */
export const INVESTOR_NAV: NavItem[] = [
	{
		label: "Feed",
		labelKey: "feed",
		href: "/investor/feed",
		icon: <Telescope className="h-4 w-4" />,
	},
	{
		label: "My Matches",
		labelKey: "myMatches",
		href: "/investor/matches",
		icon: <Zap className="h-4 w-4" />,
	},
	{
		label: "Portfolio",
		labelKey: "portfolio",
		href: "/investor/portfolio",
		icon: <BriefcaseBusiness className="h-4 w-4" />,
	},
	{
		label: "Milestones",
		labelKey: "milestones",
		href: "/investor/milestones",
		icon: <Target className="h-4 w-4" />,
	},
	{
		label: "Invitations",
		labelKey: "invitations",
		href: "/investor/invitations",
		icon: <Inbox className="h-4 w-4" />,
	},
	{
		label: "Saved",
		labelKey: "saved",
		href: "/investor/saved",
		icon: <Bookmark className="h-4 w-4" />,
	},
	{
		label: "Messages",
		labelKey: "messages",
		href: "/investor/messages",
		icon: <MessageSquare className="h-4 w-4" />,
	},
	{
		label: "Profile",
		labelKey: "profile",
		href: "/investor/profile",
		icon: <User className="h-4 w-4" />,
	},
];

/* ── Admin Sidebar Navigation ── */
export const ADMIN_NAV: NavItem[] = [
	{
		label: "Overview",
		labelKey: "overview",
		href: "/admin/oversight",
		icon: <LayoutDashboard className="h-4 w-4" />,
	},
	{
		label: "Finance",
		labelKey: "finance",
		href: "/admin/finance",
		icon: <Landmark className="h-4 w-4" />,
	},
	{
		label: "Users",
		labelKey: "users",
		href: "/admin/users",
		icon: <UsersRound className="h-4 w-4" />,
	},
	{
		label: "Submissions",
		labelKey: "submissions",
		href: "/admin/submissions",
		icon: <FileStack className="h-4 w-4" />,
	},
	{
		label: "Reports",
		labelKey: "reports",
		href: "/admin/reports",
		icon: <AlertTriangle className="h-4 w-4" />,
	},
	{
		label: "Messages",
		labelKey: "messages",
		href: "/admin/messages",
		icon: <MessageSquare className="h-4 w-4" />,
	},
	{
		label: "Profile",
		labelKey: "profile",
		href: "/admin/profile",
		icon: <User className="h-4 w-4" />,
	},
	{
		label: "Settings",
		labelKey: "settings",
		href: "/admin/settings",
		icon: <SlidersHorizontal className="h-4 w-4" />,
	},
];
