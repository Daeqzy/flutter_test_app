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

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,

      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // WELCOME
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

            const SizedBox(height: 24),

            // ==================================================
            // QUICK ACCESS
            // ==================================================
            const AppSectionHeader(
              title: 'Quick access',
              subtitle: 'Jump straight into your workspace',
            ),

            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,

              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              mainAxisSpacing: 10,

              crossAxisSpacing: 10,

              childAspectRatio: 1.18,

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
                  icon: Icons.person_outline_rounded,

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

            const SizedBox(height: 26),

            // ==================================================
            // WORKSPACE
            // ==================================================
            const AppSectionHeader(
              title: 'Workspace',
              subtitle: 'Your CODEX environment at a glance',
            ),

            const SizedBox(height: 12),

            const _WorkspaceCard(),

            const SizedBox(height: 26),

            // ==================================================
            // RECENT ACTIVITY
            // ==================================================
            const AppSectionHeader(
              title: 'Recent activity',
              subtitle: 'Your latest workspace actions',
            ),

            const SizedBox(height: 12),

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

      padding: const EdgeInsets.all(18),

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

            blurRadius: 18,

            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          // ====================================================
          // ICON
          // ====================================================

          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),

              borderRadius: BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.waving_hand_rounded,
              size: 22,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 13),

          // ====================================================
          // USER
          // ====================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Welcome back',

                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,

                    color: Colors.white.withValues(alpha: 0.68),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  username,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.35,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Your CODEX workspace is ready.',

                  style: TextStyle(
                    fontSize: 11,
                    height: 1.35,

                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ====================================================
          // CONNECTION STATUS
          // ====================================================
          Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Icon(Icons.circle, size: 6, color: Color(0xFF86EFAC)),

              const SizedBox(width: 5),

              Text(
                'Connected',

                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,

                  color: Colors.white.withValues(alpha: 0.90),
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
      color: isDark ? colors.surfaceContainerHigh : colors.surface,

      borderRadius: BorderRadius.circular(18),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(18),

        child: Container(
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),

            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.65),
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // ICON + ARROW
              // ==================================================

              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,

                    decoration: BoxDecoration(
                      color: colors.primary.withValues(
                        alpha: isDark ? 0.14 : 0.08,
                      ),

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Icon(icon, size: 20, color: colors.primary),
                  ),

                  const Spacer(),

                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 17,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),

              const Spacer(),

              // ==================================================
              // TITLE
              // ==================================================
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

                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  fontSize: 10.5,
                  color: colors.onSurfaceVariant,
                ),
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

      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.65),
        ),
      ),

      child: Column(
        children: [
          // ====================================================
          // SESSION
          // ====================================================

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

          const _WorkspaceDivider(),

          // ====================================================
          // BACKEND
          // ====================================================
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

          const _WorkspaceDivider(),

          // ====================================================
          // PARTNERS
          // ====================================================
          _WorkspaceRow(
            icon: Icons.business_outlined,

            title: 'Partner directory',

            subtitle: 'Loaded only when you need it',

            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 20,
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

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),

          child: Row(
            children: [
              // ==================================================
              // ICON
              // ==================================================

              Container(
                width: 38,
                height: 38,

                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: isDark ? 0.14 : 0.08),

                  borderRadius: BorderRadius.circular(11),
                ),

                child: Icon(icon, size: 19, color: colors.primary),
              ),

              const SizedBox(width: 12),

              // ==================================================
              // TEXT
              // ==================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,

                      style: TextStyle(
                        fontSize: 10.5,
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
      ),
    );
  }
}

// ============================================================
// WORKSPACE DIVIDER
// ============================================================

class _WorkspaceDivider extends StatelessWidget {
  const _WorkspaceDivider();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Divider(
      height: 1,

      indent: 64,

      endIndent: 14,

      color: colors.outlineVariant.withValues(alpha: 0.60),
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

      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),

      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: isDark ? 0.07 : 0.045),

        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [
          // ====================================================
          // ICON
          // ====================================================

          Icon(Icons.history_rounded, size: 19, color: colors.primary),

          const SizedBox(width: 10),

          // ====================================================
          // TEXT
          // ====================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'No recent activity yet',

                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Your latest workspace actions will appear here.',

                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.4,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
