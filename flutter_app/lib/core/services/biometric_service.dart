import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final _auth = LocalAuthentication();
  static const _biometricEnabledKey = 'vip_biometric_enabled';
  static const _savedEmailKey = 'vip_biometric_email';
  static const _savedPasswordKey = 'vip_biometric_password';

  /// Revisa si el usuario ha activado la huella digital o Face ID
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Revisa si el dispositivo tiene hardware biométrico compatible
  static Future<bool> isDeviceSupported() async {
    if (kIsWeb) return true; // En Web permitimos simulación VIP Studio
    try {
      return await _auth.isDeviceSupported() || await _auth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Guarda o elimina la preferencia y credenciales seguras
  static Future<void> setBiometricEnabled(bool enabled, [String? email, String? password]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
    if (enabled && email != null && password != null) {
      await prefs.setString(_savedEmailKey, email);
      await prefs.setString(_savedPasswordKey, password);
    } else if (!enabled) {
      await prefs.remove(_savedEmailKey);
      await prefs.remove(_savedPasswordKey);
    }
  }

  /// Retorna las credenciales guardadas para auto-login
  static Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_biometricEnabledKey) ?? false;
    if (!enabled) return null;
    final email = prefs.getString(_savedEmailKey);
    final pass = prefs.getString(_savedPasswordKey);
    if (email != null && pass != null) {
      return {'email': email, 'password': pass};
    }
    return null;
  }

  /// Lanza la solicitud biométrica nativa o simulación en Web
  static Future<bool> authenticate({required String reason}) async {
    if (kIsWeb) {
      // En Chrome/Web devolvemos true para que la UI maneje la animación del escáner VIP
      return true;
    }
    try {
      final canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canCheck) return false;
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
