import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';

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
          toolbarHeight: 72,
          titleSpacing: 8,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Security',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                'Account and device security',
                style: TextStyle(
                  fontSize: 12,
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
                color: isDark ? colors.surfaceContainerHigh : colors.surface,

                borderRadius: BorderRadius.circular(14),

                child: InkWell(
                  borderRadius: BorderRadius.circular(14),

                  onTap: () {
                    context.read<UserBloc>().add(
                      const CheckBiometricAvailability(),
                    );
                  },

                  child: Container(
                    width: 44,
                    height: 44,

                    decoration: BoxDecoration(
                      border: Border.all(color: colors.outlineVariant),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Icon(
                      Icons.refresh_rounded,
                      size: 21,
                      color: colors.onSurface,
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

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,

                      colors: [
                        colors.primary,
                        colors.primary.withValues(alpha: 0.76),
                      ],
                    ),

                    borderRadius: BorderRadius.circular(24),

                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(
                          alpha: isDark ? 0.16 : 0.22,
                        ),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,

                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: const Icon(
                          Icons.shield_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              'Account protected',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              authenticatedUsername.isNotEmpty
                                  ? authenticatedUsername
                                  : 'CODEX account',

                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,

                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.80),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // SESSION
                // ==================================================
                _SectionTitle(
                  title: 'Session',
                  subtitle: 'Current authentication status',
                ),

                const SizedBox(height: 10),

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

                const SizedBox(height: 24),

                // ==================================================
                // REMEMBERED ACCOUNT
                // ==================================================
                _SectionTitle(
                  title: 'Remembered account',
                  subtitle: 'Credentials securely stored on this device',
                ),

                const SizedBox(height: 10),

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

                const SizedBox(height: 24),

                // ==================================================
                // BIOMETRICS
                // ==================================================
                _SectionTitle(
                  title: 'Biometric authentication',
                  subtitle: 'Device verification for remembered login',
                ),

                const SizedBox(height: 10),

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

                const SizedBox(height: 24),

                // ==================================================
                // APPLICATION SECURITY
                // ==================================================
                _SectionTitle(
                  title: 'Application security',
                  subtitle: 'Protect access to the current session',
                ),

                const SizedBox(height: 10),

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

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: colors.primary.withValues(
                      alpha: isDark ? 0.08 : 0.06,
                    ),

                    borderRadius: BorderRadius.circular(18),

                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.14),
                    ),
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: colors.primary,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          'Biometric verification is handled '
                          'by your phone\'s operating system. '
                          'On some Android devices the exact '
                          'method may be reported generically '
                          'instead of specifically as Face or '
                          'Fingerprint.',

                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
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

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: colors.outlineVariant),

        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
        ],
      ),

      child: child,
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

    return Padding(
      padding: const EdgeInsets.all(16),

      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),

              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, size: 22, color: colors.primary),
          ),

          const SizedBox(width: 14),

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
                    height: 1.3,
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

    final actionColor = destructive ? colors.error : colors.primary;

    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(22),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,

                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.10),

                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(icon, size: 22, color: actionColor),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: destructive ? colors.error : colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,

                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Icon(
                Icons.arrow_forward_ios_rounded,

                size: 13,

                color: destructive ? colors.error : colors.onSurfaceVariant,
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),

      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.10),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        label,

        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: statusColor,
        ),
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
    return Divider(
      height: 1,
      indent: 74,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
