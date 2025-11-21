import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // Chaves
  static const String _keyDeviceId = 'device_id';
  static const String _keyAuthToken = 'auth_token';
  static const String _keySubscriptionStatus = 'subscription_status';

  /// Salva um valor seguro
  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Lê um valor seguro
  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Remove um valor
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Limpa todos os dados seguros
  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // --- Métodos Específicos ---

  static Future<void> saveDeviceId(String deviceId) async {
    await write(_keyDeviceId, deviceId);
  }

  static Future<String?> getDeviceId() async {
    return await read(_keyDeviceId);
  }

  static Future<void> saveAuthToken(String token) async {
    await write(_keyAuthToken, token);
  }

  static Future<String?> getAuthToken() async {
    return await read(_keyAuthToken);
  }

  static Future<void> saveSubscriptionStatus(bool isPremium) async {
    await write(_keySubscriptionStatus, isPremium.toString());
  }

  static Future<bool> getSubscriptionStatus() async {
    final status = await read(_keySubscriptionStatus);
    return status == 'true';
  }
}
