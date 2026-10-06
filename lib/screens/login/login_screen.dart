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

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    final state = context.read<UserBloc>().state;

    _usernameController = TextEditingController(
      text: state.hasRememberedAccount ? '' : state.username,
    );

    _passwordController = TextEditingController();
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

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
        // ====================================================
        // ERROR
        // ====================================================

        if (state.errorMessage != null) {
          _showMessage(state.errorMessage!);

          return;
        }

        // ====================================================
        // SUCCESS
        // ====================================================

        if (state.authStatus == AuthStatus.authenticated) {
          TextInput.finishAutofillContext(shouldSave: true);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      },

      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),

              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),

                child: BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    return Container(
                      width: double.infinity,

                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),

                      decoration: BoxDecoration(
                        color: isDark
                            ? colors.surfaceContainerHigh
                            : colors.surface,

                        borderRadius: BorderRadius.circular(26),

                        border: Border.all(color: colors.outlineVariant),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.24 : 0.06,
                            ),

                            blurRadius: 24,

                            offset: const Offset(0, 10),
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
      ),
    );
  }

  // ==========================================================
  // REMEMBERED ACCOUNT LOGIN
  // ==========================================================

  Widget _buildRememberedAccount(UserState state, ColorScheme colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        // ------------------------------------------------------
        // LOGO
        // ------------------------------------------------------

        ClipRRect(
          borderRadius: BorderRadius.circular(22),

          child: Image.asset(
            'assets/images/codex_logo.png',

            width: 225,

            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 30),

        // ------------------------------------------------------
        // WELCOME
        // ------------------------------------------------------
        Text(
          'Welcome back',

          style: TextStyle(
            fontSize: 29,

            fontWeight: FontWeight.w800,

            letterSpacing: -0.6,

            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          state.authStatus == AuthStatus.sessionExpired
              ? 'Your session expired. Verify your identity to continue.'
              : 'Verify your identity to continue',

          textAlign: TextAlign.center,

          style: TextStyle(
            fontSize: 14,

            height: 1.4,

            color: colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 26),

        // ------------------------------------------------------
        // REMEMBERED ACCOUNT
        // ------------------------------------------------------
        Container(
          width: double.infinity,

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.07),

            borderRadius: BorderRadius.circular(18),

            border: Border.all(color: colors.primary.withValues(alpha: 0.16)),
          ),

          child: Row(
            children: [
              Container(
                width: 48,

                height: 48,

                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),

                  shape: BoxShape.circle,
                ),

                child: Icon(
                  Icons.person_outline_rounded,

                  color: colors.primary,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Remembered account',

                      style: TextStyle(
                        fontSize: 11,

                        fontWeight: FontWeight.w600,

                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      state.rememberedUsername,

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

              Icon(Icons.verified_user_rounded, color: colors.primary),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // ------------------------------------------------------
        // SINGLE BIOMETRIC ACTION
        // ------------------------------------------------------
        Material(
          color: Colors.transparent,

          child: InkWell(
            onTap: state.isLoading ? null : _biometricLogin,

            customBorder: const CircleBorder(),

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),

              width: 112,

              height: 112,

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
                          color: colors.primary.withValues(alpha: 0.13),

                          blurRadius: 26,

                          spreadRadius: 2,
                        ),
                      ],
              ),

              child: Center(
                child: state.isLoading
                    ? SizedBox(
                        width: 36,

                        height: 36,

                        child: CircularProgressIndicator(
                          strokeWidth: 3,

                          color: colors.primary,
                        ),
                      )
                    : Icon(
                        _biometricIcon(state),

                        size: 55,

                        color: colors.primary,
                      ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 17),

        // ------------------------------------------------------
        // BIOMETRIC TITLE
        // ------------------------------------------------------
        Text(
          state.isLoading ? 'Verifying identity...' : _biometricTitle(state),

          textAlign: TextAlign.center,

          style: TextStyle(
            fontSize: 17,

            fontWeight: FontWeight.w700,

            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          state.isLoading
              ? 'Complete the verification on your device.'
              : 'Tap the icon to securely sign in',

          textAlign: TextAlign.center,

          style: TextStyle(
            fontSize: 12,

            fontWeight: FontWeight.w500,

            color: colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 15),

        // ------------------------------------------------------
        // OS SECURITY INFO
        // ------------------------------------------------------
        Container(
          width: double.infinity,

          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.45),

            borderRadius: BorderRadius.circular(14),

            border: Border.all(color: colors.outlineVariant),
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Icon(Icons.security_rounded, size: 19, color: colors.primary),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  'Fingerprint or face verification is handled securely '
                  'by your phone. CODEX never receives your biometric data.',

                  style: TextStyle(
                    fontSize: 10.5,

                    height: 1.45,

                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        Divider(color: colors.outlineVariant),

        const SizedBox(height: 8),

        // ------------------------------------------------------
        // USE ANOTHER ACCOUNT
        // ------------------------------------------------------
        TextButton.icon(
          onPressed: state.isLoading ? null : _useAnotherAccount,

          icon: const Icon(Icons.person_add_alt_1_outlined),

          label: const Text('Use another account'),
        ),

        const SizedBox(height: 2),

        Text(
          'This removes the remembered account from this device.',

          textAlign: TextAlign.center,

          style: TextStyle(fontSize: 10.5, color: colors.onSurfaceVariant),
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
            // --------------------------------------------------
            // LOGO
            // --------------------------------------------------

            ClipRRect(
              borderRadius: BorderRadius.circular(22),

              child: Image.asset(
                'assets/images/codex_logo.png',

                width: 225,

                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 28),

            // --------------------------------------------------
            // TITLE
            // --------------------------------------------------
            Text(
              'Sign in',

              style: TextStyle(
                fontSize: 29,

                fontWeight: FontWeight.w800,

                letterSpacing: -0.6,

                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Access your CODEX workspace',

              textAlign: TextAlign.center,

              style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
            ),

            const SizedBox(height: 28),

            // --------------------------------------------------
            // USERNAME
            // --------------------------------------------------
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

                border: OutlineInputBorder(),
              ),

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your username';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // --------------------------------------------------
            // PASSWORD
            // --------------------------------------------------
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

                border: const OutlineInputBorder(),

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

            const SizedBox(height: 8),

            // --------------------------------------------------
            // REMEMBER ME
            // --------------------------------------------------
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
                      fontSize: 13,

                      fontWeight: FontWeight.w500,

                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // --------------------------------------------------
            // SIGN IN BUTTON
            // --------------------------------------------------
            SizedBox(
              width: double.infinity,

              height: 52,

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

                          SizedBox(width: 10),

                          Text('Signing in...'),
                        ],
                      )
                    : const Text(
                        'Sign In',

                        style: TextStyle(
                          fontSize: 15,

                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // --------------------------------------------------
            // BIOMETRIC INFO
            // --------------------------------------------------
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.55),

                borderRadius: BorderRadius.circular(16),

                border: Border.all(color: colors.outlineVariant),
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.lock_person_rounded,

                    size: 22,

                    color: colors.primary,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'Enable Remember me during a successful login '
                      'to use biometric authentication the next time '
                      'you open the app.',

                      style: TextStyle(
                        fontSize: 11,

                        height: 1.45,

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
  // BIOMETRIC ICON
  // ==========================================================

  IconData _biometricIcon(UserState state) {
    // --------------------------------------------------------
    // MULTIPLE TYPES
    // --------------------------------------------------------
    //
    // If the phone reports both fingerprint and face,
    // don't pretend that our app lets the user choose.
    //
    // The operating system controls which biometric
    // verification method is used.
    // --------------------------------------------------------

    if (state.hasFingerprint && state.hasFaceAuthentication) {
      return Icons.lock_person_rounded;
    }

    // --------------------------------------------------------
    // FACE ONLY
    // --------------------------------------------------------

    if (state.hasFaceAuthentication) {
      return Icons.face_retouching_natural;
    }

    // --------------------------------------------------------
    // FINGERPRINT ONLY
    // --------------------------------------------------------

    if (state.hasFingerprint) {
      return Icons.fingerprint_rounded;
    }

    // --------------------------------------------------------
    // GENERIC BIOMETRIC
    // --------------------------------------------------------
    //
    // Some Android devices report generic strong/weak
    // biometrics rather than an exact type.
    // --------------------------------------------------------

    return Icons.lock_person_rounded;
  }

  // ==========================================================
  // BIOMETRIC TITLE
  // ==========================================================

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

    return 'Continue with biometrics';
  }
}
