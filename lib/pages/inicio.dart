import 'package:flutter/material.dart';
import '../widgets/video_popup_player.dart';

class ConhecaMaisPage extends StatelessWidget {
  const ConhecaMaisPage({super.key});

  final List<Map<String, String>> informacoes = const [
    {
      'titulo': 'Espiritualidade',
      'resumo': 'Descubra o significado da espiritualidade.',
      'video': 'assets/conteudo/espiritualidade.mp4'
    },
    {
      'titulo': 'Autoconhecimento',
      'resumo': 'Aprofunde-se em si mesmo.',
      'video': 'assets/conteudo/autoconhecimento.mp4'
    },
    {
      'titulo': 'Gratidão',
      'resumo': 'O poder de agradecer diariamente.',
      'video': 'assets/conteudo/gratidao.mp4'
    },
    {
      'titulo': 'Fé',
      'resumo': 'A força da crença interior.',
      'video': 'assets/conteudo/fe.mp4'
    },
    {
      'titulo': 'Resiliência',
      'resumo': 'Superando obstáculos com equilíbrio.',
      'video': 'assets/conteudo/resiliencia.mp4'
    },
    {
      'titulo': 'Compaixão',
      'resumo': 'Praticando o cuidado com o próximo.',
      'video': 'assets/conteudo/compaixao.mp4'
    },
    {
      'titulo': 'Propósito',
      'resumo': 'Encontre o seu motivo de viver.',
      'video': 'assets/conteudo/proposito.mp4'
    },
    {
      'titulo': 'Equilíbrio',
      'resumo': 'Harmonia entre corpo, mente e espírito.',
      'video': 'assets/conteudo/equilibrio.mp4'
    },
    {
      'titulo': 'Esperança',
      'resumo': 'Acreditar em dias melhores.',
      'video': 'assets/conteudo/esperanca.mp4'
    },
    {
      'titulo': 'Amor',
      'resumo': 'A energia que transforma tudo.',
      'video': 'assets/conteudo/amor.mp4'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: informacoes.length,
          itemBuilder: (context, index) {
            final info = informacoes[index];
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Cabeçalho com título e botão fechar
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    info['titulo'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Player de vídeo
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: VideoPopupPlayer(
                                videoUrl: info['video'] ?? '',
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Logo ocupando 100% do espaço
                    Container(
                      color: const Color(0xFFF5F3E8), // Cor bege/creme de fundo
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                          'assets/logo_conheca_mais.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    // Gradiente na parte inferior para melhor legibilidade
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                        child: Text(
                          info['titulo'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 2,
                                color: Colors.black,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
