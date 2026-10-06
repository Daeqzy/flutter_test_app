import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';

// ============================================================
// SECURITY SCREEN
// ============================================================

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  @override
  void initState() {
    super.initState();

    // Refresh biometric information whenever
    // the Security screen is opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<UserBloc>().add(const CheckBiometricAvailability());
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<UserBloc, UserState>(
      listenWhen: (previous, current) {
        return previous.hasRememberedAccount && !current.hasRememberedAccount;
      },

      listener: (context, state) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Remembered account removed from this device.'),
          ),
        );
      },

      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        // ======================================================
        // APP BAR
        // ======================================================
        appBar: AppBar(
          toolbarHeight: 68,

          titleSpacing: 8,

          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                'Security',

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                'Account and device security',

                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14),

              child: Material(
                color: isDark
                    ? colors.surfaceContainerHigh.withValues(alpha: 0.60)
                    : colors.surface,

                borderRadius: BorderRadius.circular(12),

                child: InkWell(
                  borderRadius: BorderRadius.circular(12),

                  onTap: () {
                    context.read<UserBloc>().add(
                      const CheckBiometricAvailability(),
                    );
                  },

                  child: SizedBox(
                    width: 40,
                    height: 40,

                    child: Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ======================================================
        // CONTENT
        // ======================================================
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            final authenticatedUsername =
                state.authenticatedUsername.trim().isNotEmpty
                ? state.authenticatedUsername
                : state.username.trim();

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),

              children: [
                // ==================================================
                // SECURITY SUMMARY
                // ==================================================

                _SecurityHero(
                  username: authenticatedUsername.isNotEmpty
                      ? authenticatedUsername
                      : 'CODEX account',
                ),

                const SizedBox(height: 24),

                // ==================================================
                // SESSION
                // ==================================================
                const _SectionTitle(
                  title: 'Session',
                  subtitle: 'Current authentication status',
                ),

                const SizedBox(height: 12),

                _SecurityCard(
                  child: Column(
                    children: [
                      _SecurityInfoRow(
                        icon: Icons.verified_user_outlined,

                        title: 'Session status',

                        subtitle: 'Current CODEX authentication',

                        status: _authStatusLabel(state.authStatus),

                        positive: state.authStatus == AuthStatus.authenticated,
                      ),

                      const _SecurityDivider(),

                      _SecurityInfoRow(
                        icon: Icons.person_outline_rounded,

                        title: 'Signed in as',

                        subtitle: authenticatedUsername.isEmpty
                            ? 'Unknown user'
                            : authenticatedUsername,

                        status: state.authStatus == AuthStatus.authenticated
                            ? 'Active'
                            : 'Inactive',

                        positive: state.authStatus == AuthStatus.authenticated,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // ==================================================
                // REMEMBERED ACCOUNT
                // ==================================================
                const _SectionTitle(
                  title: 'Remembered account',
                  subtitle: 'Credentials securely stored on this device',
                ),

                const SizedBox(height: 12),

                _SecurityCard(
                  child: Column(
                    children: [
                      _SecurityInfoRow(
                        icon: Icons.account_circle_outlined,

                        title: 'Remember me',

                        subtitle: state.hasRememberedAccount
                            ? state.rememberedUsername
                            : 'No account is remembered',

                        status: state.hasRememberedAccount
                            ? 'Enabled'
                            : 'Disabled',

                        positive: state.hasRememberedAccount,
                      ),

                      if (state.hasRememberedAccount) ...[
                        const _SecurityDivider(),

                        _ActionRow(
                          icon: Icons.person_remove_outlined,

                          title: 'Forget remembered account',

                          subtitle:
                              'Remove saved login credentials from this device',

                          destructive: true,

                          onTap: () {
                            _confirmForgetAccount(
                              context,
                              state.rememberedUsername,
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // ==================================================
                // BIOMETRICS
                // ==================================================
                const _SectionTitle(
                  title: 'Biometric authentication',
                  subtitle: 'Device verification for remembered login',
                ),

                const SizedBox(height: 12),

                _SecurityCard(
                  child: Column(
                    children: [
                      _SecurityInfoRow(
                        icon: Icons.fingerprint_rounded,

                        title: 'Fingerprint',

                        subtitle: state.hasFingerprint
                            ? 'Fingerprint detected by the operating system'
                            : 'Not specifically reported by the operating system',

                        status: state.hasFingerprint ? 'Detected' : 'System',

                        positive: state.hasFingerprint,
                      ),

                      const _SecurityDivider(),

                      _SecurityInfoRow(
                        icon: Icons.face_retouching_natural,

                        title: 'Face authentication',

                        subtitle: state.hasFaceAuthentication
                            ? 'Face authentication detected by the operating system'
                            : 'Not specifically reported by the operating system',

                        status: state.hasFaceAuthentication
                            ? 'Detected'
                            : 'System',

                        positive: state.hasFaceAuthentication,
                      ),

                      if (state.hasIrisAuthentication) ...[
                        const _SecurityDivider(),

                        const _SecurityInfoRow(
                          icon: Icons.remove_red_eye_outlined,

                          title: 'Iris authentication',

                          subtitle: 'Iris authentication detected',

                          status: 'Detected',

                          positive: true,
                        ),
                      ],

                      const _SecurityDivider(),

                      _ActionRow(
                        icon: Icons.refresh_rounded,

                        title: 'Refresh biometric status',

                        subtitle: 'Check enrolled biometric methods again',

                        onTap: () {
                          context.read<UserBloc>().add(
                            const CheckBiometricAvailability(),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // ==================================================
                // APPLICATION SECURITY
                // ==================================================
                const _SectionTitle(
                  title: 'Application security',
                  subtitle: 'Protect access to the current session',
                ),

                const SizedBox(height: 12),

                _SecurityCard(
                  child: _ActionRow(
                    icon: Icons.lock_outline_rounded,

                    title: 'Lock application',

                    subtitle: state.hasRememberedAccount
                        ? 'End this session and require biometric verification again'
                        : 'End this session and return to login',

                    onTap: () {
                      _confirmLockApplication(context);
                    },
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // SECURITY INFO
                // ==================================================
                const _SecurityInfoNote(),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // FORGET REMEMBERED ACCOUNT
  // ==========================================================

  Future<void> _confirmForgetAccount(
    BuildContext context,
    String username,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          icon: Icon(Icons.person_remove_outlined, color: colors.error),

          title: const Text('Forget remembered account?'),

          content: Text(
            username.trim().isNotEmpty
                ? 'Saved credentials for "$username" will be removed from this device. Your current session will remain active.'
                : 'Saved login credentials will be removed from this device. Your current session will remain active.',
          ),

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

              child: const Text('Forget account'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    context.read<UserBloc>().add(const RememberMeChanged(false));
  }

  // ==========================================================
  // LOCK APPLICATION
  // ==========================================================

  Future<void> _confirmLockApplication(BuildContext context) async {
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
  // AUTH STATUS LABEL
  // ==========================================================

  String _authStatusLabel(AuthStatus status) {
    switch (status) {
      case AuthStatus.authenticated:
        return 'Authenticated';

      case AuthStatus.sessionExpired:
        return 'Expired';

      case AuthStatus.unauthenticated:
        return 'Signed out';

      case AuthStatus.initial:
        return 'Checking';
    }
  }
}

// ============================================================
// SECURITY HERO
// ============================================================

class _SecurityHero extends StatelessWidget {
  final String username;

  const _SecurityHero({required this.username});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [colors.primary, colors.primary.withValues(alpha: 0.86)],
        ),

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.10),

            blurRadius: 18,

            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),

              borderRadius: BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.shield_rounded,
              size: 22,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Account protected',

                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  username,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 11.5,

                    fontWeight: FontWeight.w500,

                    color: Colors.white.withValues(alpha: 0.74),
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
                'Secure',

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
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,

            style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECURITY CARD
// ============================================================

class _SecurityCard extends StatelessWidget {
  final Widget child;

  const _SecurityCard({required this.child});

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

      child: ClipRRect(borderRadius: BorderRadius.circular(18), child: child),
    );
  }
}

// ============================================================
// INFORMATION ROW
// ============================================================

class _SecurityInfoRow extends StatelessWidget {
  final IconData icon;

  final String title;

  final String subtitle;

  final String status;

  final bool positive;

  const _SecurityInfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),

      child: Row(
        children: [
          // ====================================================
          // ICON
          // ====================================================

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

          // ====================================================
          // TEXT
          // ====================================================
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

          _StatusBadge(label: status, positive: positive),
        ],
      ),
    );
  }
}

// ============================================================
// ACTION ROW
// ============================================================

class _ActionRow extends StatelessWidget {
  final IconData icon;

  final String title;

  final String subtitle;

  final VoidCallback onTap;

  final bool destructive;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actionColor = destructive ? colors.error : colors.primary;

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
                  color: actionColor.withValues(alpha: isDark ? 0.13 : 0.07),

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

                color: destructive
                    ? colors.error.withValues(alpha: 0.80)
                    : colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STATUS BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
  final String label;

  final bool positive;

  const _StatusBadge({required this.label, required this.positive});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final statusColor = positive
        ? const Color(0xFF16A34A)
        : colors.onSurfaceVariant;

    return Container(
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
            label,

            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DIVIDER
// ============================================================

class _SecurityDivider extends StatelessWidget {
  const _SecurityDivider();

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
// SECURITY INFO NOTE
// ============================================================

class _SecurityInfoNote extends StatelessWidget {
  const _SecurityInfoNote();

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
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(Icons.info_outline_rounded, size: 19, color: colors.primary),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'Biometric verification is handled by your phone\'s '
              'operating system. On some Android devices the exact '
              'method may be reported generically rather than '
              'specifically as Face or Fingerprint.',

              style: TextStyle(
                fontSize: 10.5,
                height: 1.4,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
