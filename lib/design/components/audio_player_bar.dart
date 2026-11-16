import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens.dart';
import '../../services/audio_service.dart';

/// Player compacto com progresso, usado no leitor de cartas.
class AudioPlayerBar extends StatefulWidget {
  const AudioPlayerBar({
    super.key,
    required this.cardIndex,
    required this.isOrganizacao,
    required this.title,
  });

  final int cardIndex;
  final bool isOrganizacao;
  final String title;

  @override
  State<AudioPlayerBar> createState() => _AudioPlayerBarState();
}

class _AudioPlayerBarState extends State<AudioPlayerBar> {
  final AudioService _audio = AudioService();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  PlayerState _state = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _loading = true;
  bool _hasAudio = false;

  @override
  void initState() {
    super.initState();
    _listen();
    _start();
  }

  void _listen() {
    _subscriptions
      ..add(_audio.onPlayerStateChanged.listen((state) {
        if (mounted) setState(() => _state = state);
      }))
      ..add(_audio.onPositionChanged.listen((position) {
        if (mounted) setState(() => _position = position);
      }))
      ..add(_audio.onDurationChanged.listen((duration) {
        if (mounted) setState(() => _duration = duration);
      }))
      ..add(_audio.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _state = PlayerState.stopped;
            _position = Duration.zero;
          });
        }
      }));
  }

  Future<void> _start() async {
    setState(() => _loading = true);
    final found = widget.isOrganizacao
        ? await _audio.playCartaOrganizacao(widget.cardIndex)
        : await _audio.playCartaDia(widget.cardIndex);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _hasAudio = found;
    });
  }

  Future<void> _toggle() async {
    switch (_state) {
      case PlayerState.playing:
        await _audio.pauseAudio();
      case PlayerState.paused:
        await _audio.resumeAudio();
      default:
        await _start();
    }
  }

  String _format(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _audio.stopAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxMillis = _duration.inMilliseconds;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.soft(theme.brightness),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _loading || !_hasAudio ? null : _toggle,
                  icon: Icon(
                    _state == PlayerState.playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppColors.gold,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _loading
                          ? 'Carregando áudio...'
                          : _hasAudio
                              ? 'Áudio narrado'
                              : 'Áudio não disponível',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _hasAudio ? _audio.stopAudio : null,
                icon: const Icon(Icons.stop_rounded),
                tooltip: 'Parar',
              ),
            ],
          ),
          if (_hasAudio) ...[
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: AppColors.gold,
                inactiveTrackColor: theme.colorScheme.outlineVariant,
                thumbColor: AppColors.gold,
              ),
              child: Slider(
                value: maxMillis == 0
                    ? 0
                    : _position.inMilliseconds.clamp(0, maxMillis).toDouble(),
                max: maxMillis == 0 ? 1 : maxMillis.toDouble(),
                onChanged: (value) {
                  if (maxMillis > 0) {
                    _audio.seek(Duration(milliseconds: value.round()));
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_format(_position), style: theme.textTheme.labelSmall),
                  Text(_format(_duration), style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
