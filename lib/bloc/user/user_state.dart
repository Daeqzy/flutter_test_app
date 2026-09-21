import 'package:equatable/equatable.dart';

import '../../models/user.dart';

class UserState extends Equatable {
  final bool isLoading;
  final bool loginSuccess;
  final User? user;
  final List<User> users;
  final String? errorMessage;

  const UserState({
    this.isLoading = false,
    this.loginSuccess = false,
    this.user,
    this.users = const [],
    this.errorMessage,
  });

  UserState copyWith({
    bool? isLoading,
    bool? loginSuccess,
    User? user,
    List<User>? users,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      loginSuccess: loginSuccess ?? this.loginSuccess,
      user: clearUser ? null : (user ?? this.user),
      users: users ?? this.users,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    loginSuccess,
    user,
    users,
    errorMessage,
  ];
}
