import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';

import '../main/main_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ==========================================================
  // NORMAL LOGIN
  // ==========================================================

  void _login(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final state = context.read<UserBloc>().state;

    context.read<UserBloc>().add(
      UserLoginRequested(
        username: state.username.trim(),
        password: state.password,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<UserBloc, UserState>(
      listenWhen: (previous, current) {
        final becameAuthenticated =
            previous.authStatus != current.authStatus &&
            current.authStatus == AuthStatus.authenticated;

        final errorChanged = previous.errorMessage != current.errorMessage;

        return becameAuthenticated || errorChanged;
      },

      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));

          return;
        }

        if (state.authStatus == AuthStatus.authenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      },

      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        // ======================================================
        // APP BAR
        // ======================================================
        appBar: AppBar(
          title: Text(
            'CODEX Computers',
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),

              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),

                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),

                  decoration: BoxDecoration(
                    color: isDark ? colors.surfaceContainer : colors.surface,

                    borderRadius: BorderRadius.circular(26),

                    border: Border.all(color: colors.outlineVariant),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.24 : 0.055,
                        ),

                        blurRadius: isDark ? 24 : 20,

                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Form(
                    key: _formKey,

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        // ======================================
                        // LOGO
                        // ======================================

                        Container(
                          padding: const EdgeInsets.all(14),

                          decoration: BoxDecoration(
                            color: isDark
                                ? colors.surfaceContainerHighest
                                : colors.surfaceContainerLowest,

                            borderRadius: BorderRadius.circular(24),

                            border: Border.all(color: colors.outlineVariant),
                          ),

                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),

                            child: Image.asset(
                              'assets/images/codex_logo.png',

                              width: 230,

                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ======================================
                        // TITLE
                        // ======================================
                        Text(
                          'Welcome Back',

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,

                            letterSpacing: -0.6,

                            color: colors.onSurface,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Sign in to continue',

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            fontSize: 14,

                            color: colors.onSurfaceVariant,
                          ),
                        ),

                        // ======================================
                        // REMEMBERED ACCOUNT
                        // ======================================
                        BlocBuilder<UserBloc, UserState>(
                          buildWhen: (previous, current) {
                            return previous.hasRememberedAccount !=
                                    current.hasRememberedAccount ||
                                previous.rememberedUsername !=
                                    current.rememberedUsername;
                          },

                          builder: (context, state) {
                            if (!state.hasRememberedAccount) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 22),

                              child: Container(
                                width: double.infinity,

                                padding: const EdgeInsets.all(15),

                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(
                                    alpha: isDark ? 0.14 : 0.065,
                                  ),

                                  borderRadius: BorderRadius.circular(16),

                                  border: Border.all(
                                    color: colors.primary.withValues(
                                      alpha: isDark ? 0.25 : 0.14,
                                    ),
                                  ),
                                ),

                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,

                                      decoration: BoxDecoration(
                                        color: colors.primary.withValues(
                                          alpha: isDark ? 0.20 : 0.11,
                                        ),

                                        shape: BoxShape.circle,
                                      ),

                                      child: Icon(
                                        Icons.person_outline_rounded,

                                        color: colors.primary,

                                        size: 22,
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            'Remembered account',

                                            style: TextStyle(
                                              fontSize: 12,

                                              fontWeight: FontWeight.w500,

                                              color: colors.onSurfaceVariant,
                                            ),
                                          ),

                                          const SizedBox(height: 2),

                                          Text(
                                            state.rememberedUsername.isNotEmpty
                                                ? state.rememberedUsername
                                                : 'Saved user',

                                            maxLines: 1,

                                            overflow: TextOverflow.ellipsis,

                                            style: TextStyle(
                                              fontSize: 15,

                                              fontWeight: FontWeight.w700,

                                              color: colors.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Icon(
                                      Icons.check_circle_rounded,

                                      color: colors.primary,

                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        // ======================================
                        // USERNAME
                        // ======================================
                        BlocBuilder<UserBloc, UserState>(
                          buildWhen: (previous, current) {
                            return previous.rememberedUsername !=
                                    current.rememberedUsername ||
                                previous.hasRememberedAccount !=
                                    current.hasRememberedAccount;
                          },

                          builder: (context, state) {
                            return TextFormField(
                              key: ValueKey(
                                'username_${state.hasRememberedAccount}',
                              ),

                              initialValue: state.username,

                              style: TextStyle(color: colors.onSurface),

                              cursorColor: colors.primary,

                              onChanged: (value) {
                                context.read<UserBloc>().add(
                                  UsernameChanged(value),
                                );
                              },

                              decoration: const InputDecoration(
                                labelText: 'Username',

                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),

                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your username';
                                }

                                return null;
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        // ======================================
                        // PASSWORD
                        // ======================================
                        BlocBuilder<UserBloc, UserState>(
                          buildWhen: (previous, current) {
                            return previous.obscurePassword !=
                                    current.obscurePassword ||
                                previous.rememberedPassword !=
                                    current.rememberedPassword ||
                                previous.hasRememberedAccount !=
                                    current.hasRememberedAccount;
                          },

                          builder: (context, state) {
                            return TextFormField(
                              key: ValueKey(
                                'password_${state.hasRememberedAccount}',
                              ),

                              initialValue: state.password,

                              obscureText: state.obscurePassword,

                              style: TextStyle(color: colors.onSurface),

                              cursorColor: colors.primary,

                              onChanged: (value) {
                                context.read<UserBloc>().add(
                                  PasswordChanged(value),
                                );
                              },

                              decoration: InputDecoration(
                                labelText: 'Password',

                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                ),

                                suffixIcon: IconButton(
                                  icon: Icon(
                                    state.obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),

                                  onPressed: () {
                                    context.read<UserBloc>().add(
                                      const TogglePasswordVisibility(),
                                    );
                                  },
                                ),
                              ),

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }

                                return null;
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        // ======================================
                        // REMEMBER ME
                        // ======================================
                        BlocBuilder<UserBloc, UserState>(
                          buildWhen: (previous, current) {
                            return previous.rememberMe != current.rememberMe ||
                                previous.isLoading != current.isLoading;
                          },

                          builder: (context, state) {
                            return Row(
                              children: [
                                Checkbox(
                                  value: state.rememberMe,

                                  onChanged: state.isLoading
                                      ? null
                                      : (value) {
                                          context.read<UserBloc>().add(
                                            RememberMeChanged(value ?? false),
                                          );
                                        },
                                ),

                                Text(
                                  'Remember me',

                                  style: TextStyle(
                                    fontSize: 14,

                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // ======================================
                        // SIGN IN
                        // ======================================
                        BlocBuilder<UserBloc, UserState>(
                          buildWhen: (previous, current) {
                            return previous.isLoading != current.isLoading;
                          },

                          builder: (context, state) {
                            return SizedBox(
                              width: double.infinity,

                              height: 54,

                              child: FilledButton(
                                onPressed: state.isLoading
                                    ? null
                                    : () {
                                        _login(context);
                                      },

                                child: state.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,

                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,

                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Sign In',

                                        style: TextStyle(
                                          fontSize: 16,

                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),

                        // ======================================
                        // BIOMETRICS
                        // ======================================
                        BlocBuilder<UserBloc, UserState>(
                          buildWhen: (previous, current) {
                            return previous.hasFingerprint !=
                                    current.hasFingerprint ||
                                previous.hasFaceAuthentication !=
                                    current.hasFaceAuthentication ||
                                previous.hasIrisAuthentication !=
                                    current.hasIrisAuthentication ||
                                previous.hasRememberedAccount !=
                                    current.hasRememberedAccount ||
                                previous.rememberedPassword !=
                                    current.rememberedPassword ||
                                previous.isLoading != current.isLoading;
                          },

                          builder: (context, state) {
                            final hasBiometrics =
                                state.hasFingerprint ||
                                state.hasFaceAuthentication ||
                                state.hasIrisAuthentication;

                            final canUseRememberedBiometrics =
                                state.hasRememberedAccount &&
                                state.rememberedPassword.isNotEmpty &&
                                hasBiometrics;

                            if (!canUseRememberedBiometrics) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              children: [
                                const SizedBox(height: 22),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: colors.outlineVariant,
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),

                                      child: Text(
                                        'or sign in with',

                                        style: TextStyle(
                                          fontSize: 12,

                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: Divider(
                                        color: colors.outlineVariant,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                Wrap(
                                  alignment: WrapAlignment.center,

                                  spacing: 18,

                                  runSpacing: 12,

                                  children: [
                                    // --------------------------
                                    // FINGERPRINT
                                    // --------------------------

                                    if (state.hasFingerprint)
                                      _BiometricButton(
                                        icon: Icons.fingerprint_rounded,

                                        label: 'Fingerprint',

                                        isLoading: state.isLoading,

                                        onPressed: () {
                                          context.read<UserBloc>().add(
                                            const BiometricAuthRequested(),
                                          );
                                        },
                                      ),

                                    // --------------------------
                                    // FACE
                                    // --------------------------
                                    if (state.hasFaceAuthentication)
                                      _BiometricButton(
                                        icon: Icons.face_retouching_natural,

                                        label: 'Face ID',

                                        isLoading: state.isLoading,

                                        onPressed: () {
                                          context.read<UserBloc>().add(
                                            const BiometricAuthRequested(),
                                          );
                                        },
                                      ),

                                    // --------------------------
                                    // IRIS
                                    // --------------------------
                                    if (state.hasIrisAuthentication)
                                      _BiometricButton(
                                        icon: Icons.remove_red_eye_outlined,

                                        label: 'Iris',

                                        isLoading: state.isLoading,

                                        onPressed: () {
                                          context.read<UserBloc>().add(
                                            const BiometricAuthRequested(),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BIOMETRIC BUTTON
// ============================================================

class _BiometricButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _BiometricButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Material(
          color: colors.primary.withValues(alpha: isDark ? 0.17 : 0.075),

          shape: const CircleBorder(),

          child: InkWell(
            customBorder: const CircleBorder(),

            onTap: isLoading ? null : onPressed,

            child: Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                border: Border.all(
                  color: colors.primary.withValues(alpha: isDark ? 0.24 : 0.11),
                ),
              ),

              child: Icon(
                icon,

                size: 32,

                color: isLoading ? colors.onSurfaceVariant : colors.primary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 7),

        Text(
          label,

          style: TextStyle(
            fontSize: 12,

            fontWeight: FontWeight.w600,

            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
