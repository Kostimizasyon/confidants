import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isBiometricsAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck || isSupported;
    } on PlatformException {
      return false;
    }
  }

  /// [reason] is shown in the native OS prompt; callers pass a localized string.
  Future<bool> authenticate({required String reason}) async {
    try {
      final available = await isBiometricsAvailable();
      if (!available) return false;

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
