import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // ==========================================================
  // CAN DEVICE USE BIOMETRICS?
  // ==========================================================

  Future<bool> canUseBiometrics() async {
    try {
      final isDeviceSupported = await _auth.isDeviceSupported();

      if (!isDeviceSupported) {
        return false;
      }

      final canCheckBiometrics = await _auth.canCheckBiometrics;

      if (!canCheckBiometrics) {
        return false;
      }

      final availableBiometrics = await _auth.getAvailableBiometrics();

      return availableBiometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ==========================================================
  // AVAILABLE BIOMETRIC TYPES
  // ==========================================================

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return <BiometricType>[];
    }
  }

  // ==========================================================
  // FINGERPRINT AVAILABLE?
  // ==========================================================

  Future<bool> hasFingerprint() async {
    final biometrics = await getAvailableBiometrics();

    return biometrics.contains(BiometricType.fingerprint);
  }

  // ==========================================================
  // FACE AVAILABLE?
  // ==========================================================

  Future<bool> hasFaceAuthentication() async {
    final biometrics = await getAvailableBiometrics();

    return biometrics.contains(BiometricType.face);
  }

  // ==========================================================
  // IRIS AVAILABLE?
  // ==========================================================

  Future<bool> hasIrisAuthentication() async {
    final biometrics = await getAvailableBiometrics();

    return biometrics.contains(BiometricType.iris);
  }

  // ==========================================================
  // ANY ENROLLED BIOMETRIC?
  // ==========================================================

  Future<bool> hasAvailableBiometric() async {
    try {
      final biometrics = await getAvailableBiometrics();

      return biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ==========================================================
  // AUTHENTICATE
  // ==========================================================

  Future<bool> authenticate() async {
    try {
      // ------------------------------------------------------
      // MAKE SURE THERE IS AN ENROLLED BIOMETRIC
      // ------------------------------------------------------

      final available = await getAvailableBiometrics();

      if (available.isEmpty) {
        return false;
      }

      // ------------------------------------------------------
      // OPEN THE DEVICE'S BIOMETRIC PROMPT
      // ------------------------------------------------------
      //
      // Android/iOS ultimately decides which enrolled
      // biometric is presented.
      // ------------------------------------------------------

      return await _auth.authenticate(
        localizedReason:
            'Verify your identity to sign in to your CODEX account',

        biometricOnly: true,

        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      rethrow;
    } catch (_) {
      return false;
    }
  }
}
