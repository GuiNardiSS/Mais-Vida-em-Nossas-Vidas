import 'package:flutter/material.dart';
import '../widgets/video_player_widget.dart';
import 'pagamento_cartao.dart';
import 'pagamento_pix.dart';

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
            // Vídeo promocional das assinaturas
            Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const VideoPlayerWidget(
                videoUrl:
                    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
                width: 300,
                height: 200,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Assinaturas',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tenha acesso a conteúdos exclusivos, cartas especiais e benefícios únicos.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Benefícios da assinatura
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0b4c52).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF0b4c52).withValues(alpha: 0.3)),
              ),
              child: const Column(
                children: [
                  Text(
                    '✨ Benefícios Inclusos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Color(0xFF0b4c52), size: 20),
                      SizedBox(width: 8),
                      Expanded(child: Text('Cartas exclusivas premium')),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Color(0xFF0b4c52), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                          child: Text('Conteúdo de espiritualidade avançado')),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Color(0xFF0b4c52), size: 20),
                      SizedBox(width: 8),
                      Expanded(child: Text('Acesso sem anúncios')),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Color(0xFF0b4c52), size: 20),
                      SizedBox(width: 8),
                      Expanded(child: Text('Suporte prioritário')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Valor: R\$ 19,90/mês',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFa99045),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Escolha a melhor forma de pagamento:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PagamentoCartaoPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: const Color(0xFF0b4c52),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.credit_card),
                  label: const Text('Cartão'),
                ),
                const SizedBox(width: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PagamentoPixPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: const Color(0xFFa99045),
                    foregroundColor: Colors.white,
                  ),
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
