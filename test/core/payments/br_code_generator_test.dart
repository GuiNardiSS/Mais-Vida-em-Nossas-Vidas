import 'package:flutter_test/flutter_test.dart';
import 'package:meu_app_flutter/core/payments/br_code_generator.dart';

String _field(String payload, String id) {
  final start = payload.indexOf(id);
  expect(start, isNonNegative, reason: 'campo $id não encontrado');
  final length = int.parse(payload.substring(start + 2, start + 4));
  return payload.substring(start + 4, start + 4 + length);
}

String _recalculateCrc(String payload) {
  final withoutCrc = payload.substring(0, payload.length - 4);
  return BrCodeGenerator.crc16(withoutCrc);
}

void main() {
  group('BrCodeGenerator', () {
    const pixKey = 'maisvida@exemplo.com.br';
    const name = 'MAIS VIDA EM NOSSAS VIDAS';
    const city = 'SAO PAULO';

    test('gera payload com campos obrigatórios e valor formatado', () {
      final payload = BrCodeGenerator.generate(
        pixKey: pixKey,
        merchantName: name,
        merchantCity: city,
        amount: 19.9,
      );

      expect(payload.startsWith('000201'), isTrue);
      expect(_field(payload, '53'), '986');
      expect(_field(payload, '54'), '19.90');
      expect(_field(payload, '58'), 'BR');
      expect(_field(payload, '59'), name);
      expect(_field(payload, '60'), city);
      expect(payload, contains(pixKey));
    });

    test('o CRC final corresponde ao cálculo do próprio payload', () {
      final payload = BrCodeGenerator.generate(
        pixKey: pixKey,
        merchantName: name,
        merchantCity: city,
        amount: 4.99,
        txid: 'DEMO123',
      );

      final crc = payload.substring(payload.length - 4);
      expect(crc, _recalculateCrc(payload));
      expect(payload, endsWith('6304$crc'));
      expect(_field(payload, '62'), contains('DEMO123'));
    });

    test('remove acentos e limita nome e cidade', () {
      final payload = BrCodeGenerator.generate(
        pixKey: pixKey,
        merchantName: 'Coração e Ação',
        merchantCity: 'São Paulo - Região Metropolitana',
        amount: 1,
      );

      expect(_field(payload, '59'), 'Coracao e Acao');
      expect(_field(payload, '60'), 'Sao Paulo - Reg');
    });

    test('aceita chave aleatória e txid padrão', () {
      final payload = BrCodeGenerator.generate(
        pixKey: '12345678901234567890123456789012',
        merchantName: name,
        merchantCity: city,
        amount: 9.99,
      );

      expect(payload, contains('12345678901234567890123456789012'));
      expect(_field(payload, '62'), contains('***'));
    });
  });
}
