import 'package:equatable/equatable.dart';

import '../../models/user.dart';

enum AuthStatus { initial, authenticated, unauthenticated, sessionExpired }

enum PasswordChangeStatus { initial, loading, success, failure }

class UserState extends Equatable {
  final bool isLoading;

  final AuthStatus authStatus;

  // ----------------------------------------------------------
  // PASSWORD CHANGE
  // ----------------------------------------------------------

  final PasswordChangeStatus passwordChangeStatus;

  final String? passwordChangeMessage;

  // ----------------------------------------------------------
  // REMEMBERED ACCOUNT
  // ----------------------------------------------------------

  final bool rememberMe;

  final bool hasRememberedAccount;

  final bool hasRememberedSession;

  // ----------------------------------------------------------
  // BIOMETRICS
  // ----------------------------------------------------------

  final bool hasFingerprint;

  final bool hasFaceAuthentication;

  final bool hasIrisAuthentication;

  // ----------------------------------------------------------
  // USER DATA
  // ----------------------------------------------------------

  final String authenticatedUsername;

  final String username;

  final String rememberedUsername;

  final User? user;

  final List<User> users;

  final String? errorMessage;

  const UserState({
    this.isLoading = false,
    this.authStatus = AuthStatus.initial,
    this.passwordChangeStatus = PasswordChangeStatus.initial,
    this.passwordChangeMessage,
    this.rememberMe = false,
    this.hasRememberedAccount = false,
    this.hasRememberedSession = false,
    this.hasFingerprint = false,
    this.hasFaceAuthentication = false,
    this.hasIrisAuthentication = false,
    this.authenticatedUsername = '',
    this.username = '',
    this.rememberedUsername = '',
    this.user,
    this.users = const [],
    this.errorMessage,
  });

  UserState copyWith({
    bool? isLoading,
    AuthStatus? authStatus,
    PasswordChangeStatus? passwordChangeStatus,
    String? passwordChangeMessage,
    bool clearPasswordChangeMessage = false,
    bool? rememberMe,
    bool? hasRememberedAccount,
    bool? hasRememberedSession,
    bool? hasFingerprint,
    bool? hasFaceAuthentication,
    bool? hasIrisAuthentication,
    String? authenticatedUsername,
    String? username,
    String? rememberedUsername,
    User? user,
    List<User>? users,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,

      authStatus: authStatus ?? this.authStatus,

      passwordChangeStatus: passwordChangeStatus ?? this.passwordChangeStatus,

      passwordChangeMessage: clearPasswordChangeMessage
          ? null
          : passwordChangeMessage ?? this.passwordChangeMessage,

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

      rememberedUsername: rememberedUsername ?? this.rememberedUsername,

      user: clearUser ? null : (user ?? this.user),

      users: users ?? this.users,

      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    authStatus,
    passwordChangeStatus,
    passwordChangeMessage,
    rememberMe,
    hasRememberedAccount,
    hasRememberedSession,
    hasFingerprint,
    hasFaceAuthentication,
    hasIrisAuthentication,
    authenticatedUsername,
    username,
    rememberedUsername,
    user,
    users,
    errorMessage,
  ];
}
