import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../entrepreneur_profile/presentation/bloc/entrepreneur_profile_bloc.dart';
import '../../../submissions/domain/entities/submission_entity.dart';
import '../bloc/dashboard_bloc.dart';

class EntrepreneurDashboardPage extends StatefulWidget {
  const EntrepreneurDashboardPage({super.key});

  @override
  State<EntrepreneurDashboardPage> createState() =>
      _EntrepreneurDashboardPageState();
}

class _EntrepreneurDashboardPageState extends State<EntrepreneurDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardStatsRequested());
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
              'Dashboard',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Manage your pitches and track investor interest',
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
              context
                  .read<DashboardBloc>()
                  .add(const DashboardRefreshRequested());
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<DashboardBloc, DashboardState>(
          listener: (context, state) {
            // Handle any side effects if needed
          },
          builder: (context, state) {
            if (state.status == DashboardStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == DashboardStatus.error) {
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
                        state.error ?? 'Failed to load dashboard',
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.gapLg,
                      AppButton(
                        text: 'Try again',
                        onPressed: () {
                          context
                              .read<DashboardBloc>()
                              .add(const DashboardStatsRequested());
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
                // New Pitch Button
                BlocBuilder<EntrepreneurProfileBloc, EntrepreneurProfileState>(
                  builder: (context, profileState) {
                    final isVerified = profileState.status ==
                            EntrepreneurProfileStatus.loaded &&
                        profileState.profile != null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: AppButton(
                        text: '+ New Pitch',
                        onPressed: isVerified
                            ? () {
                                // Navigate to pitch creation
                                // TODO: Implement navigation to pitch creation page
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Pitch creation will be implemented next'),
                                  ),
                                );
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Complete your profile verification to create pitches'),
                                  ),
                                );
                              },
                        icon: isVerified ? null : Icons.lock_outline,
                      ),
                    );
                  },
                ),

                // Statistics Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.description_outlined,
                        label: 'Total Pitches',
                        value: state.totalPitches.toString(),
                        subtitle: '${state.draftPitches} draft${state.draftPitches != 1 ? 's' : ''}',
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: _StatCard(
                        icon: Icons.send_outlined,
                        label: 'Submitted',
                        value: state.submittedPitches.toString(),
                        subtitle: 'Awaiting review',
                        color: const Color(0xFF06B6D4),
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapMd,
                _StatCard(
                  icon: Icons.handshake_outlined,
                  label: 'Matches',
                  value: state.acceptedMatchCount.toString(),
                  subtitle: 'Accepted investor matches',
                  color: const Color(0xFF10B981),
                  fullWidth: true,
                ),

                AppSpacing.gapLg,
                const Divider(color: AppColors.border),
                AppSpacing.gapLg,

                // Pitches List
                Text(
                  'Your Pitches',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.gapMd,

                if (state.submissions.isEmpty)
                  EmptyStateView(
                    icon: Icons.rocket_launch_outlined,
                    title: 'Submit Your First Pitch',
                    message:
                        'Create a compelling pitch and let our AI match you with the right investors.',
                    actionLabel: 'Create New Pitch',
                    onAction: () {
                      // TODO: Navigate to pitch creation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Pitch creation will be implemented next'),
                        ),
                      );
                    },
                  )
                else
                  ...state.submissions.map((submission) => _PitchCard(submission: submission)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final bool fullWidth;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PitchCard extends StatelessWidget {
  final SubmissionEntity submission;

  const _PitchCard({required this.submission});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          // Navigate to pitch detail or edit
          // TODO: Implement navigation based on status
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.gapXs,
                    Text(
                      '${submission.sector} · \$${submission.targetAmount?.toString() ?? '0'} · ${_formatDate(submission.updatedAt)}',
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
                  if (submission.aiScore != null)
                    Text(
                      'Score: ${submission.aiScore!.toStringAsFixed(0)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  AppSpacing.gapXs,
                  _StatusBadge(status: submission.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final SubmissionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String label;
    Color color;
    
    switch (status) {
      case SubmissionStatus.draft:
        label = 'Draft';
        color = AppColors.mutedForeground;
        break;
      case SubmissionStatus.submitted:
      case SubmissionStatus.underReview:
        label = status == SubmissionStatus.underReview ? 'Under Review' : 'Submitted';
        color = const Color(0xFF6B7280);
        break;
      case SubmissionStatus.approved:
        label = 'Approved';
        color = const Color(0xFF10B981);
        break;
      case SubmissionStatus.rejected:
        label = 'Rejected';
        color = const Color(0xFFEF4444);
        break;
      case SubmissionStatus.matched:
        label = 'Matched';
        color = const Color(0xFF3B82F6);
        break;
      default:
        label = status.name;
        color = AppColors.mutedForeground;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
