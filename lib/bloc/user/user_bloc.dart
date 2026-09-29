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

    on<CheckBiometricAvailability>(checkBiometricAvailability);

    on<BiometricAuthRequested>(biometricAuthRequested);
  }

  // ----------------------------------------------------------
  // NORMAL LOGIN
  // ----------------------------------------------------------

  FutureOr<void> userLoginRequested(
    UserLoginRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        loginSuccess: false,
        logoutSuccess: false,
        clearError: true,
      ),
    );

    try {
      final loginResponse = await repository.login(
        event.username,
        event.password,
      );

      // ------------------------------------------------------
      // REMEMBER ME
      // ------------------------------------------------------

      if (state.rememberMe) {
        await repository.saveRememberMe(loginResponse.username, event.password);

        emit(
          state.copyWith(
            isLoading: false,
            loginSuccess: true,
            logoutSuccess: false,

            authenticatedUsername: loginResponse.username,

            username: loginResponse.username,

            password: event.password,

            rememberedUsername: loginResponse.username,

            rememberedPassword: event.password,

            rememberMe: true,

            hasRememberedAccount: true,
            hasRememberedSession: true,

            clearError: true,
          ),
        );

        return;
      }

      // ------------------------------------------------------
      // NO REMEMBER ME
      // ------------------------------------------------------

      await repository.clearRememberMe();

      emit(
        state.copyWith(
          isLoading: false,
          loginSuccess: true,
          logoutSuccess: false,

          authenticatedUsername: loginResponse.username,

          username: loginResponse.username,

          password: '',

          rememberedUsername: '',
          rememberedPassword: '',

          rememberMe: false,

          hasRememberedAccount: false,
          hasRememberedSession: false,

          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          loginSuccess: false,
          logoutSuccess: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ----------------------------------------------------------
  // GET USERS
  // ----------------------------------------------------------

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

  // ----------------------------------------------------------
  // ADD USER
  // ----------------------------------------------------------

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

  // ----------------------------------------------------------
  // LOGOUT
  // ----------------------------------------------------------

  Future<void> userLogoutRequested(
    UserLogoutRequested event,
    Emitter<UserState> emit,
  ) async {
    final shouldRemember =
        state.rememberMe &&
        state.rememberedUsername.trim().isNotEmpty &&
        state.rememberedPassword.isNotEmpty;

    // Keep the actual username temporarily for the Login screen,
    // even when Remember Me is disabled.
    final lastUsername = state.authenticatedUsername.trim().isNotEmpty
        ? state.authenticatedUsername
        : state.username.trim();

    final rememberedUsername = shouldRemember ? state.rememberedUsername : '';

    final rememberedPassword = shouldRemember ? state.rememberedPassword : '';

    await repository.logout();

    emit(
      UserState(
        logoutSuccess: true,

        rememberMe: shouldRemember,

        hasRememberedAccount: shouldRemember,

        hasRememberedSession: false,

        // Persisted only when Remember Me is enabled.
        rememberedUsername: rememberedUsername,

        rememberedPassword: rememberedPassword,

        // Keep last username visible after logout.
        username: lastUsername,

        // Password only survives when Remember Me is enabled.
        password: shouldRemember ? rememberedPassword : '',

        authenticatedUsername: '',

        obscurePassword: true,

        hasFingerprint: state.hasFingerprint,

        hasFaceAuthentication: state.hasFaceAuthentication,

        hasIrisAuthentication: state.hasIrisAuthentication,
      ),
    );
  }

  // ----------------------------------------------------------
  // PASSWORD VISIBILITY
  // ----------------------------------------------------------

  void togglePasswordVisibility(
    TogglePasswordVisibility event,
    Emitter<UserState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  // ----------------------------------------------------------
  // USERNAME
  // ----------------------------------------------------------

  void usernameChanged(UsernameChanged event, Emitter<UserState> emit) {
    emit(state.copyWith(username: event.username));
  }

  // ----------------------------------------------------------
  // PASSWORD
  // ----------------------------------------------------------

  void passwordChanged(PasswordChanged event, Emitter<UserState> emit) {
    emit(state.copyWith(password: event.password));
  }

  // ----------------------------------------------------------
  // REMEMBER ME
  // ----------------------------------------------------------

  Future<void> rememberMeChanged(
    RememberMeChanged event,
    Emitter<UserState> emit,
  ) async {
    if (!event.rememberMe) {
      await repository.clearRememberMe();

      emit(
        state.copyWith(
          rememberMe: false,

          hasRememberedAccount: false,
          hasRememberedSession: false,

          rememberedUsername: '',
          rememberedPassword: '',

          clearError: true,
        ),
      );

      return;
    }

    emit(state.copyWith(rememberMe: true, clearError: true));
  }

  // ----------------------------------------------------------
  // CHECK REMEMBERED ACCOUNT
  // ----------------------------------------------------------

  Future<void> checkRememberedSession(
    CheckRememberedSession event,
    Emitter<UserState> emit,
  ) async {
    try {
      final hasRememberedAccount = await repository.hasRememberedAccount();

      final hasRememberedSession = await repository.hasRememberedSession();

      String rememberedUsername = '';
      String rememberedPassword = '';

      if (hasRememberedAccount) {
        rememberedUsername = await repository.getRememberedUsername() ?? '';

        rememberedPassword = await repository.getRememberedPassword() ?? '';
      }

      emit(
        state.copyWith(
          rememberMe: hasRememberedAccount,

          hasRememberedAccount: hasRememberedAccount,

          hasRememberedSession: hasRememberedSession,

          rememberedUsername: rememberedUsername,

          rememberedPassword: rememberedPassword,

          username: rememberedUsername,

          password: rememberedPassword,

          clearError: true,
        ),
      );

      // After loading the remembered account,
      // detect device biometrics.
      add(const CheckBiometricAvailability());
    } catch (e) {
      emit(
        state.copyWith(
          rememberMe: false,
          hasRememberedAccount: false,
          hasRememberedSession: false,

          rememberedUsername: '',
          rememberedPassword: '',

          errorMessage: e.toString(),
        ),
      );

      add(const CheckBiometricAvailability());
    }
  }

  // ----------------------------------------------------------
  // CHECK BIOMETRIC AVAILABILITY
  // ----------------------------------------------------------

  Future<void> checkBiometricAvailability(
    CheckBiometricAvailability event,
    Emitter<UserState> emit,
  ) async {
    try {
      final canUse = await biometricService.canUseBiometrics();

      if (!canUse) {
        emit(
          state.copyWith(
            hasFingerprint: false,
            hasFaceAuthentication: false,
            hasIrisAuthentication: false,
          ),
        );

        return;
      }

      final hasFingerprint = await biometricService.hasFingerprint();

      final hasFaceAuthentication = await biometricService
          .hasFaceAuthentication();

      final hasIrisAuthentication = await biometricService
          .hasIrisAuthentication();

      emit(
        state.copyWith(
          hasFingerprint: hasFingerprint,

          hasFaceAuthentication: hasFaceAuthentication,

          hasIrisAuthentication: hasIrisAuthentication,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          hasFingerprint: false,
          hasFaceAuthentication: false,
          hasIrisAuthentication: false,
        ),
      );
    }
  }

  // ----------------------------------------------------------
  // BIOMETRIC LOGIN
  // ----------------------------------------------------------

  Future<void> biometricAuthRequested(
    BiometricAuthRequested event,
    Emitter<UserState> emit,
  ) async {
    // --------------------------------------------------------
    // MUST HAVE REMEMBERED CREDENTIALS
    // --------------------------------------------------------

    if (!state.hasRememberedAccount ||
        state.rememberedUsername.trim().isEmpty ||
        state.rememberedPassword.isEmpty) {
      emit(
        state.copyWith(
          errorMessage:
              'No remembered account is available for biometric login.',
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        loginSuccess: false,
        logoutSuccess: false,
        clearError: true,
      ),
    );

    try {
      // ------------------------------------------------------
      // CHECK BIOMETRICS
      // ------------------------------------------------------

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

      // ------------------------------------------------------
      // OS BIOMETRIC AUTHENTICATION
      // ------------------------------------------------------

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

      // ------------------------------------------------------
      // BIOMETRIC SUCCEEDED
      //
      // Perform a REAL backend login using credentials
      // stored in FlutterSecureStorage.
      // ------------------------------------------------------

      final loginResponse = await repository.login(
        state.rememberedUsername,
        state.rememberedPassword,
      );

      // Refresh the remembered username in case
      // the backend returned canonical formatting.
      await repository.saveRememberMe(
        loginResponse.username,
        state.rememberedPassword,
      );

      // ------------------------------------------------------
      // AUTHENTICATED
      // ------------------------------------------------------

      emit(
        state.copyWith(
          isLoading: false,
          loginSuccess: true,
          logoutSuccess: false,

          authenticatedUsername: loginResponse.username,

          username: loginResponse.username,

          rememberedUsername: loginResponse.username,

          rememberMe: true,

          hasRememberedAccount: true,

          // repository.login() stored fresh tokens.
          hasRememberedSession: true,

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
