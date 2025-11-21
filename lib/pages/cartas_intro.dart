import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../widgets/themed_logo.dart';
import 'home.dart';

class CartasIntroPage extends StatefulWidget {
  const CartasIntroPage({super.key});

  @override
  State<CartasIntroPage> createState() => _CartasIntroPageState();
}

class _CartasIntroPageState extends State<CartasIntroPage> {
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(
        'assets/intro/video_boas_vindas.mp4',
      );
      await _controller!.initialize();
      setState(() {
        _isVideoInitialized = true;
      });
      // Vídeo inicia pausado
      _controller!.setLooping(false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Vídeo não disponível';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _entrar(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagem do dia'),
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
              'A carta do Mais Vida em Nossas  Vidas, trazem mensagens especiais para inspirar o seu cotidiano.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Vídeo de boas-vindas
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _isVideoInitialized && _controller != null
                    ? Center(
                        child: AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(_controller!),
                              Center(
                                child: IconButton(
                                  icon: Icon(
                                    _controller!.value.isPlaying
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_filled,
                                    size: 64,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_controller!.value.isPlaying) {
                                        _controller!.pause();
                                      } else {
                                        _controller!.play();
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Center(
                        child: _errorMessage != null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.videocam_off,
                                    size: 48,
                                    color: Colors.white54,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            : const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                      ),
              ),
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
