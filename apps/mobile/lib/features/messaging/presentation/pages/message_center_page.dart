import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../bloc/messaging_bloc.dart';
import 'notifications_page.dart';
import 'conversations_page.dart';

class MessageCenterPage extends StatefulWidget {
  const MessageCenterPage({super.key});

  @override
  State<MessageCenterPage> createState() => _MessageCenterPageState();
}

class _MessageCenterPageState extends State<MessageCenterPage> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    context.read<MessagingBloc>().add(const UnreadCountRequested());
    context.read<MessagingBloc>().add(const ConversationsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const ConversationsPage(),
      const NotificationsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MessagingBloc>().add(const UnreadCountRequested());
              context.read<MessagingBloc>().add(const ConversationsRequested());
              context.read<MessagingBloc>().add(const NotificationsRequested());
            },
          ),
          BlocBuilder<MessagingBloc, MessagingState>(
            builder: (context, state) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: Text(
                    'Unread ${state.unreadCount}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: KeyedSubtree(
              key: ValueKey<int>(_tab),
              child: tabs[_tab],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _tab,
        onDestinationSelected: (i) {
          setState(() => _tab = i);
          if (i == 0) {
            context.read<MessagingBloc>().add(const ConversationsRequested());
          } else {
            context.read<MessagingBloc>().add(const NotificationsRequested());
          }
        },
        destinations: const <AppBottomNavDestination>[
          AppBottomNavDestination(
            icon: Icons.chat_bubble_outline,
            selectedIcon: Icons.chat_bubble,
            label: 'Chats',
          ),
          AppBottomNavDestination(
            icon: Icons.notifications_outlined,
            selectedIcon: Icons.notifications,
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}
