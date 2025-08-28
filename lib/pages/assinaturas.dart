import 'package:flutter/material.dart';

class AssinaturasPage extends StatelessWidget {
  const AssinaturasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assinaturas'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/assinaturas_img.png', // Salve a imagem da página 10 como 'assinaturas_img.png'
              width: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            const Text(
              'Assinaturas',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tenha acesso a conteúdos exclusivos, cartas especiais e benefícios únicos. '
              'Escolha a melhor forma de pagamento para você:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Ação para pagamento por cartão
                  },
                  icon: const Icon(Icons.credit_card),
                  label: const Text('Cartão'),
                ),
                const SizedBox(width: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Ação para pagamento por Pix
                  },
                  icon: const Icon(Icons.pix),
                  label: const Text('Pix'),
                ),
              ],
            ),
            // Adicione mais textos ou detalhes conforme o conteúdo da página 10
          ],
        ),
      ),
    );
  }
}
