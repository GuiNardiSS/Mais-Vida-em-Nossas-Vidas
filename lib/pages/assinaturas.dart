import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/subscription_service.dart';
import '../widgets/pix_payment_dialog.dart';

class AssinaturasPage extends StatefulWidget {
  const AssinaturasPage({super.key});

  @override
  State<AssinaturasPage> createState() => _AssinaturasPageState();
}

class _AssinaturasPageState extends State<AssinaturasPage> {
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;
  String? _errorMessage;
  bool _isPremium = false;
  Map<String, dynamic>? _subscriptionInfo;
  bool _isLoadingSubscription = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _loadSubscriptionStatus();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(
        'assets/assinaturas/video_assinatura.mp4',
      );
      await _controller!.initialize();
      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Vídeo não disponível';
      });
    }
  }

  Future<void> _loadSubscriptionStatus() async {
    setState(() => _isLoadingSubscription = true);

    try {
      final isPremium = await SubscriptionService.isPremium();
      final info = await SubscriptionService.getSubscriptionInfo();

      setState(() {
        _isPremium = isPremium;
        _subscriptionInfo = info;
        _isLoadingSubscription = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSubscription = false;
      });
    }
  }

  void _openPixPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PixPaymentDialog(
        amount: 4.99,
        onSuccess: () {
          _loadSubscriptionStatus();
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assinaturas'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Player de vídeo
            LayoutBuilder(
              builder: (context, constraints) {
                final orientation = MediaQuery.of(context).orientation;
                final screenHeight = MediaQuery.of(context).size.height;

                // Altura responsiva: 25% da tela em portrait, 45% em landscape
                final videoHeight = orientation == Orientation.portrait
                    ? screenHeight * 0.25
                    : screenHeight * 0.45;

                return Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: 200,
                    maxHeight: videoHeight.clamp(200.0, 500.0),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _isVideoInitialized && _controller != null
                        ? AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                VideoPlayer(_controller!),
                                Center(
                                  child: IconButton(
                                    icon: Icon(
                                      _controller!.value.isPlaying
                                          ? Icons.pause_circle_filled
                                          : Icons.play_circle_filled,
                                      size: 64,
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
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
                );
              },
            ),
            const SizedBox(height: 32),

            // Status da Assinatura
            if (_isLoadingSubscription)
              const Center(child: CircularProgressIndicator())
            else if (_isPremium && _subscriptionInfo != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Assinatura Ativa',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_subscriptionInfo!['daysRemaining']} dias restantes',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Válida até ${_formatDate(_subscriptionInfo!['expiryDate'])}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              )
            else
              const Text(
                'Tenha acesso a conteúdos exclusivos, cartas especiais e benefícios únicos.',
                style: TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 40),

            // Card de Plano Mensal
            _buildPlanCard(
              context: context,
              title: 'Plano Mensal',
              price: 'R\$ 4,99',
              period: '/mês',
              features: [
                'Acesso a todas as cartas do dia',
                'Cartas de organização exclusivas',
                'Conteúdos especiais',
                'Áudios inspiracionais',
              ],
              icon: Icons.calendar_month,
              isPopular: true,
            ),

            const SizedBox(height: 32),
            const Text(
              'Escolha a melhor forma de pagamento:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Mostra botões de pagamento apenas se não tiver assinatura ativa
            if (!_isPremium)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _openPixPayment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.pix),
                  label: const Text('Pix'),
                ),
              )
            else
              // Botão para renovar assinatura
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isPremium = false;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Renovar Assinatura'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFa99045),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required IconData icon,
    bool isPopular = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: isPopular ? const Color(0xFFa99045) : Colors.grey.shade300,
          width: isPopular ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFa99045),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: const Text(
                'MAIS POPULAR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: const Color(0xFF0b4c52),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0b4c52),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFa99045),
                      ),
                    ),
                    Text(
                      period,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF0b4c52),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
