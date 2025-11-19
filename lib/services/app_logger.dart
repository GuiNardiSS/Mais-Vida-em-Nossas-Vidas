import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'device_service.dart';

/// Sistema centralizado de logging do aplicativo
///
/// Funcionalidades:
/// - Logs por nível (debug, info, warning, error, fatal)
/// - Rastreamento de páginas e eventos
/// - Salvamento local em arquivo
/// - Envio para backend (opcional)
/// - Performance monitoring
/// - User journey tracking
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  late Logger _logger;
  File? _logFile;
  bool _isInitialized = false;
  String? _deviceId;
  String? _sessionId;
  DateTime? _sessionStart;

  // Configurações
  static const bool _enableFileLogging = true;
  static const bool _enableRemoteLogging = false; // Ativar quando tiver backend
  static const String _backendUrl = 'http://10.0.2.2:3000/logs';
  static const int _maxLogFileSize = 5 * 1024 * 1024; // 5MB

  /// Inicializa o sistema de logging
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Gera session ID única
      _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
      _sessionStart = DateTime.now();

      // Obtém device ID
      _deviceId = await DeviceService.getDeviceId();

      // Configura o logger
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
        filter: ProductionFilter(),
        level: kDebugMode ? Level.debug : Level.info,
      );

      // Configura arquivo de log
      if (_enableFileLogging) {
        await _setupLogFile();
      }

      _isInitialized = true;

      // Log de inicialização
      info('App Logger inicializado', data: {
        'sessionId': _sessionId,
        'deviceId': _deviceId?.substring(0, 8),
        'platform': Platform.operatingSystem,
      });
    } catch (e) {
      debugPrint('Erro ao inicializar AppLogger: $e');
    }
  }

  /// Configura o arquivo de log local
  Future<void> _setupLogFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${directory.path}/logs');

      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _logFile = File('${logsDir.path}/app_log_$dateStr.txt');

      // Verifica tamanho do arquivo
      if (await _logFile!.exists()) {
        final fileSize = await _logFile!.length();
        if (fileSize > _maxLogFileSize) {
          // Arquivo muito grande, cria um novo com timestamp
          final timestamp = DateFormat('HHmmss').format(DateTime.now());
          _logFile = File('${logsDir.path}/app_log_${dateStr}_$timestamp.txt');
        }
      }
    } catch (e) {
      debugPrint('Erro ao configurar arquivo de log: $e');
    }
  }

  /// Escreve no arquivo de log
  Future<void> _writeToFile(
      String level, String message, Map<String, dynamic>? data) async {
    if (!_enableFileLogging || _logFile == null) return;

    try {
      final timestamp =
          DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
      final logEntry = StringBuffer();

      logEntry.writeln('[$timestamp] [$level] $message');

      if (data != null && data.isNotEmpty) {
        logEntry.writeln('  Data: ${jsonEncode(data)}');
      }

      logEntry.writeln(
          '  Session: $_sessionId | Device: ${_deviceId?.substring(0, 8)}');
      logEntry.writeln('---');

      await _logFile!.writeAsString(
        logEntry.toString(),
        mode: FileMode.append,
        flush: true,
      );
    } catch (e) {
      debugPrint('Erro ao escrever no arquivo de log: $e');
    }
  }

  /// Envia log para o backend
  Future<void> _sendToBackend(
      String level, String message, Map<String, dynamic>? data) async {
    if (!_enableRemoteLogging) return;

    try {
      await http
          .post(
            Uri.parse(_backendUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'timestamp': DateTime.now().toIso8601String(),
              'level': level,
              'message': message,
              'data': data,
              'sessionId': _sessionId,
              'deviceId': _deviceId,
              'platform': Platform.operatingSystem,
            }),
          )
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      // Ignora erro de envio para não causar problemas no app
      debugPrint('Erro ao enviar log para backend: $e');
    }
  }

  // ==================== LOGS POR NÍVEL ====================

  /// Log de debug (apenas em desenvolvimento)
  void debug(String message, {Map<String, dynamic>? data}) {
    if (!kDebugMode) return;
    _logger.d(message, error: data);
    _writeToFile('DEBUG', message, data);
  }

  /// Log informativo
  void info(String message, {Map<String, dynamic>? data}) {
    _logger.i(message, error: data);
    _writeToFile('INFO', message, data);
  }

  /// Log de aviso
  void warning(String message, {Map<String, dynamic>? data}) {
    _logger.w(message, error: data);
    _writeToFile('WARNING', message, data);

    // Envia warnings críticos para backend
    if (data?['critical'] == true) {
      _sendToBackend('WARNING', message, data);
    }
  }

  /// Log de erro
  void error(String message,
      {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    _logger.e(message, error: error, stackTrace: stackTrace);

    final errorData = {
      ...?data,
      'error': error?.toString(),
      'stackTrace': stackTrace?.toString(),
    };

    _writeToFile('ERROR', message, errorData);
    _sendToBackend('ERROR', message, errorData);
  }

  /// Log de erro fatal (crítico)
  void fatal(String message,
      {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    _logger.f(message, error: error, stackTrace: stackTrace);

    final errorData = {
      ...?data,
      'error': error?.toString(),
      'stackTrace': stackTrace?.toString(),
    };

    _writeToFile('FATAL', message, errorData);
    _sendToBackend('FATAL', message, errorData);
  }

  // ==================== LOGS ESPECIALIZADOS ====================

  /// Log de navegação de página
  void logPageView(String pageName, {Map<String, dynamic>? data}) {
    info('Page View: $pageName', data: {
      'page': pageName,
      'timestamp': DateTime.now().toIso8601String(),
      ...?data,
    });
  }

  /// Log de evento do usuário
  void logEvent(String eventName, {Map<String, dynamic>? data}) {
    info('Event: $eventName', data: {
      'event': eventName,
      'timestamp': DateTime.now().toIso8601String(),
      ...?data,
    });
  }

  /// Log de pagamento
  void logPayment(String method, double amount, String status,
      {Map<String, dynamic>? data}) {
    info('Payment: $method', data: {
      'method': method,
      'amount': amount,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
      ...?data,
    });
  }

  /// Log de assinatura
  void logSubscription(String action, {Map<String, dynamic>? data}) {
    info('Subscription: $action', data: {
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      ...?data,
    });
  }

  /// Log de performance
  void logPerformance(String operation, Duration duration,
      {Map<String, dynamic>? data}) {
    info('Performance: $operation', data: {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      'timestamp': DateTime.now().toIso8601String(),
      ...?data,
    });
  }

  /// Log de erro de rede
  void logNetworkError(String endpoint, int? statusCode, dynamic error,
      {Map<String, dynamic>? data}) {
    error('Network Error: $endpoint', error: error, data: {
      'endpoint': endpoint,
      'statusCode': statusCode,
      ...?data,
    });
  }

  // ==================== MÉTRICAS ====================

  /// Retorna duração da sessão atual
  Duration? getSessionDuration() {
    if (_sessionStart == null) return null;
    return DateTime.now().difference(_sessionStart!);
  }

  /// Retorna informações da sessão
  Map<String, dynamic> getSessionInfo() {
    return {
      'sessionId': _sessionId,
      'deviceId': _deviceId?.substring(0, 8),
      'duration': getSessionDuration()?.inMinutes,
      'platform': Platform.operatingSystem,
    };
  }

  // ==================== GERENCIAMENTO DE LOGS ====================

  /// Retorna o caminho do arquivo de log atual
  String? getLogFilePath() => _logFile?.path;

  /// Retorna o conteúdo dos logs
  Future<String?> getLogContent() async {
    if (_logFile == null || !await _logFile!.exists()) return null;

    try {
      return await _logFile!.readAsString();
    } catch (e) {
      debugPrint('Erro ao ler arquivo de log: $e');
      return null;
    }
  }

  /// Lista todos os arquivos de log
  Future<List<File>> listLogFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${directory.path}/logs');

      if (!await logsDir.exists()) return [];

      return logsDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.txt'))
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path)); // Mais recente primeiro
    } catch (e) {
      debugPrint('Erro ao listar arquivos de log: $e');
      return [];
    }
  }

  /// Limpa logs antigos (mantém últimos 7 dias)
  Future<void> cleanOldLogs({int daysToKeep = 7}) async {
    try {
      final files = await listLogFiles();
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      for (final file in files) {
        final stat = await file.stat();
        if (stat.modified.isBefore(cutoffDate)) {
          await file.delete();
          debug('Log antigo deletado: ${file.path}');
        }
      }
    } catch (e) {
      debugPrint('Erro ao limpar logs antigos: $e');
    }
  }

  /// Exporta logs para compartilhamento
  Future<File?> exportLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final exportFile = File('${directory.path}/logs_export_$timestamp.txt');

      final files = await listLogFiles();
      final buffer = StringBuffer();

      buffer.writeln('=== LOGS EXPORTADOS ===');
      buffer.writeln(
          'Data: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}');
      buffer.writeln('Session: $_sessionId');
      buffer.writeln('Device: $_deviceId');
      buffer.writeln('=' * 50);
      buffer.writeln();

      for (final file in files) {
        buffer.writeln('--- ${file.path.split('/').last} ---');
        buffer.writeln(await file.readAsString());
        buffer.writeln();
      }

      await exportFile.writeAsString(buffer.toString());
      return exportFile;
    } catch (e) {
      error('Erro ao exportar logs', error: e);
      return null;
    }
  }

  /// Finaliza a sessão de logging
  Future<void> closeSession() async {
    final duration = getSessionDuration();
    info('Sessão encerrada', data: {
      'duration_minutes': duration?.inMinutes,
      'sessionId': _sessionId,
    });
  }
}

/// Atalho global para o logger
final appLogger = AppLogger();
