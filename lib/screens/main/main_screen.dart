import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            MaterialPageRoute(builder: (_) => const LoginScreen()),

            (route) => false,
          );
        }
      },

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

            return PopScope(
              canPop: false,

              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) {
                  return;
                }

                if (state.selectedIndex != 0) {
                  context.read<NavigationBloc>().add(
                    const NavigationTabChanged(0),
                  );

                  return;
                }

                final shouldExit = await showDialog<bool>(
                  context: context,

                  builder: (dialogContext) {
                    final dialogColors = Theme.of(dialogContext).colorScheme;

                    return AlertDialog(
                      icon: Icon(
                        Icons.exit_to_app_rounded,

                        color: dialogColors.primary,
                      ),

                      title: const Text('Exit CODEX?'),

                      content: const Text(
                        'Are you sure you want to close the application?',
                      ),

                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(false);
                          },

                          child: const Text('Cancel'),
                        ),

                        FilledButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(true);
                          },

                          child: const Text('Exit'),
                        ),
                      ],
                    );
                  },
                );

                if (shouldExit == true) {
                  SystemNavigator.pop();
                }
              },

              child: Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,

                // ==================================================
                // APP BAR
                // ==================================================
                appBar: AppBar(
                  toolbarHeight: 68,

                  titleSpacing: 18,

                  title: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),

                        child: Image.asset(
                          'assets/images/app_icon.png',

                          width: 36,
                          height: 36,

                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(width: 11),

                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              'CODEX',

                              style: TextStyle(
                                fontSize: 17,

                                fontWeight: FontWeight.w800,

                                letterSpacing: -0.35,

                                color: colors.onSurface,
                              ),
                            ),

                            Text(
                              pageTitle,

                              style: TextStyle(
                                fontSize: 11,

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
                    Builder(
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 14),

                          child: Material(
                            color: colors.surfaceContainerHighest.withValues(
                              alpha: 0.55,
                            ),

                            borderRadius: BorderRadius.circular(12),

                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),

                              onTap: () {
                                Scaffold.of(context).openEndDrawer();
                              },

                              child: SizedBox(
                                width: 40,

                                height: 40,

                                child: Icon(
                                  Icons.menu_rounded,

                                  size: 21,

                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

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
                // BOTTOM NAV
                // ==================================================
                bottomNavigationBar: SafeArea(
                  top: false,

                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 5, 14, 10),

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,

                        vertical: 7,
                      ),

                      decoration: BoxDecoration(
                        color: colors.surface,

                        borderRadius: BorderRadius.circular(20),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? 0.14
                                  : 0.045,
                            ),

                            blurRadius: 18,

                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),

                      child: GNav(
                        selectedIndex: state.selectedIndex,

                        gap: 6,

                        iconSize: 21,

                        color: colors.onSurfaceVariant,

                        activeColor: colors.primary,

                        tabBackgroundColor: colors.primary.withValues(
                          alpha: 0.08,
                        ),

                        tabBorderRadius: 14,

                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,

                          vertical: 10,
                        ),

                        duration: const Duration(milliseconds: 220),

                        curve: Curves.easeOutCubic,

                        textStyle: TextStyle(
                          color: colors.primary,

                          fontSize: 12,

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
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// DRAWER
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
            // HEADER
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),

              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.all(17),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,

                    end: Alignment.bottomRight,

                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),

                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.10),

                      blurRadius: 16,

                      offset: const Offset(0, 6),
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),

                              child: Image.asset(
                                'assets/images/app_icon.png',

                                width: 48,
                                height: 48,

                                fit: BoxFit.cover,
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

                  _DrawerItem(
                    icon: Icons.dashboard_outlined,

                    selectedIcon: Icons.dashboard_rounded,

                    title: 'Dashboard',

                    selected: selectedIndex == 0,

                    accent: AppColors.primary,

                    onTap: () {
                      _openBottomTab(context, 0);
                    },
                  ),

                  _DrawerItem(
                    icon: Icons.business_outlined,

                    selectedIcon: Icons.business_rounded,

                    title: 'Partners',

                    accent: AppColors.partnersAccent,

                    onTap: () {
                      _openPartners(context);
                    },
                  ),

                  _DrawerItem(
                    icon: Icons.grid_view_outlined,

                    selectedIcon: Icons.grid_view_rounded,

                    title: 'Services',

                    selected: selectedIndex == 1,

                    accent: AppColors.servicesAccent,

                    onTap: () {
                      _openBottomTab(context, 1);
                    },
                  ),

                  _DrawerItem(
                    icon: Icons.notifications_none_rounded,

                    selectedIcon: Icons.notifications_rounded,

                    title: 'Notifications',

                    selected: selectedIndex == 2,

                    accent: AppColors.notificationsAccent,

                    onTap: () {
                      _openBottomTab(context, 2);
                    },
                  ),

                  const SizedBox(height: 20),

                  const _DrawerSectionLabel(label: 'ACCOUNT'),

                  const SizedBox(height: 6),

                  _DrawerItem(
                    icon: Icons.person_outline_rounded,

                    selectedIcon: Icons.person_rounded,

                    title: 'Profile',

                    selected: selectedIndex == 3,

                    accent: AppColors.profileAccent,

                    onTap: () {
                      _openBottomTab(context, 3);
                    },
                  ),

                  // ============================================
                  // PREFERENCES ONLY
                  // ============================================
                  _DrawerItem(
                    icon: Icons.tune_outlined,

                    selectedIcon: Icons.tune_rounded,

                    title: 'Preferences',

                    accent: AppColors.preferencesAccent,

                    onTap: () {
                      final navigator = Navigator.of(context);

                      navigator.pop();

                      navigator.push(
                        MaterialPageRoute(
                          builder: (_) => const PreferencesScreen(),
                        ),
                      );
                    },
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

  void _openBottomTab(BuildContext context, int index) {
    final navigationBloc = context.read<NavigationBloc>();

    Navigator.pop(context);

    navigationBloc.add(NavigationTabChanged(index));
  }

  void _openPartners(BuildContext context) {
    final repository = context.read<DataRepository>();

    final navigator = Navigator.of(context);

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
}

// ============================================================
// DRAWER SECTION
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

  final Color accent;

  const _DrawerItem({
    required this.icon,
    required this.selectedIcon,
    required this.title,
    required this.onTap,
    required this.accent,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),

      child: Material(
        color: selected ? accent.withValues(alpha: 0.10) : Colors.transparent,

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
                        ? accent.withValues(alpha: 0.13)
                        : colors.surfaceContainerHighest,

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Icon(
                    selected ? selectedIcon : icon,

                    size: 20,

                    color: selected ? accent : colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,

                    style: TextStyle(
                      fontSize: 14,

                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,

                      color: selected ? accent : colors.onSurface,
                    ),
                  ),
                ),

                if (selected)
                  Container(
                    width: 6,

                    height: 6,

                    decoration: BoxDecoration(
                      color: accent,

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
