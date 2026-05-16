import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/pitch_detail_bloc.dart';
import '../widgets/pitch_detail_app_bar.dart';
import '../widgets/pitch_detail_content.dart';

class PitchDetailPage extends StatefulWidget {
  final String pitchId;

  const PitchDetailPage({
    super.key,
    required this.pitchId,
  });

  @override
  State<PitchDetailPage> createState() => _PitchDetailPageState();
}

class _PitchDetailPageState extends State<PitchDetailPage> {
  late PitchDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<PitchDetailBloc>();
    _bloc.add(PitchDetailRequested(widget.pitchId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _onRefresh() {
    _bloc.add(PitchDetailRefresh(widget.pitchId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<PitchDetailBloc, PitchDetailState>(
      bloc: _bloc,
      builder: (context, state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: PitchDetailAppBar(
              isSaved: state.isSaved,
              onSaveToggle: () {
                _bloc.add(PitchDetailSaveToggled(widget.pitchId));
              },
              isTogglingState: state.isSavingToggle,
            ),
          ),
          body: SafeArea(
            child: _buildBody(context, state, theme),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    PitchDetailState state,
    ThemeData theme,
  ) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            AppSpacing.gapMd,
            Text(
              'Loading pitch details...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      );
    }

    if (state.status == PitchDetailStatus.error) {
      return Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 56,
                color: AppColors.destructive,
              ),
              AppSpacing.gapMd,
              Text(
                'Failed to load pitch details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapSm,
              Text(
                state.errorMessage ?? 'An unexpected error occurred',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapLg,
              AppButton(
                text: 'Try Again',
                onPressed: _onRefresh,
              ),
            ],
          ),
        ),
      );
    }

    if (state.pitch == null) {
      return Center(
        child: Text(
          'Pitch not found',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _onRefresh();
        // Wait for the state to update
        await _bloc.stream
            .firstWhere((s) => s.status != PitchDetailStatus.loading);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: PitchDetailContent(
          pitch: state.pitch!,
          onSaveToggle: () {
            _bloc.add(PitchDetailSaveToggled(widget.pitchId));
          },
        ),
      ),
    );
  }
}
