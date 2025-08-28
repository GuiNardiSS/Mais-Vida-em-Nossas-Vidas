import 'package:flutter/material.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 16),
            Text(
              'O que é a espiritualidade?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'A espiritualidade está relacionada diretamente no propósito da vida, com questões significativas em que se acredita nos aspectos espiritualistas para justificar sua existência e significados, a espiritualidade nos leva a transcender além da nossa limitada capacidade perceptiva, a ponto de se perceberem valores que deem sentido à vida e que talvez nunca tenhamos nos dados conta que estes existem, é algo muito mais íntimo, uma construção de consciência.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'A Espiritualidade dentro da Religiosidade',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'A religião pode estar intrínseca na espiritualidade, mas a espiritualidade não necessariamente precisa estar ligada a uma religião.\n'
              'Neste sentido, é um sistema de significados que organiza a percepção da realidade e, ao mesmo tempo, uma força que promove a coesão social, ao unir seus seguidores em torno de símbolos, dogmas e ritos, um momento de elevação da sua fé contemplativa.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Mais Vida em Nossas Vidas lhe apresenta o poder da espiritualidade, busca te trazer e entender o que ela reserva para você, em dias caóticos onde tudo que precisamos é uma mensagem inspiradora e reconfortante;\n'
              'Contamos com uma seleção diária de até 50 cartas com mensagens direcionada a você.',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
