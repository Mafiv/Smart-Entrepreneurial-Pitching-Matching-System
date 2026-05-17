import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Role enumeration for role-specific drawer items
enum UserRole { entrepreneur, investor, admin }

/// Drawer item model for configuring navigation items
class DrawerItemModel extends Equatable {
  const DrawerItemModel({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
    this.roles = const [UserRole.entrepreneur, UserRole.investor],
    this.badge,
    this.requiresAuth = true,
    this.analyticsEvent,
    this.dividerBefore = false,
    this.dividerAfter = false,
  });

  /// Unique identifier for the drawer item
  final String id;

  /// Display label for the item
  final String label;

  /// Unselected icon
  final IconData icon;

  /// Selected icon (highlighted state)
  final IconData selectedIcon;

  /// Navigation route path
  final String route;

  /// Roles that can see this item
  final List<UserRole> roles;

  /// Optional badge count (e.g., notifications)
  final int? badge;

  /// Whether authentication is required to access this item
  final bool requiresAuth;

  /// Analytics event name for tracking
  final String? analyticsEvent;

  /// Show divider before this item
  final bool dividerBefore;

  /// Show divider after this item
  final bool dividerAfter;

  @override
  List<Object?> get props => [
        id,
        label,
        icon,
        selectedIcon,
        route,
        roles,
        badge,
        requiresAuth,
        analyticsEvent,
        dividerBefore,
        dividerAfter,
      ];

  /// Create a copy of this item with modified fields
  DrawerItemModel copyWith({
    String? id,
    String? label,
    IconData? icon,
    IconData? selectedIcon,
    String? route,
    List<UserRole>? roles,
    int? badge,
    bool? requiresAuth,
    String? analyticsEvent,
    bool? dividerBefore,
    bool? dividerAfter,
  }) {
    return DrawerItemModel(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      route: route ?? this.route,
      roles: roles ?? this.roles,
      badge: badge ?? this.badge,
      requiresAuth: requiresAuth ?? this.requiresAuth,
      analyticsEvent: analyticsEvent ?? this.analyticsEvent,
      dividerBefore: dividerBefore ?? this.dividerBefore,
      dividerAfter: dividerAfter ?? this.dividerAfter,
    );
  }
}

/// User profile information for drawer header
class DrawerUserInfo extends Equatable {
  const DrawerUserInfo({
    required this.name,
    required this.role,
    this.avatarUrl,
    this.isVerified = false,
    this.isPremium = false,
  });

  final String name;
  final UserRole role;
  final String? avatarUrl;
  final bool isVerified;
  final bool isPremium;

  @override
  List<Object?> get props => [name, role, avatarUrl, isVerified, isPremium];

  /// Get role display string
  String getRoleDisplay() {
    switch (role) {
      case UserRole.entrepreneur:
        return 'Entrepreneur';
      case UserRole.investor:
        return 'Investor';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  /// Get user initials for avatar fallback
  String getInitials() {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

/// Drawer state model
class DrawerState extends Equatable {
  const DrawerState({
    required this.userInfo,
    required this.isOpen,
    required this.selectedItemId,
    required this.items,
  });

  final DrawerUserInfo userInfo;
  final bool isOpen;
  final String? selectedItemId;
  final List<DrawerItemModel> items;

  @override
  List<Object?> get props => [userInfo, isOpen, selectedItemId, items];

  DrawerState copyWith({
    DrawerUserInfo? userInfo,
    bool? isOpen,
    String? selectedItemId,
    List<DrawerItemModel>? items,
  }) {
    return DrawerState(
      userInfo: userInfo ?? this.userInfo,
      isOpen: isOpen ?? this.isOpen,
      selectedItemId: selectedItemId ?? this.selectedItemId,
      items: items ?? this.items,
    );
  }
}
