import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'secure_storage_service.dart';

/// Service para identificação única do dispositivo
/// Usado para validar assinatura sem necessidade de login de usuário
class DeviceService {
  static String? _cachedDeviceId;

  /// Obtém ID único do dispositivo (gerado uma vez e armazenado)
  static Future<String> getDeviceId() async {
    try {
      // Retorna do cache se já tiver
      if (_cachedDeviceId != null) {
        return _cachedDeviceId!;
      }

      // Aguarda um pouco para garantir que o sistema está pronto
      await Future.delayed(const Duration(milliseconds: 50));

      // Verifica se já foi salvo anteriormente no Secure Storage
      String? savedId;
      try {
        savedId = await SecureStorageService.getDeviceId();
      } catch (e) {
        // Se SecureStorage falhar, gera novo ID
        savedId = null;
      }

      if (savedId != null && savedId.isNotEmpty) {
        _cachedDeviceId = savedId;
        return savedId;
      }

      // Gera novo ID baseado no dispositivo
      String deviceId = await _generateDeviceId();

      // Tenta salvar para uso futuro (não falha se não conseguir)
      try {
        await SecureStorageService.saveDeviceId(deviceId);
      } catch (e) {
        // Ignora erro de salvamento
      }

      _cachedDeviceId = deviceId;

      return deviceId;
    } catch (e) {
      // Em caso de qualquer erro, retorna um ID temporário
      return 'temp_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Gera ID único do dispositivo baseado em informações do hardware
  static Future<String> _generateDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String identifier = '';

    try {
      // ANDROID ONLY - App configurado apenas para Android
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      // Combina múltiplos identificadores para criar ID único
      identifier =
          '${androidInfo.id}-${androidInfo.device}-${androidInfo.model}-${androidInfo.brand}';
    } catch (e) {
      // Se falhar, gera ID aleatório baseado no timestamp
      identifier = 'fallback-${DateTime.now().millisecondsSinceEpoch}';
    }

    // Gera hash SHA256 para garantir formato consistente e seguro
    final bytes = utf8.encode(identifier);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  /// Obtém informações detalhadas do dispositivo (para logs/debug)
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      // ANDROID ONLY - App configurado apenas para Android
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return {
        'platform': 'android',
        'model': androidInfo.model,
        'brand': androidInfo.brand,
        'device': androidInfo.device,
        'manufacturer': androidInfo.manufacturer,
        'version': androidInfo.version.release,
        'sdkInt': androidInfo.version.sdkInt,
        'androidId': androidInfo.id,
      };
    } catch (e) {
      return {'platform': 'android', 'error': e.toString()};
    }
  }

  /// Limpa o device ID (útil para testes ou reset)
  static Future<void> clearDeviceId() async {
    await SecureStorageService.delete('device_id');
    _cachedDeviceId = null;
  }

  /// Verifica se o device ID já foi gerado
  static Future<bool> hasDeviceId() async {
    if (_cachedDeviceId != null) return true;

    final savedId = await SecureStorageService.getDeviceId();
    return savedId != null;
  }
}
