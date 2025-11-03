import 'package:flutter/material.dart';
import '../widgets/themed_logo.dart';
import 'home.dart';

class CartasIntroPage extends StatelessWidget {
  const CartasIntroPage({super.key});

  void _entrar(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartas do Dia'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Bem-vindo(a)!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'As Cartas do Dia trazem mensagens especiais para inspirar o seu cotidiano.\n\n'
              'Escolha uma carta para receber um lembrete significativo, ouvir o áudio correspondente '
              'e refletir sobre o tema ao longo do dia.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Carta grande clicável (sem fundo colorido)
            Semantics(
              button: true,
              label: 'Entrar nas Cartas do Dia',
              child: GestureDetector(
                onTap: () => _entrar(context),
                child: SizedBox(
                  width: double.infinity,
                  height: 400,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Logo grande sem fundo
                      Positioned.fill(
                        child: ThemedLogo(
                          baseName: 'assets/logo_carta_dia',
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),
                      // CTA
                      Positioned(
                        bottom: 40,
                        left: 24,
                        right: 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Toque para entrar nas Cartas do Dia',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
