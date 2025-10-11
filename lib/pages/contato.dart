import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

// Classe para representar links de conteúdo
class ContentLink {
  final String title;
  final String url;
  final String? thumbnailUrl;
  final ContentType type;

  ContentLink({
    required this.title,
    required this.url,
    this.thumbnailUrl,
    required this.type,
  });
}

enum ContentType { youtube, instagram, other }

class ContatoPage extends StatefulWidget {
  const ContatoPage({super.key});

  @override
  State<ContatoPage> createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  List<ContentLink> contentLinks = [
    // Exemplos iniciais com vídeos específicos que terão thumbnails extraídas automaticamente
    ContentLink(
      title: 'Meditação Guiada - Encontrando Seu Propósito',
      url:
          'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // Exemplo - substitua por vídeos reais
      type: ContentType.youtube,
    ),
    ContentLink(
      title: 'Espiritualidade no Ambiente de Trabalho',
      url:
          'https://www.youtube.com/watch?v=ScMzIvxBSi4', // Exemplo - substitua por vídeos reais
      type: ContentType.youtube,
    ),
    ContentLink(
      title: 'Posts Inspiracionais no Instagram',
      url: 'https://www.instagram.com/helocoelhoconsultoria',
      type: ContentType.instagram,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadThumbnails();
  }

  // Carrega as thumbnails dos links automaticamente
  Future<void> _loadThumbnails() async {
    for (int i = 0; i < contentLinks.length; i++) {
      final link = contentLinks[i];
      String? thumbnailUrl;

      if (link.type == ContentType.youtube) {
        thumbnailUrl = await _getYoutubeThumbnail(link.url);
      } else if (link.type == ContentType.instagram) {
        thumbnailUrl = await _getInstagramThumbnail(link.url);
      }

      if (thumbnailUrl != null && mounted) {
        setState(() {
          contentLinks[i] = ContentLink(
            title: link.title,
            url: link.url,
            thumbnailUrl: thumbnailUrl,
            type: link.type,
          );
        });
      }
    }
  }

  // Extrai thumbnail do YouTube
  Future<String?> _getYoutubeThumbnail(String url) async {
    try {
      // Extrai o ID do vídeo do YouTube
      String? videoId = _extractYouTubeVideoId(url);
      if (videoId != null) {
        // Retorna a URL da thumbnail do YouTube
        return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
      }
    } catch (e) {
      debugPrint('Erro ao extrair thumbnail do YouTube: $e');
    }
    return null;
  }

  // Extrai ID do vídeo do YouTube da URL
  String? _extractYouTubeVideoId(String url) {
    final regex = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  // Simula extração de thumbnail do Instagram (API limitada)
  Future<String?> _getInstagramThumbnail(String url) async {
    try {
      // Para o Instagram, vamos usar uma imagem padrão ou tentar extrair do HTML
      // Como a API do Instagram é restrita, usaremos uma abordagem simplificada
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final htmlContent = response.body;
        final regex = RegExp(r'property="og:image" content="([^"]+)"');
        final match = regex.firstMatch(htmlContent);
        return match?.group(1);
      }
    } catch (e) {
      debugPrint('Erro ao extrair thumbnail do Instagram: $e');
    }
    return null;
  }

  // Adiciona um novo link de conteúdo
  void _addContentLink(String title, String url) {
    ContentType type = ContentType.other;

    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      type = ContentType.youtube;
    } else if (url.contains('instagram.com')) {
      type = ContentType.instagram;
    }

    setState(() {
      contentLinks.add(ContentLink(
        title: title,
        url: url,
        type: type,
      ));
    });

    _loadThumbnails(); // Recarrega thumbnails
  }

  // Dialog para adicionar novo link
  void _showAddLinkDialog() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Conteúdo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ex: Vídeo sobre meditação',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    urlController.text.isNotEmpty) {
                  _addContentLink(titleController.text, urlController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Quem é Helô Coelho?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sou Administradora, mentora, consultora e palestrante com uma sólida trajetória de 30 anos no empreendedorismo e na gestão empresarial. Atuei como idealizadora de ações e de eventos que impulsionaram empreendedores e líderes, contribuindo para o fortalecimento e visibilidade de novos negócios no mercado.\n\n'
                'Minha paixão pela comunicação me levou a expandir minha atuação no segmento de TV. Além de exercer a função de CEO nacional da TV Padrão Brasil, ao longo dessa jornada me dediquei a conectar histórias, inspirar pessoas e líderes e iniciativas que fazem a diferença no mundo dos negócios.\n\n'
                'Atualmente, também sou Pós-graduada em Neurociências do Comportamento e Desenvolvimento Humano, idealizadora da Espiritualidade na Prática Clínica, Inovação da Espiritualidade nas Relações e Brancas. Acredito que a espiritualidade é um pilar essencial para o desenvolvimento humano nas pautas do autoconhecimento, autogestão e propósito de vida, em ambientes organizacionais e na vida pessoal.\n\n'
                'Minha missão é inspirar pessoas a encontrarem sentido e propósito em suas jornadas, promovendo a dedicação e estudo da influência da espiritualidade nas relações humanas e no ambiente de trabalho, para que haja mais integração, bem-estar e felicidade.\n\n'
                'Através dos meus projetos, cursos, mentorias e palestras, busco compartilhar conhecimento e experiências que auxiliem na construção de um mundo melhor.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text(
                'Contatos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Grid de contatos clicáveis
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildContactButton(
                    context,
                    'E-mail',
                    FontAwesomeIcons.envelope,
                    'mailto:helocoelho10@outlook.com',
                  ),
                  _buildContactButton(
                    context,
                    'Instagram',
                    FontAwesomeIcons.instagram,
                    'https://www.instagram.com/helocoelhoconsultoria',
                  ),
                  _buildContactButton(
                    context,
                    'WhatsApp',
                    FontAwesomeIcons.whatsapp,
                    'https://api.whatsapp.com/message/5TM3HXDZJ77NL1?autoload=1&app_absent=0',
                  ),
                  _buildContactButton(
                    context,
                    'YouTube',
                    FontAwesomeIcons.youtube,
                    'https://www.youtube.com/@helocoelho10',
                  ),
                  _buildContactButton(
                    context,
                    'LinkedIn',
                    FontAwesomeIcons.linkedin,
                    'https://www.linkedin.com/in/helôcoelho',
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Seção de Conteúdo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Conteúdo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _showAddLinkDialog,
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Adicionar conteúdo',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lista de conteúdo
              if (contentLinks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.video_library_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum conteúdo adicionado ainda.\nToque no + para adicionar links.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contentLinks.length,
                  itemBuilder: (context, index) {
                    return _buildContentCard(contentLinks[index]);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para exibir cada card de conteúdo
  Widget _buildContentCard(ContentLink contentLink) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: InkWell(
        onTap: () => _launchUrl(contentLink.url),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 120,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF0b4c52).withValues(alpha: 0.1),
                ),
                child: contentLink.thumbnailUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          contentLink.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultThumbnail(contentLink.type);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        ),
                      )
                    : _buildDefaultThumbnail(contentLink.type),
              ),
              const SizedBox(width: 16),

              // Conteúdo do texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      contentLink.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _getIconForContentType(contentLink.type),
                          size: 16,
                          color: _getColorForContentType(contentLink.type),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getPlatformName(contentLink.type),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getColorForContentType(contentLink.type),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contentLink.url,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Ícone de link externo
              Icon(
                Icons.open_in_new,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Thumbnail padrão para cada tipo de conteúdo
  Widget _buildDefaultThumbnail(ContentType type) {
    IconData icon;
    Color color;

    switch (type) {
      case ContentType.youtube:
        icon = FontAwesomeIcons.youtube;
        color = const Color(0xFFFF0000);
        break;
      case ContentType.instagram:
        icon = FontAwesomeIcons.instagram;
        color = const Color(0xFFE4405F);
        break;
      default:
        icon = Icons.link;
        color = const Color(0xFF0b4c52);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: FaIcon(
          icon,
          size: 32,
          color: color,
        ),
      ),
    );
  }

  // Retorna o ícone apropriado para cada tipo de conteúdo
  IconData _getIconForContentType(ContentType type) {
    switch (type) {
      case ContentType.youtube:
        return FontAwesomeIcons.youtube;
      case ContentType.instagram:
        return FontAwesomeIcons.instagram;
      default:
        return Icons.link;
    }
  }

  // Retorna a cor apropriada para cada tipo de conteúdo
  Color _getColorForContentType(ContentType type) {
    switch (type) {
      case ContentType.youtube:
        return const Color(0xFFFF0000);
      case ContentType.instagram:
        return const Color(0xFFE4405F);
      default:
        return const Color(0xFF0b4c52);
    }
  }

  // Retorna o nome da plataforma
  String _getPlatformName(ContentType type) {
    switch (type) {
      case ContentType.youtube:
        return 'YouTube';
      case ContentType.instagram:
        return 'Instagram';
      default:
        return 'Link';
    }
  }

  Widget _buildContactButton(
    BuildContext context,
    String label,
    IconData icon,
    String url,
  ) {
    // Cores específicas para cada rede social
    Color iconColor;
    Color borderColor;

    switch (label.toLowerCase()) {
      case 'instagram':
        iconColor = const Color(0xFFE4405F); // Rosa do Instagram
        borderColor = const Color(0xFFE4405F).withValues(alpha: 0.3);
        break;
      case 'whatsapp':
        iconColor = const Color(0xFF25D366); // Verde do WhatsApp
        borderColor = const Color(0xFF25D366).withValues(alpha: 0.3);
        break;
      case 'youtube':
        iconColor = const Color(0xFFFF0000); // Vermelho do YouTube
        borderColor = const Color(0xFFFF0000).withValues(alpha: 0.3);
        break;
      case 'linkedin':
        iconColor = const Color(0xFF0077B5); // Azul do LinkedIn
        borderColor = const Color(0xFF0077B5).withValues(alpha: 0.3);
        break;
      case 'e-mail':
        iconColor = const Color(0xFF34495E); // Cinza escuro para email
        borderColor = const Color(0xFF34495E).withValues(alpha: 0.3);
        break;
      default:
        iconColor = const Color(0xFF0b4c52);
        borderColor = const Color(0xFF0b4c52).withValues(alpha: 0.3);
    }

    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              color: iconColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: iconColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Handle error - could show a snackbar or dialog
      debugPrint('Could not launch $url');
    }
  }
}
