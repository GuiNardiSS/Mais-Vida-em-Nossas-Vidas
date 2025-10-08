import 'package:flutter/material.dart';

class ConhecaMaisPage extends StatelessWidget {
  const ConhecaMaisPage({super.key});

  final List<Map<String, String>> informacoes = const [
    {
      'titulo': 'Espiritualidade',
      'resumo': 'Descubra o significado da espiritualidade.',
      'imagem': 'assets/icone1.png',
      'detalhe':
          'A espiritualidade é a busca por um sentido maior na vida, conectando-se com valores, propósito e o universo.'
    },
    {
      'titulo': 'Autoconhecimento',
      'resumo': 'Aprofunde-se em si mesmo.',
      'imagem': 'assets/icone2.png',
      'detalhe':
          'O autoconhecimento é fundamental para o crescimento pessoal e espiritual, permitindo compreender emoções e atitudes.'
    },
    {
      'titulo': 'Gratidão',
      'resumo': 'O poder de agradecer diariamente.',
      'imagem': 'assets/icone3.png',
      'detalhe':
          'A gratidão transforma a percepção da vida, trazendo leveza e bem-estar ao reconhecer o valor das pequenas coisas.'
    },
    {
      'titulo': 'Fé',
      'resumo': 'A força da crença interior.',
      'imagem': 'assets/icone4.png',
      'detalhe':
          'A fé é a confiança em algo maior, capaz de renovar esperanças e superar desafios.'
    },
    {
      'titulo': 'Resiliência',
      'resumo': 'Superando obstáculos com equilíbrio.',
      'imagem': 'assets/icone5.png',
      'detalhe':
          'Resiliência é a capacidade de se adaptar e crescer diante das adversidades, mantendo o equilíbrio emocional.'
    },
    {
      'titulo': 'Compaixão',
      'resumo': 'Praticando o cuidado com o próximo.',
      'imagem': 'assets/icone6.png',
      'detalhe':
          'Compaixão é a empatia ativa, promovendo ajuda e compreensão ao outro.'
    },
    {
      'titulo': 'Propósito',
      'resumo': 'Encontre o seu motivo de viver.',
      'imagem': 'assets/icone7.png',
      'detalhe':
          'Ter propósito é viver com direção e significado, guiando escolhas e ações.'
    },
    {
      'titulo': 'Equilíbrio',
      'resumo': 'Harmonia entre corpo, mente e espírito.',
      'imagem': 'assets/icone8.png',
      'detalhe':
          'O equilíbrio é essencial para o bem-estar integral, unindo saúde física, mental e espiritual.'
    },
    {
      'titulo': 'Esperança',
      'resumo': 'Acreditar em dias melhores.',
      'imagem': 'assets/icone9.png',
      'detalhe':
          'A esperança motiva a busca por soluções e mantém o otimismo diante das dificuldades.'
    },
    {
      'titulo': 'Amor',
      'resumo': 'A energia que transforma tudo.',
      'imagem': 'assets/icone10.png',
      'detalhe':
          'O amor é a base das relações humanas, capaz de curar, unir e transformar vidas.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conheça Mais'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: informacoes.length,
          itemBuilder: (context, index) {
            final info = informacoes[index];
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(
                      info['titulo'] ?? '',
                      style: const TextStyle(color: Colors.black),
                    ),
                    content: Text(
                      info['detalhe'] ?? '',
                      style: const TextStyle(color: Colors.black),
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
              },
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        info['imagem'] ?? '',
                        height: 48,
                        width: 48,
                        errorBuilder: (_, __, ___) =>
                            const SizedBox(height: 48, width: 48),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        info['titulo'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
