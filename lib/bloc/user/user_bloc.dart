import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/user_repository.dart';

import '../../services/auth_session_service.dart';
import '../../services/biometric_service.dart';

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

    on<ChangePasswordRequested>(changePasswordRequested);

    on<ResetPasswordChangeState>(resetPasswordChangeState);

    on<GetUsersRequested>(getUsersRequested);

    on<AddUserRequested>(addUserRequested);

    on<RememberMeChanged>(rememberMeChanged);

    on<UseAnotherAccountRequested>(useAnotherAccountRequested);

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
  // NORMAL / PASSWORD LOGIN
  // ==========================================================

  Future<void> userLoginRequested(
    UserLoginRequested event,
    Emitter<UserState> emit,
  ) async {
    // --------------------------------------------------------
    // LOGIN START
    // --------------------------------------------------------
    //
    // This works for:
    //
    // 1. Normal username/password login.
    // 2. Password login for a remembered account.
    //
    // A remembered account can therefore use either
    // biometrics OR password.
    // --------------------------------------------------------

    emit(
      state.copyWith(
        isLoading: true,
        authStatus: AuthStatus.initial,
        clearError: true,
      ),
    );

    try {
      final loginResponse = await repository.login(
        event.username.trim(),
        event.password,
      );

      // ------------------------------------------------------
      // REMEMBER ME ENABLED
      // ------------------------------------------------------

      if (state.rememberMe) {
        await repository.saveRememberMe(loginResponse.username, event.password);

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

        return;
      }

      // ------------------------------------------------------
      // REMEMBER ME DISABLED
      // ------------------------------------------------------

      await repository.clearRememberMe();

      emit(
        state.copyWith(
          isLoading: false,

          authStatus: AuthStatus.authenticated,

          authenticatedUsername: loginResponse.username,

          username: loginResponse.username,

          rememberedUsername: '',

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
  // CHANGE PASSWORD
  // ==========================================================

  Future<void> changePasswordRequested(
    ChangePasswordRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(
      state.copyWith(
        passwordChangeStatus: PasswordChangeStatus.loading,

        clearPasswordChangeMessage: true,
      ),
    );

    try {
      await repository.changePassword(event.currentPassword, event.newPassword);

      emit(
        state.copyWith(
          passwordChangeStatus: PasswordChangeStatus.success,

          passwordChangeMessage: 'Password changed successfully.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          passwordChangeStatus: PasswordChangeStatus.failure,

          passwordChangeMessage: e.toString(),
        ),
      );
    }
  }

  // ==========================================================
  // RESET CHANGE PASSWORD STATE
  // ==========================================================

  void resetPasswordChangeState(
    ResetPasswordChangeState event,
    Emitter<UserState> emit,
  ) {
    emit(
      state.copyWith(
        passwordChangeStatus: PasswordChangeStatus.initial,

        clearPasswordChangeMessage: true,
      ),
    );
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
  // REMEMBER ME
  // ==========================================================

  Future<void> rememberMeChanged(
    RememberMeChanged event,
    Emitter<UserState> emit,
  ) async {
    // --------------------------------------------------------
    // DISABLED
    // --------------------------------------------------------

    if (!event.rememberMe) {
      await repository.clearRememberMe();

      emit(
        state.copyWith(
          rememberMe: false,

          hasRememberedAccount: false,

          hasRememberedSession: false,

          rememberedUsername: '',

          clearError: true,
        ),
      );

      return;
    }

    // --------------------------------------------------------
    // ENABLED
    // --------------------------------------------------------
    //
    // Nothing is stored until a successful login.
    // --------------------------------------------------------

    emit(state.copyWith(rememberMe: true, clearError: true));
  }

  // ==========================================================
  // USE ANOTHER ACCOUNT
  // ==========================================================

  Future<void> useAnotherAccountRequested(
    UseAnotherAccountRequested event,
    Emitter<UserState> emit,
  ) async {
    // Remove remembered credentials.
    await repository.clearRememberMe();

    // Remove any active access token.
    await repository.logout();

    emit(
      UserState(
        authStatus: AuthStatus.initial,

        rememberMe: false,

        hasRememberedAccount: false,

        hasRememberedSession: false,

        authenticatedUsername: '',

        username: '',

        rememberedUsername: '',

        // Preserve biometric capability information.
        hasFingerprint: state.hasFingerprint,

        hasFaceAuthentication: state.hasFaceAuthentication,

        hasIrisAuthentication: state.hasIrisAuthentication,
      ),
    );
  }

  // ==========================================================
  // LOGOUT / LOCK APP
  // ==========================================================

  Future<void> userLogoutRequested(
    UserLogoutRequested event,
    Emitter<UserState> emit,
  ) async {
    // --------------------------------------------------------
    // CHECK REMEMBERED ACCOUNT
    // --------------------------------------------------------

    final hasRememberedAccount = await repository.hasRememberedAccount();

    final rememberedUsername = hasRememberedAccount
        ? await repository.getRememberedUsername() ?? ''
        : '';

    final lastUsername = state.authenticatedUsername.trim().isNotEmpty
        ? state.authenticatedUsername
        : state.username.trim();

    // Remove the active API session.
    //
    // Remembered credentials intentionally survive.
    await repository.logout();

    emit(
      UserState(
        authStatus: AuthStatus.unauthenticated,

        rememberMe: hasRememberedAccount,

        hasRememberedAccount: hasRememberedAccount,

        hasRememberedSession: false,

        rememberedUsername: rememberedUsername,

        username: hasRememberedAccount ? rememberedUsername : lastUsername,

        authenticatedUsername: '',

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

        hasRememberedSession: false,

        authenticatedUsername: '',

        username: lastUsername,

        clearError: true,
      ),
    );
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

      final rememberedUsername = hasRememberedAccount
          ? await repository.getRememberedUsername() ?? ''
          : '';

      // ------------------------------------------------------
      // IMPORTANT
      // ------------------------------------------------------
      //
      // Password is intentionally NOT loaded into UserState.
      //
      // It remains inside secure storage.
      //
      // Any old access token is removed so the application
      // always requires fresh authentication on launch.
      // ------------------------------------------------------

      await repository.logout();

      emit(
        state.copyWith(
          isLoading: false,

          authStatus: AuthStatus.initial,

          rememberMe: hasRememberedAccount,

          hasRememberedAccount: hasRememberedAccount,

          hasRememberedSession: false,

          rememberedUsername: rememberedUsername,

          username: hasRememberedAccount ? rememberedUsername : '',

          authenticatedUsername: '',

          clearError: true,
        ),
      );

      add(const CheckBiometricAvailability());
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,

          authStatus: AuthStatus.initial,

          rememberMe: false,

          hasRememberedAccount: false,

          hasRememberedSession: false,

          rememberedUsername: '',

          authenticatedUsername: '',

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
    // REMEMBERED ACCOUNT REQUIRED
    // --------------------------------------------------------

    if (!state.hasRememberedAccount ||
        state.rememberedUsername.trim().isEmpty) {
      emit(
        state.copyWith(
          errorMessage:
              'No remembered account is available '
              'for biometric login.',
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
      // DEVICE SUPPORT
      // ------------------------------------------------------

      final canUseBiometrics = await biometricService.canUseBiometrics();

      final hasBiometric = await biometricService.hasAvailableBiometric();

      if (!canUseBiometrics || !hasBiometric) {
        emit(
          state.copyWith(
            isLoading: false,

            authStatus: AuthStatus.initial,

            errorMessage:
                'No enrolled biometric authentication '
                'is available on this device.',
          ),
        );

        return;
      }

      // ------------------------------------------------------
      // OS BIOMETRIC PROMPT
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
      // FRESH BACKEND LOGIN
      // ------------------------------------------------------
      //
      // Repository retrieves the remembered password
      // directly from secure storage.
      //
      // UserBloc never receives the stored password.
      // ------------------------------------------------------

      final loginResponse = await repository.loginRememberedAccount();

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
