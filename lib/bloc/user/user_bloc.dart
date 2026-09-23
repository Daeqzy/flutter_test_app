import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc(this.repository) : super(const UserState()) {
    on<UserLoginRequested>(userLoginRequested);
    on<GetUsersRequested>(getUsersRequested);
    on<AddUserRequested>(addUserRequested);
    on<GetUserLocationsRequested>(getUserLocationsRequested);
    on<TogglePasswordVisibility>(togglePasswordVisibility);
    on<UsernameChanged>(usernameChanged);
    on<PasswordChanged>(passwordChanged);
  }

  FutureOr<void> userLoginRequested(
    UserLoginRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(
      state.copyWith(isLoading: true, loginSuccess: false, clearError: true),
    );

    try {
      await repository.login(event.username, event.password);

      emit(
        state.copyWith(isLoading: false, loginSuccess: true, clearError: true),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
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

  Future<void> getUserLocationsRequested(
    GetUserLocationsRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final locations = await repository.getUserLocations();

      emit(
        state.copyWith(
          isLoading: false,
          locations: locations,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
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
}
