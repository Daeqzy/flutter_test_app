import 'package:equatable/equatable.dart';

import '../../models/user.dart';

class UserState extends Equatable {
  final bool isLoading;
  final User? user;
  final List<User> users;
  final String? errorMessage;

  const UserState({
    this.isLoading = false,
    this.user,
    this.users = const [],
    this.errorMessage,
  });

  UserState copyWith({
    bool? isLoading,
    User? user,
    List<User>? users,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      users: users ?? this.users,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, user, users, errorMessage];
}
