import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'device_service.dart';

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
  // URL do backend (ajustar para produção)
  static const String _baseUrl = 'http://10.0.2.2:3000';

  // Keys para SharedPreferences
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

    // Carrega do SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final statusStr = prefs.getString(_statusKey);
    final expiryStr = prefs.getString(_expiryKey);

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
    try {
      final deviceId = await DeviceService.getDeviceId();

      final response = await http
          .post(
            Uri.parse('$_baseUrl/subscription/activate'),
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

        return true;
      }

      return false;
    } catch (e) {
      // Log de erro (em produção, usar logging service apropriado)
      // ignore: avoid_print
      debugPrint('Erro ao ativar assinatura: $e');
      return false;
    }
  }

  /// Valida assinatura com o backend (sincronização)
  static Future<bool> validateSubscription() async {
    try {
      final deviceId = await DeviceService.getDeviceId();

      final response = await http
          .post(
            Uri.parse('$_baseUrl/subscription/validate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'deviceId': deviceId}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['isActive'] == true) {
          final expiryDate = DateTime.parse(data['expiryDate']);
          await _updateLocalStatus(SubscriptionStatus.active, expiryDate);
          return true;
        } else {
          await _updateLocalStatus(SubscriptionStatus.expired, DateTime.now());
          return false;
        }
      }

      return false;
    } catch (e) {
      // Log de erro (em produção, usar logging service apropriado)
      debugPrint('Erro ao validar assinatura: $e');
      // Em caso de erro de conexão, mantém status local
      return await isPremium();
    }
  }

  /// Obtém data de expiração da assinatura
  static Future<DateTime?> getExpiryDate() async {
    if (_cachedExpiry != null) {
      return _cachedExpiry;
    }

    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString(_expiryKey);

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
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_statusKey, status.name);
    await prefs.setString(_expiryKey, expiry.toIso8601String());
    await prefs.setString(_lastCheckKey, DateTime.now().toIso8601String());

    if (transactionId != null) {
      await prefs.setString(_transactionIdKey, transactionId);
    }

    _cachedStatus = status;
    _cachedExpiry = expiry;
  }

  /// Verifica se deve sincronizar com backend (a cada 24h)
  static Future<bool> shouldSyncWithBackend() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckStr = prefs.getString(_lastCheckKey);

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_statusKey);
    await prefs.remove(_expiryKey);
    await prefs.remove(_transactionIdKey);
    await prefs.remove(_lastCheckKey);

    _cachedStatus = null;
    _cachedExpiry = null;
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

    final prefs = await SharedPreferences.getInstance();
    final transactionId = prefs.getString(_transactionIdKey);

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
