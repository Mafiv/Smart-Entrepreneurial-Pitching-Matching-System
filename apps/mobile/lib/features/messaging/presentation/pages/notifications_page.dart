import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../bloc/messaging_bloc.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagingBloc, MessagingState>(
      builder: (context, state) {
        if (state.isLoading && state.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == MessagingStatus.error &&
            state.notifications.isEmpty) {
          return Center(
            child: Text(state.error ??
                'Could not load notifications. Please try again.'),
          );
        }
        if (state.notifications.isEmpty) {
          return const Center(child: Text('No notifications yet.'));
        }
        return ListView.separated(
          itemCount: state.notifications.length,
          separatorBuilder: (_, __) => AppSpacing.gapMd,
          itemBuilder: (context, i) {
            final n = state.notifications[i];
            return Card(
              child: ListTile(
                title: Text(n.title),
                subtitle: Text(n.body),
                trailing: n.read
                    ? const Icon(Icons.check_circle_outline)
                    : Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                onTap: n.id.isEmpty
                    ? null
                    : () => context
                        .read<MessagingBloc>()
                        .add(NotificationReadRequested(n.id)),
              ),
            );
          },
        );
      },
    );
  }
}
