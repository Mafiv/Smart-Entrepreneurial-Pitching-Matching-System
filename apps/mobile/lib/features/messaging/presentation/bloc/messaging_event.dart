part of 'messaging_bloc.dart';

abstract class MessagingEvent extends Equatable {
  const MessagingEvent();
  @override
  List<Object?> get props => [];
}

class ConversationsRequested extends MessagingEvent {
  const ConversationsRequested();
}

class MessagesRequested extends MessagingEvent {
  final String conversationId;
  final int? page;
  final int? limit;
  /// When true, do not flip the bloc into a loading state. Used by polling.
  final bool silent;
  const MessagesRequested(
    this.conversationId, {
    this.page,
    this.limit,
    this.silent = false,
  });
  @override
  List<Object?> get props => [conversationId, page, limit, silent];
}

class MessageSendRequested extends MessagingEvent {
  final String conversationId;
  final String body;
  final String type;
  final String? attachmentUrl;
  const MessageSendRequested({
    required this.conversationId,
    required this.body,
    this.type = 'text',
    this.attachmentUrl,
  });
  @override
  List<Object?> get props => [conversationId, body, type, attachmentUrl];
}

class ConversationReportRequested extends MessagingEvent {
  final String conversationId;
  final String reason;
  final String? details;
  const ConversationReportRequested({
    required this.conversationId,
    required this.reason,
    this.details,
  });
  @override
  List<Object?> get props => [conversationId, reason, details];
}

class ConversationReadRequested extends MessagingEvent {
  final String conversationId;
  const ConversationReadRequested(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

class UnreadCountRequested extends MessagingEvent {
  const UnreadCountRequested();
}

class NotificationsRequested extends MessagingEvent {
  const NotificationsRequested();
}

class NotificationReadRequested extends MessagingEvent {
  final String notificationId;
  const NotificationReadRequested(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

