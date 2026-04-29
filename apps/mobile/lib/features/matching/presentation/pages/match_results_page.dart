import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/di/injection_container.dart';
import '../../../invitations/presentation/bloc/send_invitation_bloc.dart';
import '../../../invitations/presentation/pages/send_invitation_page.dart';
import '../bloc/matching_bloc.dart';

class MatchResultsPage extends StatefulWidget {
  final String submissionId;
  const MatchResultsPage({super.key, required this.submissionId});

  @override
  State<MatchResultsPage> createState() => _MatchResultsPageState();
}

class _MatchResultsPageState extends State<MatchResultsPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<MatchingBloc>()
        .add(MatchingResultsRequested(widget.submissionId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              context
                  .read<MatchingBloc>()
                  .add(MatchingRunRequested(widget.submissionId));
            },
            tooltip: 'Run matching',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: BlocBuilder<MatchingBloc, MatchingState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == MatchingStatus.error) {
                return Center(
                  child: Text(state.error ??
                      'Could not load match results. Please try again.'),
                );
              }
              if (state.results.isEmpty) {
                return const Center(
                  child: Text(
                      'No matches yet. Tap Run Matching to generate results.'),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI-ranked investor candidates for this submission',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  AppSpacing.gapMd,
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.results.length,
                      separatorBuilder: (_, __) => AppSpacing.gapMd,
                      itemBuilder: (context, i) {
                        final r = state.results[i];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                    'Compatibility score: ${r.score?.toStringAsFixed(2) ?? '-'}'),
                                AppSpacing.gapXs,
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    Chip(
                                        label: Text(
                                            r.status.toString().toUpperCase()))
                                  ],
                                ),
                                AppSpacing.gapSm,
                                Text('Match reference: ${r.id}'),
                                if (r.status == 'accepted') ...[
                                  AppSpacing.gapSm,
                                  ElevatedButton(
                                    onPressed: r.id.isEmpty
                                        ? null
                                        : () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => BlocProvider(
                                                  create: (_) =>
                                                      sl<SendInvitationBloc>(),
                                                  child: SendInvitationPage(
                                                      matchId: r.id),
                                                ),
                                              ),
                                            );
                                          },
                                    child: const Text('Send Invitation'),
                                  ),
                                ],
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
