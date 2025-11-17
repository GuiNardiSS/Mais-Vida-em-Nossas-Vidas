import 'dart:convert';
import 'package:http/http.dart' as http;
import 'device_service.dart';
import 'subscription_service.dart';

/// Serviço de pagamento (PIX e Cartão)
class PaymentService {
  // URL do backend - ajuste conforme sua configuração
  static const String _baseUrl = 'http://10.0.2.2:3000'; // Android emulator

  /// Gera um pagamento PIX
  static Future<Map<String, dynamic>> generatePixPayment({
    required double amount,
  }) async {
    try {
      final deviceId = await DeviceService.getDeviceId();

      final response = await http.post(
        Uri.parse('$_baseUrl/pix/gerar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'valor': (amount * 100).toInt(), // Converte para centavos
          'deviceId': deviceId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'qrCodeImage': data['imagemQrCode'], // Base64 ou URL
          'qrCodeText': data['copiaECola'], // Código Pix Copia e Cola
        };
      } else {
        return {
          'success': false,
          'error': 'Erro ao gerar pagamento PIX',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: $e',
      };
    }
  }

  /// Cria um Payment Intent do Stripe para pagamento com cartão
  static Future<Map<String, dynamic>> createCardPayment({
    required double amount,
  }) async {
    try {
      final deviceId = await DeviceService.getDeviceId();

      final response = await http.post(
        Uri.parse('$_baseUrl/pagamento/criar-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'valor': (amount * 100).toInt(), // Converte para centavos
          'deviceId': deviceId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'clientSecret': data['clientSecret'],
        };
      } else {
        return {
          'success': false,
          'error': 'Erro ao criar pagamento com cartão',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: $e',
      };
    }
  }

  /// Confirma o pagamento e ativa a assinatura
  static Future<bool> confirmPayment({
    required String paymentId,
    required String paymentMethod, // 'pix' ou 'card'
    required double amount,
  }) async {
    try {
      // Ativa a assinatura usando o SubscriptionService
      final success = await SubscriptionService.activateSubscription(
        transactionId: paymentId,
        paymentMethod: paymentMethod,
        amount: amount,
      );

      if (!success) return false;

      final deviceId = await DeviceService.getDeviceId();
      await http.post(
        Uri.parse('$_baseUrl/subscription/activate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': deviceId,
          'paymentId': paymentId,
          'paymentMethod': paymentMethod,
          'planType': 'monthly',
        }),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verifica o status de um pagamento PIX
  static Future<Map<String, dynamic>> checkPixPaymentStatus({
    required String paymentId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/pix/status/$paymentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'status': data['status'], // 'pending', 'paid', 'expired'
        };
      } else {
        return {
          'success': false,
          'error': 'Erro ao verificar status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: $e',
      };
    }
  }
}
