import '../data_sources/user_data_sources.dart';
import '../models/user.dart';
import '../models/location_result.dart';
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

  Future<List<LocationResult>> getUserLocations() {
    return dataRepository.getUserLocations();
  }

  Future<void> logout() {
    return dataRepository.logout();
  }
}
