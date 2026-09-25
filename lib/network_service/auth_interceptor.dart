import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isLoginRequest = options.path.contains('api/Account/Login');

    if (!isLoginRequest) {
      final accessToken = await secureStorage.read(key: 'accessToken');

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    print('REQUEST: ${options.method} ${options.uri}');

    handler.next(options);
  }
}
