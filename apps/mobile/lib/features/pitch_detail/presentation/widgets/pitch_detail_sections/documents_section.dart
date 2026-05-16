import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../domain/entities/pitch_detail_entity.dart';

class DocumentsSection extends StatelessWidget {
  final List<PitchDocument> documents;

  const DocumentsSection({
    super.key,
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        AppSpacing.gapMd,
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: documents.length,
          separatorBuilder: (_, __) => AppSpacing.gapSm,
          itemBuilder: (context, index) {
            final doc = documents[index];
            return _DocumentTile(document: doc);
          },
        ),
      ],
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final PitchDocument document;

  const _DocumentTile({required this.document});

  IconData _getDocumentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pitch_deck':
      case 'presentation':
        return Icons.slideshow;
      case 'financial_model':
      case 'financials':
        return Icons.trending_up;
      case 'business_plan':
      case 'plan':
        return Icons.description;
      case 'video':
        return Icons.video_library;
      case 'image':
      case 'screenshot':
        return Icons.image;
      default:
        return Icons.attachment;
    }
  }

  String _getDocumentTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'pitch_deck':
        return 'Pitch Deck';
      case 'financial_model':
        return 'Financial Model';
      case 'business_plan':
        return 'Business Plan';
      default:
        return type.replaceAll('_', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _getDocumentIcon(document.type);
    final label = _getDocumentTypeLabel(document.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: Implement document opening/downloading
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.download_rounded,
                color: AppColors.mutedForeground,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
