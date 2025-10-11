import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/audio_service.dart';
import '../services/palette.dart';

class AudioControlWidget extends StatefulWidget {
  final int cardIndex;
  final bool isOrganizacao;
  final String cardTitle;
  final VoidCallback? onClose;

  const AudioControlWidget({
    super.key,
    required this.cardIndex,
    required this.isOrganizacao,
    required this.cardTitle,
    this.onClose,
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

    bool audioFound;
    if (widget.isOrganizacao) {
      audioFound = await _audioService.playCartaOrganizacao(widget.cardIndex);
    } else {
      audioFound = await _audioService.playCartaDia(widget.cardIndex);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasAudio = audioFound;
      });
    }
  }

  Future<void> _togglePlayPause() async {
    if (_playerState == PlayerState.playing) {
      await _audioService.pauseAudio();
    } else if (_playerState == PlayerState.paused) {
      await _audioService.resumeAudio();
    } else {
      // Se parou, toca novamente
      _initializeAudio();
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
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.logoPrimary.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabeçalho com título da carta
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.cardTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.onClose != null)
                IconButton(
                  onPressed: () {
                    _stopAudio();
                    widget.onClose!();
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Controles de áudio
          if (_isLoading)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Carregando áudio...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            )
          else if (!_hasAudio)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.volume_off, color: Colors.white70, size: 20),
                SizedBox(width: 8),
                Text(
                  'Áudio não disponível para esta carta',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botão de play/pause
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.logoGold,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      _playerState == PlayerState.playing
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Botão de stop
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.logoPrimary.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: IconButton(
                    onPressed: _stopAudio,
                    icon: const Icon(
                      Icons.stop,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Indicador de status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _playerState == PlayerState.playing
                              ? Icons.volume_up
                              : _playerState == PlayerState.paused
                                  ? Icons.pause_circle_outline
                                  : Icons.volume_off_outlined,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _playerState == PlayerState.playing
                              ? 'Reproduzindo'
                              : _playerState == PlayerState.paused
                                  ? 'Pausado'
                                  : 'Parado',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
