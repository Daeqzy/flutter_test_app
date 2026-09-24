import 'package:equatable/equatable.dart';

import '../../models/user.dart';
import '../../models/location_result.dart';

class UserState extends Equatable {
  final bool isLoading;
  final bool loginSuccess;
  final bool obscurePassword;
  final bool logoutSuccess;
  final String authenticatedUsername;
  final String username;
  final String password;
  final User? user;
  final List<User> users;
  final String? errorMessage;
  final List<LocationResult> locations;

  const UserState({
    this.isLoading = false,
    this.loginSuccess = false,
    this.obscurePassword = true,
    this.logoutSuccess = false,
    this.username = '',
    this.authenticatedUsername = '',
    this.password = '',
    this.user,
    this.users = const [],
    this.errorMessage,
    this.locations = const [],
  });

  UserState copyWith({
    bool? isLoading,
    bool? loginSuccess,
    bool? obscurePassword,
    bool? logoutSuccess,
    String? username,
    String? authenticatedUsername,
    String? password,
    User? user,
    List<User>? users,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
    List<LocationResult>? locations,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      loginSuccess: loginSuccess ?? this.loginSuccess,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      logoutSuccess: logoutSuccess ?? this.logoutSuccess,
      username: username ?? this.username,
      authenticatedUsername:
          authenticatedUsername ?? this.authenticatedUsername,
      password: password ?? this.password,
      user: clearUser ? null : (user ?? this.user),
      users: users ?? this.users,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      locations: locations ?? this.locations,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    loginSuccess,
    obscurePassword,
    logoutSuccess,
    username,
    authenticatedUsername,
    password,
    user,
    users,
    errorMessage,
    locations,
  ];
}
