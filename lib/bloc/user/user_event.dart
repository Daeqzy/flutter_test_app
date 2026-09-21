import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UserLoginRequested extends UserEvent {
  final String username;
  final String password;

  const UserLoginRequested({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

class GetUsersRequested extends UserEvent {
  const GetUsersRequested();
}

class AddUserRequested extends UserEvent {
  final String username;
  final String email;

  const AddUserRequested({required this.username, required this.email});

  @override
  List<Object?> get props => [username, email];
}

class DeleteUserRequested extends UserEvent {
  final int userId;

  const DeleteUserRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}
