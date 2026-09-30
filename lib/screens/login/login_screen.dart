import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';

import '../../theme/app_theme.dart';

import '../main/main_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ============================================================
  // LOGIN
  // ============================================================

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
        body: Stack(
          children: [
            // ==================================================
            // BACKGROUND
            // ==================================================

            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF8FAFF),
                      Color(0xFFF3F6FC),
                      Color(0xFFEEF4FF),
                    ],
                  ),
                ),
              ),
            ),

            // ==================================================
            // DECORATIVE BACKGROUND ELEMENTS
            // ==================================================
            Positioned(
              top: -120,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              bottom: -150,
              left: -110,
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ==================================================
            // CONTENT
            // ==================================================
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 32,
                  ),

                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),

                    child: Form(
                      key: _formKey,

                      child: Column(
                        children: [
                          // ====================================
                          // LOGO AREA
                          // ====================================

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 18,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),

                              borderRadius: BorderRadius.circular(24),

                              border: Border.all(color: Colors.white),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),

                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),

                            child: Image.asset(
                              'assets/images/codex_logo.png',
                              width: 210,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ====================================
                          // LOGIN CARD
                          // ====================================
                          Container(
                            width: double.infinity,

                            padding: const EdgeInsets.all(28),

                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.96),

                              borderRadius: BorderRadius.circular(28),

                              border: Border.all(color: Colors.white),

                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1E3A8A)
                                      .withValues(alpha: 0.07),

                                  blurRadius: 40,

                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                // ==============================
                                // HEADER
                                // ==============================

                                Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,

                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),

                                        borderRadius: BorderRadius.circular(14),
                                      ),

                                      child: const Icon(
                                        Icons.lock_person_rounded,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            'Welcome back',
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                              letterSpacing: -0.6,
                                            ),
                                          ),

                                          SizedBox(height: 4),

                                          Text(
                                            'Sign in to your CODEX workspace',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                // ==============================
                                // REMEMBERED ACCOUNT
                                // ==============================
                                BlocBuilder<UserBloc, UserState>(
                                  buildWhen: (previous, current) {
                                    return previous.hasRememberedAccount !=
                                            current.hasRememberedAccount ||
                                        previous.rememberedUsername !=
                                            current.rememberedUsername;
                                  },

                                  builder: (context, state) {
                                    if (!state.hasRememberedAccount) {
                                      return const SizedBox(height: 28);
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        top: 24,
                                        bottom: 2,
                                      ),

                                      child: Container(
                                        width: double.infinity,

                                        padding: const EdgeInsets.all(15),

                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0F7FF),

                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),

                                          border: Border.all(
                                            color: const Color(0xFFD8E9FF),
                                          ),
                                        ),

                                        child: Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,

                                              decoration: BoxDecoration(
                                                color: Colors.white,

                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),

                                              child: const Icon(
                                                Icons.person_rounded,
                                                color: AppColors.primary,
                                              ),
                                            ),

                                            const SizedBox(width: 12),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,

                                                children: [
                                                  const Text(
                                                    'Remembered account',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 3),

                                                  Text(
                                                    state
                                                            .rememberedUsername
                                                            .isNotEmpty
                                                        ? state
                                                              .rememberedUsername
                                                        : 'Saved user',

                                                    overflow:
                                                        TextOverflow.ellipsis,

                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(width: 10),

                                            Container(
                                              width: 30,
                                              height: 30,

                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),

                                              child: const Icon(
                                                Icons.check_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 26),

                                // ==============================
                                // USERNAME
                                // ==============================
                                const _FieldLabel(text: 'Username'),

                                const SizedBox(height: 8),

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

                                      textInputAction: TextInputAction.next,

                                      autofillHints: const [
                                        AutofillHints.username,
                                      ],

                                      onChanged: (value) {
                                        context.read<UserBloc>().add(
                                          UsernameChanged(value),
                                        );
                                      },

                                      decoration: const InputDecoration(
                                        hintText: 'Enter your username',

                                        prefixIcon: Icon(
                                          Icons.person_outline_rounded,
                                        ),
                                      ),

                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter your username';
                                        }

                                        return null;
                                      },
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                // ==============================
                                // PASSWORD
                                // ==============================
                                const _FieldLabel(text: 'Password'),

                                const SizedBox(height: 8),

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

                                      textInputAction: TextInputAction.done,

                                      autofillHints: const [
                                        AutofillHints.password,
                                      ],

                                      onFieldSubmitted: (_) {
                                        if (!state.isLoading) {
                                          _login(context);
                                        }
                                      },

                                      onChanged: (value) {
                                        context.read<UserBloc>().add(
                                          PasswordChanged(value),
                                        );
                                      },

                                      decoration: InputDecoration(
                                        hintText: 'Enter your password',

                                        prefixIcon: const Icon(
                                          Icons.lock_outline_rounded,
                                        ),

                                        suffixIcon: IconButton(
                                          tooltip: state.obscurePassword
                                              ? 'Show password'
                                              : 'Hide password',

                                          onPressed: () {
                                            context.read<UserBloc>().add(
                                              const TogglePasswordVisibility(),
                                            );
                                          },

                                          icon: Icon(
                                            state.obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                          ),
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

                                // ==============================
                                // REMEMBER ME
                                // ==============================
                                BlocBuilder<UserBloc, UserState>(
                                  buildWhen: (previous, current) {
                                    return previous.rememberMe !=
                                            current.rememberMe ||
                                        previous.isLoading != current.isLoading;
                                  },

                                  builder: (context, state) {
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(12),

                                      onTap: state.isLoading
                                          ? null
                                          : () {
                                              context.read<UserBloc>().add(
                                                RememberMeChanged(
                                                  !state.rememberMe,
                                                ),
                                              );
                                            },

                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),

                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: state.rememberMe,

                                              onChanged: state.isLoading
                                                  ? null
                                                  : (value) {
                                                      context
                                                          .read<UserBloc>()
                                                          .add(
                                                            RememberMeChanged(
                                                              value ?? false,
                                                            ),
                                                          );
                                                    },
                                            ),

                                            const SizedBox(width: 2),

                                            const Text(
                                              'Remember me',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                // ==============================
                                // SIGN IN BUTTON
                                // ==============================
                                BlocBuilder<UserBloc, UserState>(
                                  buildWhen: (previous, current) {
                                    return previous.isLoading !=
                                        current.isLoading;
                                  },

                                  builder: (context, state) {
                                    return FilledButton(
                                      onPressed: state.isLoading
                                          ? null
                                          : () {
                                              _login(context);
                                            },

                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),

                                        child: state.isLoading
                                            ? const SizedBox(
                                                key: ValueKey('loader'),
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.3,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Row(
                                                key: ValueKey('signin'),
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text('Sign In'),
                                                  SizedBox(width: 8),
                                                  Icon(
                                                    Icons.arrow_forward_rounded,
                                                    size: 19,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    );
                                  },
                                ),

                                // ==============================
                                // BIOMETRICS
                                // ==============================
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

                                    final canUseBiometrics =
                                        state.hasRememberedAccount &&
                                        state.rememberedPassword.isNotEmpty &&
                                        hasBiometrics;

                                    if (!canUseBiometrics) {
                                      return const SizedBox.shrink();
                                    }

                                    return Column(
                                      children: [
                                        const SizedBox(height: 26),

                                        const _AuthDivider(),

                                        const SizedBox(height: 20),

                                        const Text(
                                          'Quick secure sign in',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),

                                        const SizedBox(height: 14),

                                        Wrap(
                                          alignment: WrapAlignment.center,

                                          spacing: 10,
                                          runSpacing: 10,

                                          children: [
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

                                            if (state.hasFaceAuthentication)
                                              _BiometricButton(
                                                icon: Icons
                                                    .face_retouching_natural_rounded,

                                                label: 'Face',

                                                isLoading: state.isLoading,

                                                onPressed: () {
                                                  context.read<UserBloc>().add(
                                                    const BiometricAuthRequested(),
                                                  );
                                                },
                                              ),

                                            if (state.hasIrisAuthentication)
                                              _BiometricButton(
                                                icon: Icons.visibility_rounded,

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
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ====================================
                          // FOOTER
                          // ====================================
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                size: 15,
                                color: AppColors.textSecondary,
                              ),

                              SizedBox(width: 6),

                              Text(
                                'Secure CODEX workspace',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
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
}

// ============================================================
// FIELD LABEL
// ============================================================

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ============================================================
// DIVIDER
// ============================================================

class _AuthDivider extends StatelessWidget {
  const _AuthDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        Expanded(child: Divider()),
      ],
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
    return Material(
      color: const Color(0xFFF5F8FF),

      borderRadius: BorderRadius.circular(16),

      child: InkWell(
        onTap: isLoading ? null : onPressed,

        borderRadius: BorderRadius.circular(16),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

          child: Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              Icon(icon, size: 23, color: AppColors.primary),

              const SizedBox(width: 8),

              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
