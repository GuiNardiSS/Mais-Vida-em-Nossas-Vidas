import 'dart:io';
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
    // Retorna do cache se já tiver
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    // Verifica se já foi salvo anteriormente no Secure Storage
    String? savedId = await SecureStorageService.getDeviceId();

    if (savedId != null && savedId.isNotEmpty) {
      _cachedDeviceId = savedId;
      return savedId;
    }

    // Gera novo ID baseado no dispositivo
    String deviceId = await _generateDeviceId();

    // Salva para uso futuro
    await SecureStorageService.saveDeviceId(deviceId);
    _cachedDeviceId = deviceId;

    return deviceId;
  }

  /// Gera ID único do dispositivo baseado em informações do hardware
  static Future<String> _generateDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String identifier = '';

    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // Combina múltiplos identificadores para criar ID único
        identifier =
            '${androidInfo.id}-${androidInfo.device}-${androidInfo.model}';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        identifier = '${iosInfo.identifierForVendor}-${iosInfo.model}';
      } else {
        // Fallback para outras plataformas
        identifier = 'unknown-${DateTime.now().millisecondsSinceEpoch}';
      }
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
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemVersion': iosInfo.systemVersion,
          'utsname': iosInfo.utsname.machine,
        };
      }
    } catch (e) {
      return {'platform': 'unknown', 'error': e.toString()};
    }

    return {'platform': 'unknown'};
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
