import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../matching/domain/entities/match_result_entity.dart';

class MatchScoreBreakdownWidget extends StatelessWidget {
  final ScoreBreakdown breakdown;
  final bool expanded;
  final VoidCallback? onExpand;

  const MatchScoreBreakdownWidget({
    super.key,
    required this.breakdown,
    this.expanded = false,
    this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!expanded) {
      return GestureDetector(
        onTap: onExpand,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score Breakdown',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.expand_more, size: 20),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score Breakdown',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: onExpand,
                child: const Icon(Icons.expand_less, size: 20),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _ScoreItemRow(
            label: 'Sector Fit',
            score: breakdown.sector,
          ),
          const SizedBox(height: AppSpacing.md),
          _ScoreItemRow(
            label: 'Stage Alignment',
            score: breakdown.stage,
          ),
          const SizedBox(height: AppSpacing.md),
          _ScoreItemRow(
            label: 'Budget Match',
            score: breakdown.budget,
          ),
          const SizedBox(height: AppSpacing.md),
          _ScoreItemRow(
            label: 'Profile Match',
            score: breakdown.embedding,
          ),
        ],
      ),
    );
  }
}

class _ScoreItemRow extends StatelessWidget {
  final String label;
  final double score;

  const _ScoreItemRow({
    required this.label,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (score * 100).toInt();
    final color = _getScoreColor(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall,
            ),
            Text(
              '$percentage%',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.75) return Colors.green;
    if (score >= 0.5) return Colors.orange;
    if (score >= 0.25) return Colors.amber;
    return Colors.red;
  }
}
