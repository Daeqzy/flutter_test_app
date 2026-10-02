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
// PASSWORD VISIBILITY
// ----------------------------------------------------------

class TogglePasswordVisibility extends UserEvent {
  const TogglePasswordVisibility();
}

// ----------------------------------------------------------
// USERNAME
// ----------------------------------------------------------

class UsernameChanged extends UserEvent {
  final String username;

  const UsernameChanged(this.username);

  @override
  List<Object?> get props => [username];
}

// ----------------------------------------------------------
// PASSWORD
// ----------------------------------------------------------

class PasswordChanged extends UserEvent {
  final String password;

  const PasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
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
// CHECK DEVICE BIOMETRICS
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

class AuthSessionExpired extends UserEvent {
  const AuthSessionExpired();
}
