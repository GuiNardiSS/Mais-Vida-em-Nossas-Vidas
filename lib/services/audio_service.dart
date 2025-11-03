import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingPath;
  bool _isInitialized = false;
  Set<String>? _assetSet;

  // Cache de caminhos de áudio válidos
  final Map<String, String?> _audioPathCache = {};

  // Mapeamento carta -> áudio (null = usar mapeamento 1:1 padrão)
  Map<int, int>? _audioMappingDia;
  Map<int, int>? _audioMappingOrg;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Carrega o manifest de assets
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestJson);
      _assetSet = manifest.keys.toSet();
      debugPrint(
          'AudioService: Manifest carregado com \\${_assetSet!.length} assets');

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
    final cacheKey = '$folder-$index';
    if (_audioPathCache.containsKey(cacheKey)) {
      return _audioPathCache[cacheKey];
    }

    await initialize();
    final assets = _assetSet; // pode ser null
    final cardNumber = index + 1;

    // Diferentes formatos de nome de arquivo que podem existir
    final candidates = <String>[
      '$folder/carta_$cardNumber.mp3',
      '$folder/carta$cardNumber.mp3',
      '$folder/Carta_$cardNumber.mp3',
      '$folder/Carta$cardNumber.mp3',
      '$folder/audio_$cardNumber.mp3',
      '$folder/audio$cardNumber.mp3',
      '$folder/Audio_$cardNumber.mp3',
      '$folder/Audio$cardNumber.mp3',
      '$folder/$cardNumber.mp3',
      '$folder/carta_${cardNumber.toString().padLeft(2, '0')}.mp3',
      '$folder/audio_${cardNumber.toString().padLeft(2, '0')}.mp3',
    ];

    if (assets != null && assets.isNotEmpty) {
      for (final candidate in candidates) {
        if (assets.contains(candidate)) {
          debugPrint(
              'AudioService: caminho encontrado para índice $index => $candidate');
          _audioPathCache[cacheKey] = candidate;
          return candidate;
        }
      }
    }

    // Se não encontrou arquivo mp3, tenta outros formatos
    final otherFormats = ['m4a', 'wav', 'aac'];
    for (final format in otherFormats) {
      final alternativeCandidates = <String>[
        '$folder/carta_$cardNumber.$format',
        '$folder/carta$cardNumber.$format',
        '$folder/audio_$cardNumber.$format',
        '$folder/$cardNumber.$format',
      ];

      if (assets != null && assets.isNotEmpty) {
        for (final candidate in alternativeCandidates) {
          if (assets.contains(candidate)) {
            debugPrint(
                'AudioService: caminho alternativo encontrado para índice $index => $candidate');
            _audioPathCache[cacheKey] = candidate;
            return candidate;
          }
        }
      }
    }

    // Não encontrou arquivo existente
    _audioPathCache[cacheKey] = null;
    return null;
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

  bool get isPlaying => _audioPlayer.state == PlayerState.playing;
  bool get isPaused => _audioPlayer.state == PlayerState.paused;

  String? get currentlyPlayingPath => _currentlyPlayingPath;

  // Stream para escutar mudanças no estado do player
  Stream<PlayerState> get onPlayerStateChanged =>
      _audioPlayer.onPlayerStateChanged;

  void dispose() {
    _audioPlayer.dispose();
  }
}
