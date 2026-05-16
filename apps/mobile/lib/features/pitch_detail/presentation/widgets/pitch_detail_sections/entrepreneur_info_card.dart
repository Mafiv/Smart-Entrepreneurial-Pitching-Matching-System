import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../domain/entities/pitch_detail_entity.dart';

class EntrepreneurInfoCard extends StatelessWidget {
  final EntrepreneurInfo info;
  final VoidCallback? onMessage;

  const EntrepreneurInfoCard({
    super.key,
    required this.info,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: AppSpacing.screenPadding,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entrepreneur',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.gapMd,
          Row(
            children: [
              // Profile Picture or Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: info.profilePicture != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.network(
                          info.profilePicture!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: AppColors.primary,
                      ),
              ),
              AppSpacing.gapMd,
              // Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.fullName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (info.title != null && info.title!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        info.title!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (info.companyName != null &&
                        info.companyName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        info.companyName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (info.bio != null && info.bio!.isNotEmpty) ...[
            AppSpacing.gapMd,
            Text(
              info.bio!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
