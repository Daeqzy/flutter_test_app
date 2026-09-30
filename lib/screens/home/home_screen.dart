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
            // QUICK ACCESS HEADER
            // ==================================================
            const _SectionHeader(
              title: 'Quick access',
              subtitle: 'Jump straight into your workspace',
            ),

            const SizedBox(height: 14),

            // ==================================================
            // QUICK ACTIONS
            // ==================================================
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
            const _SectionHeader(
              title: 'Workspace',
              subtitle: 'Your CODEX environment at a glance',
            ),

            const SizedBox(height: 14),

            const _WorkspaceCard(),

            const SizedBox(height: 30),

            // ==================================================
            // RECENT ACTIVITY
            // ==================================================
            const _SectionHeader(
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
// SECTION HEADER
// ============================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
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
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, size: 22, color: AppColors.primary),
                  ),

                  const Spacer(),

                  const Icon(
                    Icons.arrow_outward_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),

              const Spacer(),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const _WorkspaceRow(
            icon: Icons.shield_outlined,
            title: 'Secure session',
            subtitle: 'Authentication is active',
            trailing: _StatusBadge(text: 'Active', positive: true),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(),
          ),

          const _WorkspaceRow(
            icon: Icons.cloud_done_outlined,
            title: 'Backend connection',
            subtitle: 'CODEX services available',
            trailing: _StatusBadge(text: 'Online', positive: true),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(),
          ),

          _WorkspaceRow(
            icon: Icons.business_outlined,
            title: 'Partner directory',
            subtitle: 'Loaded only when you need it',
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7FB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 21, color: AppColors.primary),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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
// STATUS BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
  final String text;
  final bool positive;

  const _StatusBadge({required this.text, required this.positive});

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),

          const SizedBox(width: 5),

          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FB),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 27,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'No recent activity yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Your latest workspace actions will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.4,
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
