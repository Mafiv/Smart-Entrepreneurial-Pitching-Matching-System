import 'urls.dart';

class ApiConfig {
  ApiConfig._();

  /// When enabled, the app will bypass real HTTP calls in remote data-sources
  /// and return deterministic mock responses instead (useful for UI preview).
  ///
  /// **Mock email sign-in:** use an address whose local part (before `@`) is
  /// `investor`, e.g. `investor@test.com`, with any password to open the investor
  /// shell. Any other local part behaves as entrepreneur.
  static const bool useMockData = true;

  /// Artificial latency to better simulate real network calls in mock mode.
  static const Duration mockLatency = Duration(milliseconds: 350);

  /// Base URL for all API requests - centralized in Urls class
  static String get baseUrl => Urls.baseUrl;

  // ============================================================================
  // ENDPOINT SHORTCUTS - Delegate to Urls class for consistency
  // ============================================================================

  /// Auth endpoints
  static String get register => Urls.authRegister;
  static String get authMe => Urls.authMe;

  /// User endpoints
  static String get usersMe => '/users/me';
  static String get usersMeProfile => '/users/me/profile';
  static String get usersMeAvatar => '/users/me/avatar';

  /// Entrepreneur endpoints
  static String get entrepreneurProfile => '/entrepreneur/profile';
  static String get entrepreneurProfileCheck => '/entrepreneur/profile/check';

  /// Investor endpoints
  static String get investorProfile => '/investor/profile';
  static String get investorSavedPitches => '/investor/saved-pitches';

  /// Pitch/Submission endpoints
  static String get submissions => '/submissions';
  static String get submissionsFeedBrowse => '/submissions/feed/browse';
  static String submissionById(String id) => '/submissions/$id';
  static String submissionSubmit(String id) => '/submissions/$id/submit';
  static String submissionCompleteness(String id) => '/submissions/$id/completeness';

  /// Matching endpoints
  static String matchingRun(String submissionId) =>
      '/matching/submissions/$submissionId/run';
  static String matchingResults(String submissionId) =>
      '/matching/submissions/$submissionId';
  static String get matchingInvestorQueue => '/matching/me/investor';
  static String matchingStatus(String matchId) => '/matching/$matchId/status';
  static String get matchesCount => '/recommendation/matches/count';

  /// Invitation endpoints
  static String get invitations => '/invitations';
  static String get invitationsMe => '/invitations/me';
  static String invitationRespond(String invitationId) =>
      '/invitations/$invitationId/respond';
  static String invitationCancel(String invitationId) =>
      '/invitations/$invitationId/cancel';

  /// Upload/Document endpoints
  static String get upload => '/upload';
  static String uploadDocument(String documentId) => '/documents/$documentId';
  static String get documents => '/documents';
  static String documentById(String documentId) => '/documents/$documentId';
  static String documentDownload(String documentId) =>
      '/documents/$documentId/download';

  /// Finance/Earnings endpoints
  static String get entrepreneurSummary => '/finance/entrepreneur-summary';

  /// Communication endpoints
  static String get meetings => Urls.listMeetings;
  static String meetingStatus(String meetingId) =>
      '/meetings/$meetingId/status';
  static String get conversations => Urls.listConversations;
  static String conversationById(String conversationId) =>
      '/messages/conversations/$conversationId';
  static String conversationMessages(String conversationId) =>
      '/messages/conversations/$conversationId/messages';
  static String conversationRead(String conversationId) =>
      '/messages/conversations/$conversationId/read';
  static String conversationReport(String conversationId) =>
      '/messages/conversations/$conversationId/report';
  static String get unreadCount => '/messages/unread-count';
  static String get notifications => '/messages/notifications';
  static String notificationRead(String notificationId) =>
      '/messages/notifications/$notificationId/read';

  /// Feedback endpoints
  static String get feedback => Urls.submitFeedback;
  static String get feedbackReceived => Urls.getFeedbackReceived;
  static String get feedbackGiven => Urls.getFeedbackGiven;
  static String get feedbackSummary => Urls.getFeedbackSummary;

  /// Milestones endpoints
  static String get milestones => Urls.listMilestones;
  static String milestoneById(String id) =>
      Urls.buildUrl(Urls.updateMilestone, id);
  static String milestoneEvidence(String id) =>
      '/milestones/$id/evidence';
  static String milestoneVerify(String id) =>
      '/milestones/$id/verify';

  /// Connection timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
