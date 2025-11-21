import 'package:flutter/foundation.dart';

class ApiConfig {
  // URLs base
  static const String _devUrl = 'http://10.0.2.2:3000';
  static const String _prodUrl =
      'https://api.maisvidaemnossasvidas.com.br'; // Exemplo

  /// Retorna a URL base apropriada para o ambiente
  static String get baseUrl {
    if (kReleaseMode) {
      return _prodUrl;
    }
    return _devUrl;
  }

  /// Verifica se a conexão é segura (HTTPS)
  static bool get isSecureConnection {
    return baseUrl.startsWith('https://');
  }
}
