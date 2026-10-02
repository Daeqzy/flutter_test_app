import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';
import '../../bloc/user/user_event.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common/app_section_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,

      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),

        child: BlocBuilder<UserBloc, UserState>(
          buildWhen: (previous, current) {
            return previous.authenticatedUsername !=
                current.authenticatedUsername;
          },

          builder: (context, state) {
            final username = state.authenticatedUsername.trim().isNotEmpty
                ? state.authenticatedUsername
                : 'CODEX User';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==================================================
                // HERO
                // ==================================================

                _ProfileHero(username: username),

                const SizedBox(height: 28),

                // ==================================================
                // PROFILE DETAILS
                // ==================================================
                const AppSectionHeader(
                  title: 'Account',
                  subtitle: 'Your CODEX workspace profile',
                ),

                const SizedBox(height: 14),

                _ProfileCard(username: username),

                const SizedBox(height: 28),

                // ==================================================
                // SESSION
                // ==================================================
                const AppSectionHeader(
                  title: 'Session',
                  subtitle: 'Current account session',
                ),

                const SizedBox(height: 14),

                const _SessionCard(),

                const SizedBox(height: 28),

                // ==================================================
                // ACCOUNT ACTIONS
                // ==================================================
                const AppSectionHeader(
                  title: 'Account actions',
                  subtitle: 'Manage your current session',
                ),

                const SizedBox(height: 14),

                _LogoutCard(
                  onTap: () {
                    context.read<UserBloc>().add(const UserLogoutRequested());
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// PROFILE HERO
// ============================================================

class _ProfileHero extends StatelessWidget {
  final String username;

  const _ProfileHero({required this.username});

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
            color: AppColors.primary.withValues(alpha: 0.20),

            blurRadius: 28,

            offset: const Offset(0, 12),
          ),
        ],
      ),

      child: Stack(
        children: [
          // ----------------------------------------------------
          // BACKGROUND DECORATION
          // ----------------------------------------------------

          Positioned(
            right: -35,
            top: -45,

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
            right: 30,
            bottom: -55,

            child: Container(
              width: 110,
              height: 110,

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
                    width: 52,
                    height: 52,

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),

                      borderRadius: BorderRadius.circular(16),

                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),

                    child: Center(
                      child: Text(
                        _getInitial(username),

                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
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
                          'Signed in',

                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                'Your profile',

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

              const SizedBox(height: 8),

              Text(
                'Manage your CODEX workspace account and session.',

                style: TextStyle(
                  height: 1.4,
                  fontSize: 13,

                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _getInitial(String username) {
    final value = username.trim();

    if (value.isEmpty) {
      return '?';
    }

    return value[0].toUpperCase();
  }
}

// ============================================================
// PROFILE CARD
// ============================================================

class _ProfileCard extends StatelessWidget {
  final String username;

  const _ProfileCard({required this.username});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: colors.outlineVariant),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.025),

            blurRadius: isDark ? 16 : 10,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,

            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: isDark ? 0.18 : 0.09),

              borderRadius: BorderRadius.circular(18),

              border: Border.all(
                color: colors.primary.withValues(alpha: isDark ? 0.22 : 0.07),
              ),
            ),

            child: Icon(Icons.person_rounded, size: 29, color: colors.primary),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Username',

                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,

                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  username,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,

                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'CODEX workspace account',

                  style: TextStyle(
                    fontSize: 12,

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

// ============================================================
// SESSION CARD
// ============================================================

class _SessionCard extends StatelessWidget {
  const _SessionCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: colors.outlineVariant),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.025),

            blurRadius: isDark ? 16 : 10,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        children: [
          const _SessionIcon(),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Authenticated session',

                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,

                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'You are currently signed in to CODEX.',

                  style: TextStyle(
                    fontSize: 12,

                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          const _ActiveBadge(),
        ],
      ),
    );
  }
}

// ============================================================
// SESSION ICON
// ============================================================

class _SessionIcon extends StatelessWidget {
  const _SessionIcon();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 44,
      height: 44,

      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: isDark ? 0.16 : 0.08),

        borderRadius: BorderRadius.circular(14),

        border: Border.all(
          color: AppColors.success.withValues(alpha: isDark ? 0.20 : 0.06),
        ),
      ),

      child: const Icon(
        Icons.verified_user_outlined,

        size: 21,

        color: AppColors.success,
      ),
    );
  }
}

// ============================================================
// ACTIVE BADGE
// ============================================================

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),

      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: AppColors.success.withValues(alpha: isDark ? 0.20 : 0.05),
        ),
      ),

      child: const Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(Icons.circle, size: 6, color: AppColors.success),

          SizedBox(width: 5),

          Text(
            'Active',

            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,

              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOGOUT CARD
// ============================================================

class _LogoutCard extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? colors.surfaceContainerHigh : colors.surface,

      borderRadius: BorderRadius.circular(22),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(22),

        child: Container(
          width: double.infinity,

          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),

            border: Border.all(
              color: isDark
                  ? AppColors.error.withValues(alpha: 0.22)
                  : colors.outlineVariant,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.02),

                blurRadius: isDark ? 14 : 8,

                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,

                decoration: BoxDecoration(
                  color: AppColors.error.withValues(
                    alpha: isDark ? 0.16 : 0.08,
                  ),

                  borderRadius: BorderRadius.circular(14),

                  border: Border.all(
                    color: AppColors.error.withValues(
                      alpha: isDark ? 0.20 : 0.05,
                    ),
                  ),
                ),

                child: const Icon(
                  Icons.logout_rounded,

                  size: 20,

                  color: AppColors.error,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Sign out',

                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,

                        color: AppColors.error,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'End your current CODEX session',

                      style: TextStyle(
                        fontSize: 12,

                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,

                color: isDark
                    ? AppColors.error.withValues(alpha: 0.85)
                    : colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
