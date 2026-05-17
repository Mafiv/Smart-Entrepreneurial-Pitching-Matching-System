import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../bloc/messaging_bloc.dart';

/// Premium chat experience for the entrepreneur (and investor) flow.
/// Mirrors the web `/entrepreneur/messages` chat:
///   * date separators
///   * read receipts driven by the current authenticated user
///   * report misconduct dialog wired to the API
///   * frozen-conversation banner for archived threads
///   * background polling for new messages
class ChatPage extends StatefulWidget {
  final String conversationId;
  final ConversationEntity? conversation;

  const ChatPage({
    super.key,
    required this.conversationId,
    this.conversation,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<MessagingBloc>();
    bloc.add(MessagesRequested(widget.conversationId, page: 1, limit: 50));
    bloc.add(ConversationReadRequested(widget.conversationId));
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      context.read<MessagingBloc>().add(
            MessagesRequested(
              widget.conversationId,
              page: 1,
              limit: 50,
              silent: true,
            ),
          );
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    HapticFeedback.lightImpact();
    context.read<MessagingBloc>().add(
          MessageSendRequested(
            conversationId: widget.conversationId,
            body: text,
          ),
        );
    // Scroll to bottom (which is `0` because list is reversed) on next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _openReportDialog() async {
    final reasonCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final messagingBloc = context.read<MessagingBloc>();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.shield_outlined, color: AppColors.destructive),
              SizedBox(width: 8),
              Flexible(child: Text('Report misconduct')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Report suspicious or inappropriate behaviour. The conversation will be frozen and an admin will be alerted for urgent review.',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                ),
                AppSpacing.gapMd,
                AppTextField(
                  label: 'Reason',
                  hint: 'e.g., Harassment, demands outside platform, fraud',
                  controller: reasonCtrl,
                ),
                AppSpacing.gapSm,
                AppTextField(
                  label: 'Additional details',
                  hint: 'Provide any additional context or evidence…',
                  controller: detailsCtrl,
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.destructive,
              ),
              onPressed: () {
                if (reasonCtrl.text.trim().isEmpty) return;
                Navigator.of(ctx).pop(true);
              },
              icon: const Icon(Icons.flag_outlined, size: 16),
              label: const Text('Submit report'),
            ),
          ],
        );
      },
    );

    if (submitted == true) {
      messagingBloc.add(
        ConversationReportRequested(
          conversationId: widget.conversationId,
          reason: reasonCtrl.text.trim(),
          details: detailsCtrl.text.trim().isEmpty
              ? null
              : detailsCtrl.text.trim(),
        ),
      );
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Report submitted. The conversation has been frozen and an admin alerted.',
          ),
        ),
      );
    }
    reasonCtrl.dispose();
    detailsCtrl.dispose();
  }

  bool get _isFrozen {
    final raw = widget.conversation?.data['isArchived'];
    return raw == true;
  }

  String get _otherName {
    return widget.conversation?.otherUserName.isNotEmpty == true
        ? widget.conversation!.otherUserName
        : 'Conversation';
  }

  String? get _otherRole {
    final c = widget.conversation;
    if (c == null) return null;
    final other = c.data['otherUser'];
    if (other is Map<String, dynamic>) {
      final r = other['role'];
      if (r is String) return r;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<MessagingBloc, MessagingState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (ctx, state) {
        if (state.status == MessagingStatus.reportSubmitted) {
          // Pop chat once the conversation is reported.
          if (mounted) Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: _ChatHeader(name: _otherName, role: _otherRole),
          actions: [
            if (!_isFrozen)
              IconButton(
                tooltip: 'Report',
                icon: const Icon(Icons.shield_outlined,
                    color: AppColors.destructive),
                onPressed: _openReportDialog,
              ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (v) {
                if (v == 'refresh') {
                  context.read<MessagingBloc>().add(
                        MessagesRequested(
                          widget.conversationId,
                          page: 1,
                          limit: 50,
                        ),
                      );
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'refresh', child: Text('Refresh')),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (_isFrozen) _frozenBanner(theme),
              Expanded(
                child: BlocBuilder<MessagingBloc, MessagingState>(
                  builder: (ctx, state) {
                    if (state.isLoading && state.messages.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.status == MessagingStatus.error &&
                        state.messages.isEmpty) {
                      return EmptyStateView(
                        icon: Icons.wifi_off_rounded,
                        title: 'Could not load messages',
                        message: state.error ?? 'Pull to refresh or try again.',
                        actionLabel: 'Retry',
                        onAction: () => ctx.read<MessagingBloc>().add(
                              MessagesRequested(widget.conversationId),
                            ),
                      );
                    }
                    if (state.messages.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildMessages(state.messages);
                  },
                ),
              ),
              _isFrozen ? _frozenComposer(theme) : _composer(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _frozenBanner(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingMd,
      color: AppColors.destructive.withValues(alpha: 0.08),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.destructive),
          AppSpacing.hGapSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conversation frozen',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.destructive,
                  ),
                ),
                Text(
                  'This conversation has been reported and is under admin review.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.destructive,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _frozenComposer(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
        ),
      ),
      child: Text(
        'Messaging is disabled while this thread is under review.',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.mutedForeground,
        ),
      ),
    );
  }

  Widget _composer(ThemeData theme) {
    return BlocBuilder<MessagingBloc, MessagingState>(
      buildWhen: (p, c) => p.isSending != c.isSending,
      builder: (ctx, state) {
        return Material(
          color: theme.colorScheme.surface,
          elevation: 8,
          shadowColor: AppColors.foreground.withValues(alpha: 0.06),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 140),
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 6,
                        style: theme.textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Type a message…',
                          filled: true,
                          fillColor: AppColors.muted.withValues(alpha: 0.6),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusFull),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.hGapSm,
                  _sendButton(state.isSending),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sendButton(bool sending) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: sending ? null : _send,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: sending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.waving_hand_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          AppSpacing.gapMd,
          Text(
            'Say hello',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          AppSpacing.gapXxs,
          Text(
            'Start the conversation by sending the first message.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(List<MessageEntity> messages) {
    final auth = context.watch<AuthBloc>().state;
    final myId = auth.user?.uid ?? '';
    // Build a flat list of items, keyed in chronological order, then reverse.
    // Item types: 'date' (String), MessageEntity.
    final items = <Object>[];
    String? currentDay;
    for (final m in messages) {
      final day = _dateKey(m.createdAt);
      if (day != currentDay) {
        currentDay = day;
        items.add(_DateLabel(date: m.createdAt));
      }
      items.add(m);
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<MessagingBloc>().add(
              MessagesRequested(
                widget.conversationId,
                page: 1,
                limit: 50,
              ),
            );
        await Future<void>.delayed(const Duration(milliseconds: 400));
      },
      child: ListView.builder(
        controller: _scrollController,
        reverse: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[items.length - 1 - index];
          if (item is _DateLabel) return item;
          final m = item as MessageEntity;
          final isMine = m.senderId == myId;
          final read = m.readBy.any(
            (r) => r.userId.isNotEmpty && r.userId != myId,
          );
          return _MessageBubble(
            message: m,
            isMine: isMine,
            readByOther: read,
          );
        },
      ),
    );
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}

class _ChatHeader extends StatelessWidget {
  final String name;
  final String? role;

  const _ChatHeader({required this.name, this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              initial,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          AppSpacing.hGapSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (role != null && role!.isNotEmpty)
                  Text(
                    _roleLabel(role!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'investor':
        return 'INVESTOR';
      case 'entrepreneur':
        return 'ENTREPRENEUR';
      case 'admin':
        return 'ADMIN';
      default:
        return role.toUpperCase();
    }
  }
}

class _DateLabel extends StatelessWidget {
  final DateTime date;
  const _DateLabel({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.muted,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            _format(date),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.mutedForeground,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  String _format(DateTime d) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final yd = DateTime(d.year, d.month, d.day);
    if (yd == DateTime(today.year, today.month, today.day)) return 'Today';
    if (yd == DateTime(yesterday.year, yesterday.month, yesterday.day)) {
      return 'Yesterday';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMine;
  final bool readByOther;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.readByOther,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isMine ? 18 : 4),
      bottomRight: Radius.circular(isMine ? 4 : 18),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isMine ? AppColors.primary : Colors.white,
                  borderRadius: radius,
                  border: isMine
                      ? null
                      : Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isMine ? Colors.white : AppColors.foreground,
                        height: 1.4,
                      ),
                    ),
                    if (message.attachmentUrl != null &&
                        message.attachmentUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attach_file_rounded,
                              size: 14,
                              color: isMine
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : AppColors.mutedForeground,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Attachment',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isMine
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : AppColors.mutedForeground,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    Icon(
                      readByOther
                          ? Icons.done_all_rounded
                          : Icons.done_rounded,
                      size: 14,
                      color: readByOther
                          ? AppColors.primary
                          : AppColors.mutedForeground,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
