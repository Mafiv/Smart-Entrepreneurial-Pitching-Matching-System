import 'dart:io';

import 'package:dartz/dartz.dart' show Either;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../documents/domain/entities/document_entity.dart';
import '../../../documents/presentation/bloc/documents_bloc.dart';
import '../../domain/constants/submission_options.dart';
import '../../domain/entities/submission_entity.dart';
import '../../domain/usecases/submissions_usecases.dart';
import 'pitch_review_page.dart';

/// Multi-step entrepreneur pitch creation flow that mirrors the web
/// `/entrepreneur/pitch/new` experience. Loads an existing draft when an
/// `editId` is provided, persists progress per step via PATCH, and gates the
/// document step on having a created submission.
class PitchCreationPage extends StatefulWidget {
  final String? editId;

  const PitchCreationPage({super.key, this.editId});

  @override
  State<PitchCreationPage> createState() => _PitchCreationPageState();
}

class _StepDef {
  final String title;
  final IconData icon;
  const _StepDef(this.title, this.icon);
}

class _PitchCreationPageState extends State<PitchCreationPage> {
  static const List<_StepDef> _steps = [
    _StepDef('Overview', Icons.assignment_outlined),
    _StepDef('Problem', Icons.search_rounded),
    _StepDef('Solution', Icons.lightbulb_outline_rounded),
    _StepDef('Business Model', Icons.bar_chart_rounded),
    _StepDef('Financials', Icons.payments_outlined),
    _StepDef('Documents', Icons.upload_file_rounded),
  ];

  final Map<int, GlobalKey<FormState>> _formKeys = {};
  int _currentStep = 0;
  String? _submissionId;
  bool _saving = false;
  String? _saveStatus;
  bool _initialLoading = false;

  // Use cases pulled directly so the stepper has fully local state without
  // colliding with the global SubmissionsBloc list view.
  late final GetSubmissionByIdUseCase _getById = sl<GetSubmissionByIdUseCase>();
  late final CreateDraftUseCase _create = sl<CreateDraftUseCase>();
  late final UpdateDraftUseCase _update = sl<UpdateDraftUseCase>();

  // Step 1 – Overview
  final _title = TextEditingController();
  final _summary = TextEditingController();
  final _targetAmount = TextEditingController();
  final _videoUrl = TextEditingController();
  String _sector = 'technology';
  String _stage = 'mvp';

  // Step 2 – Problem
  final _problemStatement = TextEditingController();
  final _targetMarket = TextEditingController();
  final _marketSize = TextEditingController();

  // Step 3 – Solution
  final _solutionDescription = TextEditingController();
  final _uniqueValue = TextEditingController();
  final _competitiveAdvantage = TextEditingController();

  // Step 4 – Business model
  final _revenueStreams = TextEditingController();
  final _pricingStrategy = TextEditingController();
  final _customerAcquisition = TextEditingController();

  // Step 5 – Financials
  final _currentRevenue = TextEditingController();
  final _projectedRevenue = TextEditingController();
  final _burnRate = TextEditingController();
  final _runway = TextEditingController();

  // Step 6 – Documents
  String _docType = 'pitch_deck';

  @override
  void initState() {
    super.initState();
    _submissionId = widget.editId;
    if (_submissionId != null && _submissionId!.isNotEmpty) {
      _loadDraft();
    }
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _summary,
      _targetAmount,
      _videoUrl,
      _problemStatement,
      _targetMarket,
      _marketSize,
      _solutionDescription,
      _uniqueValue,
      _competitiveAdvantage,
      _revenueStreams,
      _pricingStrategy,
      _customerAcquisition,
      _currentRevenue,
      _projectedRevenue,
      _burnRate,
      _runway,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDraft() async {
    setState(() => _initialLoading = true);
    final res = await _getById(_submissionId!);
    res.fold(
      (f) {
        if (mounted) _showSnack('Failed to load draft: ${f.message}');
      },
      (s) {
        _title.text = s.title;
        _summary.text = s.summary;
        _sector = s.sector.isEmpty ? 'technology' : s.sector;
        _stage = _stageToValue(s.stage);
        if (s.targetAmount != null) {
          _targetAmount.text = s.targetAmount!.toStringAsFixed(0);
        }
        _problemStatement.text = s.problem.statement;
        _targetMarket.text = s.problem.targetMarket;
        _marketSize.text = s.problem.marketSize;
        _solutionDescription.text = s.solution.description;
        _uniqueValue.text = s.solution.uniqueValue;
        _competitiveAdvantage.text = s.solution.competitiveAdvantage;
        _revenueStreams.text = s.businessModel.revenueStreams;
        _pricingStrategy.text = s.businessModel.pricingStrategy;
        _customerAcquisition.text = s.businessModel.customerAcquisition;
        _currentRevenue.text = s.financials.currentRevenue;
        _projectedRevenue.text = s.financials.projectedRevenue;
        _burnRate.text = s.financials.burnRate;
        _runway.text = s.financials.runway;
        _currentStep =
            (s.currentStep - 1).clamp(0, _steps.length - 1);
      },
    );
    if (mounted) setState(() => _initialLoading = false);
  }

  String _stageToValue(SubmissionStage s) => switch (s) {
        SubmissionStage.mvp => 'mvp',
        SubmissionStage.earlyRevenue => 'early-revenue',
        SubmissionStage.scaling => 'scaling',
      };

  Map<String, dynamic> _payloadForStep(int step) {
    switch (step) {
      case 0:
        return {
          'title': _title.text.trim(),
          'sector': _sector,
          'stage': _stage,
          'targetAmount': double.tryParse(_targetAmount.text.trim()) ?? 0,
          'summary': _summary.text.trim(),
          if (_videoUrl.text.trim().isNotEmpty)
            'pitchVideoUrl': _videoUrl.text.trim(),
          'currentStep': step + 1,
        };
      case 1:
        return {
          'problem': {
            'statement': _problemStatement.text.trim(),
            'targetMarket': _targetMarket.text.trim(),
            'marketSize': _marketSize.text.trim(),
          },
          'currentStep': step + 1,
        };
      case 2:
        return {
          'solution': {
            'description': _solutionDescription.text.trim(),
            'uniqueValue': _uniqueValue.text.trim(),
            'competitiveAdvantage': _competitiveAdvantage.text.trim(),
          },
          'currentStep': step + 1,
        };
      case 3:
        return {
          'businessModel': {
            'revenueStreams': _revenueStreams.text.trim(),
            'pricingStrategy': _pricingStrategy.text.trim(),
            'customerAcquisition': _customerAcquisition.text.trim(),
          },
          'currentStep': step + 1,
        };
      case 4:
        return {
          'financials': {
            'currentRevenue': _currentRevenue.text.trim(),
            'projectedRevenue': _projectedRevenue.text.trim(),
            'burnRate': _burnRate.text.trim(),
            'runway': _runway.text.trim(),
          },
          'currentStep': step + 1,
        };
      default:
        return {'currentStep': step + 1};
    }
  }

  Future<bool> _saveDraft({bool showToast = true}) async {
    setState(() {
      _saving = true;
      _saveStatus = null;
    });
    final patch = _payloadForStep(_currentStep);
    Either<Failure, SubmissionEntity> result;
    if (_submissionId == null || _submissionId!.isEmpty) {
      result = await _create(
        title: _title.text.trim().isEmpty ? 'Untitled Pitch' : _title.text.trim(),
        sector: _sector,
        stage: _stage,
      );
      await result.fold(
        (f) async {
          // Creation failed, keep result as failure
        },
        (created) async {
          _submissionId = created.id;
          // After creation, immediately patch with full step payload.
          if (created.id.isNotEmpty) {
            result = await _update(created.id, patch);
          }
        },
      );
    } else {
      result = await _update(_submissionId!, patch);
    }
    var ok = false;
    result.fold(
      (f) {
        if (mounted) {
          setState(() => _saveStatus = 'Failed to save');
          if (showToast) _showSnack(f.message);
        }
      },
      (_) {
        ok = true;
        if (mounted) setState(() => _saveStatus = 'Draft saved ✓');
      },
    );
    if (mounted) {
      setState(() => _saving = false);
      Future<void>.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _saveStatus = null);
      });
    }
    return ok;
  }

  bool _validateStep(int step) {
    if (step == 5) return true; // Documents step has no form
    final formKey = _formKeys.putIfAbsent(step, () => GlobalKey<FormState>());
    final form = formKey.currentState;
    if (form == null) return false;
    return form.validate();
  }

  Future<void> _onContinue() async {
    if (!_validateStep(_currentStep)) {
      _showSnack('Please fill in all required fields');
      return;
    }
    final ok = await _saveDraft(showToast: false);
    if (!ok || !mounted) {
      if (mounted) _showSnack('Failed to save draft');
      return;
    }
    if (_currentStep < _steps.length - 1) {
      if (mounted) {
        setState(() => _currentStep++);
      }
    } else {
      // Final step → review.
      if (_submissionId == null || !mounted) return;
      final id = _submissionId!;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => PitchReviewPage(submissionId: id),
        ),
      );
    }
  }

  void _onBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider<DocumentsBloc>(
      create: (_) {
        final bloc = sl<DocumentsBloc>();
        if (_submissionId != null) {
          bloc.add(const DocumentsRequested());
        }
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.editId == null ? 'Create new pitch' : 'Edit pitch',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Tell investors about your startup vision',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: TextButton.icon(
                onPressed: _saving ? null : () => _saveDraft(),
                icon: _saving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(_saving ? 'Saving' : 'Save draft'),
              ),
            ),
          ],
        ),
        body: _initialLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Column(
                  children: [
                    _buildProgressHeader(theme),
                    if (_saveStatus != null)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.xs,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            _saveStatus!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.mutedForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        switchInCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.04),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey<int>(_currentStep),
                          child: Form(
                            key: _formKeys.putIfAbsent(_currentStep, () => GlobalKey<FormState>()),
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                AppSpacing.md,
                                AppSpacing.lg,
                                120,
                              ),
                              children: [
                                _buildStepHeader(theme),
                                AppSpacing.gapLg,
                                ..._buildStepFields(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildFooter(theme),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProgressHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Step ${_currentStep + 1} of ${_steps.length}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Text(
                _steps[_currentStep].title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          AppSpacing.gapSm,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / _steps.length,
              minHeight: 6,
              backgroundColor: AppColors.muted,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          AppSpacing.gapSm,
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _steps.length,
              separatorBuilder: (_, __) => AppSpacing.hGapSm,
              itemBuilder: (_, i) {
                final active = i == _currentStep;
                final done = i < _currentStep;
                return _StepChip(
                  label: _steps[i].title,
                  icon: _steps[i].icon,
                  active: active,
                  done: done,
                  onTap: i <= _currentStep ? () => setState(() => _currentStep = i) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(ThemeData theme) {
    final s = _steps[_currentStep];
    final subtitles = [
      'Start with the basics of your business pitch.',
      'Describe the problem your business solves.',
      'How does your product or service solve the problem?',
      'How does your business make money?',
      'Share your financial metrics and projections.',
      'Upload pitch decks, financial models and legal documents.',
    ];
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(s.icon, color: AppColors.primary, size: 22),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.gapXxs,
                Text(
                  subtitles[_currentStep],
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

  List<Widget> _buildStepFields() {
    switch (_currentStep) {
      case 0:
        return _overviewFields();
      case 1:
        return _problemFields();
      case 2:
        return _solutionFields();
      case 3:
        return _businessFields();
      case 4:
        return _financialsFields();
      case 5:
        return _documentsFields();
      default:
        return const [];
    }
  }

  String? _required(String? v, {int minChars = 0, String? msg}) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Required';
    if (minChars > 0 && t.length < minChars) {
      return msg ?? 'Must be at least $minChars characters';
    }
    return null;
  }

  List<Widget> _overviewFields() {
    return [
      AppTextField(
        label: 'Pitch title',
        hint: 'e.g., AI-Powered Supply Chain for East Africa',
        controller: _title,
        validator: (v) => _required(v, minChars: 5),
      ),
      AppSpacing.gapMd,
      _buildDropdown(
        label: 'Industry sector',
        value: _sector,
        options: SubmissionOptions.sectors,
        onChanged: (v) => setState(() => _sector = v),
      ),
      AppSpacing.gapMd,
      _buildDropdown(
        label: 'Startup stage',
        value: _stage,
        options: SubmissionOptions.stages,
        onChanged: (v) => setState(() => _stage = v),
      ),
      AppSpacing.gapMd,
      AppTextField(
        label: 'Target funding amount (USD)',
        hint: 'e.g., 500000',
        controller: _targetAmount,
        keyboardType: TextInputType.number,
        validator: (v) {
          final n = double.tryParse((v ?? '').trim());
          if (n == null || n < 1000) return 'Minimum funding amount is \$1,000';
          if (n > 100000000) return 'Maximum funding amount is \$100,000,000';
          return null;
        },
      ),
      AppSpacing.gapMd,
      AppTextField(
        label: 'Executive summary',
        hint: 'A concise overview of your business and what makes it compelling…',
        controller: _summary,
        maxLines: 5,
        validator: (v) => _required(v, minChars: 20),
      ),
      AppSpacing.gapMd,
      AppTextField(
        label: 'Pitch video URL (optional)',
        hint: 'https://youtube.com/watch?v=…',
        controller: _videoUrl,
        keyboardType: TextInputType.url,
      ),
    ];
  }

  List<Widget> _problemFields() {
    return [
      AppTextField(
        label: 'Problem statement',
        hint: 'What specific problem exists in the market today?',
        controller: _problemStatement,
        maxLines: 5,
        validator: (v) => _required(v, minChars: 20),
      ),
      AppSpacing.gapMd,
      AppTextField(
        label: 'Target market',
        hint: 'Who are your target customers? Demographics, segments…',
        controller: _targetMarket,
        maxLines: 3,
        validator: (v) => _required(v, minChars: 10),
      ),
      AppSpacing.gapMd,
      AppTextField(
        label: 'Market size',
        hint: 'TAM / SAM / SOM — estimated market size in dollars…',
        controller: _marketSize,
        maxLines: 3,
        validator: (v) => _required(v, minChars: 5),
      ),
    ];
  }

  List<Widget> _solutionFields() {
    return [
      AppTextField(
        label: 'Solution description',
        hint: 'Describe your product/service and how it works…',
        controller: _solutionDescription,
        maxLines: 5,
        validator: (v) => _required(v, minChars: 20),
      ),
      AppSpacing.gapMd,
      AppTextField(
        label: 'Unique value proposition',
        hint: 'What makes your solution uniquely better than alternatives?',
        controller: _uniqueValue,
        maxLines: 3,
        validator: (v) => _required(v, minChars: 10),
      ),
      AppSpacing.gapMd,
      AppTextField(
        label: 'Competitive advantage',
        hint: 'What moats or barriers to entry do you have?',
        controller: _competitiveAdvantage,
        maxLines: 3,
        validator: (v) => _required(v, minChars: 10),
      ),
    ];
  }

  List<Widget> _businessFields() {
    return [
      AppTextField(
        label: 'Revenue streams',
        hint: 'How does your business generate revenue?',
        controller: _revenueStreams,
        maxLines: 4,
        validator: (v) => _required(v, minChars: 10),
      ),
      AppSpacing.gapMd,
      AppTextField(
        label: 'Pricing strategy',
        hint: 'Pricing tiers, freemium, usage-based…',
        controller: _pricingStrategy,
        maxLines: 3,
        validator: (v) => _required(v, minChars: 10),
      ),
      AppSpacing.gapMd,
      AppTextField(
        label: 'Customer acquisition',
        hint: 'How will you acquire and retain customers?',
        controller: _customerAcquisition,
        maxLines: 3,
        validator: (v) => _required(v, minChars: 10),
      ),
    ];
  }

  List<Widget> _financialsFields() {
    return [
      AppTextField(
        label: 'Current revenue',
        hint: 'e.g., \$50,000 MRR or Pre-revenue',
        controller: _currentRevenue,
      ),
      AppSpacing.gapMd,
      AppTextField(
        label: 'Projected revenue (12 months)',
        hint: 'e.g., \$500,000 ARR by Q4 next year',
        controller: _projectedRevenue,
        validator: (v) => _required(v, minChars: 5),
      ),
      AppSpacing.gapMd,
      AppTextField(
        label: 'Monthly burn rate',
        hint: 'e.g., \$15,000/month',
        controller: _burnRate,
      ),
      AppSpacing.gapMd,
      AppTextField(
        label: 'Remaining runway',
        hint: 'e.g., 8 months at current burn rate',
        controller: _runway,
      ),
    ];
  }

  List<Widget> _documentsFields() {
    if (_submissionId == null || _submissionId!.isEmpty) {
      return [
        Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.warning),
              AppSpacing.hGapSm,
              const Expanded(
                child: Text(
                  'Please save your pitch draft first (go back and fill at '
                  'least Step 1) before uploading documents.',
                ),
              ),
            ],
          ),
        ),
      ];
    }

    final categories =
        SubmissionOptions.docCategoriesForStage(_stage);

    return [
      Text(
        '1. Document type',
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      AppSpacing.gapXs,
      Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _docType,
            isExpanded: true,
            items: categories
                .map(
                  (c) => DropdownMenuItem<String>(
                    value: c.value,
                    child: Text('${c.label}${c.required ? " *" : ""}'),
                  ),
                )
                .toList(growable: false),
            onChanged: (v) => setState(() => _docType = v ?? _docType),
          ),
        ),
      ),
      AppSpacing.gapMd,
      Text(
        '2. Upload file',
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      AppSpacing.gapXs,
      BlocConsumer<DocumentsBloc, DocumentsState>(
        listener: (ctx, state) {
          if (state.status == DocumentsStatus.error && state.error != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (ctx, state) {
          final uploading = state.isLoading;
          final docs = state.items
              .where((d) => d.submissionId == _submissionId)
              .toList(growable: false);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: uploading ? null : () => _pickAndUpload(ctx),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: AppColors.muted.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      style: BorderStyle.solid,
                      width: 1.4,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        uploading
                            ? Icons.cloud_sync_outlined
                            : Icons.cloud_upload_outlined,
                        size: 36,
                        color: AppColors.primary,
                      ),
                      AppSpacing.gapSm,
                      Text(
                        uploading ? 'Uploading…' : 'Tap to browse and upload',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      AppSpacing.gapXxs,
                      Text(
                        'PDF, DOC, PPT, XLSX, JPG up to 70MB',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.gapMd,
              if (docs.isEmpty)
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: AppColors.muted.withValues(alpha: 0.4),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.mutedForeground),
                      AppSpacing.hGapSm,
                      Expanded(
                        child: Text(
                          'No documents uploaded yet. Upload your pitch deck, '
                          'financials, or legal docs to strengthen your '
                          'submission.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uploaded documents (${docs.length})',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    AppSpacing.gapXs,
                    ...docs.map((d) => _DocumentTile(
                          document: d,
                          onDelete: () => ctx
                              .read<DocumentsBloc>()
                              .add(DocumentDeleteRequested(d.id)),
                        )),
                  ],
                ),
            ],
          );
        },
      ),
    ];
  }

  Future<void> _pickAndUpload(BuildContext ctx) async {
    final bloc = ctx.read<DocumentsBloc>();
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
        'jpg',
        'jpeg',
        'png',
        'webp',
      ],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    final path = picked.path;
    if (path == null) return;
    final file = File(path);
    if (await file.length() > 70 * 1024 * 1024) {
      if (!mounted) return;
      _showSnack('File exceeds the 70MB upload limit');
      return;
    }
    bloc.add(
      DocumentUploadRequested(
        file: file,
        type: _docType,
        submissionId: _submissionId,
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Material(
      color: theme.colorScheme.surface,
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
                  text: 'Back',
                  variant: AppButtonVariant.outline,
                  onPressed: _currentStep == 0 ? null : _onBack,
                  icon: Icons.arrow_back_rounded,
                ),
              ),
              AppSpacing.hGapMd,
              Expanded(
                flex: 2,
                child: AppButton(
                  text: _currentStep == _steps.length - 1
                      ? 'Review pitch'
                      : 'Continue',
                  onPressed: _onContinue,
                  iconOnRight: true,
                  icon: Icons.arrow_forward_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<OptionItem> options,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
        ),
        AppSpacing.gapXs,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: options
                  .map(
                    (o) => DropdownMenuItem<String>(
                      value: o.value,
                      child: Text(o.label),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _StepChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final bool done;
  final VoidCallback? onTap;

  const _StepChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.done,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = active
        ? AppColors.primary
        : done
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.muted;
    final fg = active
        ? Colors.white
        : done
            ? AppColors.primary
            : AppColors.mutedForeground;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(done ? Icons.check_rounded : icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final DocumentEntity document;
  final VoidCallback onDelete;

  const _DocumentTile({required this.document, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusBadge = _statusBadge(document.status);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: AppColors.primary),
          AppSpacing.hGapSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.filename,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.gapXxs,
                Text(
                  SubmissionOptions.docLabel(_docTypeKey(document.type)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                if (document.processingError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      document.processingError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.destructive,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          AppSpacing.hGapSm,
          statusBadge,
          IconButton(
            tooltip: 'Remove',
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.mutedForeground),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  String _docTypeKey(DocumentType t) => switch (t) {
        DocumentType.pitchDeck => 'pitch_deck',
        DocumentType.financialModel => 'financial_model',
        DocumentType.productDemo => 'product_demo',
        DocumentType.customerTestimonials => 'customer_testimonials',
        DocumentType.other => 'other',
      };

  Widget _statusBadge(DocumentProcessingStatus status) {
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case DocumentProcessingStatus.processed:
        color = AppColors.success;
        label = 'Verified';
        icon = Icons.verified_outlined;
        break;
      case DocumentProcessingStatus.processing:
        color = AppColors.primary;
        label = 'Processing';
        icon = Icons.autorenew_rounded;
        break;
      case DocumentProcessingStatus.failed:
        color = AppColors.destructive;
        label = 'Failed';
        icon = Icons.error_outline_rounded;
        break;
      case DocumentProcessingStatus.flagged:
        color = AppColors.warning;
        label = 'Suspicious';
        icon = Icons.warning_amber_outlined;
        break;
      case DocumentProcessingStatus.uploaded:
        color = AppColors.mutedForeground;
        label = 'Uploaded';
        icon = Icons.cloud_done_outlined;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
