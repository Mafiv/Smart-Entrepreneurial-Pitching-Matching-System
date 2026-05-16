import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/submission_entity.dart';
import '../bloc/submissions_bloc.dart';

class PitchReviewPage extends StatefulWidget {
  final String submissionId;

  const PitchReviewPage({super.key, required this.submissionId});

  @override
  State<PitchReviewPage> createState() => _PitchReviewPageState();
}

class _PitchReviewPageState extends State<PitchReviewPage> {
  SubmissionEntity? _submission;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubmission();
  }

  Future<void> _loadSubmission() async {
    setState(() => _isLoading = true);
    // Load submission data
    // For now, we'll use mock data
    setState(() => _isLoading = false);
  }

  void _submitPitch() {
    if (_submission == null) return;
    setState(() => _isSubmitting = true);
    // Submit the pitch
    context.read<SubmissionsBloc>().add(
          SubmissionSubmitted(widget.submissionId),
        );
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Pitch'),
        actions: [
          if (_submission != null && _submission!.status == SubmissionStatus.draft)
            TextButton(
              onPressed: _isSubmitting ? null : _submitPitch,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      AppSpacing.gapMd,
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.gapLg,
                      AppButton(text: 'Retry', onPressed: _loadSubmission),
                    ],
                  ),
                )
              : _submission == null
                  ? const Center(child: Text('Submission not found'))
                  : _buildReviewContent(),
    );
  }

  Widget _buildReviewContent() {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        // Status badge
        _buildStatusBadge(),
        AppSpacing.gapLg,

        // Overview section
        _buildSectionCard(
          title: 'Overview',
          icon: Icons.description_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Title', _submission!.title),
              AppSpacing.gapSm,
              _buildInfoRow('Sector', _submission!.sector),
              AppSpacing.gapSm,
              _buildInfoRow('Stage', _submission!.stage.toString()),
              AppSpacing.gapSm,
              _buildInfoRow(
                'Target Amount',
                '\$${_submission!.targetAmount?.toStringAsFixed(2) ?? '0'}',
              ),
              AppSpacing.gapMd,
              Text(
                'Summary',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
              ),
              AppSpacing.gapXs,
              Text(_submission!.summary),
            ],
          ),
        ),
        AppSpacing.gapLg,

        // Problem section
        _buildSectionCard(
          title: 'Problem',
          icon: Icons.search,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Statement', _submission!.problem.statement),
              AppSpacing.gapSm,
              _buildInfoRow('Target Market', _submission!.problem.targetMarket),
              AppSpacing.gapSm,
              _buildInfoRow('Market Size', _submission!.problem.marketSize),
            ],
          ),
        ),
        AppSpacing.gapLg,

        // Solution section
        _buildSectionCard(
          title: 'Solution',
          icon: Icons.lightbulb_outline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Description', _submission!.solution.description),
              AppSpacing.gapSm,
              _buildInfoRow('Unique Value', _submission!.solution.uniqueValue),
              AppSpacing.gapSm,
              _buildInfoRow(
                'Competitive Advantage',
                _submission!.solution.competitiveAdvantage,
              ),
            ],
          ),
        ),
        AppSpacing.gapLg,

        // Business Model section
        _buildSectionCard(
          title: 'Business Model',
          icon: Icons.bar_chart,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                'Revenue Streams',
                _submission!.businessModel.revenueStreams,
              ),
              AppSpacing.gapSm,
              _buildInfoRow(
                'Pricing Strategy',
                _submission!.businessModel.pricingStrategy,
              ),
              AppSpacing.gapSm,
              _buildInfoRow(
                'Customer Acquisition',
                _submission!.businessModel.customerAcquisition,
              ),
            ],
          ),
        ),
        AppSpacing.gapLg,

        // Financials section
        _buildSectionCard(
          title: 'Financials',
          icon: Icons.attach_money,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                'Current Revenue',
                _submission!.financials.currentRevenue,
              ),
              AppSpacing.gapSm,
              _buildInfoRow(
                'Projected Revenue',
                _submission!.financials.projectedRevenue,
              ),
              AppSpacing.gapSm,
              _buildInfoRow('Burn Rate', _submission!.financials.burnRate),
              AppSpacing.gapSm,
              _buildInfoRow('Runway', _submission!.financials.runway),
            ],
          ),
        ),
        AppSpacing.gapLg,

        // Documents section
        _buildSectionCard(
          title: 'Documents',
          icon: Icons.folder_open,
          child: _submission!.documents.isEmpty
              ? Text(
                  'No documents uploaded',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _submission!.documents.map((doc) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file, size: 20),
                          AppSpacing.gapSm,
                          Expanded(
                            child: Text(doc.name),
                          ),
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
        AppSpacing.gapLg,

        // Completeness check
        _buildCompletenessCard(),
        AppSpacing.gapXl,
      ],
    );
  }

  Widget _buildStatusBadge() {
    final status = _submission!.status;
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case SubmissionStatus.draft:
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        label = 'Draft';
        break;
      case SubmissionStatus.submitted:
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF2563EB);
        label = 'Submitted';
        break;
      case SubmissionStatus.underReview:
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        label = 'Under Review';
        break;
      case SubmissionStatus.approved:
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        label = 'Approved';
        break;
      case SubmissionStatus.rejected:
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        label = 'Rejected';
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        label = status.toString();
    }

    return Container(
      padding: AppSpacing.paddingSm,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                AppSpacing.gapSm,
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            AppSpacing.gapMd,
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.mutedForeground,
              ),
        ),
        AppSpacing.gapXs,
        Text(
          value.isNotEmpty ? value : 'Not specified',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildCompletenessCard() {
    // Mock completeness check
    final isComplete = _submission!.status == SubmissionStatus.submitted ||
        _submission!.status == SubmissionStatus.underReview ||
        _submission!.status == SubmissionStatus.approved;

    return Card(
      color: isComplete
          ? const Color(0xFFD1FAE5)
          : const Color(0xFFFEE2E2),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Icon(
              isComplete ? Icons.check_circle : Icons.warning_amber,
              color: isComplete ? const Color(0xFF059669) : const Color(0xFFDC2626),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isComplete ? 'Ready to Submit' : 'Incomplete',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isComplete
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                        ),
                  ),
                  AppSpacing.gapXs,
                  Text(
                    isComplete
                        ? 'All required fields are filled and documents are uploaded.'
                        : 'Please complete all required fields before submitting.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isComplete
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
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
