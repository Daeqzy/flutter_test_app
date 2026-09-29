import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/mat_partner_data.dart';
import '../models/partner_connection_data.dart';
import '../models/partner_agreement_data.dart';
import '../models/partner_contact_data.dart';
import '../network_service/api_service.dart';

class DataRepository {
  final ApiService apiService;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  DataRepository(this.apiService);

  // ----------------------------------------------------------
  // LOGIN
  // ----------------------------------------------------------

  Future<LoginResponse> login(String username, String password) async {
    final request = LoginRequest(username: username, password: password);

    final response = await apiService.login(request);

    await secureStorage.write(key: 'accessToken', value: response.accessToken);

    await secureStorage.write(
      key: 'refreshToken',
      value: response.refreshToken,
    );

    print('Logged in as: ${response.username}');

    print('Tokens saved securely');

    return response;
  }

  // ----------------------------------------------------------
  // LOGOUT
  // ----------------------------------------------------------

  Future<void> logout() async {
    // End the active authenticated session.
    await secureStorage.delete(key: 'accessToken');

    await secureStorage.delete(key: 'refreshToken');

    // IMPORTANT:
    // Do NOT delete rememberMe or rememberedUsername.
    //
    // A remembered account is allowed to survive logout.
  }

  // ----------------------------------------------------------
  // REMEMBER ME
  // ----------------------------------------------------------

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

  // ----------------------------------------------------------
  // PARTNERS
  // ----------------------------------------------------------

  Future<List<MatPartnerData>> getPartners() async {
    final partners = await apiService.getPartners();

    return partners;
  }

  // ----------------------------------------------------------
  // PARTNER CONNECTIONS
  // ----------------------------------------------------------

  Future<List<PartnerConnectionData>> getPartnerConnections(
    int tp,
    int p,
  ) async {
    final connections = await apiService.getPartnerConnections(tp, p);

    return connections;
  }

  // ----------------------------------------------------------
  // PARTNER AGREEMENTS
  // ----------------------------------------------------------

  Future<List<PartnerAgreementData>> getPartnerAgreements(int tp, int p) async {
    final agreements = await apiService.getPartnerAgreements(tp, p);

    return agreements;
  }

  // ----------------------------------------------------------
  // PARTNER CONTACTS
  // ----------------------------------------------------------

  Future<List<PartnerContactData>> getPartnerContacts(int tp, int p) async {
    final contacts = await apiService.getPartnerContacts(tp, p);

    return contacts;
  }
}
