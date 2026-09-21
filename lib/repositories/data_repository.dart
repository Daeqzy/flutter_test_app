import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/login_request.dart';
import '../network_service/api_service.dart';

class DataRepository {
  final ApiService apiService;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  DataRepository(this.apiService);

  Future<void> login(String username, String password) async {
    final request = LoginRequest(username: username, password: password);

    final response = await apiService.login(request);

    await secureStorage.write(key: 'accessToken', value: response.accessToken);

    await secureStorage.write(
      key: 'refreshToken',
      value: response.refreshToken,
    );

    print('Logged in as: ${response.username}');
    print('Tokens saved securely');
  }
}
