import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sepms_mobile/features/milestones/domain/entities/milestone_entity.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../milestone_display.dart';
import '../bloc/milestones_bloc.dart';
import '../../../payment/presentation/bloc/payment_bloc.dart';

class MilestonesPage extends StatefulWidget {
  const MilestonesPage({super.key});

  @override
  State<MilestonesPage> createState() => _MilestonesPageState();
}

class _MilestonesPageState extends State<MilestonesPage> {
  @override
  void initState() {
    super.initState();
    context.read<MilestonesBloc>().add(const MilestonesRequested());
  }

  void _reload() {
    context.read<MilestonesBloc>().add(const MilestonesRequested());
  }

  void _createDialog() {
    final submissionId = TextEditingController();
    final matchResultId = TextEditingController();
    final title = TextEditingController();
    final amount = TextEditingController();
    final dueDate = TextEditingController(
      text: DateTime.now().add(const Duration(days: 14)).toIso8601String(),
    );

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create milestone'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: 'Submission ID', controller: submissionId),
              AppSpacing.gapSm,
              AppTextField(label: 'MatchResult ID', controller: matchResultId),
              AppSpacing.gapSm,
              AppTextField(label: 'Title', controller: title),
              AppSpacing.gapSm,
              AppTextField(
                label: 'Amount',
                controller: amount,
                keyboardType: TextInputType.number,
              ),
              AppSpacing.gapSm,
              AppTextField(label: 'Due date (ISO)', controller: dueDate),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MilestonesBloc>().add(
                    MilestoneCreated({
                      'submissionId': submissionId.text.trim(),
                      'matchResultId': matchResultId.text.trim(),
                      'title': title.text.trim(),
                      'amount': double.tryParse(amount.text.trim()) ?? 0,
                      'dueDate': dueDate.text.trim(),
                    }),
                  );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _evidenceDialog(String milestoneId) {
    final name = TextEditingController();
    final url = TextEditingController();
    final type = TextEditingController(text: 'report');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit evidence'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(label: 'Name', controller: name),
            AppSpacing.gapSm,
            AppTextField(label: 'URL', controller: url),
            AppSpacing.gapSm,
            AppTextField(label: 'Type', controller: type),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MilestonesBloc>().add(
                    MilestoneEvidenceSubmitted(
                      id: milestoneId,
                      payload: {
                        'evidenceDocuments': [
                          {
                            'name': name.text.trim(),
                            'url': url.text.trim(),
                            'type': type.text.trim(),
                          },
                        ],
                      },
                    ),
                  );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _verifyDialog(String milestoneId, MilestoneEntity milestone) {
    final notes = TextEditingController();
    final rejectionMode = ValueNotifier<bool>(false);

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(
                rejectionMode.value
                    ? Icons.report_problem
                    : Icons.verified_user,
                color: rejectionMode.value
                    ? AppColors.destructive
                    : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(rejectionMode.value
                  ? 'Request Revisions'
                  : 'Verify & Release Funds'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!rejectionMode.value) ...[
                  // Proof display
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Proof of Work',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        if (milestone.proof != null &&
                            milestone.proof!.isNotEmpty) ...[
                          Text(
                            '"${milestone.proof}"',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontStyle: FontStyle.italic,
                                    ),
                          ),
                          if (milestone.proof!.startsWith('http')) ...[
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final uri = Uri.parse(milestone.proof!);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.open_in_new,
                                      size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Review Attachment',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ] else
                          const Text('No textual proof provided.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Warning
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 20, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Important',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Releasing funds is irreversible. Ensure you have reviewed the proof thoroughly.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  // Rejection feedback form
                  Text(
                    'Rejection Feedback',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    label: 'Describe what needs to be fixed...',
                    controller: notes,
                    maxLines: 4,
                    hint:
                        'Explain what\'s missing or what needs to be changed...',
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (!rejectionMode.value) ...[
              TextButton(
                onPressed: () {
                  setState(() => rejectionMode.value = true);
                },
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.destructive),
                child: const Text('Reject'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Initiate Chapa payment
                  context
                      .read<PaymentBloc>()
                      .add(PaymentInitiated(milestoneId: milestoneId));
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.payment, size: 18),
                    SizedBox(width: 8),
                    Text('Verify & Pay'),
                  ],
                ),
              ),
            ] else ...[
              TextButton(
                onPressed: () {
                  setState(() => rejectionMode.value = false);
                },
                child: const Text('Back'),
              ),
              FilledButton(
                onPressed: () {
                  if (notes.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Please provide feedback for rejection')),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  context.read<MilestonesBloc>().add(
                        MilestoneVerified(
                          id: milestoneId,
                          payload: {
                            'status': 'rejected',
                            'feedback': notes.text.trim(),
                          },
                        ),
                      );
                },
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.destructive),
                child: const Text('Confirm Rejection'),
              ),
            ],
          ],
        ),
      ),
    );
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
              'Milestones',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Evidence & verification',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Add milestone',
            icon: const Icon(Icons.add_rounded),
            onPressed: _createDialog,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _reload,
          ),
        ],
      ),
      body: SafeArea(
        child: BlocListener<PaymentBloc, PaymentState>(
          listener: (context, paymentState) {
            if (paymentState.status == PaymentStatus.paymentInitiated) {
              final checkoutUrl = paymentState.paymentResponse?.checkoutUrl;
              if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
                launchUrl(Uri.parse(checkoutUrl),
                    mode: LaunchMode.externalApplication);
              }
            } else if (paymentState.status == PaymentStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text(paymentState.errorMessage ?? 'Payment failed')),
              );
            }
          },
          child: BlocBuilder<MilestonesBloc, MilestonesState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == MilestonesStatus.error) {
                return EmptyStateView(
                  icon: Icons.flag_outlined,
                  title: 'Could not load milestones',
                  message: state.error ?? 'Please try again.',
                  actionLabel: 'Retry',
                  onAction: _reload,
                );
              }
              if (state.items.isEmpty) {
                return EmptyStateView(
                  icon: Icons.flag_circle_outlined,
                  title: 'No milestones',
                  message:
                      'Create milestones to track deliverables with investors.',
                  actionLabel: 'Add milestone',
                  onAction: _createDialog,
                );
              }

              return ListView.separated(
                padding: AppSpacing.screenPadding.copyWith(bottom: 32),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => AppSpacing.gapMd,
                itemBuilder: (context, i) {
                  final m = state.items[i];
                  final statusLabel = milestoneStatusLabel(m.status);

                  return Material(
                    color: AppColors.card,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: AppSpacing.paddingMd,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  m.title.isEmpty ? 'Milestone' : m.title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.warning.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusFull,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  child: Text(
                                    statusLabel.toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (m.amount > 0) ...[
                            AppSpacing.gapSm,
                            Text(
                              '${m.amount} ${m.currency}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                          AppSpacing.gapMd,
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              OutlinedButton(
                                onPressed: m.id.isEmpty
                                    ? null
                                    : () => _evidenceDialog(m.id),
                                child: const Text('Evidence'),
                              ),
                              FilledButton.tonal(
                                onPressed: m.id.isEmpty
                                    ? null
                                    : () => _verifyDialog(m.id, m),
                                child: const Text('Verify'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
