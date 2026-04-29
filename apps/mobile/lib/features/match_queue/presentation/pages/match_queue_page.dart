import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../bloc/match_queue_bloc.dart';

class MatchQueuePage extends StatefulWidget {
  const MatchQueuePage({super.key});

  @override
  State<MatchQueuePage> createState() => _MatchQueuePageState();
}

class _MatchQueuePageState extends State<MatchQueuePage> {
  String? _filter;

  void _refresh() {
    context
        .read<MatchQueueBloc>()
        .add(MatchQueueRequested(statusFilter: _filter));
  }

  @override
  void initState() {
    super.initState();
    context.read<MatchQueueBloc>().add(const MatchQueueRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Queue'),
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
          child: BlocBuilder<MatchQueueBloc, MatchQueueState>(
            builder: (context, state) {
              if (state.status == MatchQueueStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == MatchQueueStatus.error) {
                return Center(
                  child: Text(state.error ??
                      'Could not load matches. Please try again.'),
                );
              }
              if (state.items.isEmpty) {
                return const Center(
                    child: Text('No matches found for the selected filter.'));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review and manage active investor-entrepreneur matches',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  AppSpacing.gapMd,
                  Card(
                    child: Padding(
                      padding: AppSpacing.paddingMd,
                      child: DropdownButtonFormField<String?>(
                        value: _filter,
                        decoration:
                            const InputDecoration(labelText: 'Status filter'),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All')),
                          DropdownMenuItem(
                              value: 'pending', child: Text('Pending')),
                          DropdownMenuItem(
                              value: 'accepted', child: Text('Accepted')),
                          DropdownMenuItem(
                              value: 'declined', child: Text('Declined')),
                          DropdownMenuItem(
                              value: 'expired', child: Text('Expired')),
                        ],
                        onChanged: (v) {
                          setState(() => _filter = v);
                          _refresh();
                        },
                      ),
                    ),
                  ),
                  AppSpacing.gapMd,
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) => AppSpacing.gapMd,
                      itemBuilder: (context, i) {
                        final m = state.items[i];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                    'Compatibility score: ${m.score?.toStringAsFixed(2) ?? '-'}'),
                                AppSpacing.gapXs,
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    Chip(
                                        label: Text(
                                            m.status.toString().toUpperCase()))
                                  ],
                                ),
                                AppSpacing.gapSm,
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: (m.id.isEmpty ||
                                                m.status == 'accepted')
                                            ? null
                                            : () => context
                                                .read<MatchQueueBloc>()
                                                .add(
                                                  MatchStatusChanged(
                                                    matchId: m.id,
                                                    newStatus: 'accepted',
                                                  ),
                                                ),
                                        child: const Text('Accept'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: (m.id.isEmpty ||
                                                m.status == 'declined')
                                            ? null
                                            : () => context
                                                .read<MatchQueueBloc>()
                                                .add(
                                                  MatchStatusChanged(
                                                    matchId: m.id,
                                                    newStatus: 'declined',
                                                  ),
                                                ),
                                        child: const Text('Decline'),
                                      ),
                                    ),
                                  ],
                                ),
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
