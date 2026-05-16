import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../domain/entities/pitch_detail_entity.dart';

class FinancialSection extends StatelessWidget {
  final PitchFinancials financials;

  const FinancialSection({
    super.key,
    required this.financials,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = (financials.monthlyRecurringRevenue ?? 0) > 0 ||
        (financials.totalRevenue ?? 0) > 0 ||
        (financials.marketSize ?? 0) > 0;

    if (!hasData) {
      return Container(
        padding: AppSpacing.screenPadding,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Information',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.gapSm,
            Text(
              'No financial data available',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: AppSpacing.screenPadding,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Information',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.gapMd,
          if ((financials.monthlyRecurringRevenue ?? 0) > 0)
            _FinancialMetric(
              label: 'Monthly Recurring Revenue',
              value: financials.monthlyRecurringRevenue?.toStringAsFixed(2) ??
                  'N/A',
              currency: financials.currency ?? 'ETB',
            ),
          if ((financials.totalRevenue ?? 0) > 0) ...[
            AppSpacing.gapSm,
            _FinancialMetric(
              label: 'Total Revenue',
              value: financials.totalRevenue?.toStringAsFixed(2) ?? 'N/A',
              currency: financials.currency ?? 'ETB',
            ),
          ],
          if ((financials.burnRate ?? 0) > 0) ...[
            AppSpacing.gapSm,
            _FinancialMetric(
              label: 'Monthly Burn Rate',
              value: financials.burnRate?.toStringAsFixed(2) ?? 'N/A',
              currency: financials.currency ?? 'ETB',
            ),
          ],
          if ((financials.runway ?? 0) > 0) ...[
            AppSpacing.gapSm,
            _FinancialMetric(
              label: 'Runway',
              value: '${financials.runway} months',
              isMonetary: false,
            ),
          ],
          if ((financials.marketSize ?? 0) > 0) ...[
            AppSpacing.gapSm,
            _FinancialMetric(
              label: 'Market Size',
              value: financials.marketSize?.toStringAsFixed(2) ?? 'N/A',
              currency: financials.currency ?? 'ETB',
            ),
          ],
        ],
      ),
    );
  }
}

class _FinancialMetric extends StatelessWidget {
  final String label;
  final String value;
  final String? currency;
  final bool isMonetary;

  const _FinancialMetric({
    required this.label,
    required this.value,
    this.currency,
    this.isMonetary = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        Text(
          isMonetary ? '$currency $value' : value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.foreground,
          ),
        ),
      ],
    );
  }
}
