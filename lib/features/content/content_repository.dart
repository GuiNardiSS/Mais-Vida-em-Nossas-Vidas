import 'content_item.dart';

/// Catálogo local de conteúdos do app.
///
/// Mantido em código nesta versão para funcionar 100% offline. A estrutura já
/// está pronta para ser alimentada por um JSON remoto ou pela API no futuro.
abstract final class ContentRepository {
  static const List<ContentItem> all = [
    ContentItem(
      id: 'espiritualidade-organizacoes',
      title: 'Espiritualidade nas organizações',
      description:
          'Descubra como a espiritualidade pode transformar o ambiente corporativo, trazendo mais propósito, harmonia e resultados positivos para todos.',
      kind: ContentKind.video,
      category: 'Organizações',
      videoPath: 'assets/conteudo/video1.mp4',
      thumbnailPath: 'assets/conteudo/video1_thumb.png',
    ),
    ContentItem(
      id: 'nunca-e-tarde',
      title: 'Nunca é tarde para começar',
      description:
          'Inspire-se a dar o primeiro passo em direção aos seus sonhos. Não importa a idade ou o momento, sempre há tempo para iniciar uma nova jornada.',
      kind: ContentKind.video,
      category: 'Propósito',
      videoPath: 'assets/conteudo/video2.mp4',
      thumbnailPath: 'assets/conteudo/video2_thumb.png',
    ),
    ContentItem(
      id: 'em-busca-do-conhecimento',
      title: 'Em busca do conhecimento',
      description:
          'A jornada do aprendizado é contínua. Explore a importância de buscar sabedoria e como o conhecimento pode expandir seus horizontes.',
      kind: ContentKind.video,
      category: 'Conhecimento',
      videoPath: 'assets/conteudo/video3.mp4',
      thumbnailPath: 'assets/conteudo/video3_thumb.png',
    ),
    ContentItem(
      id: 'acolhimento',
      title: 'Acolhimento',
      description:
          'Aprenda a importância de acolher a si mesmo e ao próximo com compaixão. O acolhimento é o primeiro passo para a cura e para relações mais saudáveis.',
      kind: ContentKind.video,
      category: 'Compaixão',
      videoPath: 'assets/conteudo/Acolhimento.mp4',
      premiumOnly: true,
    ),
    ContentItem(
      id: 'o-novo-lider',
      title: 'O Novo Líder',
      description:
          'As características da liderança moderna baseada em empatia, propósito e espiritualidade. Como inspirar pessoas e criar ambientes mais humanos.',
      kind: ContentKind.video,
      category: 'Liderança',
      videoPath: 'assets/conteudo/novo_lider.mp4',
      premiumOnly: true,
    ),
    ContentItem(
      id: 'o-poder-do-perdao',
      title: 'O Poder do Perdão',
      description:
          'Entenda como perdoar pode libertar você de pesos do passado. O perdão não é esquecer, mas escolher a paz e permitir que a vida flua novamente.',
      kind: ContentKind.video,
      category: 'Perdão',
      videoPath: 'assets/conteudo/Perdão.mp4',
      premiumOnly: true,
    ),
    ContentItem(
      id: 'a-menina-que-falava-com-o-jardim',
      title: 'A Menina que Falava com o Jardim',
      description:
          'Uma história encantadora sobre conexão com a natureza e o divino.',
      kind: ContentKind.book,
      category: 'Livro',
      imagePath: 'assets/conteudo/capa_livro_menina_jardim.png',
      comingSoon: true,
      fullText: '''A Criança que Falava com o Jardim
Por Helô Coelho

Em um mundo que muitas vezes silencia o que não compreende, Luiza percebeu já na sua infância o extraordinário: ela falava com o jardim. Para ela, as árvores eram confidentes, as flores compartilhavam sabedorias e o vento trazia mensagens de um plano invisível.

Em "A Criança que falava com o Jardim", Helô Coelho nos convida a mergulhar na jornada de Luiza, uma alma que desde cedo percebeu a profunda conexão entre o visível e o invisível. Acompanhe seus desafios, suas descobertas sobre a mediunidade e a importância vital da espiritualidade para o desenvolvimento pessoal.

Esta não é apenas a história de uma menina, mas um espelho para todos os corações inquietos e sensíveis que buscam validar suas próprias percepções. É um convite para desvendar a magia que reside na escuta atenta, na aceitação do dom inato e na compreensão de que somos parte de algo muito maior.''',
    ),
  ];

  static List<String> get categories {
    final values = <String>{'Todos'};
    for (final item in all) {
      values.add(item.category);
    }
    return values.toList(growable: false);
  }

  static List<ContentItem> featured({int limit = 3}) {
    return all
        .where((item) => item.isVideo)
        .take(limit)
        .toList(growable: false);
  }
}
