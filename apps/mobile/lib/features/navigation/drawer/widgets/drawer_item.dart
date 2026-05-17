import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design/animations.dart';
import '../../../../core/design/ui_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/drawer_item_model.dart';

/// Premium drawer item with active state indicator and smooth animations
class DrawerItem extends StatefulWidget {
  const DrawerItem({
    super.key,
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final DrawerItemModel item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<DrawerItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AppAnimations.scalePress,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.98).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
      ),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppUIConstants.drawerItemHorizontalPadding,
            vertical: AppUIConstants.drawerItemVerticalPadding / 2,
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppUIConstants.borderRadiusDrawerItem),
            child: Material(
              color: Colors.transparent,
              child: Container(
                // Active state background
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? primary.withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                      AppUIConstants.borderRadiusDrawerItem),
                ),
                child: Stack(
                  children: [
                    // Main content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Active indicator (left border)
                          if (widget.isActive)
                            Container(
                              width: AppUIConstants.drawerActiveIndicatorWidth,
                              height: 24,
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            )
                          else
                            const SizedBox(width: 4),
                          const SizedBox(width: 12),

                          // Icon
                          AnimatedSwitcher(
                            duration: AppAnimations.iconTransition,
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: Icon(
                              widget.isActive
                                  ? widget.item.selectedIcon
                                  : widget.item.icon,
                              key: ValueKey(widget.isActive),
                              size: AppUIConstants.drawerItemIconSize,
                              color: widget.isActive
                                  ? primary
                                  : theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Label
                          Expanded(
                            child: AnimatedDefaultTextStyle(
                              duration: AppAnimations.colorChange,
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: widget.isActive
                                    ? primary
                                    : theme.textTheme.bodyMedium?.color,
                                fontWeight: widget.isActive
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                              child: Text(
                                widget.item.label,
                                maxLines:
                                    AppUIConstants.drawerItemLabelMaxLines,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          // Badge
                          if (widget.item.badge != null &&
                              widget.item.badge! > 0) ...[
                            const SizedBox(width: 8),
                            _NotificationBadge(count: widget.item.badge!),
                          ],
                        ],
                      ),
                    ),

                    // Ripple effect on tap
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {}, // Handled by GestureDetector
                        splashColor: primary.withValues(alpha: 0.1),
                        highlightColor: primary.withValues(alpha: 0.05),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Notification badge for drawer items
class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(
          parent: AlwaysStoppedAnimation(1.0),
          curve: Curves.easeOut,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(minWidth: 24),
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            count > 99 ? '99+' : count.toString(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
