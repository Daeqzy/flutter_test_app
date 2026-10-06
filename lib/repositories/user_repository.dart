import '../core/errors/app_exception.dart';

import '../data_sources/user_data_sources.dart';

import '../models/login_response.dart';
import '../models/user.dart';

import 'data_repository.dart';

class UserRepository {
  final UserDataSource dataSource;

  final DataRepository dataRepository;

  UserRepository(this.dataSource, this.dataRepository);

  // ==========================================================
  // NORMAL LOGIN
  // ==========================================================

  Future<LoginResponse> login(String username, String password) async {
    return await dataRepository.login(username, password);
  }

  // ==========================================================
  // REMEMBERED ACCOUNT LOGIN
  // ==========================================================
  //
  // IMPORTANT:
  //
  // The remembered password is read from secure storage
  // INSIDE the repository.
  //
  // It never enters:
  //
  // UserState
  // LoginScreen
  // TextFormField
  // BlocBuilder
  //
  // ==========================================================

  Future<LoginResponse> loginRememberedAccount() async {
    final username = await dataRepository.getRememberedUsername();

    final password = await dataRepository.getRememberedPassword();

    if (username == null ||
        username.trim().isEmpty ||
        password == null ||
        password.isEmpty) {
      throw const AppException(
        'No remembered account is available '
        'for biometric login.',
      );
    }

    final response = await dataRepository.login(username.trim(), password);

    // Keep the stored username synchronized
    // with the backend response.
    //
    // The password still stays inside
    // the repository / secure storage layer.
    await dataRepository.saveRememberMe(response.username, password);

    return response;
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> logout() {
    return dataRepository.logout();
  }

  // ==========================================================
  // REMEMBER ACCOUNT
  // ==========================================================

  Future<void> saveRememberMe(String username, String password) async {
    await dataRepository.saveRememberMe(username, password);
  }

  Future<void> clearRememberMe() async {
    await dataRepository.clearRememberMe();
  }

  Future<bool> hasRememberedAccount() async {
    return await dataRepository.hasRememberedAccount();
  }

  Future<String?> getRememberedUsername() async {
    return await dataRepository.getRememberedUsername();
  }

  // ==========================================================
  // LOCAL / DEMO USERS
  // ==========================================================

  Future<List<User>> getUsers() {
    return dataSource.getUsers();
  }

  Future<void> addUser(String username, String email) {
    return dataSource.addUser(username, email);
  }
}
