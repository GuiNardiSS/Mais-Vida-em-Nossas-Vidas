import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/audio_service.dart';
import '../services/palette.dart';

class AudioControlWidget extends StatefulWidget {
  final int cardIndex;
  final bool isOrganizacao;
  final String cardTitle;
  final VoidCallback? onClose;
  final bool autoPlay;

  const AudioControlWidget({
    super.key,
    required this.cardIndex,
    required this.isOrganizacao,
    required this.cardTitle,
    this.onClose,
    this.autoPlay = false,
  });

  @override
  State<AudioControlWidget> createState() => _AudioControlWidgetState();
}

class _AudioControlWidgetState extends State<AudioControlWidget> {
  final AudioService _audioService = AudioService();
  bool _isLoading = false;
  bool _hasAudio = false;
  PlayerState _playerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _listenToPlayerState();
  }

  void _listenToPlayerState() {
    _audioService.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });
  }

  Future<void> _initializeAudio() async {
    setState(() {
      _isLoading = true;
    });

    final available = await _audioService.hasAudio(
      isOrganizacao: widget.isOrganizacao,
      index: widget.cardIndex,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasAudio = available;
      });

      if (available && widget.autoPlay) {
        _playAudio();
      }
    }
  }

  Future<void> _playAudio() async {
    setState(() => _isLoading = true);
    bool ok;
    if (widget.isOrganizacao) {
      ok = await _audioService.playCartaOrganizacao(widget.cardIndex);
    } else {
      ok = await _audioService.playCartaDia(widget.cardIndex);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasAudio = ok;
      });
    }
  }

  Future<void> _togglePlayPause() async {
    if (_playerState == PlayerState.playing) {
      await _audioService.pauseAudio();
    } else if (_playerState == PlayerState.paused) {
      await _audioService.resumeAudio();
    } else {
      await _playAudio();
    }
  }

  Future<void> _stopAudio() async {
    await _audioService.stopAudio();
  }

  @override
  void dispose() {
    _audioService.stopAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.logoPrimary.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Controles de áudio
          if (_isLoading)
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Carregando...',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            )
          else if (!_hasAudio)
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.volume_off, color: Colors.white70, size: 16),
                SizedBox(width: 6),
                Text(
                  'Áudio não disponível',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botão de play/pause
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.logoGold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      _playerState == PlayerState.playing
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Botão de stop
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.logoPrimary.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: IconButton(
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    onPressed: _stopAudio,
                    icon: const Icon(
                      Icons.stop,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Indicador de status
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _playerState == PlayerState.playing
                          ? Icons.volume_up
                          : _playerState == PlayerState.paused
                              ? Icons.pause_circle_outline
                              : Icons.volume_off_outlined,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _playerState == PlayerState.playing
                          ? 'Tocando'
                          : _playerState == PlayerState.paused
                              ? 'Pausado'
                              : 'Parado',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
