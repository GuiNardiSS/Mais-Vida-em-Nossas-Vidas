import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/assets/asset_resolver.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingPath;
  bool _isInitialized = false;
  final AssetResolver _assetResolver = AssetResolver();

  // Mapeamento carta -> áudio (null = usar mapeamento 1:1 padrão)
  Map<int, int>? _audioMappingDia;
  Map<int, int>? _audioMappingOrg;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Carrega mapeamento de áudios
      await _loadAudioMapping();

      // Ajustes iniciais do player
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Erro ao inicializar AudioService: $e');
    }
  }

  Future<void> _loadAudioMapping() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Carrega mapeamento das cartas do dia
      final String? mappingDiaJson = prefs.getString('audio_mapping_dia');
      if (mappingDiaJson != null) {
        final Map<String, dynamic> decoded = json.decode(mappingDiaJson);
        _audioMappingDia =
            decoded.map((key, value) => MapEntry(int.parse(key), value as int));
        debugPrint(
            'AudioService: Mapeamento dia carregado com ${_audioMappingDia!.length} entradas');
      }

      // Carrega mapeamento das cartas de organização
      final String? mappingOrgJson = prefs.getString('audio_mapping_org');
      if (mappingOrgJson != null) {
        final Map<String, dynamic> decoded = json.decode(mappingOrgJson);
        _audioMappingOrg =
            decoded.map((key, value) => MapEntry(int.parse(key), value as int));
        debugPrint(
            'AudioService: Mapeamento org carregado com ${_audioMappingOrg!.length} entradas');
      }
    } catch (e) {
      debugPrint('Erro ao carregar mapeamento de áudios: $e');
    }
  }

  Future<String?> _resolveAudioPath(String folder, int index) async {
    return _assetResolver.resolveAudio(folder, index);
  }

  // Verifica se há áudio disponível para a carta (sem tocar)
  Future<bool> hasAudio(
      {required bool isOrganizacao, required int index}) async {
    if (isOrganizacao) {
      final org = await _resolveAudioPath('assets/audios_cartas_org', index);
      if (org != null) return true;
      final dia = await _resolveAudioPath('assets/audios_cartas_dia', index);
      return dia != null;
    } else {
      final dia = await _resolveAudioPath('assets/audios_cartas_dia', index);
      return dia != null;
    }
  }

  Future<bool> playCartaDia(int index) async {
    // Aplica mapeamento se existir
    final int audioIndex = _audioMappingDia?[index] ?? index;
    if (audioIndex != index) {
      debugPrint(
          'AudioService: carta dia $index mapeada para áudio $audioIndex');
    }

    final audioPath =
        await _resolveAudioPath('assets/audios_cartas_dia', audioIndex);
    return await _playAudio(audioPath);
  }

  Future<bool> playCartaOrganizacao(int index) async {
    // Aplica mapeamento se existir
    final int audioIndex = _audioMappingOrg?[index] ?? index;
    if (audioIndex != index) {
      debugPrint(
          'AudioService: carta org $index mapeada para áudio $audioIndex');
    }

    // Tenta primeiro o áudio específico de organização, e se não existir
    // faz fallback para o mesmo índice das cartas do dia (mesma mensagem)
    String? audioPath =
        await _resolveAudioPath('assets/audios_cartas_org', audioIndex);
    if (audioPath == null) {
      debugPrint(
          'AudioService: fallback para cartas do dia (org índice $audioIndex)');
      audioPath =
          await _resolveAudioPath('assets/audios_cartas_dia', audioIndex);
    }
    return await _playAudio(audioPath);
  }

  // Expose resolved paths without playing (useful for diagnostics/validation)
  Future<String?> resolveAudioPathDia(int index) async {
    return _resolveAudioPath('assets/audios_cartas_dia', index);
  }

  Future<String?> resolveAudioPathOrganizacao(int index) async {
    return _resolveAudioPath('assets/audios_cartas_org', index);
  }

  Future<bool> _playAudio(String? audioPath) async {
    if (audioPath == null) {
      debugPrint('Áudio não encontrado');
      return false;
    }

    try {
      await initialize();
      // Para áudio se estiver tocando outro
      if (_currentlyPlayingPath != null && _currentlyPlayingPath != audioPath) {
        await _audioPlayer.stop();
      }

      // AssetSource já prefixa 'assets/', então removemos se já vier com esse prefixo
      String sourcePath = audioPath;
      if (sourcePath.startsWith('assets/')) {
        sourcePath = sourcePath.substring('assets/'.length);
      }

      _currentlyPlayingPath = audioPath;
      debugPrint('AudioService: tocando AssetSource($sourcePath)');
      await _audioPlayer.play(AssetSource(sourcePath));
      return true;
    } catch (e) {
      debugPrint('Erro ao reproduzir áudio: $e');
      return false;
    }
  }

  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('Erro ao pausar áudio: $e');
    }
  }

  Future<void> resumeAudio() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('Erro ao retomar áudio: $e');
    }
  }

  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _currentlyPlayingPath = null;
    } catch (e) {
      debugPrint('Erro ao parar áudio: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      debugPrint('Erro ao avançar áudio: $e');
    }
  }

  bool get isPlaying => _audioPlayer.state == PlayerState.playing;
  bool get isPaused => _audioPlayer.state == PlayerState.paused;

  String? get currentlyPlayingPath => _currentlyPlayingPath;

  // Streams para acompanhar reprodução
  Stream<PlayerState> get onPlayerStateChanged =>
      _audioPlayer.onPlayerStateChanged;

  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;

  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;

  Stream<void> get onPlayerComplete => _audioPlayer.onPlayerComplete;

  void dispose() {
    _audioPlayer.dispose();
  }
}
