import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../bloc/submissions_bloc.dart';

class PitchCreationPage extends StatefulWidget {
  final String? editId;

  const PitchCreationPage({super.key, this.editId});

  @override
  State<PitchCreationPage> createState() => _PitchCreationPageState();
}

class _PitchCreationPageState extends State<PitchCreationPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 1;
  final int _totalSteps = 6;

  // Step 1: Overview
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _sectorController = TextEditingController();
  final _stageController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _pitchVideoUrlController = TextEditingController();

  // Step 2: Problem
  final _problemStatementController = TextEditingController();
  final _targetMarketController = TextEditingController();
  final _marketSizeController = TextEditingController();

  // Step 3: Solution
  final _solutionDescriptionController = TextEditingController();
  final _uniqueValueController = TextEditingController();
  final _competitiveAdvantageController = TextEditingController();

  // Step 4: Business Model
  final _revenueStreamsController = TextEditingController();
  final _pricingStrategyController = TextEditingController();
  final _customerAcquisitionController = TextEditingController();

  // Step 5: Financials
  final _currentRevenueController = TextEditingController();
  final _projectedRevenueController = TextEditingController();
  final _burnRateController = TextEditingController();
  final _runwayController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _sectorController.dispose();
    _stageController.dispose();
    _targetAmountController.dispose();
    _pitchVideoUrlController.dispose();
    _problemStatementController.dispose();
    _targetMarketController.dispose();
    _marketSizeController.dispose();
    _solutionDescriptionController.dispose();
    _uniqueValueController.dispose();
    _competitiveAdvantageController.dispose();
    _revenueStreamsController.dispose();
    _pricingStrategyController.dispose();
    _customerAcquisitionController.dispose();
    _currentRevenueController.dispose();
    _projectedRevenueController.dispose();
    _burnRateController.dispose();
    _runwayController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  void _saveDraft() {
    // Save current progress as draft
    context.read<SubmissionsBloc>().add(
          SubmissionDraftCreated(
            title: _titleController.text.trim(),
            sector: _sectorController.text.trim(),
            stage: _stageController.text.trim(),
          ),
        );
  }

  void _submitPitch() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Submit the pitch
    context.read<SubmissionsBloc>().add(
          SubmissionDraftCreated(
            title: _titleController.text.trim(),
            sector: _sectorController.text.trim(),
            stage: _stageController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Pitch'),
        actions: [
          TextButton(
            onPressed: _saveDraft,
            child: const Text('Save Draft'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      _totalSteps,
                      (index) => _StepIndicator(
                        step: index + 1,
                        currentStep: _currentStep,
                        label: _getStepLabel(index + 1),
                      ),
                    ),
                  ),
                  AppSpacing.gapMd,
                  LinearProgressIndicator(
                    value: _currentStep / _totalSteps,
                    backgroundColor: AppColors.mutedForeground.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,
            // Step content
            Expanded(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Form(
                  key: _formKey,
                  child: _buildStepContent(),
                ),
              ),
            ),
            // Navigation buttons
            Padding(
              padding: AppSpacing.screenPadding,
              child: Row(
                children: [
                  if (_currentStep > 1)
                    Expanded(
                      child: AppButton(
                        text: 'Previous',
                        onPressed: _previousStep,
                        variant: AppButtonVariant.outline,
                      ),
                    ),
                  if (_currentStep > 1) AppSpacing.gapMd,
                  Expanded(
                    child: AppButton(
                      text: _currentStep == _totalSteps ? 'Submit' : 'Next',
                      onPressed: _currentStep == _totalSteps
                          ? _submitPitch
                          : _nextStep,
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

  String _getStepLabel(int step) {
    switch (step) {
      case 1:
        return 'Overview';
      case 2:
        return 'Problem';
      case 3:
        return 'Solution';
      case 4:
        return 'Business';
      case 5:
        return 'Financials';
      case 6:
        return 'Documents';
      default:
        return '';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildOverviewStep();
      case 2:
        return _buildProblemStep();
      case 3:
        return _buildSolutionStep();
      case 4:
        return _buildBusinessModelStep();
      case 5:
        return _buildFinancialsStep();
      case 6:
        return _buildDocumentsStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverviewStep() {
    return ListView(
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        AppSpacing.gapSm,
        Text(
          'Tell investors about your venture',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedForeground,
              ),
        ),
        AppSpacing.gapLg,
        AppTextField(
          label: 'Title',
          controller: _titleController,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        AppSpacing.gapMd,
        AppTextField(
          label: 'Summary',
          controller: _summaryController,
          maxLines: 3,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        AppSpacing.gapMd,
        AppTextField(
          label: 'Sector',
          controller: _sectorController,
          hint: 'e.g., Technology, Healthcare, Finance',
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        AppSpacing.gapMd,
        AppTextField(
          label: 'Stage',
          controller: _stageController,
          hint: 'idea / mvp / early-revenue / scaling',
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        AppSpacing.gapMd,
        AppTextField(
          label: 'Target Amount',
          controller: _targetAmountController,
          keyboardType: TextInputType.number,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        AppSpacing.gapMd,
        AppTextField(
          label: 'Pitch Video URL (optional)',
          controller: _pitchVideoUrlController,
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _buildProblemStep() {
    return ListView(
      children: [
        Text(
          'Problem',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        AppSpacing.gapSm,
        Text(
          'What problem are you solving?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedForeground,
              ),
        ),
        AppSpacing.gapLg,
        AppTextField(
          label: 'Problem Statement',
          controller: _problemStatementController,
          maxLines: 4,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        AppSpacing.gapMd,
        AppTextField(
          label: 'Target Market',
          controller: _targetMarketController,
          maxLines: 2,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        AppSpacing.gapMd,
        AppTextField(
          label: 'Market Size',
          controller: _marketSizeController,
          maxLines: 2,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildSolutionStep() {
    return ListView(
      children: [
        Text(
          'Solution',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        AppSpacing.gapSm,
        Text(
          'How do you solve this problem?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedForeground,
              ),
        ),
        AppSpacing.gapLg,
        AppTextField(
          label: 'Solution Description',
          controller: _solutionDescriptionController,
          maxLines: 4,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        AppSpacing.gapMd,
        AppTextField(
          label: 'Unique Value Proposition',
          controller: _uniqueValueController,
          maxLines: 2,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        AppSpacing.gapMd,
        AppTextField(
          label: 'Competitive Advantage',
          controller: _competitiveAdvantageController,
          maxLines: 2,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildBusinessModelStep() {
    return ListView(
      children: [
        Text(
          'Business Model',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        AppSpacing.gapSm,
        Text(
          'How will you make money?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedForeground,
              ),
        ),
        AppSpacing.gapLg,
        AppTextField(
          label: 'Revenue Streams',
          controller: _revenueStreamsController,
          maxLines: 3,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        AppSpacing.gapMd,
        AppTextField(
          label: 'Pricing Strategy',
          controller: _pricingStrategyController,
          maxLines: 2,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        AppSpacing.gapMd,
        AppTextField(
          label: 'Customer Acquisition',
          controller: _customerAcquisitionController,
          maxLines: 2,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildFinancialsStep() {
    return ListView(
      children: [
        Text(
          'Financials',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        AppSpacing.gapSm,
        Text(
          'Your financial projections',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedForeground,
              ),
        ),
        AppSpacing.gapLg,
        AppTextField(
          label: 'Current Revenue',
          controller: _currentRevenueController,
          keyboardType: TextInputType.number,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        AppSpacing.gapMd,
        AppTextField(
          label: 'Projected Revenue',
          controller: _projectedRevenueController,
          keyboardType: TextInputType.number,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        AppSpacing.gapMd,
        AppTextField(
          label: 'Burn Rate',
          controller: _burnRateController,
          keyboardType: TextInputType.number,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        AppSpacing.gapMd,
        AppTextField(
          label: 'Runway (months)',
          controller: _runwayController,
          keyboardType: TextInputType.number,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDocumentsStep() {
    return ListView(
      children: [
        Text(
          'Documents',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        AppSpacing.gapSm,
        Text(
          'Upload supporting documents',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedForeground,
              ),
        ),
        AppSpacing.gapLg,
        Card(
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 48,
                  color: AppColors.mutedForeground,
                ),
                AppSpacing.gapMd,
                Text(
                  'Document Upload',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.gapSm,
                Text(
                  'Upload your pitch deck, financial projections, and other supporting documents.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.gapLg,
                const AppButton(
                  text: 'Upload Documents',
                  onPressed: null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;
  final int currentStep;
  final String label;

  const _StepIndicator({
    required this.step,
    required this.currentStep,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = step < currentStep;
    final isCurrent = step == currentStep;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isCurrent
                ? Theme.of(context).colorScheme.primary
                : AppColors.mutedForeground.withValues(alpha: 0.3),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    step.toString(),
                    style: TextStyle(
                      color: isCurrent ? Colors.white : AppColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        AppSpacing.gapXs,
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isCurrent
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.mutedForeground,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
      ],
    );
  }
}
