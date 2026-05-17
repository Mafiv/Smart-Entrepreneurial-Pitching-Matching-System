import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/di/injection_container.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/pages/entrepreneur_dashboard_page.dart';
import '../../../submissions/presentation/bloc/submissions_bloc.dart';
import '../../../submissions/presentation/pages/my_submissions_page.dart';
import '../../../messaging/presentation/bloc/messaging_bloc.dart';
import '../../../messaging/presentation/pages/message_center_page.dart';
import '../../../entrepreneur_profile/presentation/bloc/entrepreneur_profile_bloc.dart';
import '../../../entrepreneur_profile/presentation/pages/entrepreneur_profile_page.dart';
import '../../../navigation/drawer/drawer.dart';
import '../../../navigation/drawer/bloc/drawer_bloc.dart' as drawer_bloc;

class EntrepreneurShell extends StatefulWidget {
  const EntrepreneurShell({super.key});

  @override
  State<EntrepreneurShell> createState() => _EntrepreneurShellState();
}

class _EntrepreneurShellState extends State<EntrepreneurShell> {
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
          name: 'Entrepreneur User',
          role: UserRole.entrepreneur,
          isVerified: false,
          isPremium: false,
        ),
        userRole: UserRole.entrepreneur,
      ),
    );

    _pages = <Widget>[
      const EntrepreneurDashboardPage(),
      const MySubmissionsPage(),
      const MessageCenterPage(),
      const EntrepreneurProfilePage(),
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
              BlocProvider<DashboardBloc>(
                create: (_) => sl<DashboardBloc>(),
              ),
              BlocProvider<SubmissionsBloc>(
                create: (_) => sl<SubmissionsBloc>(),
              ),
              BlocProvider<MessagingBloc>(
                create: (_) => sl<MessagingBloc>(),
              ),
              BlocProvider<EntrepreneurProfileBloc>(
                create: (_) => sl<EntrepreneurProfileBloc>(),
              ),
            ],
            child: Scaffold(
              appBar: null,
              drawer: AppDrawer(
                userInfo: drawerState is drawer_bloc.DrawerLoaded
                    ? drawerState.userInfo
                    : const DrawerUserInfo(
                        name: 'Entrepreneur User',
                        role: UserRole.entrepreneur,
                        isVerified: false,
                        isPremium: false,
                      ),
                items: drawerState is drawer_bloc.DrawerLoaded
                    ? drawerState.items
                    : NavigationConfig.getEntrepreneurDrawerItems(),
                selectedItemId: drawerState is drawer_bloc.DrawerLoaded
                    ? drawerState.selectedItemId
                    : null,
                onItemTap: (item) {
                  _drawerBloc.add(drawer_bloc.DrawerItemSelected(item.id));
                  _handleDrawerNavigation(item, context);
                  Navigator.pop(context); // Close drawer
                },
                onEditProfile: () {
                  Navigator.pop(context);
                  setState(() => _index = 3); // Profile page index
                },
                onLogout: () {
                  Navigator.pop(context);
                  // TODO: Implement logout logic
                },
              ),
              extendBody: true,
              body: IndexedStack(index: _index, children: _pages),
              bottomNavigationBar: AppBottomNav(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                destinations: const <AppBottomNavDestination>[
                  AppBottomNavDestination(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                    label: 'Home',
                  ),
                  AppBottomNavDestination(
                    icon: Icons.description_outlined,
                    selectedIcon: Icons.description,
                    label: 'Pitches',
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
