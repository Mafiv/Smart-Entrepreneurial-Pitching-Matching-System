import 'package:flutter/material.dart';
import '../../../../core/design/animations.dart';
import '../../../../core/design/ui_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/drawer_item_model.dart';
import 'drawer_divider.dart';
import 'drawer_header.dart' as dh;
import 'drawer_item.dart';

/// Premium application drawer with role-based navigation
///
/// Provides a comprehensive navigation sidebar with:
/// - User profile header with avatar and verification badges
/// - Role-specific navigation items
/// - Notification badges
/// - Smooth animations and haptic feedback
/// - Proper elevation and shadow system
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.userInfo,
    required this.items,
    required this.selectedItemId,
    required this.onItemTap,
    required this.onEditProfile,
    required this.onLogout,
    this.appVersion = '1.0.0',
  });

  /// User information displayed in drawer header
  final DrawerUserInfo userInfo;

  /// List of navigation items to display
  final List<DrawerItemModel> items;

  /// Currently selected item ID
  final String? selectedItemId;

  /// Callback when drawer item is tapped
  final Function(DrawerItemModel item) onItemTap;

  /// Callback when edit profile is tapped
  final VoidCallback onEditProfile;

  /// Callback when logout button is tapped
  final VoidCallback onLogout;

  /// App version to display in footer
  final String appVersion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedSlide(
      duration: AppAnimations.drawerSlide,
      curve: AppAnimations.standardCurve,
      offset: Offset.zero,
      child: Drawer(
        width: AppUIConstants.drawerWidth,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            // Header
            dh.AppDrawerHeader(
              userInfo: userInfo,
              onEditProfile: onEditProfile,
            ),

            // Navigation items
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildNavigationItems(context),
                ),
              ),
            ),

            // Footer
            _DrawerFooter(
              appVersion: appVersion,
              onLogout: onLogout,
            ),
          ],
        ),
      ),
    );
  }

  /// Build the navigation items list with dividers
  List<Widget> _buildNavigationItems(BuildContext context) {
    final List<Widget> widgets = [];
    var lastWasDivider = false;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isActive = item.id == selectedItemId;

      // Skip dividers in the model (they're handled separately)
      if (item.id.startsWith('divider')) {
        if (!lastWasDivider) {
          widgets.add(DrawerDivider());
          lastWasDivider = true;
        }
        continue;
      }

      lastWasDivider = false;

      // Add divider before if specified
      if (item.dividerBefore && widgets.isNotEmpty) {
        widgets.add(DrawerDivider());
      }

      // Add the item
      widgets.add(
        DrawerItem(
          key: ValueKey(item.id),
          item: item,
          isActive: isActive,
          onTap: () => onItemTap(item),
        ),
      );

      // Add divider after if specified
      if (item.dividerAfter && i < items.length - 1) {
        widgets.add(DrawerDivider());
      }
    }

    // Ensure we end with proper spacing
    if (widgets.isNotEmpty) {
      widgets.add(AppSpacing.gapLg);
    }

    return widgets;
  }
}

/// Drawer footer with app version and logout button
class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter({
    required this.appVersion,
    required this.onLogout,
  });

  final String appVersion;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + bottomInset,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App version
          Text(
            'v$appVersion',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
          AppSpacing.gapMd,

          // Logout button
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onLogout,
                borderRadius: BorderRadius.circular(8),
                splashColor: theme.colorScheme.error.withValues(alpha: 0.1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.logout_outlined,
                        size: 20,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
