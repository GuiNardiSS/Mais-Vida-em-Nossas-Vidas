import 'dart:convert';
import 'package:http/http.dart' as http;
import 'device_service.dart';
import 'subscription_service.dart';
import 'app_logger.dart';

/// Serviço de pagamento (PIX e Cartão)
class PaymentService {
  // URL do backend - ajuste conforme sua configuração
  static const String _baseUrl = 'http://10.0.2.2:3000'; // Android emulator

  /// Gera um pagamento PIX
  static Future<Map<String, dynamic>> generatePixPayment({
    required double amount,
  }) async {
    final startTime = DateTime.now();
    appLogger.logPayment('PIX', amount, 'iniciado');

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
        final duration = DateTime.now().difference(startTime);

        appLogger.logPayment('PIX', amount, 'sucesso', data: {
          'qrCodeGenerated': data['imagemQrCode'] != null,
          'hasQrText': data['copiaECola'] != null,
        });

        appLogger.logPerformance('Geração PIX', duration);

        return {
          'success': true,
          'qrCodeImage': data['imagemQrCode'], // Base64 ou URL
          'qrCodeText': data['copiaECola'], // Código Pix Copia e Cola
        };
      } else {
        appLogger.logPayment('PIX', amount, 'erro', data: {
          'statusCode': response.statusCode,
          'error': 'Erro ao gerar pagamento PIX',
        });

        return {
          'success': false,
          'error': 'Erro ao gerar pagamento PIX',
        };
      }
    } catch (e, stackTrace) {
      appLogger.error(
        'Erro ao gerar pagamento PIX: $e',
        error: e,
        stackTrace: stackTrace,
        data: {'amount': amount},
      );

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
    final startTime = DateTime.now();
    appLogger.logPayment('Cartão', amount, 'iniciado');

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
        final duration = DateTime.now().difference(startTime);

        appLogger.logPayment('Cartão', amount, 'sucesso', data: {
          'hasClientSecret': data['clientSecret'] != null,
        });

        appLogger.logPerformance('Criação Payment Intent', duration);

        return {
          'success': true,
          'clientSecret': data['clientSecret'],
        };
      } else {
        appLogger.logPayment('Cartão', amount, 'erro', data: {
          'statusCode': response.statusCode,
          'error': 'Erro ao criar pagamento com cartão',
        });

        return {
          'success': false,
          'error': 'Erro ao criar pagamento com cartão',
        };
      }
    } catch (e, stackTrace) {
      appLogger.error(
        'Erro ao criar pagamento com cartão: $e',
        error: e,
        stackTrace: stackTrace,
        data: {'amount': amount},
      );

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
    appLogger.info('Confirmando pagamento', data: {
      'paymentId': paymentId,
      'method': paymentMethod,
      'amount': amount,
    });

    try {
      // Ativa a assinatura usando o SubscriptionService
      final success = await SubscriptionService.activateSubscription(
        transactionId: paymentId,
        paymentMethod: paymentMethod,
        amount: amount,
      );

      if (!success) {
        appLogger.warning('Falha ao ativar assinatura localmente', data: {
          'paymentId': paymentId,
        });
        return false;
      }

      final deviceId = await DeviceService.getDeviceId();
      final response = await http.post(
        Uri.parse('$_baseUrl/subscription/activate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': deviceId,
          'paymentId': paymentId,
          'paymentMethod': paymentMethod,
          'planType': 'monthly',
        }),
      );

      if (response.statusCode == 200) {
        appLogger.logSubscription('ativada', data: {
          'paymentId': paymentId,
          'method': paymentMethod,
          'amount': amount,
        });
      } else {
        appLogger.warning('Backend não confirmou ativação', data: {
          'statusCode': response.statusCode,
        });
      }

      return true;
    } catch (e, stackTrace) {
      appLogger.error(
        'Erro ao confirmar pagamento: $e',
        error: e,
        stackTrace: stackTrace,
        data: {
          'paymentId': paymentId,
          'method': paymentMethod,
        },
      );
      return false;
    }
  }

  /// Verifica o status de um pagamento PIX
  static Future<Map<String, dynamic>> checkPixPaymentStatus({
    required String paymentId,
  }) async {
    appLogger.debug('Verificando status de pagamento PIX', data: {
      'paymentId': paymentId,
    });

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/pix/status/$paymentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'];

        appLogger.info('Status PIX consultado', data: {
          'paymentId': paymentId,
          'status': status,
        });

        return {
          'success': true,
          'status': status, // 'pending', 'paid', 'expired'
        };
      } else {
        appLogger.warning('Erro ao verificar status PIX', data: {
          'paymentId': paymentId,
          'statusCode': response.statusCode,
        });

        return {
          'success': false,
          'error': 'Erro ao verificar status',
        };
      }
    } catch (e, stackTrace) {
      appLogger.error(
        'Erro ao verificar status PIX: $e',
        error: e,
        stackTrace: stackTrace,
        data: {'paymentId': paymentId},
      );

      return {
        'success': false,
        'error': 'Erro de conexão: $e',
      };
    }
  }
}
