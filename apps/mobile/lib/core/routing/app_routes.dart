import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/pages/entrepreneur_dashboard_page.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/portfolio/presentation/pages/portfolio_page.dart';
import '../../features/submissions/presentation/pages/my_submissions_page.dart';
import '../../features/messaging/presentation/pages/message_center_page.dart';
import '../../features/entrepreneur_profile/presentation/pages/entrepreneur_profile_page.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/saved_pitches/presentation/pages/saved_pitches_page.dart';
import '../../features/match_queue/presentation/pages/match_queue_page.dart';

/// Application route configuration
///
/// Centralizes all named routes for the application, including:
/// - Core features (dashboard, profile, messaging)
/// - Extended features (analytics, portfolio, funding)
/// - Admin features
///
/// Usage:
/// ```dart
/// Navigator.pushNamed(context, AppRoutes.dashboard);
/// Navigator.pushNamed(context, AppRoutes.analytics);
/// ```
class AppRoutes {
  AppRoutes._(); // Private constructor to prevent instantiation

  // Core routes (accessible from bottom nav)
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String messaging = '/messaging';

  // Entrepreneur extended routes
  static const String pitches = '/pitches';
  static const String analytics = '/analytics';
  static const String portfolio = '/portfolio';
  static const String funding = '/funding';
  static const String network = '/network';
  static const String resources = '/resources';
  static const String supportTickets = '/support';

  // Investor extended routes
  static const String feed = '/feed';
  static const String opportunities = '/opportunities';
  static const String investments = '/investments';
  static const String saved = '/saved';
  static const String reports = '/reports';
  static const String advisors = '/advisors';
  static const String insights = '/insights';

  // Common routes
  static const String settings = '/settings';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String about = '/about';
  static const String notFound = '/not-found';

  /// Map all drawer routes to this application
  static const Map<String, String> drawerRoutes = {
    // From NavigationConfig
    'dashboard': dashboard,
    'pitches': pitches,
    'messages': messaging,
    'profile': profile,
    'analytics': analytics,
    'portfolio': portfolio,
    'funding': funding,
    'network': network,
    'resources': resources,
    'support': supportTickets,
    'settings': settings,
    'terms': terms,
    'privacy': privacy,
    'feed': feed,
    'opportunities': opportunities,
    'investments': investments,
    'saved': saved,
    'reports': reports,
    'advisors': advisors,
    'insights': insights,
  };

  /// Get route from drawer item id
  ///
  /// Converts drawer item route paths to app routes
  /// Example: 'dashboard' -> '/dashboard'
  static String getRouteForDrawerItem(String itemRoute) {
    // Remove leading slash if present
    final key = itemRoute.startsWith('/') ? itemRoute.substring(1) : itemRoute;
    return drawerRoutes[key] ?? notFound;
  }

  /// Validate if route exists
  static bool isValidRoute(String route) {
    return drawerRoutes.values.contains(route) ||
        route == dashboard ||
        route == profile ||
        route == messaging ||
        route == settings ||
        route == notFound;
  }

  /// Get all entrepreneur routes
  static List<String> getEntrepreneurRoutes() {
    return [
      dashboard,
      pitches,
      messaging,
      profile,
      analytics,
      portfolio,
      funding,
      network,
      resources,
      supportTickets,
      settings,
      terms,
      privacy,
    ];
  }

  /// Get all investor routes
  static List<String> getInvestorRoutes() {
    return [
      feed,
      saved,
      opportunities,
      investments,
      messaging,
      profile,
      portfolio,
      reports,
      advisors,
      insights,
      settings,
      terms,
      privacy,
    ];
  }

  /// Get all admin routes
  static List<String> getAdminRoutes() {
    return [
      dashboard,
      ...getEntrepreneurRoutes(),
      ...getInvestorRoutes(),
    ];
  }
}

/// Route generation callback for MaterialApp
///
/// Usage:
/// ```dart
/// MaterialApp(
///   onGenerateRoute: AppRoutesGenerator.generateRoute,
/// )
/// ```
class AppRoutesGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Core routes
      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (_) => const EntrepreneurDashboardPage(),
          settings: settings,
        );

      case AppRoutes.analytics:
        return MaterialPageRoute(
          builder: (_) => const AnalyticsPage(),
          settings: settings,
        );

      case AppRoutes.portfolio:
        return MaterialPageRoute(
          builder: (_) => const PortfolioPage(),
          settings: settings,
        );

      case AppRoutes.pitches:
        return MaterialPageRoute(
          builder: (_) => const MySubmissionsPage(),
          settings: settings,
        );

      case AppRoutes.messaging:
        return MaterialPageRoute(
          builder: (_) => const MessageCenterPage(),
          settings: settings,
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const EntrepreneurProfilePage(),
          settings: settings,
        );

      // Investor routes
      case AppRoutes.feed:
        return MaterialPageRoute(
          builder: (_) => const FeedPage(),
          settings: settings,
        );

      case AppRoutes.saved:
        return MaterialPageRoute(
          builder: (_) => const SavedPitchesPage(),
          settings: settings,
        );

      case AppRoutes.opportunities:
        return MaterialPageRoute(
          builder: (_) => const MatchQueuePage(),
          settings: settings,
        );

      // Placeholder routes (implement pages as needed)
      case AppRoutes.funding:
      case AppRoutes.network:
      case AppRoutes.resources:
      case AppRoutes.supportTickets:
      case AppRoutes.investments:
      case AppRoutes.reports:
      case AppRoutes.advisors:
      case AppRoutes.insights:
      case AppRoutes.settings:
      case AppRoutes.terms:
      case AppRoutes.privacy:
        return MaterialPageRoute(
          builder: (_) => _PlaceholderPage(title: settings.name ?? 'Page'),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const _NotFoundPage(),
          settings: settings,
        );
    }
  }
}

/// Placeholder page for routes not yet implemented
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Page: $title',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text('Coming Soon...'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 404 Not Found page
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Oops! Page not found'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
