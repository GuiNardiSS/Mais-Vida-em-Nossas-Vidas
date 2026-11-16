import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

import '../core/demo/demo_config.dart';
import '../design/components/gold_badge.dart';
import '../design/components/section_header.dart';
import '../design/components/soft_card.dart';
import '../design/tokens.dart';
import '../features/payments/demo_payment_sheet.dart';
import '../services/subscription_service.dart';

class AssinaturasPage extends StatefulWidget {
  const AssinaturasPage({super.key});

  @override
  State<AssinaturasPage> createState() => _AssinaturasPageState();
}

class _AssinaturasPageState extends State<AssinaturasPage> {
  VideoPlayerController? _video;
  bool _videoReady = false;
  bool _videoError = false;

  bool _premium = false;
  Map<String, dynamic>? _info;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _load();
  }

  Future<void> _initVideo() async {
    try {
      final controller = VideoPlayerController.asset(
          'assets/assinaturas/video_assinatura.mp4');
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

  Future<void> _load() async {
    setState(() => _loading = true);
    final premium = await SubscriptionService.isPremium();
    final info = await SubscriptionService.getSubscriptionInfo();
    if (!mounted) return;
    setState(() {
      _premium = premium;
      _info = info;
      _loading = false;
    });
  }

  Future<void> _startPayment() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DemoPaymentSheet(amount: kSubscriptionPrice),
    );
    if (!mounted || result != true) return;
    await _load();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon:
            const Icon(Icons.check_circle, color: AppColors.success, size: 44),
        title: const Text('Pagamento confirmado!'),
        content: const Text(
          'Sua assinatura premium de demonstração está ativa por 30 dias. '
          'Aproveite todas as cartas e conteúdos exclusivos.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar assinatura?'),
        content: const Text(
          'O acesso premium será encerrado imediatamente nesta demonstração.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Manter'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await SubscriptionService.clearSubscription();
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assinatura de demonstração cancelada.')),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return '—';
    final date = DateTime.tryParse(iso);
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Assinaturas')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.xs,
          AppSpacing.page,
          AppSpacing.xxl,
        ),
        children: [
          _Hero(
            premium: _premium,
            days: _info?['daysRemaining'],
            expiry: _formatDate(_info?['expiryDate'] as String?),
            onSubscribe: _startPayment,
            onCancel: _cancel,
            loading: _loading,
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(
                color: Colors.black,
                child: _videoReady && _video != null
                    ? GestureDetector(
                        onTap: () {
                          if (_video!.value.isPlaying) {
                            _video!.pause();
                          } else {
                            _video!.play();
                          }
                          setState(() {});
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _video!.value.size.width,
                                height: _video!.value.size.height,
                                child: VideoPlayer(_video!),
                              ),
                            ),
                            if (!_video!.value.isPlaying)
                              Container(
                                color: Colors.black.withValues(alpha: 0.25),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white,
                                    size: 56,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    : Center(
                        child: _videoError
                            ? const Text(
                                'Vídeo indisponível',
                                style: TextStyle(color: Colors.white54),
                              )
                            : const CircularProgressIndicator(
                                color: AppColors.goldBright,
                              ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
            title: 'O que você recebe',
            subtitle: 'Uma experiência completa, sem anúncios',
          ),
          const _Benefit(
            icon: Icons.style_outlined,
            title: 'Cartas ilimitadas',
            description: 'Revele quantas cartas quiser, todos os dias.',
          ),
          const _Benefit(
            icon: Icons.headphones_outlined,
            title: 'Áudios narrados',
            description: 'Ouça cada mensagem com a narração original.',
          ),
          const _Benefit(
            icon: Icons.play_circle_outline,
            title: 'Conteúdos exclusivos',
            description:
                'Vídeos e leituras que não aparecem no plano gratuito.',
          ),
          const _Benefit(
            icon: Icons.business_center_outlined,
            title: 'Cartas para organizações',
            description: 'Mensagens pensadas para levar propósito ao trabalho.',
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Gratuito x Premium'),
          SoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: const [
                _CompareRow(
                  label: 'Cartas por dia',
                  free: '1',
                  premium: 'Ilimitadas',
                  icon: Icons.style_outlined,
                ),
                Divider(height: 1),
                _CompareRow(
                  label: 'Áudios narrados',
                  free: 'Sim',
                  premium: 'Sim',
                  icon: Icons.headphones_outlined,
                ),
                Divider(height: 1),
                _CompareRow(
                  label: 'Conteúdos premium',
                  free: '—',
                  premium: 'Completo',
                  icon: Icons.play_circle_outline,
                ),
                Divider(height: 1),
                _CompareRow(
                  label: 'Sem anúncios',
                  free: '—',
                  premium: 'Sempre',
                  icon: Icons.block_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _PlanCard(
            premium: _premium,
            loading: _loading,
            onSubscribe: _startPayment,
          ),
          const SizedBox(height: AppSpacing.md),
          SoftCard(
            color: AppColors.gold.withValues(alpha: 0.10),
            borderColor: AppColors.gold.withValues(alpha: 0.35),
            child: Row(
              children: [
                const Icon(Icons.science_outlined, color: AppColors.gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Modo demonstração: a assinatura, o PIX e o cartão são simulados. '
                    'Nenhuma cobrança real é feita e nenhum dado é enviado.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          if (_premium) ...[
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton.icon(
                onPressed: _cancel,
                icon: const Icon(Icons.close),
                label: const Text('Cancelar assinatura'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.premium,
    required this.days,
    required this.expiry,
    required this.onSubscribe,
    required this.onCancel,
    required this.loading,
  });

  final bool premium;
  final int? days;
  final String expiry;
  final VoidCallback onSubscribe;
  final VoidCallback onCancel;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.petrolDeep, AppColors.petrol],
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.soft(theme.brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GoldBadge(
                label: premium ? 'Assinatura ativa' : 'Premium',
                icon: premium ? Icons.check_circle : Icons.workspace_premium,
                dark: true,
              ),
              const Spacer(),
              if (!premium)
                Text(
                  'R\$ ${kSubscriptionPrice.toStringAsFixed(2)}/mês',
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: AppColors.goldBright,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            premium
                ? 'Sua jornada está\ncompleta.'
                : 'Mais presença,\nmais vida.',
            style: theme.textTheme.displayMedium!.copyWith(
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            premium
                ? 'Você tem acesso a todas as cartas, áudios e conteúdos exclusivos.'
                : 'Cartas ilimitadas, áudios e conteúdos exclusivos para aprofundar sua prática.',
            style: theme.textTheme.bodyMedium!.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (loading)
            const SizedBox(
              height: 48,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.goldBright),
              ),
            )
          else if (premium)
            Row(
              children: [
                Expanded(
                  child: _HeroStat(
                    label: 'Dias restantes',
                    value: '${days ?? 0}',
                  ),
                ),
                Container(
                  width: 1,
                  height: 34,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                Expanded(
                  child: _HeroStat(label: 'Válida até', value: expiry),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onSubscribe,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.goldBright,
                      foregroundColor: AppColors.petrolDeep,
                    ),
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('Assinar agora'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  tooltip: 'Gerenciar',
                  onPressed: onCancel,
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.10),
                  ),
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall!.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleLarge!.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.petrol, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                Text(description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    required this.free,
    required this.premium,
    required this.icon,
  });

  final String label;
  final String free;
  final String premium;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          SizedBox(
            width: 74,
            child: Text(
              free,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
          ),
          SizedBox(
            width: 82,
            child: Text(
              premium,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium!.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.premium,
    required this.loading,
    required this.onSubscribe,
  });

  final bool premium;
  final bool loading;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      child: Column(
        children: [
          Row(
            children: [
              Text('Plano mensal', style: theme.textTheme.titleLarge),
              const Spacer(),
              const GoldBadge(label: 'Mais popular', icon: Icons.star),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${kSubscriptionPrice.toStringAsFixed(2)}',
                style: theme.textTheme.displayMedium!.copyWith(
                  color: AppColors.gold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('/mês', style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Renovação demonstrativa de 30 dias. Cancele quando quiser.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: loading ? null : onSubscribe,
              child: Text(premium ? 'Renovar assinatura' : 'Assinar premium'),
            ),
          ),
        ],
      ),
    );
  }
}
