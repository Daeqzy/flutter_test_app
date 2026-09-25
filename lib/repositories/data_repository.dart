import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/mat_partner_data.dart';
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

    await clearRememberMe();
  }

  Future<List<MatPartnerData>> getPartners() async {
    final partners = await apiService.getPartners();

    return partners;
  }

  Future<void> saveRememberMe(String username) async {
    await secureStorage.write(key: 'rememberMe', value: 'true');

    await secureStorage.write(key: 'rememberedUsername', value: username);
  }

  Future<void> clearRememberMe() async {
    await secureStorage.delete(key: 'rememberMe');

    await secureStorage.delete(key: 'rememberedUsername');
  }

  Future<bool> hasRememberedSession() async {
    final rememberMe = await secureStorage.read(key: 'rememberMe');

    final accessToken = await secureStorage.read(key: 'accessToken');

    return rememberMe == 'true' &&
        accessToken != null &&
        accessToken.isNotEmpty;
  }

  Future<String?> getRememberedUsername() async {
    return await secureStorage.read(key: 'rememberedUsername');
  }
}
