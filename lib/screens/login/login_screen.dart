import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';

import '../main/main_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ----------------------------------------------------------
  // NORMAL LOGIN
  // ----------------------------------------------------------

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
        return previous.loginSuccess != current.loginSuccess ||
            previous.errorMessage != current.errorMessage;
      },

      listener: (context, state) {
        // ----------------------------------------------------
        // SUCCESS
        // ----------------------------------------------------

        if (state.loginSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );

          return;
        }

        // ----------------------------------------------------
        // ERROR
        // ----------------------------------------------------

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
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
                    // ========================================
                    // LOGO
                    // ========================================

                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),

                      child: Image.asset(
                        'assets/images/codex_logo.png',
                        width: 280,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ========================================
                    // TITLE
                    // ========================================
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

                    // ========================================
                    // REMEMBERED ACCOUNT
                    // ========================================
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
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF2563EB),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // ========================================
                    // USERNAME
                    // ========================================
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

                    // ========================================
                    // PASSWORD
                    // ========================================
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

                    // ========================================
                    // REMEMBER ME
                    // ========================================
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

                    // ========================================
                    // SIGN IN
                    // ========================================
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

                    // ========================================
                    // BIOMETRICS
                    // ========================================
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
                            const SizedBox(height: 20),

                            Text(
                              'or sign in with',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Wrap(
                              alignment: WrapAlignment.center,

                              spacing: 18,

                              runSpacing: 12,

                              children: [
                                // ----------------------------
                                // FINGERPRINT
                                // ----------------------------

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

                                // ----------------------------
                                // FACE ID / FACE
                                // ----------------------------
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

                                // ----------------------------
                                // IRIS
                                // ----------------------------
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
    return Column(
      children: [
        Material(
          color: const Color(0xFFEFF6FF),

          shape: const CircleBorder(),

          child: InkWell(
            customBorder: const CircleBorder(),

            onTap: isLoading ? null : onPressed,

            child: Padding(
              padding: const EdgeInsets.all(14),

              child: Icon(icon, size: 34, color: const Color(0xFF2563EB)),
            ),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}
