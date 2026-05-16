import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../bloc/messaging_bloc.dart';
import '../widgets/conversation_list_item.dart';
import 'chat_page.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  Future<void> _reload(BuildContext context) async {
    context.read<MessagingBloc>().add(const ConversationsRequested());
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagingBloc, MessagingState>(
      builder: (context, state) {
        if (state.isLoading && state.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == MessagingStatus.error &&
            state.conversations.isEmpty) {
          return EmptyStateView(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Could not load chats',
            message: state.error ?? 'Pull to refresh or try again shortly.',
            actionLabel: 'Retry',
            onAction: () => _reload(context),
          );
        }
        if (state.conversations.isEmpty) {
          return EmptyStateView(
            icon: Icons.forum_outlined,
            title: 'No conversations yet',
            message:
                'When you message investors or founders, threads will show up here.',
            actionLabel: 'Refresh',
            onAction: () => _reload(context),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _reload(context),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: state.conversations.length,
            separatorBuilder: (_, __) => AppSpacing.gapMd,
            itemBuilder: (context, i) {
              final c = state.conversations[i];
              return ConversationListItem(
                conversation: c,
                onTap: c.id.isEmpty
                    ? () {}
                    : () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => BlocProvider.value(
                              value: context.read<MessagingBloc>(),
                              child: ChatPage(conversationId: c.id),
                            ),
                          ),
                        );
                      },
              );
            },
          ),
        );
      },
    );
  }
}
