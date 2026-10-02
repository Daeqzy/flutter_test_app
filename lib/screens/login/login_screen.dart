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

  // ==========================================================
  // BIOMETRIC LOGIN
  // ==========================================================

  void _biometricLogin(BuildContext context) {
    final state = context.read<UserBloc>().state;

    if (!state.hasRememberedAccount ||
        state.rememberedUsername.trim().isEmpty ||
        state.rememberedPassword.isEmpty) {
      _showBiometricMessage(
        context,
        'Sign in once with Remember me enabled '
        'before using biometric login.',
      );

      return;
    }

    context.read<UserBloc>().add(const BiometricAuthRequested());
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showBiometricMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
        // ======================================================
        // ERROR
        // ======================================================

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));

          return;
        }

        // ======================================================
        // SUCCESS
        // ======================================================

        if (state.authStatus == AuthStatus.authenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      },

      child: Scaffold(
        appBar: AppBar(title: const Text('CODEX Computers')),

        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),

              child: Form(
                key: _formKey,

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    // ==========================================
                    // LOGO
                    // ==========================================

                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),

                      child: Image.asset(
                        'assets/images/codex_logo.png',

                        width: 280,

                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==========================================
                    // TITLE
                    // ==========================================
                    const Text(
                      'Welcome Back',

                      style: TextStyle(
                        fontSize: 32,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Sign in to continue',

                      style: TextStyle(fontSize: 16),
                    ),

                    // ==========================================
                    // REMEMBERED ACCOUNT
                    // ==========================================
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
                          padding: const EdgeInsets.only(top: 20),

                          child: Container(
                            width: double.infinity,

                            padding: const EdgeInsets.all(16),

                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),

                              borderRadius: BorderRadius.circular(14),

                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),

                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Color(0xFFDBEAFE),

                                  child: Icon(
                                    Icons.person_outline_rounded,

                                    color: Color(0xFF2563EB),
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
                                          fontSize: 13,

                                          color: Color(0xFF64748B),
                                        ),
                                      ),

                                      const SizedBox(height: 2),

                                      Text(
                                        state.rememberedUsername.isNotEmpty
                                            ? state.rememberedUsername
                                            : 'Saved user',

                                        style: const TextStyle(
                                          fontSize: 15,

                                          fontWeight: FontWeight.w600,

                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(
                                  Icons.verified_user_rounded,

                                  color: Color(0xFF2563EB),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // ==========================================
                    // USERNAME
                    // ==========================================
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
                            'username_'
                            '${state.hasRememberedAccount}',
                          ),

                          initialValue: state.username,

                          onChanged: (value) {
                            context.read<UserBloc>().add(
                              UsernameChanged(value),
                            );
                          },

                          decoration: const InputDecoration(
                            labelText: 'Username',

                            prefixIcon: Icon(Icons.person_outline),

                            border: OutlineInputBorder(),
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

                    const SizedBox(height: 20),

                    // ==========================================
                    // PASSWORD
                    // ==========================================
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
                            'password_'
                            '${state.hasRememberedAccount}',
                          ),

                          initialValue: state.password,

                          obscureText: state.obscurePassword,

                          onChanged: (value) {
                            context.read<UserBloc>().add(
                              PasswordChanged(value),
                            );
                          },

                          decoration: InputDecoration(
                            labelText: 'Password',

                            prefixIcon: const Icon(Icons.lock_outline),

                            border: const OutlineInputBorder(),

                            suffixIcon: IconButton(
                              icon: Icon(
                                state.obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
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

                    const SizedBox(height: 12),

                    // ==========================================
                    // REMEMBER ME
                    // ==========================================
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

                            const Text(
                              'Remember me',

                              style: TextStyle(
                                fontSize: 14,

                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // ==========================================
                    // SIGN IN
                    // ==========================================
                    BlocBuilder<UserBloc, UserState>(
                      buildWhen: (previous, current) {
                        return previous.isLoading != current.isLoading;
                      },

                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity,

                          height: 50,

                          child: ElevatedButton(
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
                                    ),
                                  )
                                : const Text(
                                    'Sign In',

                                    style: TextStyle(
                                      fontSize: 16,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),

                    // ==========================================
                    // BIOMETRIC LOGIN
                    // ==========================================
                    BlocBuilder<UserBloc, UserState>(
                      buildWhen: (previous, current) {
                        return previous.hasRememberedAccount !=
                                current.hasRememberedAccount ||
                            previous.rememberedUsername !=
                                current.rememberedUsername ||
                            previous.rememberedPassword !=
                                current.rememberedPassword ||
                            previous.isLoading != current.isLoading;
                      },

                      builder: (context, state) {
                        return Column(
                          children: [
                            const SizedBox(height: 22),

                            // ==================================
                            // DIVIDER
                            // ==================================
                            Row(
                              children: [
                                const Expanded(child: Divider()),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),

                                  child: Text(
                                    'or sign in with',

                                    style: TextStyle(
                                      fontSize: 13,

                                      fontWeight: FontWeight.w500,

                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ),

                                const Expanded(child: Divider()),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // ==================================
                            // ALWAYS VISIBLE
                            // ==================================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                // ==============================
                                // FINGERPRINT
                                // ==============================

                                _BiometricButton(
                                  icon: Icons.fingerprint_rounded,

                                  label: 'Fingerprint',

                                  isLoading: state.isLoading,

                                  onPressed: () {
                                    _biometricLogin(context);
                                  },
                                ),

                                const SizedBox(width: 36),

                                // ==============================
                                // FACE ID
                                // ==============================
                                _BiometricButton(
                                  icon: Icons.face_retouching_natural,

                                  label: 'Face ID',

                                  isLoading: state.isLoading,

                                  onPressed: () {
                                    _biometricLogin(context);
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // ==================================
                            // INFORMATION
                            // ==================================
                            if (state.hasRememberedAccount)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  Icon(
                                    Icons.verified_user_outlined,

                                    size: 14,

                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),

                                  const SizedBox(width: 5),

                                  Flexible(
                                    child: Text(
                                      'Verify to sign in as '
                                      '${state.rememberedUsername}',

                                      textAlign: TextAlign.center,

                                      overflow: TextOverflow.ellipsis,

                                      style: TextStyle(
                                        fontSize: 11,

                                        fontWeight: FontWeight.w600,

                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                'Biometric login becomes available '
                                'after you sign in with '
                                'Remember me enabled.',

                                textAlign: TextAlign.center,

                                style: TextStyle(
                                  fontSize: 11,

                                  height: 1.4,

                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 25),
                  ],
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
          color: isDark
              ? colors.primary.withValues(alpha: 0.14)
              : const Color(0xFFEFF6FF),

          shape: const CircleBorder(),

          child: InkWell(
            customBorder: const CircleBorder(),

            onTap: isLoading ? null : onPressed,

            child: Padding(
              padding: const EdgeInsets.all(14),

              child: Icon(icon, size: 34, color: colors.primary),
            ),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          label,

          style: TextStyle(
            fontSize: 12,

            fontWeight: FontWeight.w500,

            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
