import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common/app_section_header.dart';

// ============================================================
// PROFILE SCREEN
// ============================================================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),

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

                const SizedBox(height: 24),

                // ==================================================
                // ACCOUNT
                // ==================================================
                const AppSectionHeader(
                  title: 'Account',
                  subtitle: 'Your CODEX workspace profile',
                ),

                const SizedBox(height: 12),

                _ProfileCard(username: username),

                const SizedBox(height: 26),

                // ==================================================
                // SESSION
                // ==================================================
                const AppSectionHeader(
                  title: 'Session',
                  subtitle: 'Current account session',
                ),

                const SizedBox(height: 12),

                const _SessionCard(),

                const SizedBox(height: 26),

                // ==================================================
                // ACCOUNT ACTIONS
                // ==================================================
                const AppSectionHeader(
                  title: 'Account actions',
                  subtitle: 'Manage your current session',
                ),

                const SizedBox(height: 12),

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
        children: [
          // ====================================================
          // AVATAR
          // ====================================================

          Container(
            width: 48,
            height: 48,

            alignment: Alignment.center,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),

              borderRadius: BorderRadius.circular(14),
            ),

            child: Text(
              _getInitial(username),

              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 13),

          // ====================================================
          // USER INFO
          // ====================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Your profile',

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
                  'CODEX workspace account',

                  style: TextStyle(
                    fontSize: 11,

                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ====================================================
          // SIGNED IN STATUS
          // ====================================================
          Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Icon(Icons.circle, size: 6, color: Color(0xFF86EFAC)),

              const SizedBox(width: 5),

              Text(
                'Signed in',

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

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.65),
        ),
      ),

      child: Row(
        children: [
          // ====================================================
          // ICON
          // ====================================================

          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: isDark ? 0.14 : 0.08),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              Icons.person_outline_rounded,
              size: 21,
              color: colors.primary,
            ),
          ),

          const SizedBox(width: 12),

          // ====================================================
          // DETAILS
          // ====================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Username',

                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,

                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  username,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,

                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'CODEX workspace account',

                  style: TextStyle(
                    fontSize: 10.5,

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

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.65),
        ),
      ),

      child: Row(
        children: [
          // ====================================================
          // SESSION ICON
          // ====================================================

          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: isDark ? 0.13 : 0.07),

              borderRadius: BorderRadius.circular(12),
            ),

            child: const Icon(
              Icons.verified_user_outlined,
              size: 20,
              color: AppColors.success,
            ),
          ),

          const SizedBox(width: 12),

          // ====================================================
          // SESSION INFO
          // ====================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Authenticated session',

                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,

                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'You are currently signed in to CODEX.',

                  style: TextStyle(
                    fontSize: 10.5,

                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ====================================================
          // ACTIVE STATUS
          // ====================================================
          const _ActiveStatus(),
        ],
      ),
    );
  }
}

// ============================================================
// ACTIVE STATUS
// ============================================================

class _ActiveStatus extends StatelessWidget {
  const _ActiveStatus();

  @override
  Widget build(BuildContext context) {
    return const Row(
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

      borderRadius: BorderRadius.circular(18),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(18),

        child: Container(
          width: double.infinity,

          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),

            border: Border.all(
              color: AppColors.error.withValues(alpha: isDark ? 0.20 : 0.10),
            ),
          ),

          child: Row(
            children: [
              // ==================================================
              // ICON
              // ==================================================

              Container(
                width: 40,
                height: 40,

                decoration: BoxDecoration(
                  color: AppColors.error.withValues(
                    alpha: isDark ? 0.13 : 0.07,
                  ),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.logout_rounded,
                  size: 19,
                  color: AppColors.error,
                ),
              ),

              const SizedBox(width: 12),

              // ==================================================
              // TEXT
              // ==================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Sign out',

                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'End your current CODEX session',

                      style: TextStyle(
                        fontSize: 10.5,

                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,

                size: 20,

                color: AppColors.error.withValues(alpha: 0.80),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
