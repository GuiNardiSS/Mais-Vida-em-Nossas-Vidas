
import 'package:flutter/material.dart';

class EspiritualidadeDiaPage extends StatelessWidget {
  const EspiritualidadeDiaPage({super.key});
  @override
  Widget build(BuildContext context) {
    final parceiros = const [
      {'nome':'YogaZen','descricao':'Yoga: conexão corpo, mente e espírito.','link':'https://instagram.com/yogazen'},
      {'nome':'Espaço Luz Divina','descricao':'Harmonização de ambientes e paz interior.','link':'https://espacoluz.com'},
    ];
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: parceiros.length,
        itemBuilder: (_, i) {
          final p = parceiros[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(p['nome']!),
              subtitle: Text(p['descricao']!),
              trailing: const Icon(Icons.open_in_new),
            ),
          );
        },
      ),
    );
  }
}
