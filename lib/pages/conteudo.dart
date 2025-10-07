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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conteúdo'),
        centerTitle: true,
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 28),
              tooltip: 'Adicionar conteúdo',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Novo conteúdo'),
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
                        child: const Text('Salvar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: conteudos.length,
          itemBuilder: (context, index) {
            final c = conteudos[index];
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(c['titulo'] ?? ''),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['descricao'] ?? ''),
                        if ((c['youtube'] ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('YouTube: ${c['youtube']}'),
                          ),
                        if ((c['instagram'] ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('Instagram: ${c['instagram']}'),
                          ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Fechar'),
                      ),
                    ],
                  ),
                );
              },
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        c['titulo'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        c['descricao'] ?? '',
                        style: const TextStyle(fontSize: 13),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
