import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final String currentUserId;
  final bool isOwnMessage;
  final bool showTimestamp;
  final bool showReadReceipt;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.currentUserId,
    this.isOwnMessage = false,
    this.showTimestamp = true,
    this.showReadReceipt = true,
  }) : super(key: key);

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Material(
              color: isOwnMessage ? theme.colorScheme.primary : AppColors.muted,
              elevation: isOwnMessage ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: isOwnMessage
                    ? BorderSide.none
                    : const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Text(
                  message.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isOwnMessage
                        ? theme.colorScheme.onPrimary
                        : AppColors.foreground,
                    height: 1.45,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Timestamp and read receipt
          if (showTimestamp || (showReadReceipt && isOwnMessage))
            Padding(
              padding: isOwnMessage
                  ? const EdgeInsets.only(right: 4)
                  : const EdgeInsets.only(left: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showReadReceipt && isOwnMessage)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        message.readBy.isNotEmpty
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                        size: 14,
                        color: message.readBy.isNotEmpty
                            ? theme.colorScheme.primary
                            : AppColors.mutedForeground,
                      ),
                    ),
                  if (showTimestamp)
                    Text(
                      _formatTime(message.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.mutedForeground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
