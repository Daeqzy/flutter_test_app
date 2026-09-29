import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // ----------------------------------------------------------
  // CAN DEVICE USE BIOMETRICS?
  // ----------------------------------------------------------

  Future<bool> canUseBiometrics() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;

      final isDeviceSupported = await _auth.isDeviceSupported();

      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      print('Error checking biometric support: $e');

      return false;
    }
  }

  // ----------------------------------------------------------
  // AVAILABLE BIOMETRIC TYPES
  // ----------------------------------------------------------

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting biometrics: $e');

      return [];
    }
  }

  // ----------------------------------------------------------
  // FINGERPRINT AVAILABLE?
  // ----------------------------------------------------------

  Future<bool> hasFingerprint() async {
    final biometrics = await getAvailableBiometrics();

    return biometrics.contains(BiometricType.fingerprint);
  }

  // ----------------------------------------------------------
  // FACE / FACE ID AVAILABLE?
  // ----------------------------------------------------------

  Future<bool> hasFaceAuthentication() async {
    final biometrics = await getAvailableBiometrics();

    return biometrics.contains(BiometricType.face);
  }

  // ----------------------------------------------------------
  // IRIS AVAILABLE?
  // ----------------------------------------------------------

  Future<bool> hasIrisAuthentication() async {
    final biometrics = await getAvailableBiometrics();

    return biometrics.contains(BiometricType.iris);
  }

  // ----------------------------------------------------------
  // ANY ENROLLED BIOMETRIC?
  // ----------------------------------------------------------

  Future<bool> hasAvailableBiometric() async {
    final biometrics = await getAvailableBiometrics();

    return biometrics.isNotEmpty;
  }

  // ----------------------------------------------------------
  // AUTHENTICATE
  // ----------------------------------------------------------

  Future<bool> authenticate() async {
    try {
      final result = await _auth.authenticate(
        localizedReason: 'Authenticate to continue to your CODEX account',

        biometricOnly: true,

        persistAcrossBackgrounding: true,
      );

      print('Biometric authentication result: $result');

      return result;
    } on LocalAuthException catch (e) {
      print('Biometric error code: ${e.code}');

      print('Biometric authentication error: $e');

      rethrow;
    }
  }
}
