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
      conteudos = list.map((e) => e.map((k,v)=>MapEntry(k, v.toString()))).toList();
    } else {
      conteudos = [
        {'titulo':'Entrevista','descricao':'Transforme sua energia no trabalho.','youtube':'https://youtube.com','instagram':'https://instagram.com'}
      ];
    }
    setState((){});
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
    tituloCtrl.clear(); descCtrl.clear(); ytCtrl.clear(); igCtrl.clear();
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conteúdo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  [
              Image.asset(
                'assets/conteudo_img.png', // Salve a imagem da página 7 como 'conteudo_img.png'
                width: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              const Text(
                'Conteúdo Exclusivo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Aprofunde-se em temas de espiritualidade, autoconhecimento e bem-estar. Aqui você encontra artigos, vídeos e reflexões cuidadosamente selecionados para inspirar sua jornada e transformar seu dia a dia.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text('Novo conteúdo do dia', style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(controller: tituloCtrl, decoration: const InputDecoration(labelText: 'Título')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descrição')),
              TextField(controller: ytCtrl, decoration: const InputDecoration(labelText: 'Link YouTube')),
              TextField(controller: igCtrl, decoration: const InputDecoration(labelText: 'Link Instagram')),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _add, child: const Text('Adicionar')),
              const SizedBox(height: 16),
              const Divider(),
              const Text('Conteúdos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (final c in conteudos)
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(c['titulo'] ?? ''),
                    subtitle: Text(c['descricao'] ?? ''),
                    trailing: const Icon(Icons.link),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
