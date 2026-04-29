import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../bloc/messaging_bloc.dart';
import 'chat_page.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagingBloc, MessagingState>(
      builder: (context, state) {
        if (state.isLoading && state.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == MessagingStatus.error &&
            state.conversations.isEmpty) {
          return Center(
            child: Text(state.error ??
                'Could not load conversations. Please try again.'),
          );
        }
        if (state.conversations.isEmpty) {
          return const Center(
              child: Text('No conversations yet. Start a new chat soon.'));
        }

        return ListView.separated(
          itemCount: state.conversations.length,
          separatorBuilder: (_, __) => AppSpacing.gapMd,
          itemBuilder: (context, i) {
            final c = state.conversations[i];
            return Card(
              child: ListTile(
                title: Text(
                    c.otherUserName.isEmpty ? 'Conversation' : c.otherUserName),
                subtitle: Text('Tap to open chat'),
                trailing: c.unreadCount > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${c.unreadCount}',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                onTap: c.id.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<MessagingBloc>(),
                              child: ChatPage(conversationId: c.id),
                            ),
                          ),
                        );
                      },
              ),
            );
          },
        );
      },
    );
  }
}
