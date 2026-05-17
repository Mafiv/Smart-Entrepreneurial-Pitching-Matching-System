import 'package:flutter/material.dart';
import '../../../../core/design/ui_constants.dart';
import '../../../../core/theme/app_spacing.dart';

/// Premium drawer divider with proper spacing
class DrawerDivider extends StatelessWidget {
  const DrawerDivider({
    super.key,
    this.topPadding = AppUIConstants.drawerDividerVerticalPadding,
    this.bottomPadding = AppUIConstants.drawerDividerVerticalPadding,
  });

  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        topPadding,
        AppSpacing.md,
        bottomPadding,
      ),
      child: Divider(
        height: AppUIConstants.drawerDividerHeight,
        color: theme.dividerColor.withValues(alpha: 0.5),
        thickness: AppUIConstants.drawerDividerHeight,
      ),
    );
  }
}
