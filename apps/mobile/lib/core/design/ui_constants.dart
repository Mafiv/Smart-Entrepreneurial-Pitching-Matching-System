/// UI constants for consistent sizing and layout across the app
class AppUIConstants {
  AppUIConstants._();

  // Drawer sizing
  static const double drawerWidth = 280.0;
  static const double drawerHeaderPaddingTop = 24.0;
  static const double drawerHeaderPaddingBottom = 24.0;
  static const double drawerItemHeight = 48.0;
  static const double drawerItemHorizontalPadding = 16.0;
  static const double drawerItemVerticalPadding = 12.0;
  static const double drawerDividerHeight = 1.0;
  static const double drawerDividerVerticalPadding = 16.0;
  static const double drawerActiveIndicatorWidth = 4.0;

  // Avatar sizing
  static const double avatarSizeDrawerHeader = 56.0;
  static const double avatarBorderWidth = 3.0;
  static const double avatarInitialsFontSize = 22.0;

  // Icons
  static const double drawerItemIconSize = 24.0;
  static const double bottomNavIconSize = 24.0;
  static const double roleIconSize = 12.0;
  static const double verificationBadgeSize = 16.0;

  // Bottom navigation
  static const double bottomNavHeight = 65.0; // Including padding
  static const double bottomNavItemMinHeight = 48.0; // Touch target
  static const double bottomNavBorderRadius = 26.0;

  // Touch target minimums (accessibility)
  static const double touchTargetMinSize = 48.0;

  // Border radius
  static const double borderRadiusDrawerItem = 8.0;
  static const double borderRadiusBottomNav = 26.0;
  static const double borderRadiusAvatar = 28.0; // Half of avatar size
  static const double borderRadiusSmall = 4.0;

  // Badge
  static const double badgeSize = 24.0;
  static const double badgeFontSize = 10.0;

  // Text truncation
  static const int userNameMaxLines = 1;
  static const int drawerItemLabelMaxLines = 1;
  static const int roleMaxLines = 1;
}
