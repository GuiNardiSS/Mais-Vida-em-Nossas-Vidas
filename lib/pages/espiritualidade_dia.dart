import 'package:flutter/material.dart';

class EspiritualidadeDiaPage extends StatelessWidget {
  const EspiritualidadeDiaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final parceiros = const [
      {
        'nome': 'YogaZen',
        'descricao':
            'Yoga: conexão corpo, mente e espírito. Aulas presenciais e online para todos os níveis.',
        'contato': 'Instagram: @yogazen',
      },
      {
        'nome': 'Espaço Luz Divina',
        'descricao':
            'Harmonização de ambientes, terapias integrativas e cursos de autoconhecimento.',
        'contato': 'Site: espacoluz.com',
      },
      {
        'nome': 'MeditaFácil',
        'descricao':
            'Meditação guiada para iniciantes e avançados. Encontre equilíbrio e paz interior.',
        'contato': 'Instagram: @meditafacil',
      },
      {
        'nome': 'Alma Consciente',
        'descricao':
            'Conteúdo sobre espiritualidade, autoconhecimento e desenvolvimento pessoal.',
        'contato': 'YouTube: Alma Consciente',
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espiritualidade no Dia a Dia'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Parceiros',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...parceiros.map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['nome']!,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p['descricao']!,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p['contato']!,
                          style: const TextStyle(
                              fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
