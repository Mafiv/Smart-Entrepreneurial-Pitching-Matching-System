import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shadow system for elevation and depth hierarchy following Material Design 3.
class AppShadows {
  AppShadows._();

  /// Elevation 1 - Subtle shadow for drawer and moderate elevation
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Color(0x0F000000), // 6% opacity black
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  /// Elevation 2 - More prominent shadow for bottom nav and higher elevation
  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Color(0x1F000000), // 12% opacity black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Elevation 3 - Strong shadow for modals and overlays
  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Color(0x29000000), // 16% opacity black
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Elevation 4 - Very strong shadow for floating action buttons
  static const List<BoxShadow> elevation4 = [
    BoxShadow(
      color: Color(0x33000000), // 20% opacity black
      blurRadius: 24,
      offset: Offset(0, 6),
    ),
  ];

  /// Subtle shadow for depth on light backgrounds
  static const List<BoxShadow> innerSubtle = [
    BoxShadow(
      color: Color(0x0D000000), // 5% opacity black
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Focus ring shadow
  static List<BoxShadow> focusRing({Color color = AppColors.ring}) => [
        BoxShadow(
          color: color.withValues(alpha: 0.5),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  /// Avatar border shadow
  static const List<BoxShadow> avatarBorder = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
}
