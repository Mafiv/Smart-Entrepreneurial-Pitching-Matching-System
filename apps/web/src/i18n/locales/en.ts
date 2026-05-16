/** English (default) translation dictionary */
const en = {
	// ── Common UI ──────────────────────────────────────────────────────────────
	common: {
		loading: "Loading...",
		save: "Save",
		cancel: "Cancel",
		confirm: "Confirm",
		delete: "Delete",
		edit: "Edit",
		submit: "Submit",
		search: "Search",
		back: "Back",
		next: "Next",
		close: "Close",
		yes: "Yes",
		no: "No",
		noResults: "No results found",
		error: "Something went wrong",
		success: "Success",
		viewAll: "View All",
		signOut: "Sign Out",
		signOutConfirm: "Are you sure you want to sign out of your account?",
		profile: "Profile",
		settings: "Settings",
	},

	// ── Navigation Labels ─────────────────────────────────────────────────────
	nav: {
		dashboard: "Dashboard",
		newPitch: "New Pitch",
		messages: "Messages",
		meetings: "Meetings",
		milestones: "Milestones",
		earnings: "Earnings",
		invitations: "Invitations",
		profile: "Profile",
		feed: "Feed",
		myMatches: "My Matches",
		portfolio: "Portfolio",
		saved: "Saved",
		overview: "Overview",
		finance: "Finance",
		users: "Users",
		submissions: "Submissions",
		reports: "Reports",
		settings: "Settings",
	},

	// ── Dashboard ─────────────────────────────────────────────────────────────
	dashboard: {
		welcome: "Welcome back",
		totalPitches: "Total Pitches",
		activePitches: "Active Pitches",
		pendingReview: "Pending Review",
		totalInvestors: "Total Investors",
		recentActivity: "Recent Activity",
		quickActions: "Quick Actions",
		availablePitches: "Available Pitches",
		savedPitches: "Saved",
		activeConversations: "Active Conversations",
	},

	// ── Pitch / Submission ────────────────────────────────────────────────────
	pitch: {
		title: "Title",
		summary: "Executive Summary",
		sector: "Sector",
		stage: "Stage",
		targetAmount: "Target Amount",
		problem: "The Problem",
		solution: "The Solution",
		businessModel: "Business Model",
		financials: "Financials",
		documents: "Documents",
		pitchVideo: "Pitch Video",
		status: "Status",
		submitted: "Submitted",
		approved: "Approved",
		underReview: "Under Review",
		draft: "Draft",
		rejected: "Rejected",
		noPitches: "No pitches found",
		viewFullPitch: "View Full Pitch",
		fundingAsk: "Funding Ask",
		capitalRequired: "Capital required",
		currentRevenue: "Current Revenue",
		projectedRevenue: "Projected Rev.",
		burnRate: "Burn Rate",
		runway: "Runway",
	},

	// ── Investor Feed ─────────────────────────────────────────────────────────
	feed: {
		discoveryFeed: "Discovery Feed",
		browseDescription:
			"Browse AI-scored pitches tailored to your investment preferences",
		available: "Available",
		filterBySector: "Filter by sector",
		sortBy: "Sort by",
		newestFirst: "Newest first",
		highestScore: "Highest score",
		highestAmount: "Highest amount",
		lowestAmount: "Lowest amount",
		allSectors: "All Sectors",
	},

	// ── Matching ──────────────────────────────────────────────────────────────
	match: {
		aiMatchScore: "AI Match Score",
		showBreakdown: "Show breakdown",
		hideBreakdown: "Hide breakdown",
		sectorFit: "Sector fit",
		stageFit: "Stage fit",
		budgetFit: "Budget fit",
		semanticAI: "Semantic (AI)",
		acceptMatch: "Accept Match",
		decline: "Decline",
		requestToInvest: "Request to Invest",
		investInProject: "Invest in this Project?",
		sendRequest:
			"Send an investment request to the entrepreneur to start funding.",
	},

	// ── Messages ──────────────────────────────────────────────────────────────
	messages: {
		chats: "Chats",
		noConversations: "No conversations yet",
		startConversation:
			"Start a conversation by messaging someone from a pitch page",
		selectConversation: "Select a conversation",
		chooseFromChats: "Choose from your existing chats to start messaging",
		typeMessage: "Type a message...",
		noMessages: "No messages yet",
		sayHello: "Say hello! 👋",
		frozen: "Frozen",
		conversationFrozen: "Conversation Frozen",
		frozenDescription:
			"This conversation has been reported and is under admin review.",
		translate: "Translate",
		hideTranslation: "Hide translation",
		messageFounder: "Message Founder",
		reportConversation: "Report Conversation",
		communicate: "Communicate securely with your connections",
	},

	// ── Meetings ──────────────────────────────────────────────────────────────
	meetings: {
		scheduleMeeting: "Schedule Meeting",
		joinNow: "Join Now",
		videoMeeting: "Video Meeting",
		meetingCancelled: "Meeting cancelled",
		meetingEnded: "Meeting ended",
		joinAppears: "Join button appears 15 min before start",
	},

	// ── AI Summary ────────────────────────────────────────────────────────────
	ai: {
		geminiSummary: "Gemini AI Pitch Summary",
		aiAnalyzing: "AI is analyzing your pitch...",
		generatingDescription:
			"Gemini is generating an investor-grade summary with strengths, risks, and market analysis. This usually takes 10–20 seconds.",
		summaryFailed: "Summary Generation Failed",
		retryGeneration: "Retry Generation",
		generateSummary: "Generate AI Summary",
		regenerate: "Regenerate",
		keyStrengths: "Key Strengths",
		keyRisks: "Key Risks",
		marketOpportunity: "Market Opportunity",
		investmentReadiness: "Investment Readiness",
		poweredBy: "Powered by Google Gemini",
		voiceSummaryEN: "AI Voice Summary (English)",
		voiceSummaryAM: "🇪🇹 Listen in Amharic (አማርኛ)",
		translatingToAmharic: "Translating to Amharic...",
		speaking: "Speaking...",
		amharicDescription: "AI translates & reads the summary in Amharic",
		aiMarketScore: "AI Market Score",
	},

	// ── Admin ─────────────────────────────────────────────────────────────────
	admin: {
		adminOverview: "Admin Overview",
		monitorPlatform:
			"Monitor platform health, manage users, and review KYC submissions",
		systemOnline: "System Online",
		totalUsers: "Total Users",
		entrepreneurs: "Entrepreneurs",
		investors: "Investors",
		pendingKYC: "Pending KYC",
		needsReview: "Needs review",
		approvalQueues: "Approval Queues",
		userManagement: "User Management",
		auditLog: "Audit Log",
		suspend: "Suspend",
		activate: "Activate",
		override: "Override AI Decision",
		manage: "Manage",
		reviewKYC: "Review KYC",
		name: "Name",
		email: "Email",
		role: "Role",
		status: "Status",
		joined: "Joined",
		actions: "Actions",
		noUsersFound: "No users found",
		manageAdmins: "Manage Admins",
		kycQueue: "KYC Queue",
		pendingKYCReviews: "Pending KYC Reviews",
		allCaughtUp: "All caught up!",
		noPendingKYC: "No pending KYC reviews at the moment.",
		approve: "Approve",
		reject: "Reject",
		verify: "Verify",
	},

	// ── Language ──────────────────────────────────────────────────────────────
	language: {
		english: "English",
		amharic: "አማርኛ",
		switchLanguage: "Switch language",
	},
} as const;

export default en;

/** Recursively widen all string literal types to `string` */
type DeepStringify<T> = {
	[K in keyof T]: T[K] extends string ? string : DeepStringify<T[K]>;
};

export type TranslationDictionary = DeepStringify<typeof en>;
