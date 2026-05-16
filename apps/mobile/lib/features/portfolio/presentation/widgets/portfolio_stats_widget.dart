import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/portfolio_entity.dart';

class PortfolioStatsWidget extends StatelessWidget {
  final PortfolioSummaryEntity summary;

  const PortfolioStatsWidget({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Overview',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  title: 'Committed',
                  value: _formatCurrency(summary.totalCommitted),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatItem(
                  title: 'Released',
                  value: _formatCurrency(summary.totalReleased),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  title: 'Fees Paid',
                  value: _formatCurrency(summary.platformFeesPaid),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatItem(
                  title: 'Net Return',
                  value: _formatCurrency(summary.netReturn),
                  valueColor:
                      summary.netReturn >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  title: 'Return %',
                  value: '${summary.returnPercentage.toStringAsFixed(2)}%',
                  valueColor:
                      summary.returnPercentage >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatItem(
                  title: 'Active Projects',
                  value: summary.activeProjectCount.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _StatItem({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
