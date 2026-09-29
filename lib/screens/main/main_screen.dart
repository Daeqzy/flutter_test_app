import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../bloc/navigation/navigation_bloc.dart';
import '../../bloc/navigation/navigation_event.dart';
import '../../bloc/navigation/navigation_state.dart';

import '../../bloc/services/services_bloc.dart';
import '../../bloc/services/services_event.dart';

import '../../bloc/notifications/notifications_bloc.dart';
import '../../bloc/notifications/notifications_event.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';

import '../../bloc/partners/partners_bloc.dart';
import '../../bloc/partners/partners_event.dart';

import '../../repositories/data_repository.dart';

import '../login/login_screen.dart';
import '../home/home_screen.dart';
import '../services/services_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../home/partners_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),

      BlocProvider(
        create: (_) => ServicesBloc()..add(const ServicesRequested()),
        child: const ServicesScreen(),
      ),

      BlocProvider(
        create: (_) => NotificationsBloc()..add(const NotificationsRequested()),
        child: const NotificationsScreen(),
      ),

      const ProfileScreen(),
    ];

    return BlocListener<UserBloc, UserState>(
      listenWhen: (previous, current) {
        return previous.logoutSuccess != current.logoutSuccess;
      },

      listener: (context, state) {
        if (state.logoutSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
          );
        }
      },

      child: BlocProvider(
        create: (_) => NavigationBloc(),

        child: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, state) {
            return Scaffold(
              // ============================================
              // APP BAR
              // ============================================

              appBar: AppBar(
                title: const Text('CODEX Computers'),

                actions: [
                  Builder(
                    builder: (context) {
                      return IconButton(
                        tooltip: 'Menu',

                        icon: const Icon(Icons.menu_rounded),

                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                      );
                    },
                  ),

                  const SizedBox(width: 6),
                ],
              ),

              // ============================================
              // RIGHT-SIDE DRAWER
              // ============================================
              endDrawer: _AppDrawer(selectedIndex: state.selectedIndex),

              // ============================================
              // PAGE
              // ============================================
              body: pages[state.selectedIndex],

              // ============================================
              // BOTTOM NAVIGATION
              // ============================================
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: Colors.white,

                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                  ],
                ),

                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),

                    child: GNav(
                      selectedIndex: state.selectedIndex,

                      gap: 8,

                      iconSize: 24,

                      color: const Color(0xFF64748B),

                      activeColor: const Color(0xFF2563EB),

                      tabBackgroundColor: const Color(0xFF2563EB)
                          .withValues(alpha: 0.10),

                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),

                      duration: const Duration(milliseconds: 350),

                      tabs: const [
                        GButton(icon: Icons.home_outlined, text: 'Home'),

                        GButton(
                          icon: Icons.grid_view_rounded,
                          text: 'Services',
                        ),

                        GButton(
                          icon: Icons.notifications_outlined,
                          text: 'Notifications',
                        ),

                        GButton(icon: Icons.person_outline, text: 'Profile'),
                      ],

                      onTabChange: (index) {
                        context.read<NavigationBloc>().add(
                          NavigationTabChanged(index),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// RIGHT SIDE DRAWER
// ============================================================

class _AppDrawer extends StatelessWidget {
  final int selectedIndex;

  const _AppDrawer({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ==============================================
            // HEADER
            // ==============================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(24),

              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,

                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),

                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: const Icon(
                      Icons.business_center_outlined,

                      color: Color(0xFF2563EB),
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'CODEX',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 2),

                        Text(
                          'Navigation',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ==============================================
            // NAVIGATION
            // ==============================================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),

                children: [
                  // ----------------------------------------
                  // DASHBOARD
                  // ----------------------------------------

                  _DrawerItem(
                    icon: Icons.dashboard_outlined,

                    title: 'Dashboard',

                    selected: selectedIndex == 0,

                    onTap: () {
                      _openBottomTab(context, 0);
                    },
                  ),

                  // ----------------------------------------
                  // PARTNERS
                  // ----------------------------------------
                  _DrawerItem(
                    icon: Icons.business_outlined,

                    title: 'Partners',

                    onTap: () {
                      _openPartners(context);
                    },
                  ),

                  // ----------------------------------------
                  // SERVICES
                  // ----------------------------------------
                  _DrawerItem(
                    icon: Icons.grid_view_rounded,

                    title: 'Services',

                    selected: selectedIndex == 1,

                    onTap: () {
                      _openBottomTab(context, 1);
                    },
                  ),

                  // ----------------------------------------
                  // NOTIFICATIONS
                  // ----------------------------------------
                  _DrawerItem(
                    icon: Icons.notifications_outlined,

                    title: 'Notifications',

                    selected: selectedIndex == 2,

                    onTap: () {
                      _openBottomTab(context, 2);
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 14, 16, 8),

                    child: Divider(),
                  ),

                  // ========================================
                  // SETTINGS TREE
                  // ========================================
                  ExpansionTile(
                    leading: const Icon(Icons.settings_outlined),

                    title: const Text(
                      'Settings',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),

                    childrenPadding: const EdgeInsets.only(left: 18),

                    children: [
                      // ------------------------------------
                      // PROFILE
                      // ------------------------------------

                      ListTile(
                        leading: const Icon(Icons.person_outline),

                        title: const Text('Profile'),

                        selected: selectedIndex == 3,

                        onTap: () {
                          _openBottomTab(context, 3);
                        },
                      ),

                      // ------------------------------------
                      // PREFERENCES
                      // ------------------------------------
                      ListTile(
                        leading: const Icon(Icons.tune_rounded),

                        title: const Text('Preferences'),

                        onTap: () {
                          Navigator.pop(context);

                          _showComingSoon(context, 'Preferences');
                        },
                      ),

                      // ------------------------------------
                      // SECURITY
                      // ------------------------------------
                      ListTile(
                        leading: const Icon(Icons.security_outlined),

                        title: const Text('Security'),

                        onTap: () {
                          Navigator.pop(context);

                          _showComingSoon(context, 'Security');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ==============================================
            // LOGOUT
            // ==============================================
            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(12),

              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                leading: const Icon(Icons.logout_rounded, color: Colors.red),

                title: const Text(
                  'Logout',

                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                onTap: () {
                  Navigator.pop(context);

                  context.read<UserBloc>().add(const UserLogoutRequested());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // OPEN BOTTOM NAV TAB
  // ----------------------------------------------------------

  void _openBottomTab(BuildContext context, int index) {
    // Close drawer first.
    Navigator.pop(context);

    context.read<NavigationBloc>().add(NavigationTabChanged(index));
  }

  // ----------------------------------------------------------
  // OPEN PARTNERS
  // ----------------------------------------------------------

  void _openPartners(BuildContext context) {
    final repository = context.read<DataRepository>();

    final navigator = Navigator.of(context);

    // Close drawer.
    navigator.pop();

    navigator.push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              PartnersBloc(repository)..add(const PartnersRequested()),

          child: const PartnersScreen(),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // COMING SOON
  // ----------------------------------------------------------

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$feature screen coming soon.')));
  }
}

// ============================================================
// DRAWER ITEM
// ============================================================

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool selected;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),

      child: ListTile(
        selected: selected,

        selectedColor: const Color(0xFF2563EB),

        selectedTileColor: const Color(0xFF2563EB).withValues(alpha: 0.08),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        leading: Icon(icon),

        title: Text(
          title,

          style: TextStyle(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),

        onTap: onTap,
      ),
    );
  }
}
