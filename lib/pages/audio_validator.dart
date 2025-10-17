import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class AudioValidatorPage extends StatefulWidget {
  const AudioValidatorPage({super.key});

  @override
  State<AudioValidatorPage> createState() => _AudioValidatorPageState();
}

class _AudioValidatorPageState extends State<AudioValidatorPage> {
  final audio = AudioService();
  bool _loading = true;
  final Map<int, String?> _diaPath = {};
  final Map<int, String?> _orgPath = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    // Pré-carrega resoluções para os 50 índices de cartas (0..49)
    for (int i = 0; i < 50; i++) {
      _diaPath[i] = await audio.resolveAudioPathDia(i);
      _orgPath[i] = await audio.resolveAudioPathOrganizacao(i);
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Widget _buildRow(int i) {
    final dia = _diaPath[i];
    final org = _orgPath[i];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Carta ${i + 1}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(
                  (dia != null ? 'Dia ✓' : 'Dia –') +
                      '  |  ' +
                      (org != null ? 'Org ✓' : 'Org –'),
                  style: TextStyle(
                    color: (dia != null && org != null)
                        ? Colors.green
                        : (dia != null || org != null)
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Dia:   ${dia ?? '—'}',
                style: const TextStyle(fontSize: 12)),
            Text('Org:   ${org ?? '—'}',
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => audio.playCartaDia(i),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Dia'),
                ),
                ElevatedButton.icon(
                  onPressed: () => audio.playCartaOrganizacao(i),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Org'),
                ),
                ElevatedButton.icon(
                  onPressed: () => audio.stopAudio(),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // A/B: toca dia depois org
                    await audio.playCartaDia(i);
                  },
                  child: const Text('A/B Dia→Org'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Validator (debug)'),
        actions: [
          IconButton(
            onPressed: _loadAll,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, i) => _buildRow(i),
              itemCount: 50,
            ),
    );
  }
}
