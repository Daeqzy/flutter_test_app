import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canUseBiometrics() async {
    final canCheckBiometrics = await _auth.canCheckBiometrics;

    final isDeviceSupported = await _auth.isDeviceSupported();

    return canCheckBiometrics && isDeviceSupported;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }

  Future<bool> authenticate() async {
    try {
      final result = await _auth.authenticate(
        localizedReason: 'Authenticate to continue to your CODEX account',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      print('Biometric result: $result');

      return result;
    } on LocalAuthException catch (e) {
      print('Biometric error code: ${e.code}');
      print('Biometric error: $e');

      rethrow;
    }
  }
}
