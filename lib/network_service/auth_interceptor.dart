import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/auth_session_service.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  final AuthSessionService authSessionService;

  AuthInterceptor(this.authSessionService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isLoginRequest = _isLoginRequest(options);

    if (!isLoginRequest) {
      final accessToken = await secureStorage.read(key: 'accessToken');

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    print('REQUEST: ${options.method} ${options.uri}');

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    final isLoginRequest = _isLoginRequest(err.requestOptions);

    if (statusCode == 401 && !isLoginRequest) {
      await _clearSessionTokens();

      authSessionService.notifySessionExpired();

      print('Session expired: authentication tokens cleared.');
    }

    handler.next(err);
  }

  bool _isLoginRequest(RequestOptions options) {
    return options.path.contains('api/Account/Login');
  }

  Future<void> _clearSessionTokens() async {
    await secureStorage.delete(key: 'accessToken');

    await secureStorage.delete(key: 'refreshToken');
  }
}
