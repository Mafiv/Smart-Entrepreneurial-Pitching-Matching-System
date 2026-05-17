import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../submissions/domain/constants/submission_options.dart';
import '../../../submissions/domain/entities/submission_entity.dart';
import '../../../submissions/presentation/pages/pitch_creation_page.dart';
import '../../../submissions/presentation/pages/pitch_review_page.dart';
import '../bloc/dashboard_bloc.dart';

/// Entrepreneur home dashboard. Mirrors the web `/entrepreneur/dashboard`:
/// header card with primary action, three KPI cards, and a list of pitches.
class EntrepreneurDashboardPage extends StatefulWidget {
  const EntrepreneurDashboardPage({super.key});

  @override
  State<EntrepreneurDashboardPage> createState() =>
      _EntrepreneurDashboardPageState();
}

class _EntrepreneurDashboardPageState extends State<EntrepreneurDashboardPage> {
  bool _showSubmittedBanner = false;
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      context.read<DashboardBloc>().add(const DashboardStatsRequested());
    }
  }

  void _openCreatePitch({String? editId}) {
    final auth = context.read<AuthBloc>().state;
    final isVerified = auth.user?.isVerified ?? false;
    if (!isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete your KYC verification to create pitches.',
          ),
        ),
      );
      return;
    }
    Navigator.of(context)
        .push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PitchCreationPage(editId: editId),
      ),
    )
        .then((submitted) {
      if (mounted) {
        if (submitted == true) {
          setState(() => _showSubmittedBanner = true);
        }
        context.read<DashboardBloc>().add(const DashboardRefreshRequested());
      }
    });
  }

  void _openReview(String submissionId) {
    Navigator.of(context)
        .push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PitchReviewPage(submissionId: submissionId),
      ),
    )
        .then((submitted) {
      if (mounted) {
        if (submitted == true) {
          setState(() => _showSubmittedBanner = true);
        }
        context.read<DashboardBloc>().add(const DashboardRefreshRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
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
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context
                .read<DashboardBloc>()
                .add(const DashboardRefreshRequested()),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state.status == DashboardStatus.loading &&
                state.submissions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == DashboardStatus.error &&
                state.submissions.isEmpty) {
              return EmptyStateView(
                icon: Icons.cloud_off_rounded,
                title: 'Could not load dashboard',
                message: state.error ?? 'Please try again in a moment.',
                actionLabel: 'Retry',
                onAction: () => context
                    .read<DashboardBloc>()
                    .add(const DashboardStatsRequested()),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<DashboardBloc>()
                    .add(const DashboardRefreshRequested());
                await Future<void>.delayed(const Duration(milliseconds: 400));
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  120,
                ),
                children: [
                  if (_showSubmittedBanner) _buildSubmittedBanner(theme),
                  _buildHeroCard(theme),
                  AppSpacing.gapLg,
                  _buildStatsRow(state, theme),
                  AppSpacing.gapLg,
                  _buildSectionTitle(theme, state.submissions.length),
                  AppSpacing.gapSm,
                  if (state.submissions.isEmpty)
                    _EmptyPitches(onCreate: _openCreatePitch)
                  else
                    ...state.submissions.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _PitchCard(
                          submission: s,
                          onTap: () => s.status == SubmissionStatus.draft
                              ? _openCreatePitch(editId: s.id)
                              : _openReview(s.id),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubmittedBanner(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 22)),
          AppSpacing.hGapSm,
          Expanded(
            child: Text(
              'Your pitch was submitted successfully! Our AI will analyse it shortly.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF065F46),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _showSubmittedBanner = false),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(ThemeData theme) {
    final auth = context.read<AuthBloc>().state;
    final isVerified = auth.user?.isVerified ?? false;
    final name = auth.user?.displayName ?? 'Founder';
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E40AF),
            Color(0xFF2563EB),
            Color(0xFF3B82F6),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(Icons.rocket_launch_rounded,
                    color: Colors.white, size: 22),
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $name',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.gapXxs,
                        Text(
                          'Let\'s build your next pitch',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.gapMd,
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  icon: Icon(
                    isVerified ? Icons.add_rounded : Icons.lock_outline_rounded,
                    size: 20,
                  ),
                  label: Text(isVerified
                      ? 'Create new pitch'
                      : 'Verification required'),
                  onPressed: () => _openCreatePitch(),
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildStatsRow(DashboardState state, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.description_outlined,
            label: 'Pitches',
            value: state.totalPitches.toString(),
            subtitle: '${state.draftPitches} '
                'draft${state.draftPitches != 1 ? 's' : ''}',
            color: const Color(0xFF3B82F6),
          ),
        ),
        AppSpacing.hGapSm,
        Expanded(
          child: _StatCard(
            icon: Icons.send_outlined,
            label: 'Submitted',
            value: state.submittedPitches.toString(),
            subtitle: 'Awaiting review',
            color: const Color(0xFF06B6D4),
          ),
        ),
        AppSpacing.hGapSm,
        Expanded(
          child: _StatCard(
            icon: Icons.handshake_outlined,
            label: 'Matches',
            value: state.acceptedMatchCount.toString(),
            subtitle: 'Accepted',
            color: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, int count) {
    return Row(
      children: [
        Text(
          'Your pitches',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        if (count > 0) ...[
          AppSpacing.hGapSm,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              count.toString(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          AppSpacing.gapSm,
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.mutedForeground,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          AppSpacing.gapXxs,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PitchCard extends StatelessWidget {
  final SubmissionEntity submission;
  final VoidCallback onTap;

  const _PitchCard({required this.submission, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stageLabel = SubmissionOptions.stageLabel(_stageVal(submission.stage));
    final sectorLabel = SubmissionOptions.sectorLabel(submission.sector);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      submission.title.isEmpty
                          ? 'Untitled pitch'
                          : submission.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppSpacing.hGapSm,
                  _statusPill(submission.status),
                ],
              ),
              AppSpacing.gapXs,
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _MetaChip(label: sectorLabel, icon: Icons.workspaces_outline),
                  _MetaChip(label: stageLabel, icon: Icons.trending_up_rounded),
                  if (submission.targetAmount != null)
                    _MetaChip(
                      label: '\$${_fmt(submission.targetAmount!)}',
                      icon: Icons.attach_money_rounded,
                    ),
                  if (submission.aiScore != null)
                    _MetaChip(
                      label: 'AI ${submission.aiScore!.toStringAsFixed(0)}%',
                      icon: Icons.auto_awesome,
                    ),
                ],
              ),
              AppSpacing.gapXs,
              Text(
                'Updated ${_relTime(submission.updatedAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _stageVal(SubmissionStage s) => switch (s) {
        SubmissionStage.mvp => 'mvp',
        SubmissionStage.earlyRevenue => 'early-revenue',
        SubmissionStage.scaling => 'scaling',
      };

  String _fmt(double v) {
    final n = v.round();
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final remaining = s.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buf.write(',');
    }
    return buf.toString();
  }

  String _relTime(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.day}/${d.month}/${d.year}';
  }

  Widget _statusPill(SubmissionStatus s) {
    final (color, label) = switch (s) {
      SubmissionStatus.draft => (AppColors.mutedForeground, 'Draft'),
      SubmissionStatus.submitted => (AppColors.primary, 'Submitted'),
      SubmissionStatus.underReview => (AppColors.warning, 'Review'),
      SubmissionStatus.approved => (AppColors.success, 'Approved'),
      SubmissionStatus.rejected => (AppColors.destructive, 'Rejected'),
      SubmissionStatus.suspended => (AppColors.destructive, 'Suspended'),
      SubmissionStatus.matched => (AppColors.primaryDark, 'Matched'),
      SubmissionStatus.closed => (AppColors.mutedForeground, 'Closed'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _MetaChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.mutedForeground),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPitches extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyPitches({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.gapMd,
          Text(
            'Submit your first pitch',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          AppSpacing.gapXs,
          Text(
            'Create a compelling pitch and let our AI match you with the right investors.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          AppSpacing.gapMd,
          SizedBox(
            width: 220,
            child: AppButton(
              text: 'Create new pitch',
              icon: Icons.add_rounded,
              onPressed: onCreate,
            ),
          ),
        ],
      ),
    );
  }
}
