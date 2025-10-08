import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class EspiritualidadeDiaPage extends StatelessWidget {
  const EspiritualidadeDiaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> parceiros = const [
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          final crossAxisCount = isWide ? 2 : 1;
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      Text(
                        'Parceiros',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: isWide ? 2.8 : 2.2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = parceiros[index];
                      final imgPath = _parceiroImagePath(p['nome']!);
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _mostrarDetalhes(context, p),
                          child: Row(
                            children: [
                              Container(
                                width: isWide ? 140 : 120,
                                height: double.infinity,
                                color: const Color(0xFF0b4c52),
                                child: Image.asset(
                                  imgPath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, e, st) => const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate_outlined,
                                            color: Colors.white70, size: 32),
                                        SizedBox(height: 4),
                                        Text(
                                          'Imagem',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        p['nome']!,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        p['descricao']!,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              _abrirContato(p['contato'] ?? ''),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF0b4c52),
                                            foregroundColor: Colors.white,
                                            shape: const StadiumBorder(),
                                          ),
                                          icon: Icon(_iconForContato(
                                              p['contato'] ?? '')),
                                          label: const Text('Visitar'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: parceiros.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),
    );
  }
}

void _mostrarDetalhes(BuildContext context, Map<String, String> parceiro) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        parceiro['nome'] ?? '',
        style: const TextStyle(color: Colors.black),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parceiro['descricao'] ?? '',
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _abrirContato(parceiro['contato'] ?? ''),
            child: Text(
              parceiro['contato'] ?? '',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(ctx).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final contato = parceiro['contato'] ?? '';
            await Clipboard.setData(ClipboardData(text: contato));
            if (context.mounted) {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contato copiado')),
              );
            }
          },
          child: const Text(
            'Copiar contato',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text(
            'Fechar',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    ),
  );
}

String _parceiroImagePath(String nome) {
  // Converte nome do parceiro para nome do arquivo de imagem
  // Exemplo: "YogaZen" -> "yogazen.png", "Espaço Luz Divina" -> "espaco_luz_divina.png"
  final simple = nome
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
  return 'assets/parceiros/$simple.png';
}

Future<void> _abrirContato(String contato) async {
  // Aceita formatos: "Instagram: @user", "YouTube: canal", "Site: example.com"
  final c = contato.trim();
  Uri? uri;
  if (c.toLowerCase().startsWith('instagram')) {
    final handle = RegExp(r'@([A-Za-z0-9_.]+)').firstMatch(c)?.group(1);
    if (handle != null) {
      uri = Uri.parse('https://www.instagram.com/$handle');
    }
  } else if (c.toLowerCase().startsWith('youtube')) {
    final term = c.split(':').length > 1 ? c.split(':')[1].trim() : '';
    if (term.isNotEmpty) {
      // abre busca do YouTube para o termo
      uri = Uri.parse(
          'https://www.youtube.com/results?search_query=${Uri.encodeComponent(term)}');
    }
  } else if (c.toLowerCase().startsWith('site')) {
    final url = c.split(':').length > 1 ? c.split(':')[1].trim() : '';
    if (url.isNotEmpty) {
      final normalized = url.startsWith('http') ? url : 'https://$url';
      uri = Uri.parse(normalized);
    }
  }
  uri ??=
      Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(c)}');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

IconData _iconForContato(String contato) {
  final c = contato.toLowerCase();
  if (c.startsWith('instagram')) return Icons.camera_alt_outlined;
  if (c.startsWith('youtube')) return Icons.ondemand_video_outlined;
  if (c.startsWith('site')) return Icons.public;
  return Icons.open_in_new;
}
