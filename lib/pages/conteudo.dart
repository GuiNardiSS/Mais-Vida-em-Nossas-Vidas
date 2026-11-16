import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../design/components/gold_badge.dart';
import '../design/components/soft_card.dart';
import '../design/tokens.dart';
import '../widgets/video_popup_player.dart';
import '../services/usage_restriction_service.dart';

// Tipos de conteúdo
enum ContentType {
  video, // Vídeo interno do app
  text, // Texto longo (popup)
}

class ConteudoPage extends StatefulWidget {
  const ConteudoPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ConteudoPage> createState() => _ConteudoPageState();
}

class _ConteudoPageState extends State<ConteudoPage> {
  List<Map<String, dynamic>> conteudos = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Usando dados padrão (sem cache do SharedPreferences)
    // Para forçar o uso dos novos conteúdos internos
    conteudos = [
      // VÍDEOS INTERNOS (3 vídeos) - SEM THUMBNAIL
      {
        'titulo': 'Espiritualidade nas organizações',
        'descricao':
            'Descubra como a espiritualidade pode transformar o ambiente corporativo, trazendo mais propósito, harmonia e resultados positivos para todos.',
        'tipo': 'video',
        'videoPath': 'assets/conteudo/video1.mp4',
        'premiumOnly': false, // Definir true para conteúdo exclusivo
      },
      {
        'titulo': 'Nunca é tarde para começar',
        'descricao':
            'Inspire-se a dar o primeiro passo em direção aos seus sonhos. Não importa a idade ou o momento, sempre há tempo para iniciar uma nova jornada.',
        'tipo': 'video',
        'videoPath': 'assets/conteudo/video2.mp4',
        'premiumOnly': false, // Definir true para conteúdo exclusivo
      },
      {
        'titulo': 'Em busca do conhecimento',
        'descricao':
            'A jornada do aprendizado é contínua. Explore a importância de buscar sabedoria e como o conhecimento pode expandir seus horizontes e enriquecer sua vida.',
        'tipo': 'video',
        'videoPath': 'assets/conteudo/video3.mp4',
        'premiumOnly': false, // Definir true para conteúdo exclusivo
      },
      {
        'titulo': 'Acolhimento',
        'descricao':
            'Aprenda a importância de acolher a si mesmo e ao próximo com compaixão. O acolhimento é o primeiro passo para a cura e para a construção de relacionamentos mais saudáveis e verdadeiros.',
        'tipo': 'video',
        'videoPath': 'assets/conteudo/Acolhimento.mp4',
        'premiumOnly': true,
      },
      {
        'titulo': 'O Novo Líder',
        'descricao':
            'Descubra as características da liderança moderna baseada em empatia, propósito e espiritualidade. Entenda como inspirar pessoas e criar ambientes de trabalho mais humanos e produtivos.',
        'tipo': 'video',
        'videoPath': 'assets/conteudo/novo_lider.mp4',
        'premiumOnly': true,
      },
      {
        'titulo': 'O Poder do Perdão',
        'descricao':
            'Entenda como o ato de perdoar pode libertar você de pesos do passado. O perdão não é sobre esquecer, mas sobre escolher a paz e permitir que a vida flua novamente.',
        'tipo': 'video',
        'videoPath': 'assets/conteudo/Perdão.mp4',
        'premiumOnly': true,
      },

      // TEXTOS/LIVROS INTERNOS - COM IMAGEM E LINK EXTERNO
      {
        'titulo': 'A Menina que Falava com o Jardim',
        'descricao':
            'Uma história encantadora sobre conexão com a natureza e o divino.',
        'tipo': 'text',
        'imagePath': 'assets/conteudo/capa_livro_menina_jardim.png',
        'externalLink': '', // Adicionar link externo aqui quando disponível
        'premiumOnly': false, // Definir true para conteúdo exclusivo
        'emBreve': true,
        'textoCompleto': '''📖 A Criança que Falava com o Jardim
Por Helô Coelho

RESUMO DO LIVRO:

Em um mundo que muitas vezes silencia o que não compreende, Luiza percebeu já na sua infância o extraordinário: ela falava com o jardim. Para ela, as árvores eram suas confidentes, que trazia segurança, as flores compartilhavam sabedorias e o vento trazia mensagens de um plano invisível. Mas como uma criança tão sensível navega por um mundo que insiste em ver apenas o tangível, onde os desafios da escola e as expectativas sociais parecem querer abafar sua voz interior?

Em "A Criança que falava com o Jardim", Helô Coelho nos convida a mergulhar na jornada de Luiza, uma alma que desde cedo percebeu a profunda conexão entre o visível e o invisível. Acompanhe seus desafios, suas descobertas sobre a mediunidade e a importância vital da espiritualidade para o desenvolvimento pessoal – um tema que a autora, com sua experiência em levar a consciência espiritual às organizações, aborda com rara profundidade.

Esta não é apenas a história de uma menina, mas um espelho para todos os corações inquietos e sensíveis que buscam validar suas próprias percepções. É um convite para desvendar a magia que reside na escuta atenta, na aceitação do dom inato e na compreensão de que somos parte de algo muito maior. Prepare-se para uma leitura que irá despertar sua própria centelha interior e reacender a crença na sabedoria que a natureza e o espírito têm a nos oferecer, guiando-o para um reencontro com o seu próprio mundo.''',
      },
    ];
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

  Future<void> _showContentDialog(Map<String, dynamic> c) async {
    // Verifica se é conteúdo "Em Breve"
    if (c['emBreve'] == true) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Aviso'),
          content: Text('EM BREVE'),
        ),
      );
      return;
    }

    // ===== SISTEMA DE RESTRIÇÕES FREE/PREMIUM =====
    // Verifica se usuário pode acessar o conteúdo
    final canAccess = await UsageRestrictionService.canAccessContent(c);
    if (!canAccess) {
      if (!mounted) return;
      await UsageRestrictionService.showPremiumRequiredDialog(
        context,
        feature: c['titulo'],
      );
      return;
    }
    // ==============================================

    final tipo = c['tipo'] ?? 'video';

    // Se for vídeo, abrir player de vídeo
    if (tipo == 'video') {
      _showVideoPlayer(c);
      return;
    }

    // Se for texto/livro com link externo, abrir o link
    if (tipo == 'text') {
      final externalLink = c['externalLink']?.toString() ?? '';
      if (externalLink.isNotEmpty) {
        _openExternalLink(externalLink);
      } else {
        _showTextPopup(c);
      }
      return;
    }
  }

  // Abre link externo
  Future<void> _openExternalLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o link'),
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
    final theme = Theme.of(context);
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
            color: theme.colorScheme.surface,
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
                    style: theme.textTheme.bodyLarge!.copyWith(height: 1.8),
                  ),
                ),
              ),

              // Botão fechar
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
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
    final list = ListView.builder(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        widget.embedded ? 4 : AppSpacing.md,
        AppSpacing.page,
        AppSpacing.xxl,
      ),
      itemCount: conteudos.length,
      itemBuilder: (context, index) {
        final c = conteudos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _buildContentCard(context, c),
        );
      },
    );

    if (!widget.embedded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Conteúdo')),
        body: list,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Conteúdo',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 2),
              Text(
                'Vídeos e leituras para aprofundar a sua jornada.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Expanded(child: list),
      ],
    );
  }

  Widget _buildContentCard(BuildContext context, Map<String, dynamic> c) {
    final theme = Theme.of(context);
    final tipo = c['tipo'] ?? 'video';
    final isVideo = tipo == 'video';
    final premium = c['premiumOnly'] == true;
    final comingSoon = c['emBreve'] == true;
    final thumbnail = isVideo ? _thumbnailFor(c) : _getContentImagePath(c);

    return SoftCard(
      padding: EdgeInsets.zero,
      onTap: () => _showContentDialog(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadii.lg),
            ),
            child: SizedBox(
              height: 168,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumbnail != null)
                    Image.asset(
                      thumbnail,
                      fit: BoxFit.cover,
                      cacheWidth: 900,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  else
                    _placeholder(),
                  if (isVideo)
                    Container(
                      color: Colors.black.withValues(alpha: 0.18),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 54,
                        ),
                      ),
                    ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: GoldBadge(
                      label: isVideo ? 'Vídeo' : 'Leitura',
                      icon: isVideo
                          ? Icons.play_circle_outline
                          : Icons.menu_book_outlined,
                      dark: true,
                    ),
                  ),
                  if (premium)
                    const Positioned(
                      right: 10,
                      top: 10,
                      child: GoldBadge(
                        label: 'Premium',
                        icon: Icons.workspace_premium,
                        dark: true,
                      ),
                    ),
                  if (comingSoon)
                    const Positioned(
                      right: 10,
                      bottom: 10,
                      child: GoldBadge(
                        label: 'Em breve',
                        icon: Icons.schedule,
                        dark: true,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c['titulo']?.toString() ?? '',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  c['descricao']?.toString() ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      isVideo ? 'Assistir' : 'Ler',
                      style: theme.textTheme.labelLarge!.copyWith(
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColors.gold,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.outline,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.petrolDeep, AppColors.petrol],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          color: Colors.white.withValues(alpha: 0.6),
          size: 40,
        ),
      ),
    );
  }

  String? _thumbnailFor(Map<String, dynamic> c) {
    final path = c['videoPath']?.toString() ?? '';
    if (path.contains('video1')) return 'assets/conteudo/video1_thumb.png';
    if (path.contains('video2')) return 'assets/conteudo/video2_thumb.png';
    if (path.contains('video3')) return 'assets/conteudo/video3_thumb.png';
    return null;
  }
}
