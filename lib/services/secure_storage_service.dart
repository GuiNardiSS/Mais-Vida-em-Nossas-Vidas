import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SecureStorageService {
  // Configuração otimizada para compatibilidade com todos os dispositivos Android
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // Permite reset automático se houver erro de keystore
      resetOnError: true,
    ),
  );

  // Fallback para SharedPreferences se SecureStorage falhar
  static bool _useSecureStorage = true;
  static SharedPreferences? _prefs;

  // Chaves
  static const String _keyDeviceId = 'device_id';
  static const String _keyAuthToken = 'auth_token';
  static const String _keySubscriptionStatus = 'subscription_status';

  /// Inicializa o serviço e verifica se SecureStorage funciona
  static Future<void> _ensureInitialized() async {
    if (!_useSecureStorage && _prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  /// Salva um valor seguro com fallback
  static Future<void> write(String key, String value) async {
    try {
      if (_useSecureStorage) {
        await _storage.write(key: key, value: value);
      } else {
        await _ensureInitialized();
        await _prefs!.setString(key, value);
      }
    } catch (e) {
      // Se falhar com SecureStorage, muda para SharedPreferences
      if (_useSecureStorage) {
        debugPrint('SecureStorage falhou, usando SharedPreferences: $e');
        _useSecureStorage = false;
        await _ensureInitialized();
        await _prefs!.setString(key, value);
      } else {
        rethrow;
      }
    }
  }

  /// Lê um valor seguro com fallback
  static Future<String?> read(String key) async {
    try {
      if (_useSecureStorage) {
        return await _storage.read(key: key);
      } else {
        await _ensureInitialized();
        return _prefs!.getString(key);
      }
    } catch (e) {
      // Se falhar com SecureStorage, muda para SharedPreferences
      if (_useSecureStorage) {
        debugPrint('SecureStorage falhou, usando SharedPreferences: $e');
        _useSecureStorage = false;
        await _ensureInitialized();
        return _prefs!.getString(key);
      }
      return null;
    }
  }

  /// Remove um valor com fallback
  static Future<void> delete(String key) async {
    try {
      if (_useSecureStorage) {
        await _storage.delete(key: key);
      } else {
        await _ensureInitialized();
        await _prefs!.remove(key);
      }
    } catch (e) {
      // Se falhar com SecureStorage, muda para SharedPreferences
      if (_useSecureStorage) {
        debugPrint('SecureStorage falhou, usando SharedPreferences: $e');
        _useSecureStorage = false;
        await _ensureInitialized();
        await _prefs!.remove(key);
      }
    }
  }

  /// Limpa todos os dados seguros com fallback
  static Future<void> deleteAll() async {
    try {
      if (_useSecureStorage) {
        await _storage.deleteAll();
      } else {
        await _ensureInitialized();
        await _prefs!.clear();
      }
    } catch (e) {
      // Se falhar com SecureStorage, muda para SharedPreferences
      if (_useSecureStorage) {
        debugPrint('SecureStorage falhou, usando SharedPreferences: $e');
        _useSecureStorage = false;
        await _ensureInitialized();
        await _prefs!.clear();
      }
    }
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
