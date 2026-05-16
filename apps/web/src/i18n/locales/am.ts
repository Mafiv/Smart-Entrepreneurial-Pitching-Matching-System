import type { TranslationDictionary } from "./en";

/** Amharic (አማርኛ) translation dictionary */
const am: TranslationDictionary = {
	// ── Common UI ──────────────────────────────────────────────────────────────
	common: {
		loading: "እየጫነ ነው...",
		save: "አስቀምጥ",
		cancel: "ሰርዝ",
		confirm: "አረጋግጥ",
		delete: "ሰርዝ",
		edit: "አርትዕ",
		submit: "አስገባ",
		search: "ፈልግ",
		back: "ተመለስ",
		next: "ቀጥል",
		close: "ዝጋ",
		yes: "አዎ",
		no: "አይ",
		noResults: "ምንም ውጤት አልተገኘም",
		error: "የሆነ ችግር ተፈጥሯል",
		success: "ተሳክቷል",
		viewAll: "ሁሉንም ይመልከቱ",
		signOut: "ውጣ",
		signOutConfirm: "ከመለያዎ መውጣት እንደሚፈልጉ እርግጠኛ ነዎት?",
		profile: "መገለጫ",
		settings: "ቅንብሮች",
	},

	// ── Navigation Labels ─────────────────────────────────────────────────────
	nav: {
		dashboard: "ዳሽቦርድ",
		newPitch: "አዲስ ፒች",
		messages: "መልእክቶች",
		meetings: "ስብሰባዎች",
		milestones: "ደረጃዎች",
		earnings: "ገቢዎች",
		invitations: "ግብዣዎች",
		profile: "መገለጫ",
		feed: "ፊድ",
		myMatches: "ግጥሚያዎቼ",
		portfolio: "ፖርትፎሊዮ",
		saved: "የተቀመጡ",
		overview: "አጠቃላይ እይታ",
		finance: "ፋይናንስ",
		users: "ተጠቃሚዎች",
		submissions: "ማስገቢያዎች",
		reports: "ሪፖርቶች",
		settings: "ቅንብሮች",
	},

	// ── Dashboard ─────────────────────────────────────────────────────────────
	dashboard: {
		welcome: "እንኳን ደህና ተመለሱ",
		totalPitches: "ጠቅላላ ፒቾች",
		activePitches: "ንቁ ፒቾች",
		pendingReview: "በመገምገም ላይ",
		totalInvestors: "ጠቅላላ ባለሃብቶች",
		recentActivity: "የቅርብ ጊዜ እንቅስቃሴ",
		quickActions: "ፈጣን ድርጊቶች",
		availablePitches: "ያሉ ፒቾች",
		savedPitches: "የተቀመጡ",
		activeConversations: "ንቁ ውይይቶች",
	},

	// ── Pitch / Submission ────────────────────────────────────────────────────
	pitch: {
		title: "ርዕስ",
		summary: "አስፈፃሚ ማጠቃለያ",
		sector: "ዘርፍ",
		stage: "ደረጃ",
		targetAmount: "ዒላማ መጠን",
		problem: "ችግሩ",
		solution: "መፍትሄው",
		businessModel: "የንግድ ሞዴል",
		financials: "ፋይናንሻል",
		documents: "ሰነዶች",
		pitchVideo: "የፒች ቪዲዮ",
		status: "ሁኔታ",
		submitted: "ቀርቧል",
		approved: "ጸድቋል",
		underReview: "በግምገማ ላይ",
		draft: "ረቂቅ",
		rejected: "ተቀባይነት አላገኘም",
		noPitches: "ምንም ፒች አልተገኘም",
		viewFullPitch: "ሙሉ ፒቹን ይመልከቱ",
		fundingAsk: "የገንዘብ ጥያቄ",
		capitalRequired: "የሚያስፈልግ ካፒታል",
		currentRevenue: "የአሁን ገቢ",
		projectedRevenue: "ትንበያ ገቢ",
		burnRate: "የወጪ ፍጥነት",
		runway: "ራንዌይ",
	},

	// ── Investor Feed ─────────────────────────────────────────────────────────
	feed: {
		discoveryFeed: "ግኝት ፊድ",
		browseDescription: "ለኢንቨስትመንት ምርጫዎ በ AI የተመዘኑ ፒቾችን ያስሱ",
		available: "ያሉ",
		filterBySector: "በዘርፍ አጣራ",
		sortBy: "አስተካክል",
		newestFirst: "አዲስ ቀዳሚ",
		highestScore: "ከፍተኛ ነጥብ",
		highestAmount: "ከፍተኛ መጠን",
		lowestAmount: "ዝቅተኛ መጠን",
		allSectors: "ሁሉም ዘርፎች",
	},

	// ── Matching ──────────────────────────────────────────────────────────────
	match: {
		aiMatchScore: "የ AI ግጥሚያ ነጥብ",
		showBreakdown: "ዝርዝር አሳይ",
		hideBreakdown: "ዝርዝር ደብቅ",
		sectorFit: "የዘርፍ ተስማሚነት",
		stageFit: "የደረጃ ተስማሚነት",
		budgetFit: "የበጀት ተስማሚነት",
		semanticAI: "ትርጉም (AI)",
		acceptMatch: "ግጥሚያ ተቀበል",
		decline: "ውድቅ",
		requestToInvest: "ኢንቨስት ለማድረግ ጥይቄ",
		investInProject: "በዚህ ፕሮጀክት ኢንቨስት ማድረግ ይፈልጋሉ?",
		sendRequest: "ለስራ ፈጣሪው የኢንቨስትመንት ጥያቄ ይላኩ።",
	},

	// ── Messages ──────────────────────────────────────────────────────────────
	messages: {
		chats: "ውይይቶች",
		noConversations: "ገና ምንም ውይይት የለም",
		startConversation: "ከፒች ገጽ ላይ ለአንድ ሰው መልእክት በመላክ ውይይት ይጀምሩ",
		selectConversation: "ውይይት ይምረጡ",
		chooseFromChats: "ከነባር ውይይቶችዎ ይምረጡ",
		typeMessage: "መልእክት ይጻፉ...",
		noMessages: "ገና ምንም መልእክት የለም",
		sayHello: "ሰላም ይበሉ! 👋",
		frozen: "ቀዝቅዟል",
		conversationFrozen: "ውይይት ቀዝቅዟል",
		frozenDescription: "ይህ ውይይት ሪፖርት ተደርጎ በአስተዳዳሪ ግምገማ ላይ ነው።",
		translate: "ተርጉም",
		hideTranslation: "ትርጉም ደብቅ",
		messageFounder: "ለመስራች ይጻፉ",
		reportConversation: "ውይይት ሪፖርት ያድርጉ",
		communicate: "ከግንኙነቶችዎ ጋር በደህና ይግባቡ",
	},

	// ── Meetings ──────────────────────────────────────────────────────────────
	meetings: {
		scheduleMeeting: "ስብሰባ ቀጠሮ ያስይዙ",
		joinNow: "አሁን ይቀላቀሉ",
		videoMeeting: "ቪዲዮ ስብሰባ",
		meetingCancelled: "ስብሰባው ተሰርዟል",
		meetingEnded: "ስብሰባው ተጠናቋል",
		joinAppears: "የመቀላቀያ ቁልፍ ከመጀመሩ 15 ደቂቃ በፊት ይታያል",
	},

	// ── AI Summary ────────────────────────────────────────────────────────────
	ai: {
		geminiSummary: "Gemini AI የፒች ማጠቃለያ",
		aiAnalyzing: "AI ፒችዎን እየተነተነ ነው...",
		generatingDescription:
			"Gemini ጥንካሬዎችን፣ ስጋቶችን እና የገበያ ትንታኔን ያካተተ ለባለሃብቶች የሚያገለግል ማጠቃለያ እየፈጠረ ነው። ይህ ብዙውን ጊዜ ከ10-20 ሰከንድ ይወስዳል።",
		summaryFailed: "ማጠቃለያ ማመንጨት አልተሳካም",
		retryGeneration: "ድጋሚ ሞክር",
		generateSummary: "AI ማጠቃለያ ይፍጠሩ",
		regenerate: "ድጋሚ ፍጠር",
		keyStrengths: "ዋና ጥንካሬዎች",
		keyRisks: "ዋና ስጋቶች",
		marketOpportunity: "የገበያ ዕድል",
		investmentReadiness: "የኢንቨስትመንት ዝግጁነት",
		poweredBy: "በ Google Gemini ያለ",
		voiceSummaryEN: "AI ድምፅ ማጠቃለያ (English)",
		voiceSummaryAM: "🇪🇹 በአማርኛ ያዳምጡ (አማርኛ)",
		translatingToAmharic: "ወደ አማርኛ በመተርጎም ላይ...",
		speaking: "እየተናገረ...",
		amharicDescription: "AI ማጠቃለያውን ተርጉሞ በአማርኛ ያነባል",
		aiMarketScore: "AI የገበያ ነጥብ",
	},

	// ── Admin ─────────────────────────────────────────────────────────────────
	admin: {
		approvalQueues: "የማጽደቂያ ተራ",
		userManagement: "ተጠቃሚ አስተዳደር",
		auditLog: "የኦዲት ሪከርድ",
		suspend: "አገድ",
		activate: "አግብር",
		override: "AI ውሳኔ ሻር",
	},

	// ── Language ──────────────────────────────────────────────────────────────
	language: {
		english: "English",
		amharic: "አማርኛ",
		switchLanguage: "ቋንቋ ቀይር",
	},
};

export default am;
