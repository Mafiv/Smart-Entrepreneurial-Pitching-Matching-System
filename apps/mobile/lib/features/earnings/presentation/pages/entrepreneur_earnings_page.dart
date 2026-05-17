import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/widgets/verification_required_widget.dart';
import '../../../entrepreneur_profile/presentation/bloc/entrepreneur_profile_bloc.dart';
import '../../../earnings/domain/entities/payout_entry_entity.dart';
import '../../../earnings/domain/entities/pending_milestone_entity.dart';
import '../bloc/earnings_bloc.dart';

class EntrepreneurEarningsPage extends StatefulWidget {
  const EntrepreneurEarningsPage({super.key});

  @override
  State<EntrepreneurEarningsPage> createState() =>
      _EntrepreneurEarningsPageState();
}

class _EntrepreneurEarningsPageState extends State<EntrepreneurEarningsPage> {
  @override
  void initState() {
    super.initState();
    context.read<EarningsBloc>().add(const EarningsSummaryRequested());
    context.read<EntrepreneurProfileBloc>().add(const EntrepreneurProfileLoaded());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Earnings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Monitor your received payouts and funds awaiting release',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              context.read<EarningsBloc>().add(const EarningsRefreshRequested());
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<EntrepreneurProfileBloc, EntrepreneurProfileState>(
          builder: (context, profileState) {
            final profile = profileState.profile;
            final isVerified = profile?.isVerified ?? false;

            if (!isVerified) {
              return const VerificationRequiredWidget();
            }

            return BlocConsumer<EarningsBloc, EarningsState>(
              listener: (context, state) {
                // Handle any side effects if needed
              },
              builder: (context, state) {
                if (state.status == EarningsStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == EarningsStatus.error) {
                  return Center(
                    child: Padding(
                      padding: AppSpacing.paddingLg,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: theme.colorScheme.error.withValues(alpha: 0.8),
                          ),
                          AppSpacing.gapMd,
                          Text(
                            state.error ?? 'Failed to load earnings',
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          AppSpacing.gapLg,
                          AppButton(
                            text: 'Try again',
                            onPressed: () {
                              context
                                  .read<EarningsBloc>()
                                  .add(const EarningsSummaryRequested());
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: AppSpacing.screenPadding.copyWith(bottom: 100),
                  children: [
                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _EarningsStatCard(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Total Received',
                            value: 'ETB ${state.totalReceived.toStringAsFixed(0)}',
                            subtitle: 'Successfully disbursed to your account',
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        AppSpacing.gapMd,
                        Expanded(
                          child: _EarningsStatCard(
                            icon: Icons.schedule_outlined,
                            label: 'Pending Release',
                            value: 'ETB ${state.pendingRelease.toStringAsFixed(0)}',
                            subtitle: 'Funds verified but waiting for admin payout',
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.gapLg,

                    // Awaiting Disbursement Section
                    if (state.pendingMilestones.isNotEmpty) ...[
                      Card(
                        color: const Color(0xFFFFFBEB),
                        child: Padding(
                          padding: AppSpacing.paddingMd,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    color: const Color(0xFFF59E0B),
                                    size: 20,
                                  ),
                                  AppSpacing.gapSm,
                                  Text(
                                    'Awaiting Disbursement',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.gapMd,
                              ...state.pendingMilestones.map((milestone) {
                                if (milestone is! PendingMilestoneEntity) {
                                  return const SizedBox.shrink();
                                }
                                return _PendingMilestoneCard(milestone: milestone);
                              }),
                            ],
                          ),
                        ),
                      ),
                      AppSpacing.gapLg,
                    ],

                    // Payout History
                    Text(
                      'Payout History',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AppSpacing.gapMd,
                    Card(
                      child: state.recentPayouts.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 48),
                              child: Center(
                                child: Text(
                                  'No payout history found yet.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                ...state.recentPayouts.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final payout = entry.value;
                                  if (payout is! PayoutEntryEntity) {
                                    return const SizedBox.shrink();
                                  }
                                  return _PayoutHistoryItem(
                                    payout: payout,
                                    isLast: index == state.recentPayouts.length - 1,
                                  );
                                }),
                              ],
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EarningsStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  const _EarningsStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border(
          left: BorderSide(color: color, width: 4),
          top: BorderSide(color: color.withValues(alpha: 0.3)),
          right: BorderSide(color: color.withValues(alpha: 0.3)),
          bottom: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          AppSpacing.gapSm,
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          AppSpacing.gapXs,
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingMilestoneCard extends StatelessWidget {
  final PendingMilestoneEntity milestone;

  const _PendingMilestoneCard({required this.milestone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.gapXs,
                Text(
                  milestone.projectTitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapMd,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'ETB ${milestone.amount.toStringAsFixed(0)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFF59E0B),
                ),
              ),
              AppSpacing.gapXs,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: Text(
                  'Verified & Escrow Held',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFF59E0B),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayoutHistoryItem extends StatelessWidget {
  final PayoutEntryEntity payout;
  final bool isLast;

  const _PayoutHistoryItem({
    required this.payout,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(payout.occurredAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    AppSpacing.gapXs,
                    Text(
                      payout.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (payout.milestoneTitle != null) ...[
                      AppSpacing.gapXs,
                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 12,
                            color: AppColors.mutedForeground,
                          ),
                          AppSpacing.gapXs,
                          Text(
                            payout.milestoneTitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              AppSpacing.gapMd,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+ ETB ${payout.amount.toStringAsFixed(0)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  AppSpacing.gapXs,
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: const Color(0xFF10B981),
                      ),
                      AppSpacing.gapXs,
                      Text(
                        payout.status,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (!isLast) const Divider(height: AppSpacing.lg),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
