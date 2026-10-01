import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/navigation/navigation_bloc.dart';
import '../../bloc/navigation/navigation_event.dart';

import '../../bloc/partners/partners_bloc.dart';
import '../../bloc/partners/partners_event.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';

import '../../repositories/data_repository.dart';

import '../../theme/app_theme.dart';

import '../../widgets/common/app_section_header.dart';
import '../../widgets/common/app_status_badge.dart';

import 'partners_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,

      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // WELCOME HERO
            // ==================================================

            BlocBuilder<UserBloc, UserState>(
              buildWhen: (previous, current) {
                return previous.authenticatedUsername !=
                    current.authenticatedUsername;
              },

              builder: (context, state) {
                final username = state.authenticatedUsername.trim().isNotEmpty
                    ? state.authenticatedUsername
                    : 'CODEX User';

                return _WelcomeCard(username: username);
              },
            ),

            const SizedBox(height: 28),

            // ==================================================
            // QUICK ACCESS
            // ==================================================
            const AppSectionHeader(
              title: 'Quick access',
              subtitle: 'Jump straight into your workspace',
            ),

            const SizedBox(height: 14),

            GridView.count(
              crossAxisCount: 2,

              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              mainAxisSpacing: 12,

              crossAxisSpacing: 12,

              childAspectRatio: 1.15,

              children: [
                _QuickActionCard(
                  icon: Icons.business_rounded,
                  title: 'Partners',
                  subtitle: 'Company directory',

                  onTap: () {
                    _openPartners(context);
                  },
                ),

                _QuickActionCard(
                  icon: Icons.grid_view_rounded,
                  title: 'Services',
                  subtitle: 'Application tools',

                  onTap: () {
                    context.read<NavigationBloc>().add(
                      const NavigationTabChanged(1),
                    );
                  },
                ),

                _QuickActionCard(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: 'Updates & alerts',

                  onTap: () {
                    context.read<NavigationBloc>().add(
                      const NavigationTabChanged(2),
                    );
                  },
                ),

                _QuickActionCard(
                  icon: Icons.person_rounded,
                  title: 'Profile',
                  subtitle: 'Your account',

                  onTap: () {
                    context.read<NavigationBloc>().add(
                      const NavigationTabChanged(3),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ==================================================
            // WORKSPACE
            // ==================================================
            const AppSectionHeader(
              title: 'Workspace',
              subtitle: 'Your CODEX environment at a glance',
            ),

            const SizedBox(height: 14),

            const _WorkspaceCard(),

            const SizedBox(height: 30),

            // ==================================================
            // RECENT ACTIVITY
            // ==================================================
            const AppSectionHeader(
              title: 'Recent activity',
              subtitle: 'Your latest workspace actions',
            ),

            const SizedBox(height: 14),

            const _EmptyActivityCard(),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // OPEN PARTNERS
  // ==========================================================

  void _openPartners(BuildContext context) {
    final repository = context.read<DataRepository>();

    Navigator.of(context).push(
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
// WELCOME CARD
// ============================================================

class _WelcomeCard extends StatelessWidget {
  final String username;

  const _WelcomeCard({required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [AppColors.primary, AppColors.primaryDark],
        ),

        borderRadius: BorderRadius.circular(26),

        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),

            blurRadius: 28,

            offset: const Offset(0, 12),
          ),
        ],
      ),

      child: Stack(
        children: [
          // ----------------------------------------------------
          // DECORATION
          // ----------------------------------------------------

          Positioned(
            right: -35,
            top: -40,

            child: Container(
              width: 135,
              height: 135,

              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),

                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: 35,
            bottom: -55,

            child: Container(
              width: 115,
              height: 115,

              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),

                shape: BoxShape.circle,
              ),
            ),
          ),

          // ----------------------------------------------------
          // CONTENT
          // ----------------------------------------------------
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),

                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: const Icon(
                      Icons.waving_hand_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: const Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Icon(Icons.circle, size: 7, color: Color(0xFF86EFAC)),

                        SizedBox(width: 6),

                        Text(
                          'Connected',

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                'Welcome back,',

                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,

                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                username,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.7,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                'Everything you need for your CODEX workspace is ready.',

                style: TextStyle(
                  height: 1.4,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,

                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// QUICK ACTION CARD
// ============================================================

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: colors.surfaceContainer,

      borderRadius: BorderRadius.circular(20),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(20),

        child: Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),

            border: Border.all(color: colors.outlineVariant),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.035),

                blurRadius: isDark ? 14 : 10,

                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  // ============================================
                  // ICON TILE
                  // ============================================

                  Container(
                    width: 44,
                    height: 44,

                    decoration: BoxDecoration(
                      color: colors.primary.withValues(
                        alpha: isDark ? 0.18 : 0.09,
                      ),

                      borderRadius: BorderRadius.circular(14),

                      border: Border.all(
                        color: colors.primary.withValues(
                          alpha: isDark ? 0.20 : 0.08,
                        ),
                      ),
                    ),

                    child: Icon(icon, size: 22, color: colors.primary),
                  ),

                  const Spacer(),

                  Icon(
                    Icons.arrow_outward_rounded,

                    size: 18,

                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),

              const Spacer(),

              Text(
                title,

                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,

                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// WORKSPACE CARD
// ============================================================

class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: colors.surfaceContainer,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: colors.outlineVariant),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.025),

            blurRadius: isDark ? 16 : 10,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        children: [
          const _WorkspaceRow(
            icon: Icons.shield_outlined,
            title: 'Secure session',
            subtitle: 'Authentication is active',

            trailing: AppStatusBadge(
              text: 'Active',
              color: AppColors.success,
              showDot: true,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),

            child: Divider(color: colors.outlineVariant),
          ),

          const _WorkspaceRow(
            icon: Icons.cloud_done_outlined,
            title: 'Backend connection',
            subtitle: 'CODEX services available',

            trailing: AppStatusBadge(
              text: 'Online',
              color: AppColors.success,
              showDot: true,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),

            child: Divider(color: colors.outlineVariant),
          ),

          _WorkspaceRow(
            icon: Icons.business_outlined,
            title: 'Partner directory',
            subtitle: 'Loaded only when you need it',

            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colors.onSurfaceVariant,
            ),

            onTap: () {
              final repository = context.read<DataRepository>();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) =>
                        PartnersBloc(repository)
                          ..add(const PartnersRequested()),

                    child: const PartnersScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WORKSPACE ROW
// ============================================================

class _WorkspaceRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _WorkspaceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(14),

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),

        child: Row(
          children: [
            // ================================================
            // ICON
            // ================================================

            Container(
              width: 44,
              height: 44,

              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: isDark ? 0.17 : 0.08),

                borderRadius: BorderRadius.circular(14),

                border: Border.all(
                  color: colors.primary.withValues(alpha: isDark ? 0.20 : 0.05),
                ),
              ),

              child: Icon(icon, size: 21, color: colors.primary),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,

                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,

                    style: TextStyle(
                      fontSize: 12,

                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            trailing,
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY RECENT ACTIVITY
// ============================================================

class _EmptyActivityCard extends StatelessWidget {
  const _EmptyActivityCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: colors.surfaceContainer,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: colors.outlineVariant),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.025),

            blurRadius: isDark ? 16 : 10,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,

            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,

              borderRadius: BorderRadius.circular(18),

              border: Border.all(color: colors.outlineVariant),
            ),

            child: Icon(Icons.history_rounded, size: 27, color: colors.primary),
          ),

          const SizedBox(height: 14),

          Text(
            'No recent activity yet',

            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,

              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Your latest workspace actions will appear here.',

            textAlign: TextAlign.center,

            style: TextStyle(
              height: 1.4,
              fontSize: 12,

              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
