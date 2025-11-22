import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class EspiritualidadeDiaPage extends StatelessWidget {
  const EspiritualidadeDiaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> parceiros = const [
      {
        'nome': 'Bele Beauty Store',
        'descricao':
            'A Bele Beauty é uma empresa espiritualizada porque nasceu com um propósito que vai além da estética: cuidar da beleza que começa na alma e transborda para o mundo. Cada peça, cada criação e cada atendimento carrega intenção, presença e energia boa — porque acreditamos que beleza verdadeira é aquela que eleva, conecta e inspira.',
        'whatsapp': 'http://wa.me/5548998171948',
        'instagram':
            'https://www.instagram.com/belebeautystore?igsh=YWFoOHF0OWU0djkw',
        'site': 'http://www.belebeauty.com.br/',
        'contato': 'Site: www.belebeauty.com.br',
      },
      {
        'nome': 'Reffinatto Brazil',
        'descricao':
            'Na Reffinatto Brazil, o atendimento humanizado é o coração que transforma projetos em lares e móveis em experiências de bem-estar.',
        'whatsapp': 'http://wa.me/554891005888',
        'instagram':
            'https://www.instagram.com/reffinattobrazil?igsh=MW9yb3A4NzFpc2pm',
        'site': 'https://share.google/gx3lfudnBuqC5IhJC',
        'contato': 'Instagram: @reffinattobrazil',
      },
    ];
    return Scaffold(
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
                        'Patrocinadores',
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

                      // Configuração específica por parceiro
                      final isBele = p['nome'] == 'Bele Beauty Store';
                      final boxFit = isBele ? BoxFit.cover : BoxFit.contain;
                      final bgColor =
                          isBele ? const Color(0xFF0b4c52) : Colors.white;
                      final padding =
                          isBele ? EdgeInsets.zero : const EdgeInsets.all(8);

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _mostrarDetalhes(context, p),
                          child: Row(
                            children: [
                              Container(
                                width: isWide ? 140 : 120,
                                height: double.infinity,
                                color: bgColor,
                                padding: padding,
                                child: Image.asset(
                                  imgPath,
                                  fit: boxFit,
                                  cacheWidth:
                                      400, // Otimização: Reduz uso de memória
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
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              parceiro['descricao'] ?? '',
              style: const TextStyle(color: Colors.black, height: 1.5),
            ),
            const SizedBox(height: 16),
            // Botões de redes sociais e contato
            if (parceiro['whatsapp'] != null ||
                parceiro['instagram'] != null ||
                parceiro['site'] != null) ...[
              const Divider(),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (parceiro['whatsapp'] != null)
                    ElevatedButton.icon(
                      onPressed: () => _abrirLink(parceiro['whatsapp']!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('WhatsApp'),
                    ),
                  if (parceiro['instagram'] != null)
                    ElevatedButton.icon(
                      onPressed: () => _abrirLink(parceiro['instagram']!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE4405F),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: const Text('Instagram'),
                    ),
                  if (parceiro['site'] != null)
                    ElevatedButton.icon(
                      onPressed: () => _abrirLink(parceiro['site']!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0b4c52),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.public, size: 18),
                      label: const Text('Site'),
                    ),
                ],
              ),
            ] else ...[
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
          ],
        ),
      ),
      actions: [
        if (parceiro['whatsapp'] == null &&
            parceiro['instagram'] == null &&
            parceiro['site'] == null)
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

Future<void> _abrirLink(String url) async {
  try {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    // Ignora erro silenciosamente
  }
}

IconData _iconForContato(String contato) {
  final c = contato.toLowerCase();
  if (c.startsWith('instagram')) return Icons.camera_alt_outlined;
  if (c.startsWith('youtube')) return Icons.ondemand_video_outlined;
  if (c.startsWith('site')) return Icons.public;
  return Icons.open_in_new;
}
