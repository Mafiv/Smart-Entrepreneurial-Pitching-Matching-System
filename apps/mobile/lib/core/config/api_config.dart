import 'dart:io';

import 'package:flutter/foundation.dart';
// Use dotenv if available at runtime to override API base URL for development.
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    /// Returns the effective API base URL.
    /// Preference order:
    /// 1. .env via flutter_dotenv (dotenv.env['API_BASE_URL']) if set
    /// 2. --dart-define via String.fromEnvironment('API_BASE_URL')
    /// 3. sensible debug defaults (10.0.2.2 or localhost)

    // Access dotenv only if it was loaded successfully. Calling
    // `dotenv.env` before `dotenv.load()` runs throws NotInitializedError
    // (which is what you saw in the logs). Prefer dart-define or debug
    // defaults when dotenv is not initialized.
    String? envDot;
    try {
      if (dotenv.isInitialized) {
        envDot = dotenv.env['API_BASE_URL'];
      }
    } catch (_) {
      // If any error occurs reading dotenv, ignore and fall back.
      envDot = null;
    }

    if (envDot != null && envDot.isNotEmpty) {
      return envDot;
    }

    const configuredBaseUrl =
        String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (configuredBaseUrl.isNotEmpty) {
      return configuredBaseUrl;
    }
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'https://sepms-backend.vercel.app/api';
      } else if (Platform.isIOS) {
        return 'https://sepms-backend.vercel.app/api';
      }
      return 'https://sepms-backend.vercel.app/api';
    }
    throw StateError(
      'API_BASE_URL must be provided via --dart-define in non-debug builds.',
    );
  }

  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String role = '/auth/role';

  // Users
  static const String usersMe = '/users/me';
  static const String usersMeProfile = '/users/me/profile';
  static const String usersMeAvatar = '/users/me/avatar';

  // Entrepreneur
  static const String entrepreneurProfile = '/entrepreneur/profile';
  static const String entrepreneurProfileCheck = '/entrepreneur/profile/check';

  // Investor
  static const String investorProfile = '/investor/profile';
  static const String investorSavedPitches = '/investor/saved-pitches';

  // Submissions
  static const String submissions = '/submissions';
  static const String submissionsFeedBrowse = '/submissions/feed/browse';
  static String submissionById(String id) => '/submissions/$id';
  static String submissionSubmit(String id) => '/submissions/$id/submit';
  static String submissionCompleteness(String id) =>
      '/submissions/$id/completeness';

  // Matching
  static String matchingRun(String submissionId) =>
      '/matching/submissions/$submissionId/run';
  static String matchingResults(String submissionId) =>
      '/matching/submissions/$submissionId';
  static const String matchingInvestorQueue = '/matching/me/investor';
  static String matchingStatus(String matchId) => '/matching/$matchId/status';

  // Invitations
  static const String invitations = '/invitations';
  static const String invitationsMe = '/invitations/me';
  static String invitationRespond(String invitationId) =>
      '/invitations/$invitationId/respond';
  static String invitationCancel(String invitationId) =>
      '/invitations/$invitationId/cancel';

  // Upload / Documents
  static const String upload = '/upload';
  static String uploadDelete(String publicId) => '/upload/$publicId';
  static const String documents = '/documents';
  static String documentById(String id) => '/documents/$id';
  static String documentValidation(String id) => '/documents/$id/validation';

  // Communication
  static const String meetings = '/meetings';
  static String meetingStatus(String meetingId) =>
      '/meetings/$meetingId/status';
  static const String conversations = '/messages/conversations';
  static String conversationById(String conversationId) =>
      '/messages/conversations/$conversationId';
  static String conversationMessages(String conversationId) =>
      '/messages/conversations/$conversationId/messages';
  static String conversationRead(String conversationId) =>
      '/messages/conversations/$conversationId/read';
  static String conversationReport(String conversationId) =>
      '/messages/conversations/$conversationId/report';
  static const String unreadCount = '/messages/unread-count';
  static const String notifications = '/messages/notifications';
  static String notificationRead(String notificationId) =>
      '/messages/notifications/$notificationId/read';

  // Feedback
  static const String feedback = '/feedback';
  static const String feedbackReceived = '/feedback/me/received';
  static const String feedbackGiven = '/feedback/me/given';
  static const String feedbackSummary = '/feedback/me/summary';

  // Milestones
  static const String milestones = '/milestones';
  static String milestoneById(String id) => '/milestones/$id';
  static String milestoneEvidence(String id) => '/milestones/$id/evidence';
  static String milestoneVerify(String id) => '/milestones/$id/verify';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
