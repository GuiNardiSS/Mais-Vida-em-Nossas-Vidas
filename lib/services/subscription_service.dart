import 'dart:convert';
import 'package:http/http.dart' as http;
import 'device_service.dart';
import 'app_logger.dart';
import 'secure_storage_service.dart';
import '../config/api_config.dart';

/// Status da assinatura
enum SubscriptionStatus {
  free, // Usuário sem assinatura
  active, // Assinatura ativa e válida
  expired, // Assinatura expirada
  pending, // Pagamento pendente
}

/// Service para gerenciar assinatura premium
/// Sistema funciona SEM login de usuário, usando Device ID
class SubscriptionService {
  // Keys para SecureStorage
  static const String _statusKey = 'subscription_status';
  static const String _expiryKey = 'subscription_expiry';
  static const String _transactionIdKey = 'subscription_transaction_id';
  static const String _lastCheckKey = 'subscription_last_check';

  // Cache em memória
  static SubscriptionStatus? _cachedStatus;
  static DateTime? _cachedExpiry;

  /// Verifica se o usuário tem assinatura premium ativa
  static Future<bool> isPremium() async {
    final status = await getSubscriptionStatus();
    return status == SubscriptionStatus.active;
  }

  /// Obtém o status atual da assinatura
  static Future<SubscriptionStatus> getSubscriptionStatus() async {
    // Retorna do cache se disponível e recente
    if (_cachedStatus != null && _cachedExpiry != null) {
      if (_cachedExpiry!.isAfter(DateTime.now())) {
        return _cachedStatus!;
      }
    }

    // Carrega do SecureStorage
    final statusStr = await SecureStorageService.read(_statusKey);
    final expiryStr = await SecureStorageService.read(_expiryKey);

    if (statusStr != null && expiryStr != null) {
      final status = _parseStatus(statusStr);
      final expiry = DateTime.parse(expiryStr);

      // Se expirou, atualiza o status
      if (expiry.isBefore(DateTime.now()) &&
          status == SubscriptionStatus.active) {
        await _updateLocalStatus(SubscriptionStatus.expired, expiry);
        return SubscriptionStatus.expired;
      }

      _cachedStatus = status;
      _cachedExpiry = expiry;
      return status;
    }

    // Sem assinatura
    return SubscriptionStatus.free;
  }

  /// Ativa assinatura após pagamento bem-sucedido
  static Future<bool> activateSubscription({
    required String transactionId,
    required String paymentMethod, // 'pix' ou 'card'
    required double amount,
  }) async {
    appLogger.info('Iniciando ativação de assinatura', data: {
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
      'amount': amount,
    });

    try {
      final deviceId = await DeviceService.getDeviceId();

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/subscription/activate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'deviceId': deviceId,
              'transactionId': transactionId,
              'paymentMethod': paymentMethod,
              'amount': amount,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final expiryDate = DateTime.parse(data['expiryDate']);

        // Salva localmente
        await _updateLocalStatus(
            SubscriptionStatus.active, expiryDate, transactionId);

        appLogger.logSubscription('ativada', data: {
          'transactionId': transactionId,
          'paymentMethod': paymentMethod,
          'amount': amount,
          'expiryDate': expiryDate.toIso8601String(),
        });

        return true;
      }

      appLogger.warning('Falha ao ativar assinatura no backend', data: {
        'statusCode': response.statusCode,
        'transactionId': transactionId,
      });

      return false;
    } catch (e, stackTrace) {
      appLogger.error(
        'Erro ao ativar assinatura: $e',
        error: e,
        stackTrace: stackTrace,
        data: {
          'transactionId': transactionId,
          'paymentMethod': paymentMethod,
        },
      );
      return false;
    }
  }

  /// Valida assinatura com o backend (sincronização)
  static Future<bool> validateSubscription() async {
    appLogger.debug('Validando assinatura com backend');

    try {
      final deviceId = await DeviceService.getDeviceId();

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/subscription/validate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'deviceId': deviceId}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['isActive'] == true) {
          final expiryDate = DateTime.parse(data['expiryDate']);
          await _updateLocalStatus(SubscriptionStatus.active, expiryDate);

          appLogger.logSubscription('validada', data: {
            'isActive': true,
            'expiryDate': expiryDate.toIso8601String(),
          });

          return true;
        } else {
          await _updateLocalStatus(SubscriptionStatus.expired, DateTime.now());

          appLogger.logSubscription('expirada', data: {
            'isActive': false,
          });

          return false;
        }
      }

      appLogger.warning('Erro ao validar assinatura', data: {
        'statusCode': response.statusCode,
      });

      return false;
    } catch (e, stackTrace) {
      appLogger.error(
        'Erro ao validar assinatura: $e',
        error: e,
        stackTrace: stackTrace,
      );
      // Em caso de erro de conexão, mantém status local
      return await isPremium();
    }
  }

  /// Obtém data de expiração da assinatura
  static Future<DateTime?> getExpiryDate() async {
    if (_cachedExpiry != null) {
      return _cachedExpiry;
    }

    final expiryStr = await SecureStorageService.read(_expiryKey);

    if (expiryStr != null) {
      return DateTime.parse(expiryStr);
    }

    return null;
  }

  /// Obtém dias restantes da assinatura
  static Future<int> getDaysRemaining() async {
    final expiry = await getExpiryDate();
    if (expiry == null) return 0;

    final now = DateTime.now();
    if (expiry.isBefore(now)) return 0;

    return expiry.difference(now).inDays;
  }

  /// Atualiza status local da assinatura
  static Future<void> _updateLocalStatus(
    SubscriptionStatus status,
    DateTime expiry, [
    String? transactionId,
  ]) async {
    await SecureStorageService.write(_statusKey, status.name);
    await SecureStorageService.write(_expiryKey, expiry.toIso8601String());
    await SecureStorageService.write(
        _lastCheckKey, DateTime.now().toIso8601String());

    if (transactionId != null) {
      await SecureStorageService.write(_transactionIdKey, transactionId);
    }

    _cachedStatus = status;
    _cachedExpiry = expiry;
  }

  /// Verifica se deve sincronizar com backend (a cada 24h)
  static Future<bool> shouldSyncWithBackend() async {
    final lastCheckStr = await SecureStorageService.read(_lastCheckKey);

    if (lastCheckStr == null) return true;

    final lastCheck = DateTime.parse(lastCheckStr);
    final now = DateTime.now();

    // Sincroniza se passou mais de 24 horas
    return now.difference(lastCheck).inHours >= 24;
  }

  /// Sincronização automática (chamada periodicamente)
  static Future<void> autoSync() async {
    if (await shouldSyncWithBackend()) {
      await validateSubscription();
    }
  }

  /// Limpa dados de assinatura (útil para testes)
  static Future<void> clearSubscription() async {
    appLogger.warning('Limpando dados de assinatura');

    await SecureStorageService.delete(_statusKey);
    await SecureStorageService.delete(_expiryKey);
    await SecureStorageService.delete(_transactionIdKey);
    await SecureStorageService.delete(_lastCheckKey);

    _cachedStatus = null;
    _cachedExpiry = null;

    appLogger.logSubscription('limpa');
  }

  /// Converte string para enum
  static SubscriptionStatus _parseStatus(String status) {
    switch (status) {
      case 'active':
        return SubscriptionStatus.active;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'pending':
        return SubscriptionStatus.pending;
      default:
        return SubscriptionStatus.free;
    }
  }

  /// Obtém informações completas da assinatura
  static Future<Map<String, dynamic>> getSubscriptionInfo() async {
    final status = await getSubscriptionStatus();
    final expiry = await getExpiryDate();
    final daysRemaining = await getDaysRemaining();
    final deviceId = await DeviceService.getDeviceId();

    final transactionId = await SecureStorageService.read(_transactionIdKey);

    return {
      'status': status.name,
      'isPremium': status == SubscriptionStatus.active,
      'expiryDate': expiry?.toIso8601String(),
      'daysRemaining': daysRemaining,
      'deviceId': '${deviceId.substring(0, 8)}...', // Mostra só início
      'transactionId': transactionId,
    };
  }
}
