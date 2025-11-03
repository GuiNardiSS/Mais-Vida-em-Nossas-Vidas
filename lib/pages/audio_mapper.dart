import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/palette.dart';

class AudioMapperPage extends StatefulWidget {
  const AudioMapperPage({super.key});

  @override
  State<AudioMapperPage> createState() => _AudioMapperPageState();
}

class _AudioMapperPageState extends State<AudioMapperPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentCardIndex = 0;
  int? _selectedAudioIndex;
  Map<int, int> _audioMapping = {}; // carta -> audio
  bool _isPlaying = false;
  String? _currentlyPlayingAudio;

  @override
  void initState() {
    super.initState();
    _loadMapping();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  Future<void> _loadMapping() async {
    final prefs = await SharedPreferences.getInstance();
    final String? mappingJson = prefs.getString('audio_mapping_dia');
    if (mappingJson != null) {
      final Map<String, dynamic> decoded = json.decode(mappingJson);
      setState(() {
        _audioMapping =
            decoded.map((key, value) => MapEntry(int.parse(key), value as int));
      });
    }
  }

  Future<void> _saveMapping() async {
    final prefs = await SharedPreferences.getInstance();
    final mappingJson = json.encode(
        _audioMapping.map((key, value) => MapEntry(key.toString(), value)));
    await prefs.setString('audio_mapping_dia', mappingJson);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mapeamento salvo com sucesso!')),
      );
    }
  }

  Future<void> _playAudio(int audioIndex) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer
          .play(AssetSource('audios_cartas_dia/carta_${audioIndex + 1}.mp3'));
      setState(() {
        _currentlyPlayingAudio = 'carta_${audioIndex + 1}.mp3';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao reproduzir áudio: $e')),
        );
      }
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _currentlyPlayingAudio = null;
    });
  }

  void _assignAudioToCard() {
    if (_selectedAudioIndex != null) {
      setState(() {
        _audioMapping[_currentCardIndex] = _selectedAudioIndex!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Carta ${_currentCardIndex + 1} mapeada para carta_${_selectedAudioIndex! + 1}.mp3'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _nextCard() {
    if (_currentCardIndex < 49) {
      setState(() {
        _currentCardIndex++;
        _selectedAudioIndex = _audioMapping[_currentCardIndex];
      });
      _stopAudio();
    }
  }

  void _previousCard() {
    if (_currentCardIndex > 0) {
      setState(() {
        _currentCardIndex--;
        _selectedAudioIndex = _audioMapping[_currentCardIndex];
      });
      _stopAudio();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapear Áudios das Cartas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMapping,
            tooltip: 'Salvar Mapeamento',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Como usar'),
                  content: const Text(
                    '1. Veja a imagem da carta\n'
                    '2. Leia o texto na carta\n'
                    '3. Ouça os áudios disponíveis\n'
                    '4. Selecione o áudio que corresponde ao texto da carta\n'
                    '5. Clique em "Mapear Esta Carta"\n'
                    '6. Use as setas para navegar\n'
                    '7. Clique em salvar quando terminar',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Entendi'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progresso
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Carta ${_currentCardIndex + 1} de 50',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_audioMapping.length}/50 mapeadas',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Visualização da carta
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Imagem da Carta (Leia o texto):',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: InteractiveViewer(
                      child: Image.asset(
                        'assets/cartas_do_dia/Back (${_currentCardIndex + 1}).png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text('Imagem não encontrada'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_audioMapping.containsKey(_currentCardIndex))
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        '✓ Mapeada para: carta_${_audioMapping[_currentCardIndex]! + 1}.mp3',
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Controles de navegação da carta
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentCardIndex > 0 ? _previousCard : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Anterior'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _currentCardIndex < 49 ? _nextCard : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Próxima'),
                ),
              ],
            ),
          ),

          const Divider(thickness: 2),

          // Lista de áudios
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Selecione o áudio correspondente:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (_isPlaying)
                        IconButton(
                          icon: const Icon(Icons.stop, color: Colors.red),
                          onPressed: _stopAudio,
                          tooltip: 'Parar',
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 50,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedAudioIndex == index;
                      final isPlaying =
                          _currentlyPlayingAudio == 'carta_${index + 1}.mp3';

                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedAudioIndex = index;
                          });
                          _playAudio(index);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? AppColors.logoGold
                              : isPlaying
                                  ? Colors.blue
                                  : AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isPlaying ? Icons.volume_up : Icons.music_note,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${index + 1}',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Botão de mapear
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed:
                    _selectedAudioIndex != null ? _assignAudioToCard : null,
                icon: const Icon(Icons.link),
                label: Text(
                  _selectedAudioIndex != null
                      ? 'Mapear Carta ${_currentCardIndex + 1} → Áudio ${_selectedAudioIndex! + 1}'
                      : 'Selecione um áudio primeiro',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logoGold,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
