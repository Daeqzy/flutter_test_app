import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common/app_section_header.dart';

import '../security/security_screen.dart';
import '../security/change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,

      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),

        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            final username = state.authenticatedUsername.trim().isNotEmpty
                ? state.authenticatedUsername
                : 'CODEX User';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                _ProfileHero(username: username),

                const SizedBox(height: 24),

                const AppSectionHeader(
                  title: 'Account',

                  subtitle: 'Your CODEX workspace profile',
                ),

                const SizedBox(height: 12),

                _ProfileCard(username: username),

                const SizedBox(height: 26),

                // ==================================================
                // SECURITY
                // ==================================================
                const AppSectionHeader(
                  title: 'Security & access',

                  subtitle: 'Authentication and account protection',
                ),

                const SizedBox(height: 12),

                _ProfileSettingsCard(
                  children: [
                    _ProfileActionRow(
                      icon: Icons.shield_outlined,

                      title: 'Security settings',

                      subtitle: 'Session, biometrics and remembered account',

                      accent: AppColors.securityAccent,

                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SecurityScreen(),
                          ),
                        );
                      },
                    ),

                    const _ProfileDivider(),

                    _ProfileStatusRow(
                      icon: _biometricIcon(state),

                      title: 'Biometric login',

                      subtitle: _biometricSubtitle(state),

                      status: _biometricStatus(state),

                      positive: _hasBiometric(state),

                      accent: AppColors.primary,

                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SecurityScreen(),
                          ),
                        );
                      },
                    ),

                    const _ProfileDivider(),

                    _ProfileActionRow(
                      icon: Icons.password_rounded,

                      title: 'Change password',

                      subtitle: 'Update your CODEX account password',

                      accent: AppColors.notificationsAccent,

                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // ==================================================
                // SESSION
                // ==================================================
                const AppSectionHeader(
                  title: 'Session',

                  subtitle: 'Manage the current application session',
                ),

                const SizedBox(height: 12),

                _ProfileSettingsCard(
                  children: [
                    const _SessionStatusRow(),

                    const _ProfileDivider(),

                    _ProfileActionRow(
                      icon: Icons.lock_outline_rounded,

                      title: 'Lock application',

                      subtitle: state.hasRememberedAccount
                          ? 'End this session and authenticate again'
                          : 'End this session and return to login',

                      accent: AppColors.profileAccent,

                      onTap: () {
                        _confirmLockApplication(context);
                      },
                    ),

                    const _ProfileDivider(),

                    _ProfileActionRow(
                      icon: Icons.logout_rounded,

                      title: 'Sign out',

                      subtitle: 'End your current CODEX session',

                      destructive: true,

                      accent: AppColors.error,

                      onTap: () {
                        _confirmSignOut(context);
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // BIOMETRIC HELPERS
  // ==========================================================

  static bool _hasBiometric(UserState state) {
    return state.hasFingerprint ||
        state.hasFaceAuthentication ||
        state.hasIrisAuthentication;
  }

  static IconData _biometricIcon(UserState state) {
    if (state.hasFingerprint && state.hasFaceAuthentication) {
      return Icons.lock_person_rounded;
    }

    if (state.hasFaceAuthentication) {
      return Icons.face_retouching_natural;
    }

    if (state.hasFingerprint) {
      return Icons.fingerprint_rounded;
    }

    if (state.hasIrisAuthentication) {
      return Icons.remove_red_eye_outlined;
    }

    return Icons.lock_person_rounded;
  }

  static String _biometricStatus(UserState state) {
    if (!_hasBiometric(state)) {
      return 'Unavailable';
    }

    if (!state.hasRememberedAccount) {
      return 'Available';
    }

    return 'Ready';
  }

  static String _biometricSubtitle(UserState state) {
    if (!_hasBiometric(state)) {
      return 'No enrolled biometric method detected';
    }

    if (!state.hasRememberedAccount) {
      return 'Available after enabling Remember me';
    }

    if (state.hasFingerprint && state.hasFaceAuthentication) {
      return 'Face or fingerprint authentication available';
    }

    if (state.hasFaceAuthentication) {
      return 'Face authentication available';
    }

    if (state.hasFingerprint) {
      return 'Fingerprint authentication available';
    }

    if (state.hasIrisAuthentication) {
      return 'Iris authentication available';
    }

    return 'Biometric authentication available';
  }

  // ==========================================================
  // LOCK
  // ==========================================================

  static Future<void> _confirmLockApplication(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.lock_outline_rounded),

          title: const Text('Lock application?'),

          content: const Text(
            'The current session will end. '
            'You will need to authenticate again '
            'before accessing CODEX.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },

              child: const Text('Cancel'),
            ),

            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },

              icon: const Icon(Icons.lock_rounded),

              label: const Text('Lock'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    context.read<UserBloc>().add(const UserLogoutRequested());
  }

  // ==========================================================
  // SIGN OUT
  // ==========================================================

  static Future<void> _confirmSignOut(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(Icons.logout_rounded, color: colors.error),

          title: const Text('Sign out?'),

          content: const Text('Your current CODEX session will end.'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },

              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },

              style: FilledButton.styleFrom(
                backgroundColor: colors.error,

                foregroundColor: colors.onError,
              ),

              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    context.read<UserBloc>().add(const UserLogoutRequested());
  }
}

// ============================================================
// HERO
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

          colors: [AppColors.profileAccent, AppColors.profileAccentDark],
        ),

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: AppColors.profileAccent.withValues(alpha: 0.13),

            blurRadius: 18,

            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        children: [
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
// ACCOUNT
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
          color: AppColors.profileAccent.withValues(
            alpha: isDark ? 0.22 : 0.12,
          ),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 42,

            height: 42,

            decoration: BoxDecoration(
              color: AppColors.profileAccent.withValues(
                alpha: isDark ? 0.17 : 0.09,
              ),

              borderRadius: BorderRadius.circular(12),
            ),

            child: const Icon(
              Icons.person_outline_rounded,

              size: 21,

              color: AppColors.profileAccent,
            ),
          ),

          const SizedBox(width: 12),

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
// SETTINGS CARD
// ============================================================

class _ProfileSettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _ProfileSettingsCard({required this.children});

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

      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),

        child: Column(children: children),
      ),
    );
  }
}

// ============================================================
// ACTION ROW
// ============================================================

class _ProfileActionRow extends StatelessWidget {
  final IconData icon;

  final String title;

  final String subtitle;

  final VoidCallback onTap;

  final Color accent;

  final bool destructive;

  const _ProfileActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.accent,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actionColor = destructive ? colors.error : accent;

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),

          child: Row(
            children: [
              Container(
                width: 38,

                height: 38,

                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: isDark ? 0.16 : 0.08),

                  borderRadius: BorderRadius.circular(11),
                ),

                child: Icon(icon, size: 19, color: actionColor),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: TextStyle(
                        fontSize: 13,

                        fontWeight: FontWeight.w700,

                        color: destructive ? colors.error : colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,

                      style: TextStyle(
                        fontSize: 10.5,

                        height: 1.35,

                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Icon(
                Icons.chevron_right_rounded,

                size: 19,

                color: actionColor.withValues(alpha: 0.80),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STATUS ROW
// ============================================================

class _ProfileStatusRow extends StatelessWidget {
  final IconData icon;

  final String title;

  final String subtitle;

  final String status;

  final bool positive;

  final Color accent;

  final VoidCallback onTap;

  const _ProfileStatusRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.positive,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final statusColor = positive ? AppColors.success : colors.onSurfaceVariant;

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),

          child: Row(
            children: [
              Container(
                width: 38,

                height: 38,

                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.16 : 0.08),

                  borderRadius: BorderRadius.circular(11),
                ),

                child: Icon(icon, size: 19, color: accent),
              ),

              const SizedBox(width: 12),

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

                        height: 1.35,

                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),

                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),

                  borderRadius: BorderRadius.circular(16),
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Icon(Icons.circle, size: 5, color: statusColor),

                    const SizedBox(width: 4),

                    Text(
                      status,

                      style: TextStyle(
                        fontSize: 9.5,

                        fontWeight: FontWeight.w700,

                        color: statusColor,
                      ),
                    ),
                  ],
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
// SESSION STATUS
// ============================================================

class _SessionStatusRow extends StatelessWidget {
  const _SessionStatusRow();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),

      child: Row(
        children: [
          Container(
            width: 38,

            height: 38,

            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: isDark ? 0.16 : 0.08),

              borderRadius: BorderRadius.circular(11),
            ),

            child: const Icon(
              Icons.verified_user_outlined,

              size: 19,

              color: AppColors.success,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Authenticated session',

                  style: TextStyle(
                    fontSize: 13,

                    fontWeight: FontWeight.w700,

                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 2),

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

          const Row(
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
        ],
      ),
    );
  }
}

// ============================================================
// DIVIDER
// ============================================================

class _ProfileDivider extends StatelessWidget {
  const _ProfileDivider();

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
