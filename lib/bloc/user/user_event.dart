import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

// ----------------------------------------------------------
// LOGIN
// ----------------------------------------------------------

class UserLoginRequested extends UserEvent {
  final String username;
  final String password;

  const UserLoginRequested({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

// ----------------------------------------------------------
// CHANGE PASSWORD
// ----------------------------------------------------------

class ChangePasswordRequested extends UserEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

// ----------------------------------------------------------
// RESET CHANGE PASSWORD STATE
// ----------------------------------------------------------

class ResetPasswordChangeState extends UserEvent {
  const ResetPasswordChangeState();
}

// ----------------------------------------------------------
// GET USERS
// ----------------------------------------------------------

class GetUsersRequested extends UserEvent {
  const GetUsersRequested();
}

// ----------------------------------------------------------
// ADD USER
// ----------------------------------------------------------

class AddUserRequested extends UserEvent {
  final String username;
  final String email;

  const AddUserRequested({required this.username, required this.email});

  @override
  List<Object?> get props => [username, email];
}

// ----------------------------------------------------------
// REMEMBER ME
// ----------------------------------------------------------

class RememberMeChanged extends UserEvent {
  final bool rememberMe;

  const RememberMeChanged(this.rememberMe);

  @override
  List<Object?> get props => [rememberMe];
}

// ----------------------------------------------------------
// USE ANOTHER ACCOUNT
// ----------------------------------------------------------

class UseAnotherAccountRequested extends UserEvent {
  const UseAnotherAccountRequested();
}

// ----------------------------------------------------------
// LOGOUT
// ----------------------------------------------------------

class UserLogoutRequested extends UserEvent {
  const UserLogoutRequested();
}

// ----------------------------------------------------------
// CHECK REMEMBERED ACCOUNT
// ----------------------------------------------------------

class CheckRememberedSession extends UserEvent {
  const CheckRememberedSession();
}

// ----------------------------------------------------------
// CHECK BIOMETRICS
// ----------------------------------------------------------

class CheckBiometricAvailability extends UserEvent {
  const CheckBiometricAvailability();
}

// ----------------------------------------------------------
// BIOMETRIC LOGIN
// ----------------------------------------------------------

class BiometricAuthRequested extends UserEvent {
  const BiometricAuthRequested();
}

// ----------------------------------------------------------
// SESSION EXPIRED
// ----------------------------------------------------------

class AuthSessionExpired extends UserEvent {
  const AuthSessionExpired();
}
