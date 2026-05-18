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

/* ── Entrepreneur Sidebar Navigation ── */
export const ENTREPRENEUR_NAV = [
	{
		label: "Dashboard",
		href: "/entrepreneur/dashboard",
		icon: <LayoutDashboard className="h-4 w-4" />,
	},
	{
		label: "New Pitch",
		href: "/entrepreneur/pitch/new",
		icon: <Rocket className="h-4 w-4" />,
	},
	{
		label: "Messages",
		href: "/entrepreneur/messages",
		icon: <MessageSquare className="h-4 w-4" />,
	},
	{
		label: "Meetings",
		href: "/entrepreneur/meetings",
		icon: <CalendarRange className="h-4 w-4" />,
	},
	{
		label: "Milestones",
		href: "/entrepreneur/milestones",
		icon: <Target className="h-4 w-4" />,
	},
	{
		label: "Earnings",
		href: "/entrepreneur/earnings",
		icon: <CircleDollarSign className="h-4 w-4" />,
	},
	{
		label: "Invitations",
		href: "/entrepreneur/invitations",
		icon: <Inbox className="h-4 w-4" />,
	},
	{
		label: "Profile",
		href: "/entrepreneur/profile",
		icon: <User className="h-4 w-4" />,
	},
];

/* ── Investor Sidebar Navigation ── */
export const INVESTOR_NAV = [
	{
		label: "Feed",
		href: "/investor/feed",
		icon: <Telescope className="h-4 w-4" />,
	},
	{
		label: "My Matches",
		href: "/investor/matches",
		icon: <Zap className="h-4 w-4" />,
	},
	{
		label: "Portfolio",
		href: "/investor/portfolio",
		icon: <BriefcaseBusiness className="h-4 w-4" />,
	},
	{
		label: "Milestones",
		href: "/investor/milestones",
		icon: <Target className="h-4 w-4" />,
	},
	{
		label: "Invitations",
		href: "/investor/invitations",
		icon: <Inbox className="h-4 w-4" />,
	},
	{
		label: "Saved",
		href: "/investor/saved",
		icon: <Bookmark className="h-4 w-4" />,
	},
	{
		label: "Messages",
		href: "/investor/messages",
		icon: <MessageSquare className="h-4 w-4" />,
	},
	{
		label: "Profile",
		href: "/investor/profile",
		icon: <User className="h-4 w-4" />,
	},
];

/* ── Admin Sidebar Navigation ── */
export const ADMIN_NAV = [
	{
		label: "Overview",
		href: "/admin/oversight",
		icon: <LayoutDashboard className="h-4 w-4" />,
	},
	{
		label: "Finance",
		href: "/admin/finance",
		icon: <Landmark className="h-4 w-4" />,
	},
	{
		label: "Users",
		href: "/admin/users",
		icon: <UsersRound className="h-4 w-4" />,
	},
	{
		label: "Submissions",
		href: "/admin/submissions",
		icon: <FileStack className="h-4 w-4" />,
	},
	{
		label: "Reports",
		href: "/admin/reports",
		icon: <AlertTriangle className="h-4 w-4" />,
	},
	{
		label: "Messages",
		href: "/admin/messages",
		icon: <MessageSquare className="h-4 w-4" />,
	},
	{
		label: "Profile",
		href: "/admin/profile",
		icon: <User className="h-4 w-4" />,
	},
	{
		label: "Settings",
		href: "/admin/settings",
		icon: <SlidersHorizontal className="h-4 w-4" />,
	},
];
