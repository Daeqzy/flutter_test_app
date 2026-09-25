import 'package:equatable/equatable.dart';

import '../../models/user.dart';

class UserState extends Equatable {
  final bool isLoading;
  final bool loginSuccess;
  final bool obscurePassword;
  final bool logoutSuccess;
  final bool rememberMe;
  final bool hasRememberedSession;

  final String authenticatedUsername;
  final String username;
  final String password;
  final String rememberedUsername;

  final User? user;
  final List<User> users;

  final String? errorMessage;

  const UserState({
    this.isLoading = false,
    this.loginSuccess = false,
    this.obscurePassword = true,
    this.logoutSuccess = false,
    this.rememberMe = false,
    this.username = '',
    this.authenticatedUsername = '',
    this.password = '',
    this.user,
    this.users = const [],
    this.errorMessage,
    this.hasRememberedSession = false,
    this.rememberedUsername = '',
  });

  UserState copyWith({
    bool? isLoading,
    bool? loginSuccess,
    bool? obscurePassword,
    bool? logoutSuccess,
    bool? rememberMe,
    bool? hasRememberedSession = false,
    String? username,
    String? authenticatedUsername,
    String? password,
    String? rememberedUsername,
    User? user,
    List<User>? users,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      loginSuccess: loginSuccess ?? this.loginSuccess,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      logoutSuccess: logoutSuccess ?? this.logoutSuccess,
      rememberMe: rememberMe ?? this.rememberMe,
      username: username ?? this.username,
      authenticatedUsername:
          authenticatedUsername ?? this.authenticatedUsername,
      password: password ?? this.password,
      user: clearUser ? null : (user ?? this.user),
      users: users ?? this.users,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasRememberedSession: hasRememberedSession ?? this.hasRememberedSession,
      rememberedUsername: rememberedUsername ?? this.rememberedUsername,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    loginSuccess,
    obscurePassword,
    logoutSuccess,
    rememberMe,
    username,
    authenticatedUsername,
    password,
    user,
    users,
    errorMessage,
    hasRememberedSession,
    rememberedUsername,
  ];
}
