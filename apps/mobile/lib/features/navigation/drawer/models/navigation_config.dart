import 'package:flutter/material.dart';
import 'drawer_item_model.dart';

/// Navigation configuration and routes for the application
class NavigationConfig {
  NavigationConfig._();

  // Route paths
  static const String dashboardRoute = '/dashboard';
  static const String mySubmissionsRoute = '/my-submissions';
  static const String messagingRoute = '/messaging';
  static const String profileRoute = '/profile';

  // Extended features routes - Entrepreneur specific
  static const String analyticsRoute = '/analytics';
  static const String portfolioRoute = '/portfolio';
  static const String fundingHistoryRoute = '/funding-history';
  static const String networkRoute = '/network';
  static const String resourcesRoute = '/resources';

  // Extended features routes - Investor specific
  static const String investmentPortfolioRoute = '/investment-portfolio';
  static const String savedOpportunitiesRoute = '/saved-opportunities';
  static const String financialReportsRoute = '/financial-reports';
  static const String advisorNetworkRoute = '/advisor-network';
  static const String marketInsightsRoute = '/market-insights';

  // Common routes
  static const String settingsRoute = '/settings';
  static const String supportRoute = '/support';
  static const String termsRoute = '/terms';
  static const String privacyRoute = '/privacy';

  /// Get drawer items for entrepreneur role
  static List<DrawerItemModel> getEntrepreneurDrawerItems() {
    return [
      // Core features (shown in bottom nav, listed here for reference)
      DrawerItemModel(
        id: 'dashboard',
        label: 'Dashboard',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_filled,
        route: dashboardRoute,
        roles: [UserRole.entrepreneur],
        analyticsEvent: 'drawer_item_tapped_dashboard',
      ),
      DrawerItemModel(
        id: 'submissions',
        label: 'My Pitches',
        icon: Icons.description_outlined,
        selectedIcon: Icons.description,
        route: mySubmissionsRoute,
        roles: [UserRole.entrepreneur],
        analyticsEvent: 'drawer_item_tapped_submissions',
      ),
      DrawerItemModel(
        id: 'messages',
        label: 'Messages',
        icon: Icons.mail_outline,
        selectedIcon: Icons.mail,
        route: messagingRoute,
        roles: [UserRole.entrepreneur],
        analyticsEvent: 'drawer_item_tapped_messages',
        badge: 0, // Can be updated dynamically
      ),
      DrawerItemModel(
        id: 'profile',
        label: 'Profile',
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        route: profileRoute,
        roles: [UserRole.entrepreneur],
        analyticsEvent: 'drawer_item_tapped_profile',
      ),

      // Divider before extended features
      DrawerItemModel(
        id: 'divider_1',
        label: '',
        icon: Icons.abc,
        selectedIcon: Icons.abc,
        route: '',
        roles: [UserRole.entrepreneur],
        dividerBefore: false,
        dividerAfter: false,
      ),

      // Extended features for entrepreneurs
      DrawerItemModel(
        id: 'analytics',
        label: 'Analytics & Performance',
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart,
        route: analyticsRoute,
        roles: [UserRole.entrepreneur],
        analyticsEvent: 'drawer_item_tapped_analytics',
      ),
      DrawerItemModel(
        id: 'portfolio',
        label: 'Portfolio & Case Studies',
        icon: Icons.work_outline,
        selectedIcon: Icons.work,
        route: portfolioRoute,
        roles: [UserRole.entrepreneur],
        analyticsEvent: 'drawer_item_tapped_portfolio',
      ),
      DrawerItemModel(
        id: 'funding',
        label: 'Funding History & Status',
        icon: Icons.trending_up_outlined,
        selectedIcon: Icons.trending_up,
        route: fundingHistoryRoute,
        roles: [UserRole.entrepreneur],
        analyticsEvent: 'drawer_item_tapped_funding',
      ),
      DrawerItemModel(
        id: 'network',
        label: 'Network & Connections',
        icon: Icons.people_outline,
        selectedIcon: Icons.people,
        route: networkRoute,
        roles: [UserRole.entrepreneur],
        analyticsEvent: 'drawer_item_tapped_network',
      ),
      DrawerItemModel(
        id: 'resources',
        label: 'Resources & Learning',
        icon: Icons.school_outlined,
        selectedIcon: Icons.school,
        route: resourcesRoute,
        roles: [UserRole.entrepreneur],
        analyticsEvent: 'drawer_item_tapped_resources',
      ),

      // Divider before settings
      DrawerItemModel(
        id: 'divider_2',
        label: '',
        icon: Icons.abc,
        selectedIcon: Icons.abc,
        route: '',
        roles: [UserRole.entrepreneur],
        dividerBefore: false,
        dividerAfter: false,
      ),

      // Settings & Support
      DrawerItemModel(
        id: 'settings',
        label: 'Settings',
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        route: settingsRoute,
        roles: [UserRole.entrepreneur],
        analyticsEvent: 'drawer_item_tapped_settings',
      ),
      DrawerItemModel(
        id: 'support',
        label: 'Help & Support',
        icon: Icons.help_outline,
        selectedIcon: Icons.help,
        route: supportRoute,
        roles: [UserRole.entrepreneur],
        analyticsEvent: 'drawer_item_tapped_support',
      ),
      DrawerItemModel(
        id: 'terms',
        label: 'Terms & Conditions',
        icon: Icons.description_outlined,
        selectedIcon: Icons.description,
        route: termsRoute,
        roles: [UserRole.entrepreneur],
        analyticsEvent: 'drawer_item_tapped_terms',
      ),
      DrawerItemModel(
        id: 'privacy',
        label: 'Privacy Policy',
        icon: Icons.shield_outlined,
        selectedIcon: Icons.shield,
        route: privacyRoute,
        roles: [UserRole.entrepreneur],
        analyticsEvent: 'drawer_item_tapped_privacy',
      ),
    ];
  }

  /// Get drawer items for investor role
  static List<DrawerItemModel> getInvestorDrawerItems() {
    return [
      // Core features (shown in bottom nav, listed here for reference)
      DrawerItemModel(
        id: 'dashboard',
        label: 'Feed',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        route: dashboardRoute,
        roles: [UserRole.investor],
        analyticsEvent: 'drawer_item_tapped_feed',
      ),
      DrawerItemModel(
        id: 'opportunities',
        label: 'Opportunities',
        icon: Icons.description_outlined,
        selectedIcon: Icons.description,
        route: mySubmissionsRoute,
        roles: [UserRole.investor],
        analyticsEvent: 'drawer_item_tapped_opportunities',
      ),
      DrawerItemModel(
        id: 'investments',
        label: 'My Investments',
        icon: Icons.account_balance_wallet_outlined,
        selectedIcon: Icons.account_balance_wallet,
        route: messagingRoute,
        roles: [UserRole.investor],
        analyticsEvent: 'drawer_item_tapped_investments',
        badge: 0,
      ),
      DrawerItemModel(
        id: 'profile',
        label: 'Profile',
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        route: profileRoute,
        roles: [UserRole.investor],
        analyticsEvent: 'drawer_item_tapped_profile',
      ),

      // Divider before extended features
      DrawerItemModel(
        id: 'divider_1',
        label: '',
        icon: Icons.abc,
        selectedIcon: Icons.abc,
        route: '',
        roles: [UserRole.investor],
        dividerBefore: false,
        dividerAfter: false,
      ),

      // Extended features for investors
      DrawerItemModel(
        id: 'portfolio',
        label: 'Investment Portfolio',
        icon: Icons.trending_up_outlined,
        selectedIcon: Icons.trending_up,
        route: investmentPortfolioRoute,
        roles: [UserRole.investor],
        analyticsEvent: 'drawer_item_tapped_portfolio',
      ),
      DrawerItemModel(
        id: 'saved',
        label: 'Saved Opportunities',
        icon: Icons.bookmark_outline,
        selectedIcon: Icons.bookmark,
        route: savedOpportunitiesRoute,
        roles: [UserRole.investor],
        analyticsEvent: 'drawer_item_tapped_saved',
      ),
      DrawerItemModel(
        id: 'reports',
        label: 'Financial Reports',
        icon: Icons.assessment_outlined,
        selectedIcon: Icons.assessment,
        route: financialReportsRoute,
        roles: [UserRole.investor],
        analyticsEvent: 'drawer_item_tapped_reports',
      ),
      DrawerItemModel(
        id: 'advisors',
        label: 'Advisor Network',
        icon: Icons.groups_outlined,
        selectedIcon: Icons.groups,
        route: advisorNetworkRoute,
        roles: [UserRole.investor],
        analyticsEvent: 'drawer_item_tapped_advisors',
      ),
      DrawerItemModel(
        id: 'insights',
        label: 'Market Insights',
        icon: Icons.trending_up_outlined,
        selectedIcon: Icons.trending_up,
        route: marketInsightsRoute,
        roles: [UserRole.investor],
        analyticsEvent: 'drawer_item_tapped_insights',
      ),

      // Divider before settings
      DrawerItemModel(
        id: 'divider_2',
        label: '',
        icon: Icons.abc,
        selectedIcon: Icons.abc,
        route: '',
        roles: [UserRole.investor],
        dividerBefore: false,
        dividerAfter: false,
      ),

      // Settings & Support
      DrawerItemModel(
        id: 'settings',
        label: 'Settings',
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        route: settingsRoute,
        roles: [UserRole.investor],
        analyticsEvent: 'drawer_item_tapped_settings',
      ),
      DrawerItemModel(
        id: 'support',
        label: 'Help & Support',
        icon: Icons.help_outline,
        selectedIcon: Icons.help,
        route: supportRoute,
        roles: [UserRole.investor],
        analyticsEvent: 'drawer_item_tapped_support',
      ),
      DrawerItemModel(
        id: 'terms',
        label: 'Terms & Conditions',
        icon: Icons.description_outlined,
        selectedIcon: Icons.description,
        route: termsRoute,
        roles: [UserRole.investor],
        analyticsEvent: 'drawer_item_tapped_terms',
      ),
      DrawerItemModel(
        id: 'privacy',
        label: 'Privacy Policy',
        icon: Icons.shield_outlined,
        selectedIcon: Icons.shield,
        route: privacyRoute,
        roles: [UserRole.investor],
        analyticsEvent: 'drawer_item_tapped_privacy',
      ),
    ];
  }

  /// Get all available drawer items for a specific role (filters out dividers for display)
  static List<DrawerItemModel> getDrawerItemsForRole(UserRole role) {
    final items = role == UserRole.entrepreneur
        ? getEntrepreneurDrawerItems()
        : getInvestorDrawerItems();

    // Filter out divider items
    return items
        .where((item) => item.id != '' && !item.id.startsWith('divider'))
        .toList();
  }
}
