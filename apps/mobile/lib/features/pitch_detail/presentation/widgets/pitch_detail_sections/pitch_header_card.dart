import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../domain/entities/pitch_detail_entity.dart';

class PitchHeaderCard extends StatelessWidget {
  final PitchDetailEntity pitch;

  const PitchHeaderCard({
    super.key,
    required this.pitch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: AppColors.card,
      child: Padding(
        padding: AppSpacing.screenPadding.copyWith(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              pitch.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.gapSm,

            // Meta info row: Sector, Stage, Target Amount
            Row(
              children: [
                Expanded(
                  child: _MetaTag(
                    label: 'Sector',
                    value: pitch.sector.isEmpty ? 'General' : pitch.sector,
                  ),
                ),
                AppSpacing.gapSm,
                Expanded(
                  child: _MetaTag(
                    label: 'Stage',
                    value: pitch.stage.isEmpty ? 'Unknown' : pitch.stage,
                  ),
                ),
              ],
            ),
            AppSpacing.gapSm,

            // Target Amount
            if (pitch.targetAmount != null && pitch.targetAmount! > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Target Amount',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    Text(
                      '${pitch.currency} ${pitch.targetAmount?.toStringAsFixed(0) ?? 'N/A'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  final String label;
  final String value;

  const _MetaTag({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
