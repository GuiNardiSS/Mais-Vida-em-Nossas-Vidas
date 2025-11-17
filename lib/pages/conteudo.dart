import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../widgets/video_popup_player.dart';

// Tipos de conteúdo
enum ContentType {
  link, // Links externos (YouTube, Instagram)
  video, // Vídeo interno do app
  text, // Texto longo (popup)
}

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
  List<Map<String, dynamic>> conteudos = [];
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
      conteudos = list;
    } else {
      // Conteúdos padrão com tipos mistos
      conteudos = [
        // VÍDEOS INTERNOS (3 vídeos)
        {
          'titulo': 'Vídeo 1: Introdução à Espiritualidade',
          'descricao':
              'Assista este vídeo introdutório sobre práticas espirituais e conexão com o divino.',
          'tipo': 'video',
          'videoPath': 'assets/conteudo/video1.mp4',
          'imagePath': 'assets/conteudo/video1_thumb.png',
        },
        {
          'titulo': 'Vídeo 2: Meditação Guiada',
          'descricao':
              'Uma sessão completa de meditação guiada para acalmar a mente e encontrar paz interior.',
          'tipo': 'video',
          'videoPath': 'assets/conteudo/video2.mp4',
          'imagePath': 'assets/conteudo/video2_thumb.png',
        },
        {
          'titulo': 'Vídeo 3: Gratidão Diária',
          'descricao':
              'Aprenda a praticar gratidão todos os dias e transforme sua vida.',
          'tipo': 'video',
          'videoPath': 'assets/conteudo/video3.mp4',
          'imagePath': 'assets/conteudo/video3_thumb.png',
        },

        // TEXTOS INTERNOS
        {
          'titulo': 'A Menina que Falava com o Jardim',
          'descricao':
              'Uma história encantadora sobre conexão com a natureza e o divino.',
          'tipo': 'text',
          'textoCompleto': '''
📖 A Criança que Falava com o Jardim
Por Helô Coelho

RESUMO DO LIVRO:

Em um mundo que muitas vezes silencia o que não compreende, Luiza percebeu já na sua infância o extraordinário: ela falava com o jardim. Para ela, as árvores eram suas confidentes, que trazia segurança, as flores compartilhavam sabedorias e o vento trazia mensagens de um plano invisível. Mas como uma criança tão sensível navega por um mundo que insiste em ver apenas o tangível, onde os desafios da escola e as expectativas sociais parecem querer abafar sua voz interior?

Em "A Criança que falava com o Jardim", Helô Coelho nos convida a mergulhar na jornada de Luiza, uma alma que desde cedo percebeu a profunda conexão entre o visível e o invisível. Acompanhe seus desafios, suas descobertas sobre a mediunidade e a importância vital da espiritualidade para o desenvolvimento pessoal – um tema que a autora, com sua experiência em levar a consciência espiritual às organizações, aborda com rara profundidade.

Esta não é apenas a história de uma menina, mas um espelho para todos os corações inquietos e sensíveis que buscam validar suas próprias percepções. É um convite para desvendar a magia que reside na escuta atenta, na aceitação do dom inato e na compreensão de que somos parte de algo muito maior. Prepare-se para uma leitura que irá despertar sua própria centelha interior e reacender a crença na sabedoria que a natureza e o espírito têm a nos oferecer, guiando-o para um reencontro com o seu próprio mundo.
''',
          'imagePath': 'assets/conteudo/capa_livro_menina_jardim.png',
        },

        {
          'titulo': 'O Poder da Gratidão',
          'descricao':
              'Descubra como a gratidão pode transformar sua vida e suas relações.',
          'tipo': 'text',
          'textoCompleto': '''
A gratidão é uma das práticas mais poderosas para transformar nossa vida. Quando cultivamos um coração grato, mudamos nossa perspectiva e começamos a enxergar as bênçãos que nos cercam.

🙏 Benefícios da Gratidão:

• Melhora o bem-estar emocional
• Fortalece relacionamentos
• Reduz estresse e ansiedade
• Aumenta a felicidade
• Promove resiliência

💫 Como Praticar:

1. Mantenha um diário de gratidão
2. Agradeça 3 coisas todo dia
3. Expresse gratidão às pessoas
4. Reconheça as pequenas bênçãos
5. Medite sobre suas conquistas

A gratidão não é apenas um sentimento, é uma escolha consciente que fazemos todos os dias. Comece hoje mesmo!
''',
          'imagePath': 'assets/conteudo/gratidao.png',
        },

        // LINKS EXTERNOS (mantidos)
        {
          'titulo': 'Meditação Guiada',
          'descricao':
              'Aprenda técnicas de meditação para encontrar paz interior e equilíbrio emocional.',
          'tipo': 'link',
          'youtube': 'https://youtube.com/@meditacao',
          'instagram': 'https://instagram.com/meditacao',
          'imagePath': null,
        },
        {
          'titulo': 'Desenvolvimento Pessoal',
          'descricao':
              'Dicas práticas para seu crescimento pessoal e profissional.',
          'tipo': 'link',
          'youtube': 'https://youtube.com/@desenvolvimento',
          'instagram': 'https://instagram.com/desenvolvimento',
          'imagePath': null,
        },
        {
          'titulo': 'Mindfulness',
          'descricao':
              'Pratique a atenção plena no seu dia a dia e reduza o estresse.',
          'tipo': 'link',
          'youtube': 'https://youtube.com/@mindfulness',
          'instagram': 'https://instagram.com/mindfulness',
          'imagePath': null,
        },
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

  String? _getContentImagePath(Map<String, dynamic> c) {
    // Se tiver imagePath definido, usa ele
    if (c['imagePath'] != null) {
      return c['imagePath'].toString();
    }

    // Caso contrário, tenta gerar automaticamente
    final titulo = c['titulo']?.toString() ?? '';
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

  IconData _getContentIcon(Map<String, dynamic> c) {
    final tipo = c['tipo'] ?? 'link';
    switch (tipo) {
      case 'video':
        return Icons.play_circle_filled;
      case 'text':
        return Icons.article;
      default:
        return Icons.link;
    }
  }

  Color _getContentColor(Map<String, dynamic> c) {
    final tipo = c['tipo'] ?? 'link';
    switch (tipo) {
      case 'video':
        return const Color(0xFFFF0000); // Vermelho para vídeo
      case 'text':
        return const Color(0xFF0b4c52); // Azul escuro para texto
      default:
        return const Color(0xFF0b4c52); // Azul escuro para links
    }
  }

  Widget _buildPlaceholder(IconData icon, String tipo) {
    return Container(
      color: _getContentColor({'tipo': tipo}),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.white70,
          ),
          const SizedBox(height: 12),
          Text(
            tipo == 'video'
                ? 'Vídeo\nDisponível'
                : tipo == 'text'
                    ? 'Artigo\nDisponível'
                    : 'Links\nExternos',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirLink(String url) async {
    if (url.isEmpty) return;

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Não foi possível abrir o link: $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showContentDialog(Map<String, dynamic> c) {
    final tipo = c['tipo'] ?? 'link';

    // Se for vídeo, abrir player de vídeo
    if (tipo == 'video') {
      _showVideoPlayer(c);
      return;
    }

    // Se for texto, mostrar popup com texto completo
    if (tipo == 'text') {
      _showTextPopup(c);
      return;
    }

    // Se for link, mostrar dialog com links externos
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
            if ((c['youtube']?.toString() ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InkWell(
                  onTap: () => _abrirLink(c['youtube']?.toString() ?? ''),
                  child: Row(
                    children: [
                      const Icon(Icons.play_circle_outline,
                          color: Color(0xFFFF0000), size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'YouTube: ${c['youtube']}',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if ((c['instagram']?.toString() ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: InkWell(
                  onTap: () => _abrirLink(c['instagram']?.toString() ?? ''),
                  child: Row(
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          color: Color(0xFFE4405F), size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Instagram: ${c['instagram']}',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
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

  // Mostra player de vídeo em tela cheia
  void _showVideoPlayer(Map<String, dynamic> c) {
    final videoPath = c['videoPath']?.toString() ?? '';

    if (videoPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vídeo não disponível'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => Dialog.fullscreen(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Player de vídeo responsivo
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return VideoPopupPlayer(
                    videoUrl: videoPath,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                  );
                },
              ),
            ),

            // Botão fechar
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Título do vídeo
            Positioned(
              top: 40,
              left: 16,
              right: 80,
              child: Text(
                c['titulo'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mostra popup com texto completo
  void _showTextPopup(Map<String, dynamic> c) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: MediaQuery.of(context).size.width * 0.95,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cabeçalho
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF0b4c52),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.article, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        c['titulo'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Conteúdo de texto
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    c['textoCompleto']?.toString() ?? c['descricao'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              // Botão fechar
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0b4c52),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        ),
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
            final imagePath = _getContentImagePath(c);
            final tipo = c['tipo'] ?? 'link';
            final contentIcon = _getContentIcon(c);
            final contentColor = _getContentColor(c);

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
                      // Área da imagem com ícone de tipo
                      Stack(
                        children: [
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: contentColor,
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
                              child: imagePath != null
                                  ? Image.asset(
                                      imagePath,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          _buildPlaceholder(contentIcon, tipo),
                                    )
                                  : _buildPlaceholder(contentIcon, tipo),
                            ),
                          ),

                          // Badge com tipo de conteúdo
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    contentIcon,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    tipo == 'video'
                                        ? 'Vídeo'
                                        : tipo == 'text'
                                            ? 'Artigo'
                                            : 'Links',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

                            // Links clicáveis
                            Row(
                              children: [
                                if ((c['youtube'] ?? '').isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: InkWell(
                                      onTap: () =>
                                          _abrirLink(c['youtube'] ?? ''),
                                      borderRadius: BorderRadius.circular(16),
                                      child: const Chip(
                                        avatar: Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        label: Text(
                                          'YouTube',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor: Color(0xFFFFE5E5),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                      ),
                                    ),
                                  ),
                                if ((c['instagram'] ?? '').isNotEmpty)
                                  InkWell(
                                    onTap: () =>
                                        _abrirLink(c['instagram'] ?? ''),
                                    borderRadius: BorderRadius.circular(16),
                                    child: const Chip(
                                      avatar: Icon(
                                        Icons.camera_alt_outlined,
                                        color: Color(0xFFE4405F),
                                        size: 20,
                                      ),
                                      label: Text(
                                        'Instagram',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: Color(0xFFFFE5EC),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                    ),
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
