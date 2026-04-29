import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../bloc/invitations_bloc.dart';

class InvitationsPage extends StatefulWidget {
  const InvitationsPage({super.key});

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  String _direction = 'all';
  String? _status;

  void _refresh() {
    context.read<InvitationsBloc>().add(
          InvitationsRequested(direction: _direction, status: _status),
        );
  }

  @override
  void initState() {
    super.initState();
    context
        .read<InvitationsBloc>()
        .add(const InvitationsRequested(direction: 'all'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: BlocBuilder<InvitationsBloc, InvitationsState>(
            builder: (context, state) {
              if (state.isLoading)
                return const Center(child: CircularProgressIndicator());
              if (state.status == InvitationsStatus.error) {
                return Center(
                  child: Text(state.error ??
                      'Could not load invitations. Please try again.'),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review and respond to collaboration requests',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  AppSpacing.gapMd,
                  Card(
                    child: Padding(
                      padding: AppSpacing.paddingMd,
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _direction,
                              decoration:
                                  const InputDecoration(labelText: 'Direction'),
                              items: const [
                                DropdownMenuItem(
                                    value: 'all', child: Text('All')),
                                DropdownMenuItem(
                                    value: 'sent', child: Text('Sent')),
                                DropdownMenuItem(
                                    value: 'received', child: Text('Received')),
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() => _direction = v);
                                _refresh();
                              },
                            ),
                          ),
                          AppSpacing.hGapMd,
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              value: _status,
                              decoration:
                                  const InputDecoration(labelText: 'Status'),
                              items: const [
                                DropdownMenuItem(
                                    value: null, child: Text('Any')),
                                DropdownMenuItem(
                                    value: 'pending', child: Text('Pending')),
                                DropdownMenuItem(
                                    value: 'accepted', child: Text('Accepted')),
                                DropdownMenuItem(
                                    value: 'declined', child: Text('Declined')),
                                DropdownMenuItem(
                                    value: 'cancelled',
                                    child: Text('Cancelled')),
                                DropdownMenuItem(
                                    value: 'expired', child: Text('Expired')),
                              ],
                              onChanged: (v) {
                                setState(() => _status = v);
                                _refresh();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSpacing.gapMd,
                  Expanded(
                    child: state.items.isEmpty
                        ? const Center(
                            child: Text(
                                'No invitations found for the selected filters.'))
                        : ListView.separated(
                            itemCount: state.items.length,
                            separatorBuilder: (_, __) => AppSpacing.gapMd,
                            itemBuilder: (context, i) {
                              final inv = state.items[i];
                              final message = inv.message ?? '';
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          Chip(
                                              label: Text(inv.status
                                                  .toString()
                                                  .split('.')
                                                  .last
                                                  .toUpperCase()))
                                        ],
                                      ),
                                      if (message.isNotEmpty) ...[
                                        AppSpacing.gapXs,
                                        Text(message),
                                      ],
                                      AppSpacing.gapSm,
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: (inv.id.isEmpty ||
                                                      inv.status != 'pending')
                                                  ? null
                                                  : () => context
                                                      .read<InvitationsBloc>()
                                                      .add(
                                                        InvitationRespondRequested(
                                                          invitationId: inv.id,
                                                          status: 'accepted',
                                                        ),
                                                      ),
                                              child: const Text('Accept'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: (inv.id.isEmpty ||
                                                      inv.status != 'pending')
                                                  ? null
                                                  : () => context
                                                      .read<InvitationsBloc>()
                                                      .add(
                                                        InvitationRespondRequested(
                                                          invitationId: inv.id,
                                                          status: 'declined',
                                                        ),
                                                      ),
                                              child: const Text('Decline'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            onPressed: (inv.id.isEmpty ||
                                                    inv.status != 'pending')
                                                ? null
                                                : () => context
                                                    .read<InvitationsBloc>()
                                                    .add(
                                                        InvitationCancelRequested(
                                                            inv.id)),
                                            icon: const Icon(
                                                Icons.cancel_outlined),
                                            tooltip: 'Cancel',
                                          ),
                                        ],
                                      ),
                                      AppSpacing.gapXs,
                                      Text('Invitation reference: ${inv.id}'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
