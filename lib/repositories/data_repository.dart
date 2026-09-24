import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/location_result.dart';
import '../network_service/api_service.dart';

class DataRepository {
  final ApiService apiService;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  DataRepository(this.apiService);

  // LOGIN
  Future<LoginResponse> login(String username, String password) async {
    final request = LoginRequest(username: username, password: password);

    final response = await apiService.login(request);

    // Save access token securely
    await secureStorage.write(key: 'accessToken', value: response.accessToken);

    // Save refresh token securely
    await secureStorage.write(
      key: 'refreshToken',
      value: response.refreshToken,
    );

    print('Logged in as: ${response.username}');
    print('Tokens saved securely');
    return response;
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'accessToken');
    await secureStorage.delete(key: 'refreshToken');
  }

  // GET USER LOCATIONS
  Future<List<LocationResult>> getUserLocations() async {
    final locations = await apiService.getUserLocations();

    return locations;
  }
}
