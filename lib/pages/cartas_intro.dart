import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../core/demo/demo_config.dart';
import '../design/components/gold_badge.dart';
import '../design/tokens.dart';
import 'home.dart';

class CartasIntroPage extends StatefulWidget {
  const CartasIntroPage({super.key});

  @override
  State<CartasIntroPage> createState() => _CartasIntroPageState();
}

class _CartasIntroPageState extends State<CartasIntroPage> {
  static const _onboardingKey = 'onboarding_v2_done';

  final PageController _controller = PageController();
  VideoPlayerController? _video;
  bool _videoReady = false;
  bool _videoError = false;
  bool _checking = true;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
    _initVideo();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final done = demoSkipOnboarding ||
        (prefs.getBool(_onboardingKey) ?? false);
    if (!mounted) return;
    if (done) {
      _openHome();
    } else {
      setState(() => _checking = false);
    }
  }

  Future<void> _initVideo() async {
    try {
      final controller =
          VideoPlayerController.asset('assets/intro/video_boas_vindas.mp4');
      await controller.initialize();
      await controller.setLooping(false);
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _video = controller;
        _videoReady = true;
      });
    } catch (_) {
      if (mounted) setState(() => _videoError = true);
    }
  }

  void _openHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeShell(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: AppDurations.medium,
      ),
    );
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    if (!mounted) return;
    _openHome();
  }

  void _next() {
    if (_page == 2) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: AppDurations.medium,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: AppColors.petrolDeep,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.goldBright),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.petrolDeep,
      body: Stack(
        children: [
          Positioned(
            top: -160,
            right: -120,
            child: _Glow(
              color: AppColors.gold.withValues(alpha: 0.22),
              size: 380,
            ),
          ),
          Positioned(
            bottom: -180,
            left: -140,
            child: _Glow(
              color: AppColors.petrolSoft.withValues(alpha: 0.24),
              size: 420,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.spa,
                          color: AppColors.goldBright, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Mais Vida',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _finish,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                        child: const Text('Pular'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (value) => setState(() => _page = value),
                    children: [
                      _WelcomeSlide(
                        video: _video,
                        videoReady: _videoReady,
                        videoError: _videoError,
                        onToggleVideo: _toggleVideo,
                      ),
                      const _CardsSlide(),
                      const _JourneySlide(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final active = index == _page;
                          return AnimatedContainer(
                            duration: AppDurations.fast,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 26 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.goldBright
                                  : Colors.white.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _next,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.goldBright,
                            foregroundColor: AppColors.petrolDeep,
                            minimumSize: const Size(0, 56),
                          ),
                          child: Text(
                            _page == 2 ? 'Começar agora' : 'Continuar',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Projeto de portfólio • pagamentos em demonstração',
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleVideo() {
    final video = _video;
    if (video == null) return;
    if (video.value.isPlaying) {
      video.pause();
    } else {
      video.play();
    }
    setState(() {});
  }
}

class _WelcomeSlide extends StatelessWidget {
  const _WelcomeSlide({
    required this.video,
    required this.videoReady,
    required this.videoError,
    required this.onToggleVideo,
  });

  final VideoPlayerController? video;
  final bool videoReady;
  final bool videoError;
  final VoidCallback onToggleVideo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.gold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/icon.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.auto_awesome,
                color: AppColors.petrol,
                size: 54,
              ),
            ),
          ),
        ).animate().fadeIn(duration: 600.ms).scale(
              begin: const Offset(0.92, 0.92),
              curve: Curves.easeOutCubic,
            ),
        const SizedBox(height: 26),
        Text(
          'Uma pausa de luz\nno seu dia',
          textAlign: TextAlign.center,
          style: theme.textTheme.displayLarge!.copyWith(
            color: Colors.white,
            height: 1.1,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 120.ms).slideY(begin: 0.08),
        const SizedBox(height: 12),
        Text(
          'Cartas, áudios e conteúdos para cultivar presença, propósito e bem-estar.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge!.copyWith(
            color: Colors.white.withValues(alpha: 0.74),
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 220.ms),
        const SizedBox(height: 22),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ColoredBox(
              color: Colors.black,
              child: videoReady && video != null
                  ? GestureDetector(
                      onTap: onToggleVideo,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: video!.value.size.width,
                              height: video!.value.size.height,
                              child: VideoPlayer(video!),
                            ),
                          ),
                          if (!video!.value.isPlaying)
                            Container(
                              color: Colors.black.withValues(alpha: 0.28),
                              child: const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 58,
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  : Center(
                      child: videoError
                          ? const Text(
                              'Vídeo de boas-vindas indisponível',
                              style: TextStyle(color: Colors.white54),
                            )
                          : const CircularProgressIndicator(
                              color: AppColors.goldBright,
                            ),
                    ),
            ),
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 320.ms),
      ],
    );
  }
}

class _CardsSlide extends StatelessWidget {
  const _CardsSlide();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: -0.12,
                child: _CardPreview(
                  image: 'assets/logo_carta_org.png',
                  width: 150,
                ),
              ),
              Transform.rotate(
                angle: 0.10,
                child: _CardPreview(
                  image: 'assets/logo_carta_dia.png',
                  width: 160,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.08),
        const SizedBox(height: 28),
        Text(
          'Sua carta do dia',
          textAlign: TextAlign.center,
          style: theme.textTheme.displayMedium!.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(
          'Escolha uma carta, leia a mensagem e ouça a narração. '
          'Uma reflexão por dia no plano gratuito; ilimitada no premium.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge!.copyWith(
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 24),
        const _FeatureRow(
          icon: Icons.image_outlined,
          title: 'Arte exclusiva',
          description: 'Cada carta tem uma ilustração própria.',
        ),
        const _FeatureRow(
          icon: Icons.headphones_outlined,
          title: 'Áudio narrado',
          description: 'Ouça a mensagem com calma, onde estiver.',
        ),
        const _FeatureRow(
          icon: Icons.favorite_outline,
          title: 'Reflexão diária',
          description: 'Um convite para voltar a si mesma.',
        ),
      ],
    );
  }
}

class _JourneySlide extends StatelessWidget {
  const _JourneySlide();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      children: [
        const SizedBox(height: 18),
        Center(
          child: Column(
            children: [
              const GoldBadge(
                label: 'Experiência completa',
                icon: Icons.workspace_premium,
                dark: true,
              ),
              const SizedBox(height: 14),
              Text(
                'Uma jornada\npara todos os dias',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium!.copyWith(
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms),
        const SizedBox(height: 26),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: const [
            _JourneyTile(
              icon: Icons.style_outlined,
              label: 'Cartas do Dia',
            ),
            _JourneyTile(
              icon: Icons.business_center_outlined,
              label: 'Organizações',
            ),
            _JourneyTile(
              icon: Icons.play_circle_outline,
              label: 'Vídeos e livros',
            ),
            _JourneyTile(
              icon: Icons.headphones_outlined,
              label: 'Áudios narrados',
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              const Icon(Icons.science_outlined,
                  color: AppColors.goldBright, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Este é um projeto de portfólio. A assinatura e os pagamentos '
                  'são simulados e nenhum valor será cobrado.',
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardPreview extends StatelessWidget {
  const _CardPreview({required this.image, required this.width});

  final String image;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 1.48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: AppColors.petrol,
          child: Icon(Icons.auto_awesome, color: Colors.white70, size: 42),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.goldBright, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: Colors.white.withValues(alpha: 0.65),
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

class _JourneyTile extends StatelessWidget {
  const _JourneyTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.goldBright, size: 28),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
