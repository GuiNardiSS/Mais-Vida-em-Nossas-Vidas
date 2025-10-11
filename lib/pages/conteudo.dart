import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ConteudoPage extends StatefulWidget {
  const ConteudoPage({super.key});
  @override
  State<ConteudoPage> createState() => _ConteudoPageState();
}

class _ConteudoPageState extends State<ConteudoPage> {
  final tituloCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final ytCtrl = TextEditingController();
  final igCtrl = TextEditingController();
  List<Map<String, String>> conteudos = [];
  final bool isAdmin = true; // Troque para false para usuário comum

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('conteudos');
    if (raw != null) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      conteudos =
          list.map((e) => e.map((k, v) => MapEntry(k, v.toString()))).toList();
    } else {
      conteudos = [
        {
          'titulo': 'Entrevista',
          'descricao': 'Transforme sua energia no trabalho.',
          'youtube': 'https://youtube.com',
          'instagram': 'https://instagram.com'
        }
      ];
    }
    setState(() {});
  }

  Future<void> _add() async {
    final item = {
      'titulo': tituloCtrl.text,
      'descricao': descCtrl.text,
      'youtube': ytCtrl.text,
      'instagram': igCtrl.text,
    };
    conteudos.insert(0, item);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('conteudos', jsonEncode(conteudos));
    tituloCtrl.clear();
    descCtrl.clear();
    ytCtrl.clear();
    igCtrl.clear();
    setState(() {});
  }

  String _getContentImagePath(String titulo) {
    // Converte título para nome de arquivo de imagem
    final simple = titulo
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ã', 'a')
        .replaceAll('õ', 'o')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return 'assets/conteudo/$simple.png';
  }

  void _showContentDialog(Map<String, String> c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          c['titulo'] ?? '',
          style: const TextStyle(color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              c['descricao'] ?? '',
              style: const TextStyle(color: Colors.black),
            ),
            if ((c['youtube'] ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_outline,
                        color: Color(0xFFFF0000), size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'YouTube: ${c['youtube']}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            if ((c['instagram'] ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.camera_alt_outlined,
                        color: Color(0xFFE4405F), size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Instagram: ${c['instagram']}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Fechar',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 28),
              tooltip: 'Adicionar conteúdo',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text(
                      'Novo conteúdo',
                      style: TextStyle(color: Colors.black),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                              controller: tituloCtrl,
                              decoration:
                                  const InputDecoration(labelText: 'Título')),
                          TextField(
                              controller: descCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Descrição')),
                          TextField(
                              controller: ytCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Link YouTube')),
                          TextField(
                              controller: igCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Link Instagram')),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _add();
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Salvar',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: conteudos.map((c) {
            final imagePath = _getContentImagePath(c['titulo'] ?? '');

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () => _showContentDialog(c),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Área da imagem
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0b4c52),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: const Color(0xFF0b4c52),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 48,
                                    color: Colors.white70,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Imagem do\nConteúdo',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Área do conteúdo
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['titulo'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF0b4c52),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              c['descricao'] ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Links
                            Row(
                              children: [
                                if ((c['youtube'] ?? '').isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: const Chip(
                                      avatar: Icon(Icons.play_circle_outline,
                                          size: 18),
                                      label: Text('YouTube',
                                          style: TextStyle(fontSize: 12)),
                                      backgroundColor: Color(0xFFFF0000),
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                    ),
                                  ),
                                if ((c['instagram'] ?? '').isNotEmpty)
                                  const Chip(
                                    avatar: Icon(Icons.camera_alt_outlined,
                                        size: 18),
                                    label: Text('Instagram',
                                        style: TextStyle(fontSize: 12)),
                                    backgroundColor: Color(0xFFE4405F),
                                    labelStyle: TextStyle(color: Colors.white),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
