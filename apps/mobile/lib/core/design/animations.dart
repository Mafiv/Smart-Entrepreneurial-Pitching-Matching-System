/// Animation constants for consistent, performant animations throughout the app
import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  // Duration constants
  static const Duration fast = Duration(milliseconds: 100);
  static const Duration normal = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 250);
  static const Duration slower = Duration(milliseconds: 300);
  static const Duration slowest = Duration(milliseconds: 400);

  // Specific animation durations
  static const Duration drawerSlide = Duration(milliseconds: 250);
  static const Duration drawerOverlay = Duration(milliseconds: 200);
  static const Duration itemSelect = Duration(milliseconds: 150);
  static const Duration iconTransition = Duration(milliseconds: 150);
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration backPageTransition = Duration(milliseconds: 200);
  static const Duration scalePress = Duration(milliseconds: 100);
  static const Duration colorChange = Duration(milliseconds: 150);
  static const Duration labelFade = Duration(milliseconds: 100);
  static const Duration badgeAppear = Duration(milliseconds: 200);

  // Curve constants
  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve enterCurve = Curves.easeOut;
  static const Curve exitCurve = Curves.easeIn;
  static const Curve emphasizedCurve = Curves.easeInOutCubic;
}
