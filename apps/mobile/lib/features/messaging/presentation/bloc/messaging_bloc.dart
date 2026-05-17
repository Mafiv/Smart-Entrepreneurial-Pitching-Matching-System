import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/messaging_usecases.dart';

part 'messaging_event.dart';
part 'messaging_state.dart';

class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {
  final ListConversationsUseCase _listConversations;
  final ListMessagesUseCase _listMessages;
  final SendMessageUseCase _sendMessage;
  final MarkConversationReadUseCase _markRead;
  final ReportConversationUseCase _reportConversation;
  final UnreadCountUseCase _unreadCount;
  final ListNotificationsUseCase _listNotifications;
  final MarkNotificationReadUseCase _markNotificationRead;

  MessagingBloc({
    required ListConversationsUseCase listConversations,
    required ListMessagesUseCase listMessages,
    required SendMessageUseCase sendMessage,
    required MarkConversationReadUseCase markRead,
    required ReportConversationUseCase reportConversation,
    required UnreadCountUseCase unreadCount,
    required ListNotificationsUseCase listNotifications,
    required MarkNotificationReadUseCase markNotificationRead,
  })  : _listConversations = listConversations,
        _listMessages = listMessages,
        _sendMessage = sendMessage,
        _markRead = markRead,
        _reportConversation = reportConversation,
        _unreadCount = unreadCount,
        _listNotifications = listNotifications,
        _markNotificationRead = markNotificationRead,
        super(const MessagingState.initial()) {
    on<ConversationsRequested>(_onConversations);
    on<MessagesRequested>(_onMessages);
    on<MessageSendRequested>(_onSend);
    on<ConversationReadRequested>(_onMarkRead);
    on<ConversationReportRequested>(_onReport);
    on<UnreadCountRequested>(_onUnread);
    on<NotificationsRequested>(_onNotifications);
    on<NotificationReadRequested>(_onNotificationRead);
  }

  Future<void> _onConversations(
    ConversationsRequested event,
    Emitter<MessagingState> emit,
  ) async {
    emit(state.copyWith(status: MessagingStatus.loading, error: null));
    final result = await _listConversations();
    result.fold(
      (f) => emit(state.copyWith(status: MessagingStatus.error, error: f.message)),
      (items) => emit(state.copyWith(
        status: MessagingStatus.conversationsLoaded,
        conversations: items,
      )),
    );
  }

  Future<void> _onMessages(MessagesRequested event, Emitter<MessagingState> emit) async {
    if (!event.silent) {
      emit(state.copyWith(status: MessagingStatus.loading, error: null));
    }
    final result = await _listMessages(
      event.conversationId,
      page: event.page,
      limit: event.limit,
    );
    result.fold(
      (f) {
        if (!event.silent) {
          emit(state.copyWith(status: MessagingStatus.error, error: f.message));
        }
      },
      (items) => emit(state.copyWith(
        status: MessagingStatus.messagesLoaded,
        conversationId: event.conversationId,
        messages: items,
      )),
    );
  }

  Future<void> _onSend(MessageSendRequested event, Emitter<MessagingState> emit) async {
    emit(state.copyWith(isSending: true, error: null));
    final result = await _sendMessage(
      event.conversationId,
      body: event.body,
      type: event.type,
      attachmentUrl: event.attachmentUrl,
    );
    result.fold(
      (f) => emit(state.copyWith(
        isSending: false,
        status: MessagingStatus.error,
        error: f.message,
      )),
      (_) {
        emit(state.copyWith(isSending: false));
        add(MessagesRequested(event.conversationId, silent: true));
      },
    );
  }

  Future<void> _onReport(
    ConversationReportRequested event,
    Emitter<MessagingState> emit,
  ) async {
    emit(state.copyWith(isSending: true, error: null));
    final result = await _reportConversation(
      event.conversationId,
      reason: event.reason,
      details: event.details,
    );
    result.fold(
      (f) => emit(state.copyWith(
        isSending: false,
        status: MessagingStatus.error,
        error: f.message,
      )),
      (_) => emit(state.copyWith(
        isSending: false,
        status: MessagingStatus.reportSubmitted,
      )),
    );
  }

  Future<void> _onMarkRead(
    ConversationReadRequested event,
    Emitter<MessagingState> emit,
  ) async {
    final result = await _markRead(event.conversationId);
    result.fold(
      (f) => emit(state.copyWith(error: f.message)),
      (_) {},
    );
  }

  Future<void> _onUnread(UnreadCountRequested event, Emitter<MessagingState> emit) async {
    final result = await _unreadCount();
    result.fold(
      (f) => emit(state.copyWith(error: f.message)),
      (count) => emit(state.copyWith(unreadCount: count)),
    );
  }

  Future<void> _onNotifications(
    NotificationsRequested event,
    Emitter<MessagingState> emit,
  ) async {
    emit(state.copyWith(status: MessagingStatus.loading, error: null));
    final result = await _listNotifications();
    result.fold(
      (f) => emit(state.copyWith(status: MessagingStatus.error, error: f.message)),
      (items) => emit(state.copyWith(
        status: MessagingStatus.notificationsLoaded,
        notifications: items,
      )),
    );
  }

  Future<void> _onNotificationRead(
    NotificationReadRequested event,
    Emitter<MessagingState> emit,
  ) async {
    final result = await _markNotificationRead(event.notificationId);
    result.fold(
      (f) => emit(state.copyWith(error: f.message)),
      (_) => add(const NotificationsRequested()),
    );
  }
}

