import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/di/injection_container.dart';
import '../../../saved_pitches/presentation/bloc/saved_pitches_bloc.dart';
import '../bloc/feed_bloc.dart';

class PitchDetailPage extends StatefulWidget {
  final String pitchId;
  const PitchDetailPage({super.key, required this.pitchId});

  @override
  State<PitchDetailPage> createState() => _PitchDetailPageState();
}

class _PitchDetailPageState extends State<PitchDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<FeedBloc>().add(PitchRequested(widget.pitchId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pitch')),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: BlocBuilder<FeedBloc, FeedState>(
            builder: (context, state) {
              if (state.isLoading)
                return const Center(child: CircularProgressIndicator());
              if (state.status == FeedStatus.error) {
                return Center(
                  child: Text(state.error ??
                      'Could not load pitch details. Please try again.'),
                );
              }
              final p = state.pitch;
              if (p == null)
                return const Center(
                    child: Text('Pitch details are unavailable right now.'));

              return ListView(
                children: [
                  Text(
                    p.title.isEmpty ? 'Untitled pitch' : p.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  AppSpacing.gapMd,
                  Card(
                    child: Padding(
                      padding: AppSpacing.paddingMd,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Sector: ${p.sector}'),
                          AppSpacing.gapXs,
                          Text('Stage: ${p.stage}'),
                          if (p.targetAmount != null) ...[
                            AppSpacing.gapXs,
                            Text('Target: ${p.targetAmount}'),
                          ],
                        ],
                      ),
                    ),
                  ),
                  AppSpacing.gapLg,
                  ElevatedButton(
                    onPressed: () async {
                      final tempBloc = sl<SavedPitchesBloc>();
                      tempBloc.add(SavedPitchToggled(widget.pitchId));
                      await tempBloc.stream.firstWhere(
                        (s) => s.status != SavedPitchesStatus.loading,
                      );
                      await tempBloc.close();
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text('Save / Unsave'),
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
