import 'package:flutter/material.dart';

class CartasDoDiaPage extends StatefulWidget {
  const CartasDoDiaPage({super.key});

  @override
  State<CartasDoDiaPage> createState() => _CartasDoDiaPageState();
}

class _CartasDoDiaPageState extends State<CartasDoDiaPage> {
  final List<String> cartas = [
    'Carta 1',
    'Carta 2',
    'Carta 3',
    'Carta 4',
    'Carta 5',
    'Carta 6',
    'Carta 7',
    'Carta 8',
    'Carta 9',
    'Carta 10',
  ];
  final List<String> mensagens = [
    'Mensagem especial da Carta 1 para iluminar sua jornada.',
    'Mensagem especial da Carta 2 para inspirar o seu momento.',
    'Mensagem especial da Carta 3 para abrir seu coração.',
    'Mensagem especial da Carta 4 para trazer paz interior.',
    'Mensagem especial da Carta 5 para renovar suas energias.',
    'Mensagem especial da Carta 6 para fortalecer sua fé.',
    'Mensagem especial da Carta 7 para guiar suas decisões.',
    'Mensagem especial da Carta 8 para cultivar gratidão.',
    'Mensagem especial da Carta 9 para promover autoconhecimento.',
    'Mensagem especial da Carta 10 para celebrar conquistas.',
  ];
  int? cartaSelecionada;
  bool cartasReveladas = false;

  void _mostrarCartas() {
    setState(() {
      cartasReveladas = true;
    });
  }

  void _selecionarCarta(int index) {
    if (cartaSelecionada == null) {
      setState(() {
        cartaSelecionada = index;
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(cartas[index]),
          content: Text(mensagens[index]),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartas do Dia'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Cartas do Dia',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Escolha uma das cartas abaixo para receber uma mensagem especial para o seu dia. Você só pode selecionar uma carta por vez.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (!cartasReveladas)
              ElevatedButton(
                onPressed: _mostrarCartas,
                child: const Text('Mostrar Cartas'),
              ),
            if (cartasReveladas)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(
                    10,
                    (i) => ElevatedButton(
                          onPressed: cartaSelecionada == null
                              ? () => _selecionarCarta(i)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cartaSelecionada == i
                                ? Colors.deepPurple
                                : null,
                          ),
                          child: Text('Carta ${i + 1}'),
                        )),
              ),
          ],
        ),
      ),
    );
  }
}
