import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Carrega o manifest de assets
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestJson);
      _assetSet = manifest.keys.toSet();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Erro ao inicializar AudioService: $e');
    }
  }

  Future<String?> _resolveAudioPath(String folder, int index) async {
    final cacheKey = '$folder-$index';
    if (_audioPathCache.containsKey(cacheKey)) {
      return _audioPathCache[cacheKey];
    }

    await initialize();
    final assets = _assetSet ?? {};
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

    for (final candidate in candidates) {
      if (assets.contains(candidate)) {
        _audioPathCache[cacheKey] = candidate;
        return candidate;
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

      for (final candidate in alternativeCandidates) {
        if (assets.contains(candidate)) {
          _audioPathCache[cacheKey] = candidate;
          return candidate;
        }
      }
    }

    _audioPathCache[cacheKey] = null;
    return null;
  }

  Future<bool> playCartaDia(int index) async {
    final audioPath =
        await _resolveAudioPath('assets/audios_cartas_dia', index);
    return await _playAudio(audioPath);
  }

  Future<bool> playCartaOrganizacao(int index) async {
    final audioPath =
        await _resolveAudioPath('assets/audios_cartas_org', index);
    return await _playAudio(audioPath);
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

      _currentlyPlayingPath = audioPath;
      await _audioPlayer.play(AssetSource(audioPath));
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
