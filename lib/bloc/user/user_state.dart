import 'package:equatable/equatable.dart';

import '../../models/user.dart';

enum AuthStatus { initial, authenticated, unauthenticated, sessionExpired }

class UserState extends Equatable {
  final bool isLoading;

  final AuthStatus authStatus;

  // ----------------------------------------------------------
  // REMEMBERED ACCOUNT
  // ----------------------------------------------------------

  final bool rememberMe;

  /// Whether a remembered account exists in secure storage.
  final bool hasRememberedAccount;

  /// Whether that remembered account currently has
  /// an authenticated API session.
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

  /// Used mainly for normal login / last username.
  ///
  /// Password intentionally does NOT live in UserState anymore.
  final String username;

  /// Safe to expose to the UI.
  ///
  /// The remembered password stays inside secure storage.
  final String rememberedUsername;

  final User? user;

  final List<User> users;

  final String? errorMessage;

  const UserState({
    this.isLoading = false,
    this.authStatus = AuthStatus.initial,
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
