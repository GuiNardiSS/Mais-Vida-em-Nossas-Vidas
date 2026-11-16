/// Gerador de payload PIX no padrão EMV (BR Code).
///
/// Usado no modo demonstração: o código é estruturalmente válido e pode ser
/// lido por apps de banco, mas não está vinculado a uma cobrança real.
class BrCodeGenerator {
  const BrCodeGenerator._();

  static String generate({
    required String pixKey,
    required String merchantName,
    required String merchantCity,
    required double amount,
    String? description,
    String txid = '***',
  }) {
    final key = _sanitize(pixKey, maxLength: 77);
    final name = _sanitize(merchantName, maxLength: 25);
    final city = _sanitize(merchantCity, maxLength: 15);
    final txidSanitized = _sanitize(txid, maxLength: 25);
    final formattedAmount = amount.toStringAsFixed(2);

    final merchantAccount = StringBuffer()
      ..write(_tlv('00', 'br.gov.bcb.pix'))
      ..write(_tlv('01', key));
    if (description != null && description.trim().isNotEmpty) {
      merchantAccount.write(_tlv('02', _sanitize(description, maxLength: 72)));
    }

    final additionalData =
        _tlv('05', txidSanitized.isEmpty ? '***' : txidSanitized);

    final payload = StringBuffer()
      ..write(_tlv('00', '01'))
      ..write(_tlv('26', merchantAccount.toString()))
      ..write(_tlv('52', '0000'))
      ..write(_tlv('53', '986'))
      ..write(_tlv('54', formattedAmount))
      ..write(_tlv('58', 'BR'))
      ..write(_tlv('59', name))
      ..write(_tlv('60', city))
      ..write(_tlv('62', additionalData))
      ..write('6304');

    final crc = crc16(payload.toString());
    return '${payload.toString()}$crc';
  }

  /// TLV: identificador (2) + tamanho (2) + valor.
  static String _tlv(String id, String value) {
    final length = value.length.toString().padLeft(2, '0');
    return '$id$length$value';
  }

  /// Remove acentos, caracteres de controle e limita o tamanho.
  static String _sanitize(String input, {required int maxLength}) {
    const replacements = {
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'Á': 'A',
      'À': 'A',
      'Â': 'A',
      'Ã': 'A',
      'Ä': 'A',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'É': 'E',
      'È': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'Í': 'I',
      'Ì': 'I',
      'Î': 'I',
      'Ï': 'I',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'Ó': 'O',
      'Ò': 'O',
      'Ô': 'O',
      'Õ': 'O',
      'Ö': 'O',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'Ú': 'U',
      'Ù': 'U',
      'Û': 'U',
      'Ü': 'U',
      'ç': 'c',
      'Ç': 'C',
      'ñ': 'n',
      'Ñ': 'N',
    };

    final buffer = StringBuffer();
    for (final char in input.trim().split('')) {
      final replaced = replacements[char] ?? char;
      final code = replaced.codeUnitAt(0);
      if (code >= 32 && code != 127) {
        buffer.write(replaced);
      }
    }

    final sanitized = buffer.toString();
    return sanitized.length <= maxLength
        ? sanitized
        : sanitized.substring(0, maxLength);
  }

  /// CRC16/CCITT-FALSE (poly 0x1021, init 0xFFFF, sem reflexão).
  static String crc16(String payload) {
    var crc = 0xFFFF;
    for (final codeUnit in payload.codeUnits) {
      crc ^= (codeUnit & 0xFF) << 8;
      for (var bit = 0; bit < 8; bit++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}
