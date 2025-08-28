import 'package:flutter/material.dart';
import 'dart:math';

class CartasDoDiaPage extends StatefulWidget {
  const CartasDoDiaPage({super.key});

  @override
  State<CartasDoDiaPage> createState() => _CartasDoDiaPageState();
}

class _CartasDoDiaPageState extends State<CartasDoDiaPage> {
  final List<String> mensagens = [
    'Ao escolher sua carta do dia, permita-se receber uma mensagem especial para iluminar sua jornada.',
    'Cada carta traz uma reflexão única para inspirar o seu momento.',
    'Abra seu coração e deixe a espiritualidade guiar o seu dia.',
    // Adicione mais mensagens conforme desejar
  ];

  String? mensagemSelecionada;

  void _selecionarCarta() {
    final random = Random();
    setState(() {
      mensagemSelecionada = mensagens[random.nextInt(mensagens.length)];
    });
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
              'Escolha uma carta e receba uma mensagem inspiradora para o seu dia. Deixe a espiritualidade surpreender você!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _selecionarCarta,
              child: const Text('Selecionar Carta'),
            ),
            const SizedBox(height: 32),
            if (mensagemSelecionada != null)
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    mensagemSelecionada!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
