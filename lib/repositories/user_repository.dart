import '../data_sources/user_data_sources.dart';
import '../models/user.dart';

class UserRepository {
  final UserDataSource dataSource;

  UserRepository(this.dataSource);

  // Login
  Future<User> login(String username, String password) {
    return dataSource.login(username, password);
  }

  // Get all users
  Future<List<User>> getUsers() {
    return dataSource.getUsers();
  }

  // Add a new user
  Future<void> addUser(String username, String email) {
    return dataSource.addUser(username, email);
  }
}
