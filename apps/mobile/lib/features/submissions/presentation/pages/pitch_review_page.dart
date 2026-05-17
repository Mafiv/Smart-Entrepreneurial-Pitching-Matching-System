import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/constants/submission_options.dart';
import '../../domain/entities/submission_entity.dart';
import '../../domain/usecases/submissions_usecases.dart';
import 'pitch_creation_page.dart';

/// Read-only review of a pitch with completeness check + submit action.
/// Mirrors the entrepreneur web `/pitch/review` page.
class PitchReviewPage extends StatefulWidget {
  final String submissionId;

  const PitchReviewPage({super.key, required this.submissionId});

  @override
  State<PitchReviewPage> createState() => _PitchReviewPageState();
}

class _PitchReviewPageState extends State<PitchReviewPage> {
  late final GetSubmissionByIdUseCase _getById = sl<GetSubmissionByIdUseCase>();
  late final CompletenessUseCase _completenessUC = sl<CompletenessUseCase>();
  late final SubmitPitchUseCase _submitUC = sl<SubmitPitchUseCase>();

  SubmissionEntity? _submission;
  Map<String, dynamic>? _completeness;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _getById(widget.submissionId);
    res.fold(
      (f) => _error = f.message,
      (s) => _submission = s,
    );
    if (_submission != null) {
      final c = await _completenessUC(widget.submissionId);
      c.fold((_) => null, (data) => _completeness = data);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final res = await _submitUC(widget.submissionId);
    if (!mounted) return;
    setState(() => _submitting = false);
    res.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🎉 Your pitch was submitted successfully! Our AI will analyse it shortly.',
            ),
          ),
        );
        Navigator.of(context).pop(true);
      },
    );
  }

  void _editStep() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PitchCreationPage(editId: widget.submissionId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = _submission;
    final isDraft = s?.status == SubmissionStatus.draft;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review pitch',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              s?.title ?? 'Loading…',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          if (isDraft)
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: _editStep,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? EmptyStateView(
                  icon: Icons.error_outline_rounded,
                  title: 'Could not load pitch',
                  message: _error!,
                  actionLabel: 'Retry',
                  onAction: _load,
                )
              : s == null
                  ? const Center(child: Text('Submission not found'))
                  : _buildContent(theme, s, isDraft),
    );
  }

  Widget _buildContent(ThemeData theme, SubmissionEntity s, bool isDraft) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              120,
            ),
            children: [
              _StatusBadge(status: s.status),
              AppSpacing.gapLg,
              if (_completeness != null) _buildCompletenessCard(theme),
              if (_completeness != null) AppSpacing.gapLg,
              _SectionCard(
                icon: Icons.assignment_outlined,
                title: 'Overview',
                onEdit: isDraft ? _editStep : null,
                children: [
                  _Row(label: 'Title', value: s.title),
                  _Row(
                    label: 'Sector',
                    value: SubmissionOptions.sectorLabel(s.sector),
                  ),
                  _Row(
                    label: 'Stage',
                    value: SubmissionOptions.stageLabel(_stageVal(s.stage)),
                  ),
                  _Row(
                    label: 'Target amount',
                    value: s.targetAmount == null
                        ? 'Not specified'
                        : '\$${_formatAmount(s.targetAmount!)}',
                  ),
                  _Row(
                    label: 'Summary',
                    value: s.summary,
                    multiline: true,
                  ),
                ],
              ),
              AppSpacing.gapLg,
              _SectionCard(
                icon: Icons.search_rounded,
                title: 'Problem',
                onEdit: isDraft ? _editStep : null,
                children: [
                  _Row(label: 'Statement', value: s.problem.statement, multiline: true),
                  _Row(label: 'Target market', value: s.problem.targetMarket, multiline: true),
                  _Row(label: 'Market size', value: s.problem.marketSize, multiline: true),
                ],
              ),
              AppSpacing.gapLg,
              _SectionCard(
                icon: Icons.lightbulb_outline_rounded,
                title: 'Solution',
                onEdit: isDraft ? _editStep : null,
                children: [
                  _Row(label: 'Description', value: s.solution.description, multiline: true),
                  _Row(label: 'Unique value', value: s.solution.uniqueValue, multiline: true),
                  _Row(
                    label: 'Competitive advantage',
                    value: s.solution.competitiveAdvantage,
                    multiline: true,
                  ),
                ],
              ),
              AppSpacing.gapLg,
              _SectionCard(
                icon: Icons.bar_chart_rounded,
                title: 'Business model',
                onEdit: isDraft ? _editStep : null,
                children: [
                  _Row(label: 'Revenue streams', value: s.businessModel.revenueStreams, multiline: true),
                  _Row(label: 'Pricing strategy', value: s.businessModel.pricingStrategy, multiline: true),
                  _Row(
                    label: 'Customer acquisition',
                    value: s.businessModel.customerAcquisition,
                    multiline: true,
                  ),
                ],
              ),
              AppSpacing.gapLg,
              _SectionCard(
                icon: Icons.payments_outlined,
                title: 'Financials',
                onEdit: isDraft ? _editStep : null,
                children: [
                  _Row(label: 'Current revenue', value: s.financials.currentRevenue),
                  _Row(label: 'Projected revenue', value: s.financials.projectedRevenue),
                  _Row(label: 'Burn rate', value: s.financials.burnRate),
                  _Row(label: 'Runway', value: s.financials.runway),
                ],
              ),
              AppSpacing.gapLg,
              _SectionCard(
                icon: Icons.folder_open_outlined,
                title: 'Documents',
                onEdit: isDraft ? _editStep : null,
                children: [
                  if (s.documents.isEmpty)
                    Text(
                      'No documents uploaded.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    )
                  else
                    ...s.documents.map((d) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.insert_drive_file_outlined,
                                  color: AppColors.primary),
                              AppSpacing.hGapSm,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(d.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    Text(
                                      SubmissionOptions.docLabel(d.type),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.check_circle_outline,
                                  color: AppColors.success, size: 18),
                            ],
                          ),
                        )),
                ],
              ),
              if (s.aiScore != null) ...[
                AppSpacing.gapLg,
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFEEF2FF),
                        Color(0xFFE0E7FF),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: AppColors.primary),
                      AppSpacing.hGapSm,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Score',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${s.aiScore!.toStringAsFixed(0)}%',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isDraft)
          Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Edit',
                        variant: AppButtonVariant.outline,
                        onPressed: _editStep,
                        icon: Icons.edit_outlined,
                      ),
                    ),
                    AppSpacing.hGapMd,
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        text: 'Submit pitch',
                        onPressed: _submit,
                        isLoading: _submitting,
                        icon: Icons.send_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCompletenessCard(ThemeData theme) {
    final c = _completeness!;
    final isComplete = (c['ready'] as bool?) ?? (c['isComplete'] as bool?) ?? false;
    final missing = (c['missingFields'] as List?) ?? const [];
    final color = isComplete ? AppColors.success : AppColors.warning;
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isComplete
                ? Icons.check_circle_outline
                : Icons.warning_amber_outlined,
            color: color,
          ),
          AppSpacing.hGapSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isComplete ? 'Ready to submit' : 'Almost there',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                AppSpacing.gapXxs,
                Text(
                  isComplete
                      ? 'All required sections are filled in.'
                      : missing.isEmpty
                          ? 'A few fields still need attention before submission.'
                          : 'Missing: ${missing.join(", ")}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stageVal(SubmissionStage s) => switch (s) {
        SubmissionStage.mvp => 'mvp',
        SubmissionStage.earlyRevenue => 'early-revenue',
        SubmissionStage.scaling => 'scaling',
      };

  String _formatAmount(double v) {
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
}

class _StatusBadge extends StatelessWidget {
  final SubmissionStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      SubmissionStatus.draft => (AppColors.mutedForeground, 'Draft'),
      SubmissionStatus.submitted => (AppColors.primary, 'Submitted'),
      SubmissionStatus.underReview => (AppColors.warning, 'Under review'),
      SubmissionStatus.approved => (AppColors.success, 'Approved'),
      SubmissionStatus.rejected => (AppColors.destructive, 'Rejected'),
      SubmissionStatus.suspended => (AppColors.destructive, 'Suspended'),
      SubmissionStatus.matched => (AppColors.primaryDark, 'Matched'),
      SubmissionStatus.closed => (AppColors.mutedForeground, 'Closed'),
    };
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  final VoidCallback? onEdit;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs + 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (onEdit != null)
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                ),
            ],
          ),
          AppSpacing.gapSm,
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool multiline;

  const _Row({
    required this.label,
    required this.value,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final v = value.trim().isEmpty ? 'Not specified' : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.mutedForeground,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            v,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: value.trim().isEmpty
                  ? AppColors.mutedForeground
                  : AppColors.foreground,
            ),
            maxLines: multiline ? null : 2,
            overflow: multiline ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
