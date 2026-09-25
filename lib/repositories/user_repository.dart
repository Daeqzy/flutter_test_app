import '../data_sources/user_data_sources.dart';
import '../models/user.dart';
import '../models/login_response.dart';
import 'data_repository.dart';

class UserRepository {
  final UserDataSource dataSource;
  final DataRepository dataRepository;

  UserRepository(this.dataSource, this.dataRepository);

  // Real API login through DataRepository
  Future<LoginResponse> login(String username, String password) async {
    return await dataRepository.login(username, password);
  }

  // Fake/local users for now
  Future<List<User>> getUsers() {
    return dataSource.getUsers();
  }

  // Fake/local add user for now
  Future<void> addUser(String username, String email) {
    return dataSource.addUser(username, email);
  }

  Future<void> logout() {
    return dataRepository.logout();
  }

  Future<void> saveRememberMe(String username) async {
    await dataRepository.saveRememberMe(username);
  }

  Future<void> clearRememberMe() async {
    await dataRepository.clearRememberMe();
  }

  Future<bool> hasRememberedSession() async {
    return await dataRepository.hasRememberedSession();
  }

  Future<String?> getRememberedUsername() async {
    return await dataRepository.getRememberedUsername();
  }
}
