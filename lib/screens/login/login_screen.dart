import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';

import '../main/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameController;

  late final TextEditingController _passwordController;

  bool _obscurePassword = true;

  bool _showRememberedPassword = false;

  @override
  void initState() {
    super.initState();

    final state = context.read<UserBloc>().state;

    _usernameController = TextEditingController(
      text: state.hasRememberedAccount ? '' : state.username,
    );

    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();

    _passwordController.dispose();

    super.dispose();
  }

  // ==========================================================
  // NORMAL LOGIN
  // ==========================================================

  void _login() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() != true) {
      return;
    }

    context.read<UserBloc>().add(
      UserLoginRequested(
        username: _usernameController.text.trim(),

        password: _passwordController.text,
      ),
    );
  }

  // ==========================================================
  // REMEMBERED ACCOUNT PASSWORD LOGIN
  // ==========================================================

  void _rememberedPasswordLogin(UserState state) {
    FocusScope.of(context).unfocus();

    final password = _passwordController.text;

    if (password.isEmpty) {
      _showMessage('Please enter your password');

      return;
    }

    final username = state.rememberedUsername.trim();

    if (username.isEmpty) {
      _showMessage('No remembered account is available.');

      return;
    }

    context.read<UserBloc>().add(
      UserLoginRequested(username: username, password: password),
    );
  }

  // ==========================================================
  // BIOMETRIC LOGIN
  // ==========================================================

  void _biometricLogin() {
    final state = context.read<UserBloc>().state;

    if (!state.hasRememberedAccount ||
        state.rememberedUsername.trim().isEmpty) {
      _showMessage(
        'Sign in once with Remember me enabled before using biometric login.',
      );

      return;
    }

    context.read<UserBloc>().add(const BiometricAuthRequested());
  }

  // ==========================================================
  // USE ANOTHER ACCOUNT
  // ==========================================================

  void _useAnotherAccount() {
    _usernameController.clear();

    _passwordController.clear();

    setState(() {
      _obscurePassword = true;

      _showRememberedPassword = false;
    });

    context.read<UserBloc>().add(const UseAnotherAccountRequested());
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

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
          _showMessage(state.errorMessage!);

          return;
        }

        if (state.authStatus == AuthStatus.authenticated) {
          TextInput.finishAutofillContext(shouldSave: true);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      },

      child: Scaffold(
        resizeToAvoidBottomInset: false,

        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = (constraints.maxWidth - 32)
                  .clamp(0.0, 460.0)
                  .toDouble();

              final availableHeight = (constraints.maxHeight - 24)
                  .clamp(0.0, double.infinity)
                  .toDouble();

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,

                  vertical: 12,
                ),

                child: Center(
                  child: SizedBox(
                    width: availableWidth,

                    height: availableHeight,

                    child: FittedBox(
                      fit: BoxFit.scaleDown,

                      alignment: Alignment.center,

                      child: SizedBox(
                        width: availableWidth,

                        child: BlocBuilder<UserBloc, UserState>(
                          builder: (context, state) {
                            return Container(
                              width: double.infinity,

                              padding: const EdgeInsets.fromLTRB(
                                22,
                                22,
                                22,
                                20,
                              ),

                              decoration: BoxDecoration(
                                color: isDark
                                    ? colors.surfaceContainerHigh
                                    : colors.surface,

                                borderRadius: BorderRadius.circular(24),

                                border: Border.all(
                                  color: colors.outlineVariant,
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.22 : 0.055,
                                    ),

                                    blurRadius: 22,

                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),

                              child: state.hasRememberedAccount
                                  ? _buildRememberedAccount(state, colors)
                                  : _buildNormalLogin(state, colors),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // REMEMBERED ACCOUNT
  // ==========================================================

  Widget _buildRememberedAccount(UserState state, ColorScheme colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),

          child: Image.asset(
            'assets/images/codex_logo.png',

            width: 185,

            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Welcome back',

          style: TextStyle(
            fontSize: 26,

            fontWeight: FontWeight.w800,

            letterSpacing: -0.55,

            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          state.authStatus == AuthStatus.sessionExpired
              ? 'Your session expired. Verify your identity to continue.'
              : 'Verify your identity to continue',

          textAlign: TextAlign.center,

          style: TextStyle(
            fontSize: 12.5,

            height: 1.35,

            color: colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 18),

        // ======================================================
        // REMEMBERED ACCOUNT CARD
        // ======================================================
        Container(
          width: double.infinity,

          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.065),

            borderRadius: BorderRadius.circular(16),

            border: Border.all(color: colors.primary.withValues(alpha: 0.14)),
          ),

          child: Row(
            children: [
              Container(
                width: 42,

                height: 42,

                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.11),

                  shape: BoxShape.circle,
                ),

                child: Icon(
                  Icons.person_outline_rounded,

                  size: 21,

                  color: colors.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Remembered account',

                      style: TextStyle(
                        fontSize: 10.5,

                        fontWeight: FontWeight.w600,

                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      state.rememberedUsername,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 14.5,

                        fontWeight: FontWeight.w700,

                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.verified_user_rounded,

                size: 21,

                color: colors.primary,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        if (!_showRememberedPassword) ...[
          // ====================================================
          // SMALLER BIOMETRIC BUTTON
          // ====================================================

          Material(
            color: Colors.transparent,

            child: InkWell(
              onTap: state.isLoading ? null : _biometricLogin,

              customBorder: const CircleBorder(),

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),

                width: 86,

                height: 86,

                decoration: BoxDecoration(
                  color: colors.primary.withValues(
                    alpha: state.isLoading ? 0.06 : 0.10,
                  ),

                  shape: BoxShape.circle,

                  border: Border.all(
                    color: colors.primary.withValues(
                      alpha: state.isLoading ? 0.12 : 0.24,
                    ),

                    width: 2,
                  ),

                  boxShadow: state.isLoading
                      ? null
                      : [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.12),

                            blurRadius: 20,

                            spreadRadius: 1,
                          ),
                        ],
                ),

                child: Center(
                  child: state.isLoading
                      ? SizedBox(
                          width: 28,

                          height: 28,

                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,

                            color: colors.primary,
                          ),
                        )
                      : Icon(
                          _biometricIcon(state),

                          size: 40,

                          color: colors.primary,
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 11),

          Text(
            state.isLoading ? 'Verifying identity...' : _biometricTitle(state),

            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 15.5,

              fontWeight: FontWeight.w700,

              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            state.isLoading
                ? 'Complete the verification on your device.'
                : 'Tap the icon to securely sign in',

            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 11,

              fontWeight: FontWeight.w500,

              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(child: Divider(color: colors.outlineVariant)),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),

                child: Text(
                  'or',

                  style: TextStyle(
                    fontSize: 10.5,

                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),

              Expanded(child: Divider(color: colors.outlineVariant)),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 46,

            width: double.infinity,

            child: OutlinedButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () {
                      setState(() {
                        _passwordController.clear();

                        _obscurePassword = true;

                        _showRememberedPassword = true;
                      });
                    },

              icon: const Icon(Icons.password_rounded, size: 18),

              label: const Text('Sign in with password'),
            ),
          ),
        ] else ...[
          Text(
            'Sign in with password',

            style: TextStyle(
              fontSize: 16,

              fontWeight: FontWeight.w800,

              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Enter the password for ${state.rememberedUsername}.',

            textAlign: TextAlign.center,

            style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
          ),

          const SizedBox(height: 14),

          AutofillGroup(
            child: TextFormField(
              controller: _passwordController,

              enabled: !state.isLoading,

              obscureText: _obscurePassword,

              textInputAction: TextInputAction.done,

              autocorrect: false,

              enableSuggestions: false,

              autofillHints: const [AutofillHints.password],

              onFieldSubmitted: (_) {
                if (!state.isLoading) {
                  _rememberedPasswordLogin(state);
                }
              },

              decoration: InputDecoration(
                labelText: 'Password',

                hintText: 'Enter your password',

                prefixIcon: const Icon(Icons.lock_outline_rounded),

                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',

                  onPressed: state.isLoading
                      ? null
                      : () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },

                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,

            height: 48,

            child: FilledButton(
              onPressed: state.isLoading
                  ? null
                  : () {
                      _rememberedPasswordLogin(state);
                    },

              child: state.isLoading
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        SizedBox(
                          width: 18,

                          height: 18,

                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),

                        SizedBox(width: 9),

                        Text('Signing in...'),
                      ],
                    )
                  : const Text('Sign in with password'),
            ),
          ),

          const SizedBox(height: 8),

          TextButton.icon(
            onPressed: state.isLoading
                ? null
                : () {
                    setState(() {
                      _passwordController.clear();

                      _showRememberedPassword = false;
                    });
                  },

            icon: Icon(_biometricIcon(state), size: 18),

            label: const Text('Use biometrics instead'),
          ),
        ],

        const SizedBox(height: 12),

        Container(
          width: double.infinity,

          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.40),

            borderRadius: BorderRadius.circular(13),
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Icon(
                _showRememberedPassword
                    ? Icons.lock_outline_rounded
                    : Icons.security_rounded,

                size: 18,

                color: colors.primary,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  _showRememberedPassword
                      ? 'Your password is sent only to the CODEX server for authentication.'
                      : 'Biometric verification is handled by your phone. CODEX never receives your biometric data.',

                  style: TextStyle(
                    fontSize: 10,

                    height: 1.35,

                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        TextButton.icon(
          onPressed: state.isLoading ? null : _useAnotherAccount,

          icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),

          label: const Text('Use another account'),
        ),
      ],
    );
  }

  // ==========================================================
  // NORMAL LOGIN
  // ==========================================================

  Widget _buildNormalLogin(UserState state, ColorScheme colors) {
    return AutofillGroup(
      child: Form(
        key: _formKey,

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),

              child: Image.asset(
                'assets/images/codex_logo.png',

                width: 185,

                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 19),

            Text(
              'Sign in',

              style: TextStyle(
                fontSize: 26,

                fontWeight: FontWeight.w800,

                letterSpacing: -0.55,

                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Access your CODEX workspace',

              textAlign: TextAlign.center,

              style: TextStyle(fontSize: 12.5, color: colors.onSurfaceVariant),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _usernameController,

              enabled: !state.isLoading,

              autofillHints: const [AutofillHints.username],

              textInputAction: TextInputAction.next,

              keyboardType: TextInputType.text,

              autocorrect: false,

              enableSuggestions: false,

              decoration: const InputDecoration(
                labelText: 'Username',

                hintText: 'Enter your username',

                prefixIcon: Icon(Icons.person_outline_rounded),
              ),

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your username';
                }

                return null;
              },
            ),

            const SizedBox(height: 13),

            TextFormField(
              controller: _passwordController,

              enabled: !state.isLoading,

              autofillHints: const [AutofillHints.password],

              textInputAction: TextInputAction.done,

              obscureText: _obscurePassword,

              autocorrect: false,

              enableSuggestions: false,

              onFieldSubmitted: (_) {
                if (!state.isLoading) {
                  _login();
                }
              },

              decoration: InputDecoration(
                labelText: 'Password',

                hintText: 'Enter your password',

                prefixIcon: const Icon(Icons.lock_outline_rounded),

                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',

                  onPressed: state.isLoading
                      ? null
                      : () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },

                  icon: Icon(
                    _obscurePassword
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
            ),

            const SizedBox(height: 4),

            Row(
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

                Expanded(
                  child: Text(
                    'Remember me',

                    style: TextStyle(
                      fontSize: 12.5,

                      fontWeight: FontWeight.w500,

                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,

              height: 50,

              child: FilledButton(
                onPressed: state.isLoading ? null : _login,

                child: state.isLoading
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          SizedBox(
                            width: 18,

                            height: 18,

                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),

                          SizedBox(width: 9),

                          Text('Signing in...'),
                        ],
                      )
                    : const Text(
                        'Sign In',

                        style: TextStyle(
                          fontSize: 14.5,

                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 13),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.42),

                borderRadius: BorderRadius.circular(13),
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.lock_person_rounded,

                    size: 19,

                    color: colors.primary,
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: Text(
                      'Enable Remember me to use biometric authentication or quick password login next time.',

                      style: TextStyle(
                        fontSize: 10.2,

                        height: 1.35,

                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // BIOMETRIC HELPERS
  // ==========================================================

  IconData _biometricIcon(UserState state) {
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

  String _biometricTitle(UserState state) {
    if (state.hasFingerprint && state.hasFaceAuthentication) {
      return 'Verify your identity';
    }

    if (state.hasFaceAuthentication) {
      return 'Continue with face verification';
    }

    if (state.hasFingerprint) {
      return 'Continue with fingerprint';
    }

    if (state.hasIrisAuthentication) {
      return 'Continue with iris verification';
    }

    return 'Continue with biometrics';
  }
}
