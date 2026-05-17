import 'package:flutter/material.dart';
import '../../../../core/design/shadows.dart';
import '../../../../core/design/ui_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/drawer_item_model.dart';

/// Premium drawer header displaying user profile information
class AppDrawerHeader extends StatelessWidget {
  const AppDrawerHeader({
    super.key,
    required this.userInfo,
    required this.onEditProfile,
  });

  final DrawerUserInfo userInfo;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        top: AppUIConstants.drawerHeaderPaddingTop,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppUIConstants.drawerHeaderPaddingBottom,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: AppShadows.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with border
          _UserAvatar(userInfo: userInfo),
          AppSpacing.gapMd,

          // User info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // User name
                    Text(
                      userInfo.name,
                      maxLines: AppUIConstants.userNameMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.gapXs,

                    // Role badge with verification status
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _RoleBadge(userInfo: userInfo),
                        if (userInfo.isVerified) ...[
                          AppSpacing.hGapXs,
                          _VerificationBadge(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,

          // Edit profile link
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onEditProfile,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Edit Profile',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// User avatar with circular border and fallback initials
class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.userInfo});

  final DrawerUserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.primary,
          width: AppUIConstants.avatarBorderWidth,
        ),
        shape: BoxShape.circle,
        boxShadow: AppShadows.avatarBorder,
      ),
      child: CircleAvatar(
        radius: AppUIConstants.avatarSizeDrawerHeader / 2,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        backgroundImage: userInfo.avatarUrl != null
            ? NetworkImage(userInfo.avatarUrl!)
            : null,
        child: userInfo.avatarUrl == null
            ? Text(
                userInfo.getInitials(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: AppUIConstants.avatarInitialsFontSize,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              )
            : null,
      ),
    );
  }
}

/// Role badge displaying user's current role
class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.userInfo});

  final DrawerUserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppUIConstants.borderRadiusSmall),
      ),
      child: Text(
        userInfo.getRoleDisplay(),
        maxLines: AppUIConstants.roleMaxLines,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Verification badge indicating verified user status
class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: 'Verified User',
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          size: AppUIConstants.verificationBadgeSize - 4,
          color: Colors.white,
        ),
      ),
    );
  }
}
