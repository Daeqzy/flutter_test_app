import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/login_request.dart';
import '../models/location_result.dart';
import '../network_service/api_service.dart';

class DataRepository {
  final ApiService apiService;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  DataRepository(this.apiService);

  // LOGIN
  Future<void> login(String username, String password) async {
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
  }

  // GET USER LOCATIONS
  Future<List<LocationResult>> getUserLocations() async {
    final locations = await apiService.getUserLocations();

    return locations;
  }
}
