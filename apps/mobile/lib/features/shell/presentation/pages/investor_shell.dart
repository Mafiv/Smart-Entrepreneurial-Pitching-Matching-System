import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../feed/presentation/bloc/feed_bloc.dart';
import '../../../feed/presentation/pages/feed_page.dart';
import '../../../saved_pitches/presentation/bloc/saved_pitches_bloc.dart';
import '../../../saved_pitches/presentation/pages/saved_pitches_page.dart';
import '../../../match_queue/presentation/bloc/match_queue_bloc.dart';
import '../../../match_queue/presentation/pages/match_queue_page.dart';
import '../../../messaging/presentation/bloc/messaging_bloc.dart';
import '../../../messaging/presentation/pages/message_center_page.dart';
import '../../../portfolio/presentation/bloc/portfolio_bloc.dart';
import '../../../portfolio/presentation/pages/portfolio_page.dart';
import '../../../investor_profile/presentation/bloc/investor_profile_bloc.dart';
import '../../../investor_profile/presentation/pages/investor_profile_page.dart';
import '../../../navigation/drawer/drawer.dart';
import '../../../navigation/drawer/bloc/drawer_bloc.dart' as drawer_bloc;

class InvestorShell extends StatefulWidget {
  const InvestorShell({super.key});

  @override
  State<InvestorShell> createState() => _InvestorShellState();
}

class _InvestorShellState extends State<InvestorShell> {
  int _index = 0;
  late final List<Widget> _pages;
  late drawer_bloc.DrawerBloc _drawerBloc;

  @override
  void initState() {
    super.initState();

    // Initialize drawer BLoC with placeholder user info
    // TODO: Get actual user info from AuthBloc when available
    _drawerBloc = drawer_bloc.DrawerBloc();
    _drawerBloc.add(
      const drawer_bloc.DrawerInitRequested(
        userInfo: DrawerUserInfo(
          name: 'Investor User',
          role: UserRole.investor,
          isVerified: false,
          isPremium: false,
        ),
        userRole: UserRole.investor,
      ),
    );

    _pages = <Widget>[
      const FeedPage(),
      const SavedPitchesPage(),
      const MatchQueuePage(),
      const PortfolioPage(),
      const MessageCenterPage(),
      const InvestorProfilePage(),
    ];
  }

  @override
  void dispose() {
    _drawerBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<drawer_bloc.DrawerBloc>.value(
      value: _drawerBloc,
      child: BlocBuilder<drawer_bloc.DrawerBloc, drawer_bloc.DrawerState>(
        builder: (context, drawerState) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<FeedBloc>(
                create: (_) => sl<FeedBloc>(),
              ),
              BlocProvider<SavedPitchesBloc>(
                create: (_) => sl<SavedPitchesBloc>(),
              ),
              BlocProvider<MatchQueueBloc>(
                create: (_) => sl<MatchQueueBloc>(),
              ),
              BlocProvider<PortfolioBloc>(
                create: (_) => sl<PortfolioBloc>(),
              ),
              BlocProvider<MessagingBloc>(
                create: (_) => sl<MessagingBloc>(),
              ),
              BlocProvider<InvestorProfileBloc>(
                create: (_) => sl<InvestorProfileBloc>(),
              ),
            ],
            child: Scaffold(
              drawer: drawerState is drawer_bloc.DrawerLoaded
                  ? AppDrawer(
                      userInfo: drawerState.userInfo,
                      items: drawerState.items,
                      selectedItemId: drawerState.selectedItemId,
                      onItemTap: (item) {
                        _drawerBloc
                            .add(drawer_bloc.DrawerItemSelected(item.id));
                        _handleDrawerNavigation(item, context);
                        Navigator.pop(context); // Close drawer
                      },
                      onEditProfile: () {
                        Navigator.pop(context);
                        setState(() =>
                            _index = 5); // Profile page index for investor
                      },
                      onLogout: () {
                        Navigator.pop(context);
                        // TODO: Implement logout logic
                      },
                    )
                  : null,
              extendBody: true,
              body: IndexedStack(index: _index, children: _pages),
              bottomNavigationBar: AppBottomNav(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                destinations: const <AppBottomNavDestination>[
                  AppBottomNavDestination(
                    icon: Icons.view_list_outlined,
                    selectedIcon: Icons.view_list,
                    label: 'Feed',
                  ),
                  AppBottomNavDestination(
                    icon: Icons.bookmark_outline,
                    selectedIcon: Icons.bookmark,
                    label: 'Saved',
                  ),
                  AppBottomNavDestination(
                    icon: Icons.handshake_outlined,
                    selectedIcon: Icons.handshake,
                    label: 'Matches',
                  ),
                  AppBottomNavDestination(
                    icon: Icons.trending_up_outlined,
                    selectedIcon: Icons.trending_up,
                    label: 'Portfolio',
                  ),
                  AppBottomNavDestination(
                    icon: Icons.chat_bubble_outline,
                    selectedIcon: Icons.chat_bubble,
                    label: 'Messages',
                  ),
                  AppBottomNavDestination(
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person,
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleDrawerNavigation(DrawerItemModel item, BuildContext context) {
    // TODO: Implement navigation based on item route
    // Use Navigator.pushNamed(context, item.route) when route is configured
    debugPrint('Navigating to: ${item.route}');
  }
}
