import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common/app_section_header.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _currentPasswordController;

  late final TextEditingController _newPasswordController;

  late final TextEditingController _confirmPasswordController;

  bool _obscureCurrentPassword = true;

  bool _obscureNewPassword = true;

  bool _obscureConfirmPassword = true;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _currentPasswordController = TextEditingController();

    _newPasswordController = TextEditingController();

    _confirmPasswordController = TextEditingController();

    context.read<UserBloc>().add(const ResetPasswordChangeState());
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _currentPasswordController.dispose();

    _newPasswordController.dispose();

    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ==========================================================
  // SUBMIT
  // ==========================================================

  void _submit() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() != true) {
      return;
    }

    context.read<UserBloc>().add(
      ChangePasswordRequested(
        currentPassword: _currentPasswordController.text,

        newPassword: _newPasswordController.text,
      ),
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
        return previous.passwordChangeStatus != current.passwordChangeStatus;
      },

      listener: (context, state) {
        if (state.passwordChangeStatus == PasswordChangeStatus.success) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,

              content: Text(
                state.passwordChangeMessage ?? 'Password changed successfully.',
              ),
            ),
          );

          Navigator.of(context).pop();

          return;
        }

        if (state.passwordChangeStatus == PasswordChangeStatus.failure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,

              content: Text(
                state.passwordChangeMessage ?? 'Unable to change password.',
              ),
            ),
          );
        }
      },

      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        appBar: AppBar(
          toolbarHeight: 68,

          titleSpacing: 8,

          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                'Change password',

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                'Update your CODEX credentials',

                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        body: BlocBuilder<UserBloc, UserState>(
          buildWhen: (previous, current) {
            return previous.passwordChangeStatus !=
                current.passwordChangeStatus;
          },

          builder: (context, state) {
            final isLoading =
                state.passwordChangeStatus == PasswordChangeStatus.loading;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // ==========================================
                    // HERO
                    // ==========================================

                    _PasswordHero(isLoading: isLoading),

                    const SizedBox(height: 24),

                    // ==========================================
                    // PASSWORD
                    // ==========================================
                    const AppSectionHeader(
                      title: 'Password',
                      subtitle:
                          'Verify your current password and choose a new one',
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(15),

                      decoration: BoxDecoration(
                        color: isDark
                            ? colors.surfaceContainerHigh
                            : colors.surface,

                        borderRadius: BorderRadius.circular(18),

                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.65),
                        ),
                      ),

                      child: Column(
                        children: [
                          // CURRENT PASSWORD

                          TextFormField(
                            controller: _currentPasswordController,

                            enabled: !isLoading,

                            obscureText: _obscureCurrentPassword,

                            textInputAction: TextInputAction.next,

                            autocorrect: false,

                            enableSuggestions: false,

                            autofillHints: const [AutofillHints.password],

                            decoration: InputDecoration(
                              labelText: 'Current password',

                              hintText: 'Enter your current password',

                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),

                              suffixIcon: IconButton(
                                tooltip: _obscureCurrentPassword
                                    ? 'Show password'
                                    : 'Hide password',

                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _obscureCurrentPassword =
                                              !_obscureCurrentPassword;
                                        });
                                      },

                                icon: Icon(
                                  _obscureCurrentPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),

                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your current password';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // NEW PASSWORD
                          TextFormField(
                            controller: _newPasswordController,

                            enabled: !isLoading,

                            obscureText: _obscureNewPassword,

                            textInputAction: TextInputAction.next,

                            autocorrect: false,

                            enableSuggestions: false,

                            decoration: InputDecoration(
                              labelText: 'New password',

                              hintText: 'Enter your new password',

                              prefixIcon: const Icon(Icons.password_rounded),

                              suffixIcon: IconButton(
                                tooltip: _obscureNewPassword
                                    ? 'Show password'
                                    : 'Hide password',

                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _obscureNewPassword =
                                              !_obscureNewPassword;
                                        });
                                      },

                                icon: Icon(
                                  _obscureNewPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),

                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter a new password';
                              }

                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }

                              if (value == _currentPasswordController.text) {
                                return 'New password must be different from the current password';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // CONFIRM PASSWORD
                          TextFormField(
                            controller: _confirmPasswordController,

                            enabled: !isLoading,

                            obscureText: _obscureConfirmPassword,

                            textInputAction: TextInputAction.done,

                            autocorrect: false,

                            enableSuggestions: false,

                            onFieldSubmitted: (_) {
                              if (!isLoading) {
                                _submit();
                              }
                            },

                            decoration: InputDecoration(
                              labelText: 'Confirm new password',

                              hintText: 'Enter the new password again',

                              prefixIcon: const Icon(
                                Icons.verified_user_outlined,
                              ),

                              suffixIcon: IconButton(
                                tooltip: _obscureConfirmPassword
                                    ? 'Show password'
                                    : 'Hide password',

                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },

                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),

                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirm your new password';
                              }

                              if (value != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==========================================
                    // PASSWORD REQUIREMENTS
                    // ==========================================
                    _PasswordInfoCard(isDark: isDark),

                    const SizedBox(height: 24),

                    // ==========================================
                    // SUBMIT
                    // ==========================================
                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child: FilledButton(
                        onPressed: isLoading ? null : _submit,

                        child: isLoading
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,

                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),

                                  SizedBox(width: 10),

                                  Text('Changing password...'),
                                ],
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  Icon(Icons.password_rounded, size: 19),

                                  SizedBox(width: 8),

                                  Text(
                                    'Change password',

                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// HERO
// ============================================================

class _PasswordHero extends StatelessWidget {
  final bool isLoading;

  const _PasswordHero({required this.isLoading});

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
              Icons.password_rounded,
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
                  'Secure your account',

                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  isLoading
                      ? 'Updating your credentials...'
                      : 'Choose a new password for your CODEX account',

                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,

                    color: Colors.white.withValues(alpha: 0.74),
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
// INFO
// ============================================================

class _PasswordInfoCard extends StatelessWidget {
  final bool isDark;

  const _PasswordInfoCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
              'Your new password must contain at least '
              '8 characters and must be different from '
              'your current password. If this account is '
              'remembered, the securely stored login will '
              'also be updated.',

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
