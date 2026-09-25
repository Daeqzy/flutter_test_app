import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';

import '../main/main_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
      listener: (context, state) {
        // LOGIN OR BIOMETRIC SUCCESS
        if (state.loginSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }

        // ERROR
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },

      child: Scaffold(
        appBar: AppBar(title: const Text('CODEX Computers')),

        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Form(
              key: _formKey,

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  // CODEX LOGO
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      'assets/images/codex_logo.png',
                      width: 280,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // TITLE
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Sign in to continue',
                    style: TextStyle(fontSize: 16),
                  ),

                  // REMEMBERED ACCOUNT
                  BlocBuilder<UserBloc, UserState>(
                    buildWhen: (previous, current) {
                      return previous.hasRememberedSession !=
                              current.hasRememberedSession ||
                          previous.rememberedUsername !=
                              current.rememberedUsername ||
                          previous.isLoading != current.isLoading;
                    },

                    builder: (context, state) {
                      if (!state.hasRememberedSession) {
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

                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              // REMEMBERED USER
                              Row(
                                children: [
                                  const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF2563EB),
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
                                ],
                              ),

                              const SizedBox(height: 14),

                              // FINGERPRINT BUTTON
                              SizedBox(
                                width: double.infinity,

                                child: OutlinedButton.icon(
                                  onPressed: state.isLoading
                                      ? null
                                      : () {
                                          context.read<UserBloc>().add(
                                            const BiometricAuthRequested(),
                                          );
                                        },

                                  icon: const Icon(
                                    Icons.fingerprint_rounded,
                                    size: 24,
                                  ),

                                  label: const Text('Sign in with fingerprint'),

                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),

                                    foregroundColor: const Color(0xFF2563EB),

                                    side: const BorderSide(
                                      color: Color(0xFF2563EB),
                                    ),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // USERNAME
                  TextFormField(
                    onChanged: (value) {
                      context.read<UserBloc>().add(UsernameChanged(value));
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
                  ),

                  const SizedBox(height: 20),

                  // PASSWORD
                  BlocBuilder<UserBloc, UserState>(
                    buildWhen: (previous, current) {
                      return previous.obscurePassword !=
                          current.obscurePassword;
                    },

                    builder: (context, state) {
                      return TextFormField(
                        obscureText: state.obscurePassword,

                        onChanged: (value) {
                          context.read<UserBloc>().add(PasswordChanged(value));
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

                  // REMEMBER ME
                  BlocBuilder<UserBloc, UserState>(
                    buildWhen: (previous, current) {
                      return previous.rememberMe != current.rememberMe;
                    },

                    builder: (context, state) {
                      return Row(
                        children: [
                          Checkbox(
                            value: state.rememberMe,

                            onChanged: (value) {
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

                  // LOGIN BUTTON
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
                              : () => _login(context),

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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
