import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../meetings/presentation/pages/meeting_join_page.dart';
import '../../domain/entities/pitch_detail_entity.dart';
import 'pitch_detail_sections/documents_section.dart';
import 'pitch_detail_sections/entrepreneur_info_card.dart';
import 'pitch_detail_sections/financial_section.dart';
import 'pitch_detail_sections/pitch_header_card.dart';

class PitchDetailContent extends StatelessWidget {
  final PitchDetailEntity pitch;
  final VoidCallback onSaveToggle;

  const PitchDetailContent({
    super.key,
    required this.pitch,
    required this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Card with basic pitch info
        PitchHeaderCard(pitch: pitch),
        AppSpacing.gapMd,

        // Entrepreneur Info
        Padding(
          padding: AppSpacing.screenPadding,
          child: EntrepreneurInfoCard(
            info: pitch.entrepreneur,
            onMessage: () {
              // TODO: Implement create or get conversation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening conversation...')),
              );
            },
          ),
        ),
        AppSpacing.gapMd,

        // Schedule Meeting Button
        Padding(
          padding: AppSpacing.screenPadding,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MeetingJoinPage(
                      meetingId: pitch.id,
                      meetingTitle: pitch.title,
                      participantName: pitch.entrepreneur.fullName,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.videocam),
              label: const Text('Schedule Meeting'),
            ),
          ),
        ),
        AppSpacing.gapMd,

        // Financial Information
        Padding(
          padding: AppSpacing.screenPadding,
          child: FinancialSection(financials: pitch.financials),
        ),
        AppSpacing.gapMd,

        // Pitch Description
        Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pitch Summary',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.gapSm,
              Text(
                pitch.summary.isEmpty ? 'No summary provided' : pitch.summary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: pitch.summary.isEmpty
                      ? AppColors.mutedForeground
                      : AppColors.foreground,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapMd,

        // Problem Statement
        Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Problem',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.gapSm,
              Text(
                pitch.problemStatement.isEmpty
                    ? 'Not provided'
                    : pitch.problemStatement,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: pitch.problemStatement.isEmpty
                      ? AppColors.mutedForeground
                      : AppColors.foreground,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapMd,

        // Solution Statement
        Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Solution',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.gapSm,
              Text(
                pitch.solution.isEmpty ? 'Not provided' : pitch.solution,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: pitch.solution.isEmpty
                      ? AppColors.mutedForeground
                      : AppColors.foreground,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapMd,

        // Competitive Advantage
        if (pitch.competitiveAdvantage.isNotEmpty) ...[
          Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Competitive Advantage',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.gapSm,
                Text(
                  pitch.competitiveAdvantage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapMd,
        ],

        // Documents Section
        if (pitch.documents.isNotEmpty) ...[
          Padding(
            padding: AppSpacing.screenPadding,
            child: DocumentsSection(documents: pitch.documents),
          ),
          AppSpacing.gapMd,
        ],

        // Bottom Padding
        AppSpacing.gapXl,
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ],
    );
  }
}
