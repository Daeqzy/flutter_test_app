import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/user_repository.dart';

import '../../services/biometric_service.dart';
import '../../services/auth_session_service.dart';

import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  final BiometricService biometricService;

  final AuthSessionService authSessionService;

  late final StreamSubscription<void> _sessionExpiredSubscription;

  UserBloc(this.repository, this.biometricService, this.authSessionService)
    : super(const UserState()) {
    // --------------------------------------------------------
    // EVENTS
    // --------------------------------------------------------

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

    on<AuthSessionExpired>(_onAuthSessionExpired);

    // --------------------------------------------------------
    // SESSION EXPIRATION STREAM
    // --------------------------------------------------------

    _sessionExpiredSubscription = authSessionService.sessionExpiredStream
        .listen((_) {
          add(const AuthSessionExpired());
        });
  }

  // ==========================================================
  // NORMAL LOGIN
  // ==========================================================

  Future<void> userLoginRequested(
    UserLoginRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,

        // Neutral state while authenticating.
        authStatus: AuthStatus.initial,

        clearError: true,
      ),
    );

    try {
      final loginResponse = await repository.login(
        event.username,
        event.password,
      );

      // ------------------------------------------------------
      // REMEMBER ME ON
      // ------------------------------------------------------

      if (state.rememberMe) {
        await repository.saveRememberMe(loginResponse.username, event.password);

        emit(
          state.copyWith(
            isLoading: false,

            authStatus: AuthStatus.authenticated,

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
      // REMEMBER ME OFF
      // ------------------------------------------------------

      await repository.clearRememberMe();

      emit(
        state.copyWith(
          isLoading: false,

          authStatus: AuthStatus.authenticated,

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

          authStatus: AuthStatus.initial,

          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ==========================================================
  // GET USERS
  // ==========================================================

  Future<void> getUsersRequested(
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

  // ==========================================================
  // ADD USER
  // ==========================================================

  Future<void> addUserRequested(
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

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> userLogoutRequested(
    UserLogoutRequested event,
    Emitter<UserState> emit,
  ) async {
    final shouldRemember =
        state.rememberMe &&
        state.rememberedUsername.trim().isNotEmpty &&
        state.rememberedPassword.isNotEmpty;

    // --------------------------------------------------------
    // KEEP LAST USERNAME
    // --------------------------------------------------------

    final lastUsername = state.authenticatedUsername.trim().isNotEmpty
        ? state.authenticatedUsername
        : state.username.trim();

    final rememberedUsername = shouldRemember ? state.rememberedUsername : '';

    final rememberedPassword = shouldRemember ? state.rememberedPassword : '';

    // Delete active tokens.
    await repository.logout();

    emit(
      UserState(
        // Explicit logout.
        authStatus: AuthStatus.unauthenticated,

        rememberMe: shouldRemember,

        hasRememberedAccount: shouldRemember,

        hasRememberedSession: false,

        rememberedUsername: rememberedUsername,

        rememberedPassword: rememberedPassword,

        // Keep last username visible even
        // if Remember Me is OFF.
        username: lastUsername,

        // Keep password only if Remember Me is ON.
        password: shouldRemember ? rememberedPassword : '',

        authenticatedUsername: '',

        obscurePassword: true,

        // Preserve biometric capability information.
        hasFingerprint: state.hasFingerprint,

        hasFaceAuthentication: state.hasFaceAuthentication,

        hasIrisAuthentication: state.hasIrisAuthentication,
      ),
    );
  }

  // ==========================================================
  // SESSION EXPIRED
  // ==========================================================

  void _onAuthSessionExpired(
    AuthSessionExpired event,
    Emitter<UserState> emit,
  ) {
    final hasRememberedAccount =
        state.hasRememberedAccount &&
        state.rememberedUsername.trim().isNotEmpty;

    final lastUsername = hasRememberedAccount
        ? state.rememberedUsername
        : state.authenticatedUsername.trim().isNotEmpty
        ? state.authenticatedUsername
        : state.username;

    emit(
      state.copyWith(
        isLoading: false,

        authStatus: AuthStatus.sessionExpired,

        // Interceptor removed the token.
        hasRememberedSession: false,

        authenticatedUsername: '',

        username: lastUsername,

        password: hasRememberedAccount ? state.rememberedPassword : '',

        clearError: true,
      ),
    );
  }

  // ==========================================================
  // PASSWORD VISIBILITY
  // ==========================================================

  void togglePasswordVisibility(
    TogglePasswordVisibility event,
    Emitter<UserState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  // ==========================================================
  // USERNAME
  // ==========================================================

  void usernameChanged(UsernameChanged event, Emitter<UserState> emit) {
    emit(state.copyWith(username: event.username));
  }

  // ==========================================================
  // PASSWORD
  // ==========================================================

  void passwordChanged(PasswordChanged event, Emitter<UserState> emit) {
    emit(state.copyWith(password: event.password));
  }

  // ==========================================================
  // REMEMBER ME
  // ==========================================================

  Future<void> rememberMeChanged(
    RememberMeChanged event,
    Emitter<UserState> emit,
  ) async {
    // --------------------------------------------------------
    // TURN OFF
    // --------------------------------------------------------

    if (!event.rememberMe) {
      await repository.clearRememberMe();

      emit(
        state.copyWith(
          rememberMe: false,

          hasRememberedAccount: false,

          hasRememberedSession: false,

          rememberedUsername: '',

          rememberedPassword: '',

          // Do NOT clear username/password.
          // User may still want to press Sign In.
          clearError: true,
        ),
      );

      return;
    }

    // --------------------------------------------------------
    // TURN ON
    // --------------------------------------------------------
    //
    // Credentials are saved only AFTER
    // successful authentication.
    // --------------------------------------------------------

    emit(state.copyWith(rememberMe: true, clearError: true));
  }

  // ==========================================================
  // CHECK REMEMBERED ACCOUNT
  // ==========================================================

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
          authStatus: AuthStatus.initial,

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

      add(const CheckBiometricAvailability());
    } catch (e) {
      emit(
        state.copyWith(
          authStatus: AuthStatus.initial,

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

  // ==========================================================
  // CHECK BIOMETRICS
  // ==========================================================

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
    } catch (_) {
      emit(
        state.copyWith(
          hasFingerprint: false,

          hasFaceAuthentication: false,

          hasIrisAuthentication: false,
        ),
      );
    }
  }

  // ==========================================================
  // BIOMETRIC LOGIN
  // ==========================================================

  Future<void> biometricAuthRequested(
    BiometricAuthRequested event,
    Emitter<UserState> emit,
  ) async {
    // --------------------------------------------------------
    // REMEMBERED CREDENTIALS REQUIRED
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

        authStatus: AuthStatus.initial,

        clearError: true,
      ),
    );

    try {
      // ------------------------------------------------------
      // CHECK BIOMETRIC SUPPORT
      // ------------------------------------------------------

      final canUseBiometrics = await biometricService.canUseBiometrics();

      if (!canUseBiometrics) {
        emit(
          state.copyWith(
            isLoading: false,

            authStatus: AuthStatus.initial,

            errorMessage:
                'Biometric authentication is not available on this device.',
          ),
        );

        return;
      }

      // ------------------------------------------------------
      // OS BIOMETRIC AUTH
      // ------------------------------------------------------

      final authenticated = await biometricService.authenticate();

      if (!authenticated) {
        emit(
          state.copyWith(
            isLoading: false,

            authStatus: AuthStatus.initial,

            clearError: true,
          ),
        );

        return;
      }

      // ------------------------------------------------------
      // REAL API LOGIN
      // ------------------------------------------------------

      final loginResponse = await repository.login(
        state.rememberedUsername,
        state.rememberedPassword,
      );

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

          authStatus: AuthStatus.authenticated,

          authenticatedUsername: loginResponse.username,

          username: loginResponse.username,

          rememberedUsername: loginResponse.username,

          rememberMe: true,

          hasRememberedAccount: true,

          hasRememberedSession: true,

          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,

          authStatus: AuthStatus.initial,

          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ==========================================================
  // CLEANUP
  // ==========================================================

  @override
  Future<void> close() async {
    await _sessionExpiredSubscription.cancel();

    return super.close();
  }
}
