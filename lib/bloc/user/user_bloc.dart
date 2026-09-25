import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/user_repository.dart';
import '../../services/biometric_service.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;
  final BiometricService biometricService;

  UserBloc(this.repository, this.biometricService) : super(const UserState()) {
    on<UserLoginRequested>(userLoginRequested);
    on<GetUsersRequested>(getUsersRequested);
    on<AddUserRequested>(addUserRequested);
    on<TogglePasswordVisibility>(togglePasswordVisibility);
    on<UsernameChanged>(usernameChanged);
    on<PasswordChanged>(passwordChanged);
    on<RememberMeChanged>(rememberMeChanged);
    on<UserLogoutRequested>(userLogoutRequested);
    on<CheckRememberedSession>(checkRememberedSession);
    on<BiometricAuthRequested>(biometricAuthRequested);
  }

  FutureOr<void> userLoginRequested(
    UserLoginRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(
      state.copyWith(isLoading: true, loginSuccess: false, clearError: true),
    );

    try {
      final loginResponse = await repository.login(
        event.username,
        event.password,
      );

      if (state.rememberMe) {
        await repository.saveRememberMe(loginResponse.username);
      } else {
        await repository.clearRememberMe();
      }

      emit(
        state.copyWith(
          isLoading: false,
          loginSuccess: true,
          authenticatedUsername: loginResponse.username,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          loginSuccess: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  FutureOr<void> getUsersRequested(
    GetUsersRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final users = await repository.getUsers();

      emit(state.copyWith(isLoading: false, users: users, clearError: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  FutureOr<void> addUserRequested(
    AddUserRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await repository.addUser(event.username, event.email);

      emit(state.copyWith(isLoading: false, clearError: true));

      add(const GetUsersRequested());
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> userLogoutRequested(
    UserLogoutRequested event,
    Emitter<UserState> emit,
  ) async {
    await repository.logout();

    emit(const UserState(logoutSuccess: true));
  }

  void togglePasswordVisibility(
    TogglePasswordVisibility event,
    Emitter<UserState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void usernameChanged(UsernameChanged event, Emitter<UserState> emit) {
    emit(state.copyWith(username: event.username));
  }

  void passwordChanged(PasswordChanged event, Emitter<UserState> emit) {
    emit(state.copyWith(password: event.password));
  }

  void rememberMeChanged(RememberMeChanged event, Emitter<UserState> emit) {
    emit(state.copyWith(rememberMe: event.rememberMe));
  }

  Future<void> checkRememberedSession(
    CheckRememberedSession event,
    Emitter<UserState> emit,
  ) async {
    try {
      final hasSession = await repository.hasRememberedSession();

      if (!hasSession) {
        emit(
          state.copyWith(
            hasRememberedSession: false,
            rememberedUsername: '',
            rememberMe: false,
            clearError: true,
          ),
        );

        return;
      }

      final rememberedUsername = await repository.getRememberedUsername();

      emit(
        state.copyWith(
          hasRememberedSession: true,
          rememberedUsername: rememberedUsername ?? '',
          rememberMe: true,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          hasRememberedSession: false,
          rememberedUsername: '',
          rememberMe: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> biometricAuthRequested(
    BiometricAuthRequested event,
    Emitter<UserState> emit,
  ) async {
    // There must already be a remembered session.
    if (!state.hasRememberedSession) {
      emit(state.copyWith(errorMessage: 'No remembered session found.'));

      return;
    }

    emit(
      state.copyWith(isLoading: true, loginSuccess: false, clearError: true),
    );

    try {
      final canUseBiometrics = await biometricService.canUseBiometrics();

      if (!canUseBiometrics) {
        emit(
          state.copyWith(
            isLoading: false,
            loginSuccess: false,
            errorMessage:
                'Biometric authentication is not available on this device.',
          ),
        );

        return;
      }

      final authenticated = await biometricService.authenticate();

      if (!authenticated) {
        emit(
          state.copyWith(
            isLoading: false,
            loginSuccess: false,
            clearError: true,
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          isLoading: false,
          loginSuccess: true,
          authenticatedUsername: state.rememberedUsername,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          loginSuccess: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
