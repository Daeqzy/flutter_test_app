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

import '../../theme/app_theme.dart';

import '../login/login_screen.dart';
import '../home/home_screen.dart';
import '../services/services_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../home/partners_screen.dart';
import '../preferences/preferences_screen.dart';

import '../security/security_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const List<String> _pageTitles = [
    'Dashboard',
    'Services',
    'Notifications',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      // ========================================================
      // AUTHENTICATION / SESSION LISTENER
      // ========================================================

      listenWhen: (previous, current) {
        if (previous.authStatus == current.authStatus) {
          return false;
        }

        return current.authStatus == AuthStatus.unauthenticated ||
            current.authStatus == AuthStatus.sessionExpired;
      },

      listener: (context, state) {
        if (state.authStatus == AuthStatus.unauthenticated ||
            state.authStatus == AuthStatus.sessionExpired) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
          );
        }
      },

      // ========================================================
      // MAIN SCREEN BLOCS
      // ========================================================
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => NavigationBloc()),

          BlocProvider(
            create: (_) => ServicesBloc()..add(const ServicesRequested()),
          ),

          BlocProvider(
            create: (_) =>
                NotificationsBloc()..add(const NotificationsRequested()),
          ),
        ],

        child: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, state) {
            final pageTitle = _pageTitles[state.selectedIndex];

            final colors = Theme.of(context).colorScheme;

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,

              // ==================================================
              // APP BAR
              // ==================================================
              appBar: AppBar(
                toolbarHeight: 76,
                titleSpacing: 20,

                title: Row(
                  children: [
                    // ------------------------------------------------
                    // CODEX ICON
                    // ------------------------------------------------

                    Container(
                      width: 42,
                      height: 42,

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),

                        borderRadius: BorderRadius.circular(13),

                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),

                      child: const Icon(
                        Icons.business_center_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 13),

                    // ------------------------------------------------
                    // APP TITLE
                    // ------------------------------------------------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Text(
                            'CODEX',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface,
                              letterSpacing: -0.4,
                            ),
                          ),

                          const SizedBox(height: 1),

                          Text(
                            pageTitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                actions: [
                  // ==============================================
                  // MENU BUTTON
                  // ==============================================

                  Builder(
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 14),

                        child: Material(
                          color: colors.surface,

                          borderRadius: BorderRadius.circular(14),

                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),

                            onTap: () {
                              Scaffold.of(context).openEndDrawer();
                            },

                            child: Container(
                              width: 44,
                              height: 44,

                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: colors.outlineVariant,
                                ),

                                borderRadius: BorderRadius.circular(14),
                              ),

                              child: Icon(
                                Icons.menu_rounded,
                                color: colors.onSurface,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // ==================================================
              // RIGHT DRAWER
              // ==================================================
              endDrawer: _AppDrawer(selectedIndex: state.selectedIndex),

              // ==================================================
              // PAGES
              // ==================================================
              body: IndexedStack(
                index: state.selectedIndex,

                children: const [
                  HomeScreen(),
                  ServicesScreen(),
                  NotificationsScreen(),
                  ProfileScreen(),
                ],
              ),

              // ==================================================
              // MODERN BOTTOM NAVIGATION
              // ==================================================
              bottomNavigationBar: SafeArea(
                top: false,

                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: colors.surface,

                      borderRadius: BorderRadius.circular(24),

                      border: Border.all(color: colors.outlineVariant),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha:
                                Theme.of(context).brightness == Brightness.dark
                                ? 0.20
                                : 0.07,
                          ),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: GNav(
                      selectedIndex: state.selectedIndex,

                      gap: 7,

                      iconSize: 22,

                      color: colors.onSurfaceVariant,

                      activeColor: colors.primary,

                      tabBackgroundColor: colors.primary.withValues(
                        alpha: 0.10,
                      ),

                      tabBorderRadius: 17,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),

                      duration: const Duration(milliseconds: 300),

                      curve: Curves.easeOutCubic,

                      textStyle: TextStyle(
                        color: colors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),

                      tabs: const [
                        GButton(icon: Icons.home_outlined, text: 'Home'),

                        GButton(
                          icon: Icons.grid_view_rounded,
                          text: 'Services',
                        ),

                        GButton(
                          icon: Icons.notifications_none_rounded,
                          text: 'Alerts',
                        ),

                        GButton(
                          icon: Icons.person_outline_rounded,
                          text: 'Profile',
                        ),
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
// RIGHT DRAWER
// ============================================================

class _AppDrawer extends StatelessWidget {
  final int selectedIndex;

  const _AppDrawer({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colors.surface,

      child: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // DRAWER HEADER
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),

              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),

                  borderRadius: BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: BlocBuilder<UserBloc, UserState>(
                  buildWhen: (previous, current) {
                    return previous.authenticatedUsername !=
                        current.authenticatedUsername;
                  },

                  builder: (context, state) {
                    final username =
                        state.authenticatedUsername.trim().isNotEmpty
                        ? state.authenticatedUsername
                        : 'CODEX User';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,

                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(15),
                              ),

                              child: const Icon(
                                Icons.business_center_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),

                            const Spacer(),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: const Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 7,
                                    color: Color(0xFF86EFAC),
                                  ),

                                  SizedBox(width: 6),

                                  Text(
                                    'Online',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'CODEX Workspace',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // ==================================================
            // NAVIGATION
            // ==================================================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),

                children: [
                  const _DrawerSectionLabel(label: 'WORKSPACE'),

                  const SizedBox(height: 6),

                  // --------------------------------------------
                  // DASHBOARD
                  // --------------------------------------------
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    selected: selectedIndex == 0,

                    onTap: () {
                      _openBottomTab(context, 0);
                    },
                  ),

                  // --------------------------------------------
                  // PARTNERS
                  // --------------------------------------------
                  _DrawerItem(
                    icon: Icons.business_outlined,
                    selectedIcon: Icons.business_rounded,
                    title: 'Partners',

                    onTap: () {
                      _openPartners(context);
                    },
                  ),

                  // --------------------------------------------
                  // SERVICES
                  // --------------------------------------------
                  _DrawerItem(
                    icon: Icons.grid_view_outlined,
                    selectedIcon: Icons.grid_view_rounded,
                    title: 'Services',
                    selected: selectedIndex == 1,

                    onTap: () {
                      _openBottomTab(context, 1);
                    },
                  ),

                  // --------------------------------------------
                  // NOTIFICATIONS
                  // --------------------------------------------
                  _DrawerItem(
                    icon: Icons.notifications_none_rounded,
                    selectedIcon: Icons.notifications_rounded,
                    title: 'Notifications',
                    selected: selectedIndex == 2,

                    onTap: () {
                      _openBottomTab(context, 2);
                    },
                  ),

                  const SizedBox(height: 20),

                  const _DrawerSectionLabel(label: 'ACCOUNT'),

                  const SizedBox(height: 6),

                  // --------------------------------------------
                  // PROFILE
                  // --------------------------------------------
                  _DrawerItem(
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    title: 'Profile',
                    selected: selectedIndex == 3,

                    onTap: () {
                      _openBottomTab(context, 3);
                    },
                  ),

                  // --------------------------------------------
                  // SETTINGS
                  // --------------------------------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),

                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),

                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 13),

                        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 6, 6),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),

                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),

                        leading: Container(
                          width: 38,
                          height: 38,

                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Icon(
                            Icons.settings_outlined,
                            size: 20,
                            color: colors.onSurfaceVariant,
                          ),
                        ),

                        title: Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),

                        iconColor: colors.onSurfaceVariant,

                        collapsedIconColor: colors.onSurfaceVariant,

                        children: [
                          // ====================================
                          // PREFERENCES
                          // ====================================

                          _DrawerSubItem(
                            icon: Icons.tune_rounded,
                            title: 'Preferences',

                            onTap: () {
                              final navigator = Navigator.of(context);

                              // Close drawer.
                              navigator.pop();

                              // Open Preferences.
                              navigator.push(
                                MaterialPageRoute(
                                  builder: (_) => const PreferencesScreen(),
                                ),
                              );
                            },
                          ),

                          // ====================================
                          // SECURITY
                          // ====================================
                          _DrawerSubItem(
                            icon: Icons.shield_outlined,
                            title: 'Security',
                            onTap: () {
                              final navigator = Navigator.of(context);

                              // Close drawer.
                              navigator.pop();

                              // Open Security.
                              navigator.push(
                                MaterialPageRoute(
                                  builder: (_) => const SecurityScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // LOGOUT
            // ==================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),

              child: Material(
                color: colors.error.withValues(alpha: 0.08),

                borderRadius: BorderRadius.circular(16),

                child: InkWell(
                  borderRadius: BorderRadius.circular(16),

                  onTap: () {
                    final userBloc = context.read<UserBloc>();

                    Navigator.pop(context);

                    userBloc.add(const UserLogoutRequested());
                  },

                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),

                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: colors.error,
                          size: 20,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            'Sign out',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.error,
                            ),
                          ),
                        ),

                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: colors.error,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // OPEN BOTTOM TAB
  // ==========================================================

  void _openBottomTab(BuildContext context, int index) {
    final navigationBloc = context.read<NavigationBloc>();

    Navigator.pop(context);

    navigationBloc.add(NavigationTabChanged(index));
  }

  // ==========================================================
  // OPEN PARTNERS
  // ==========================================================

  void _openPartners(BuildContext context) {
    final repository = context.read<DataRepository>();

    final navigator = Navigator.of(context);

    // Close drawer.
    navigator.pop();

    // Partners stays lazy-loaded.
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
}

// ============================================================
// DRAWER SECTION LABEL
// ============================================================

class _DrawerSectionLabel extends StatelessWidget {
  final String label;

  const _DrawerSectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: Text(
        label,

        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.15,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ============================================================
// DRAWER ITEM
// ============================================================

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;

  final String title;

  final VoidCallback onTap;

  final bool selected;

  const _DrawerItem({
    required this.icon,
    required this.selectedIcon,
    required this.title,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),

      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.10)
            : Colors.transparent,

        borderRadius: BorderRadius.circular(16),

        child: InkWell(
          borderRadius: BorderRadius.circular(16),

          onTap: onTap,

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),

            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,

                  decoration: BoxDecoration(
                    color: selected
                        ? colors.primary.withValues(alpha: 0.12)
                        : colors.surfaceContainerHighest,

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Icon(
                    selected ? selectedIcon : icon,

                    size: 20,

                    color: selected ? colors.primary : colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,

                    style: TextStyle(
                      fontSize: 14,

                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,

                      color: selected ? colors.primary : colors.onSurface,
                    ),
                  ),
                ),

                if (selected)
                  Container(
                    width: 6,
                    height: 6,

                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DRAWER SUB ITEM
// ============================================================

class _DrawerSubItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerSubItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

      leading: Icon(icon, size: 19, color: colors.onSurfaceVariant),

      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
        ),
      ),

      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 11,
        color: colors.onSurfaceVariant,
      ),

      onTap: onTap,
    );
  }
}
