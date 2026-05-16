import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/conversation_entity.dart';

class ConversationListItem extends StatelessWidget {
  final ConversationEntity conversation;
  final VoidCallback onTap;

  const ConversationListItem({
    Key? key,
    required this.conversation,
    required this.onTap,
  }) : super(key: key);

  String _getMessagePreview(String message) {
    if (message.isEmpty) return 'No messages yet';
    if (message.length > 50) {
      return '${message.substring(0, 50)}...';
    }
    return message;
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun'
      ][date.weekday - 1];
    } else {
      return '${date.day}/${date.month}/${date.year % 100}';
    }
  }

  DateTime _getLastMessageTime() {
    final updatedAt = conversation.data['updatedAt'];
    if (updatedAt is String) {
      return DateTime.tryParse(updatedAt) ?? DateTime.now();
    }
    return DateTime.now();
  }

  String _getLastMessage() {
    final lastMessage = conversation.data['lastMessage'];
    if (lastMessage is String) {
      return _getMessagePreview(lastMessage);
    }
    if (lastMessage is Map && lastMessage['body'] is String) {
      return _getMessagePreview(lastMessage['body'] as String);
    }
    return 'No messages yet';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = conversation.otherUserName.isEmpty
        ? 'Conversation'
        : conversation.otherUserName;
    final initial = title.isNotEmpty ? title.trim()[0].toUpperCase() : '?';
    final hasUnread = conversation.unreadCount > 0;

    return Material(
      color: hasUnread
          ? AppColors.primary.withValues(alpha: 0.04)
          : AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(
          color: hasUnread
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: conversation.id.isEmpty ? null : onTap,
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with unread indicator
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Text(
                      initial,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.card,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),

              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Name and timestamp row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight:
                                  hasUnread ? FontWeight.w800 : FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _formatTime(_getLastMessageTime()),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: hasUnread
                                ? theme.colorScheme.primary
                                : AppColors.mutedForeground,
                            fontWeight:
                                hasUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.gapXs,

                    // Message preview
                    Text(
                      _getLastMessage(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: hasUnread
                            ? AppColors.foreground.withValues(alpha: 0.8)
                            : AppColors.mutedForeground,
                        fontWeight:
                            hasUnread ? FontWeight.w500 : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Unread badge or read receipt
              if (hasUnread)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      '${conversation.unreadCount}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                )
              else
                Icon(
                  Icons.done_all_rounded,
                  size: 18,
                  color: AppColors.mutedForeground.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
