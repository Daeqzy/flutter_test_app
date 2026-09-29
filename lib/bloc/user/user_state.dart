import 'package:equatable/equatable.dart';

import '../../models/user.dart';

enum AuthStatus { initial, authenticated, unauthenticated, sessionExpired }

class UserState extends Equatable {
  final bool isLoading;

  final AuthStatus authStatus;

  final bool obscurePassword;

  final bool rememberMe;

  // Remembered account exists locally.
  final bool hasRememberedAccount;

  // Remembered account currently has an active token.
  final bool hasRememberedSession;

  // ----------------------------------------------------------
  // BIOMETRICS
  // ----------------------------------------------------------

  final bool hasFingerprint;
  final bool hasFaceAuthentication;
  final bool hasIrisAuthentication;

  // ----------------------------------------------------------
  // USER / LOGIN DATA
  // ----------------------------------------------------------

  final String authenticatedUsername;

  final String username;
  final String password;

  final String rememberedUsername;
  final String rememberedPassword;

  final User? user;

  final List<User> users;

  final String? errorMessage;

  const UserState({
    this.isLoading = false,

    this.authStatus = AuthStatus.initial,

    this.obscurePassword = true,

    this.rememberMe = false,

    this.hasRememberedAccount = false,
    this.hasRememberedSession = false,

    this.hasFingerprint = false,
    this.hasFaceAuthentication = false,
    this.hasIrisAuthentication = false,

    this.authenticatedUsername = '',

    this.username = '',
    this.password = '',

    this.rememberedUsername = '',
    this.rememberedPassword = '',

    this.user,

    this.users = const [],

    this.errorMessage,
  });

  UserState copyWith({
    bool? isLoading,

    AuthStatus? authStatus,

    bool? obscurePassword,

    bool? rememberMe,

    bool? hasRememberedAccount,
    bool? hasRememberedSession,

    bool? hasFingerprint,
    bool? hasFaceAuthentication,
    bool? hasIrisAuthentication,

    String? authenticatedUsername,

    String? username,
    String? password,

    String? rememberedUsername,
    String? rememberedPassword,

    User? user,

    List<User>? users,

    String? errorMessage,

    bool clearUser = false,
    bool clearError = false,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,

      authStatus: authStatus ?? this.authStatus,

      obscurePassword: obscurePassword ?? this.obscurePassword,

      rememberMe: rememberMe ?? this.rememberMe,

      hasRememberedAccount: hasRememberedAccount ?? this.hasRememberedAccount,

      hasRememberedSession: hasRememberedSession ?? this.hasRememberedSession,

      hasFingerprint: hasFingerprint ?? this.hasFingerprint,

      hasFaceAuthentication:
          hasFaceAuthentication ?? this.hasFaceAuthentication,

      hasIrisAuthentication:
          hasIrisAuthentication ?? this.hasIrisAuthentication,

      authenticatedUsername:
          authenticatedUsername ?? this.authenticatedUsername,

      username: username ?? this.username,

      password: password ?? this.password,

      rememberedUsername: rememberedUsername ?? this.rememberedUsername,

      rememberedPassword: rememberedPassword ?? this.rememberedPassword,

      user: clearUser ? null : (user ?? this.user),

      users: users ?? this.users,

      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,

    authStatus,

    obscurePassword,

    rememberMe,

    hasRememberedAccount,
    hasRememberedSession,

    hasFingerprint,
    hasFaceAuthentication,
    hasIrisAuthentication,

    authenticatedUsername,

    username,
    password,

    rememberedUsername,
    rememberedPassword,

    user,

    users,

    errorMessage,
  ];
}
