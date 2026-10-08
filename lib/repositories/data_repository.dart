import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/errors/app_exception.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/mat_partner_data.dart';
import '../models/partner_connection_data.dart';
import '../models/partner_agreement_data.dart';
import '../models/partner_contact_data.dart';
import '../models/change_password_request.dart';

import '../network_service/api_service.dart';

class DataRepository {
  final ApiService apiService;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  DataRepository(this.apiService);

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<LoginResponse> login(String username, String password) async {
    final request = LoginRequest(username: username, password: password);

    final response = await _safeApiCall(() => apiService.login(request));

    await secureStorage.write(key: 'accessToken', value: response.accessToken);

    await secureStorage.write(
      key: 'refreshToken',
      value: response.refreshToken,
    );

    print('Logged in as: ${response.username}');

    print('Tokens saved securely');

    return response;
  }

  // ==========================================================
  // CHANGE PASSWORD
  // ==========================================================

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final request = ChangePasswordRequest(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    await _safeApiCall<void>(() => apiService.changePassword(request));
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> logout() async {
    // End the authenticated session.
    await secureStorage.delete(key: 'accessToken');

    await secureStorage.delete(key: 'refreshToken');

    // Remembered account information intentionally survives.
  }

  // ==========================================================
  // REMEMBER ME
  // ==========================================================

  Future<void> saveRememberMe(String username, String password) async {
    await secureStorage.write(key: 'rememberMe', value: 'true');

    await secureStorage.write(key: 'rememberedUsername', value: username);

    await secureStorage.write(key: 'rememberedPassword', value: password);
  }

  Future<void> clearRememberMe() async {
    await secureStorage.delete(key: 'rememberMe');

    await secureStorage.delete(key: 'rememberedUsername');

    await secureStorage.delete(key: 'rememberedPassword');
  }

  Future<bool> hasRememberedAccount() async {
    final rememberMe = await secureStorage.read(key: 'rememberMe');

    final rememberedUsername = await secureStorage.read(
      key: 'rememberedUsername',
    );

    return rememberMe == 'true' &&
        rememberedUsername != null &&
        rememberedUsername.trim().isNotEmpty;
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

  Future<String?> getRememberedPassword() async {
    return await secureStorage.read(key: 'rememberedPassword');
  }

  // ==========================================================
  // PARTNERS
  // ==========================================================

  Future<List<MatPartnerData>> getPartners() async {
    return await _safeApiCall(() => apiService.getPartners());
  }

  // ==========================================================
  // PARTNER CONNECTIONS
  // ==========================================================

  Future<List<PartnerConnectionData>> getPartnerConnections(
    int tp,
    int p,
  ) async {
    return await _safeApiCall(() => apiService.getPartnerConnections(tp, p));
  }

  // ==========================================================
  // PARTNER AGREEMENTS
  // ==========================================================

  Future<List<PartnerAgreementData>> getPartnerAgreements(int tp, int p) async {
    return await _safeApiCall(() => apiService.getPartnerAgreements(tp, p));
  }

  // ==========================================================
  // PARTNER CONTACTS
  // ==========================================================

  Future<List<PartnerContactData>> getPartnerContacts(int tp, int p) async {
    return await _safeApiCall(() => apiService.getPartnerContacts(tp, p));
  }

  // ==========================================================
  // SAFE API CALL
  //
  // Every Dio request passes through here.
  // ==========================================================

  Future<T> _safeApiCall<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      // Something happened that wasn't a Dio/network error.
      throw const AppException('Something went wrong. Please try again.');
    }
  }

  // ==========================================================
  // DIO ERROR → FRIENDLY APP ERROR
  // ==========================================================

  AppException _mapDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        return const AppException(
          'The server took too long to respond. Please try again.',
        );

      case DioExceptionType.sendTimeout:
        return const AppException(
          'The request took too long to send. Please try again.',
        );

      case DioExceptionType.receiveTimeout:
        return const AppException(
          'The server took too long to send a response.',
        );

      case DioExceptionType.transformTimeout:
        return const AppException(
          'The server response took too long to process.',
        );

      case DioExceptionType.connectionError:
        return const AppException(
          'Unable to connect to the server. Check your network connection.',
        );

      case DioExceptionType.badCertificate:
        return const AppException(
          'A secure connection to the server could not be established.',
        );

      case DioExceptionType.cancel:
        return const AppException('The request was cancelled.');

      case DioExceptionType.badResponse:
        return _handleHttpError(exception);

      case DioExceptionType.unknown:
        return const AppException('Unable to communicate with the server.');
    }
  }

  // ==========================================================
  // HTTP STATUS CODE HANDLING
  // ==========================================================

  AppException _handleHttpError(DioException exception) {
    final statusCode = exception.response?.statusCode;

    final path = exception.requestOptions.path;

    switch (statusCode) {
      // ------------------------------------------------------
      // 400 BAD REQUEST
      // ------------------------------------------------------

      case 400:
        if (path.contains('api/Account/ChangePassword')) {
          return const AppException(
            'The current password is incorrect '
            'or the new password is invalid.',
            statusCode: 400,
          );
        }

        return const AppException(
          'The request was invalid. '
          'Please check the information and try again.',
          statusCode: 400,
        );

      // ------------------------------------------------------
      // 403 FORBIDDEN
      // ------------------------------------------------------

      case 403:
        return const AppException(
          'You do not have permission to perform this action.',
          statusCode: 403,
        );

      // ------------------------------------------------------
      // 404 NOT FOUND
      // ------------------------------------------------------

      case 404:
        return const AppException(
          'The requested information could not be found.',
          statusCode: 404,
        );

      // ------------------------------------------------------
      // 408 REQUEST TIMEOUT
      // ------------------------------------------------------

      case 408:
        return const AppException(
          'The request timed out. Please try again.',
          statusCode: 408,
        );

      // ------------------------------------------------------
      // 409 CONFLICT
      // ------------------------------------------------------

      case 409:
        return const AppException(
          'The request conflicts with existing data.',
          statusCode: 409,
        );

      // ------------------------------------------------------
      // 422 VALIDATION
      // ------------------------------------------------------

      case 422:
        return const AppException(
          'Some of the provided information is invalid.',
          statusCode: 422,
        );

      // ------------------------------------------------------
      // 429 TOO MANY REQUESTS
      // ------------------------------------------------------

      case 429:
        return const AppException(
          'Too many requests. Please wait a moment and try again.',
          statusCode: 429,
        );

      // ------------------------------------------------------
      // 500
      // ------------------------------------------------------

      case 500:
        return const AppException(
          'The server encountered an error. Please try again.',
          statusCode: 500,
        );

      // ------------------------------------------------------
      // 502
      // ------------------------------------------------------

      case 502:
        return const AppException(
          'The server is temporarily unavailable.',
          statusCode: 502,
        );

      // ------------------------------------------------------
      // 503
      // ------------------------------------------------------

      case 503:
        return const AppException(
          'The service is temporarily unavailable. Please try again later.',
          statusCode: 503,
        );

      // ------------------------------------------------------
      // 504
      // ------------------------------------------------------

      case 504:
        return const AppException(
          'The server took too long to respond.',
          statusCode: 504,
        );

      // ------------------------------------------------------
      // OTHER HTTP ERRORS
      // ------------------------------------------------------

      default:
        return AppException(
          'Something went wrong while communicating with the server.',
          statusCode: statusCode,
        );
    }
  }
}
