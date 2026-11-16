import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/cartas_data.dart';
import '../design/components/gold_badge.dart';
import '../design/components/section_header.dart';
import '../design/components/soft_card.dart';
import '../design/tokens.dart';
import '../features/content/content_item.dart';
import '../features/content/content_repository.dart';
import '../services/subscription_service.dart';
import '../services/usage_restriction_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  _DashboardData? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final premium = await SubscriptionService.isPremium();
    final used = await UsageRestrictionService.getCartasDiaUsedToday();
    int? selected;
    if (prefs.getString('carta_dia_date') == today) {
      selected = prefs.getInt('carta_dia_index');
    }

    if (!mounted) return;
    setState(() {
      _data = _DashboardData(
        isPremium: premium,
        usedToday: used,
        selectedIndex: selected,
      );
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  String get _dateLabel {
    const months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    const weekdays = [
      'segunda',
      'terça',
      'quarta',
      'quinta',
      'sexta',
      'sábado',
      'domingo',
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]}';
  }

  String get _quote {
    final day = DateTime.now().difference(DateTime(2020)).inDays;
    return cartasDisponiveis[day % cartasDisponiveis.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = _data;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.xs,
          AppSpacing.page,
          AppSpacing.xxl,
        ),
        children: [
          _Header(greeting: _greeting, dateLabel: _dateLabel),
          const SizedBox(height: AppSpacing.lg),
          _DailyHero(
            selectedIndex: data?.selectedIndex,
            isPremium: data?.isPremium ?? false,
            onTap: () => widget.onNavigate(1),
          ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.06, end: 0),
          const SizedBox(height: AppSpacing.md),
          _StatsRow(data: data),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
            title: 'Explore',
            subtitle: 'Atalhos para a sua jornada',
          ),
          _ExploreGrid(
            onCards: () => widget.onNavigate(1),
            onOrganizations: () => widget.onNavigate(3),
            onContent: () => widget.onNavigate(2),
            onPremium: () => Navigator.of(context).pushNamed('/assinaturas'),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Inspiração de hoje'),
          SoftCard(
            color: AppColors.petrol,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.format_quote_rounded,
                    color: AppColors.goldBright, size: 30),
                const SizedBox(height: 6),
                Text(
                  _quote,
                  style: theme.textTheme.headlineMedium!.copyWith(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Mensagem do Mais Vida em Nossas Vidas',
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: 'Destaques',
            subtitle: 'Conteúdos para assistir e refletir',
            trailing: TextButton(
              onPressed: () => widget.onNavigate(2),
              child: const Text('Ver todos'),
            ),
          ),
          _FeaturedList(items: ContentRepository.featured()),
          if (data != null && !data.isPremium) ...[
            const SizedBox(height: AppSpacing.xl),
            _PremiumBanner(
              onTap: () => Navigator.of(context).pushNamed('/assinaturas'),
            ).animate().fadeIn(duration: 500.ms, delay: 120.ms),
          ],
        ],
      ),
    );
  }
}

class _DashboardData {
  const _DashboardData({
    required this.isPremium,
    required this.usedToday,
    required this.selectedIndex,
  });

  final bool isPremium;
  final int usedToday;
  final int? selectedIndex;
}

class _Header extends StatelessWidget {
  const _Header({required this.greeting, required this.dateLabel});

  final String greeting;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text('que bom ter você aqui',
                  style: theme.textTheme.displayMedium),
              const SizedBox(height: 4),
              Text(dateLabel, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.16),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
          ),
          child: const Icon(Icons.spa_outlined, color: AppColors.petrol),
        ),
      ],
    );
  }
}

class _DailyHero extends StatelessWidget {
  const _DailyHero({
    required this.selectedIndex,
    required this.isPremium,
    required this.onTap,
  });

  final int? selectedIndex;
  final bool isPremium;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = selectedIndex != null;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.petrolDeep, AppColors.petrol],
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.soft(theme.brightness),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: Opacity(
              opacity: 0.28,
              child: Image.asset(
                'assets/logo_carta_dia.png',
                width: 210,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GoldBadge(
                  label: selected ? 'Carta de hoje' : 'Sua carta do dia',
                  icon: selected ? Icons.check_circle : Icons.auto_awesome,
                  dark: true,
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: 230,
                  child: Text(
                    selected
                        ? 'Sua carta está guardada para hoje.'
                        : 'Uma mensagem espera por você.',
                    style: theme.textTheme.headlineLarge!.copyWith(
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 250,
                  child: Text(
                    selected
                        ? 'Respire fundo e retome a leitura ou o áudio quando quiser.'
                        : 'Escolha uma carta, ouça a narração e leve essa reflexão com você.',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.goldBright,
                    foregroundColor: AppColors.petrolDeep,
                  ),
                  icon: Icon(
                    selected ? Icons.menu_book_rounded : Icons.style_rounded,
                    size: 20,
                  ),
                  label:
                      Text(selected ? 'Abrir minha carta' : 'Escolher carta'),
                ),
                if (!isPremium) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Plano gratuito: 1 carta por dia',
                    style: theme.textTheme.labelSmall!.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data});

  final _DashboardData? data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.workspace_premium_outlined,
            label: 'Plano',
            value: data == null
                ? '—'
                : data!.isPremium
                    ? 'Premium'
                    : 'Gratuito',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.style_outlined,
            label: 'Cartas hoje',
            value: data == null
                ? '—'
                : data!.isPremium
                    ? 'Ilimitado'
                    : '${data!.usedToday}/1',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.play_circle_outline,
            label: 'Conteúdos',
            value: '${ContentRepository.all.length}',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.gold),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _ExploreGrid extends StatelessWidget {
  const _ExploreGrid({
    required this.onCards,
    required this.onOrganizations,
    required this.onContent,
    required this.onPremium,
  });

  final VoidCallback onCards;
  final VoidCallback onOrganizations;
  final VoidCallback onContent;
  final VoidCallback onPremium;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: [
        _ExploreTile(
          icon: Icons.style_rounded,
          title: 'Cartas do Dia',
          color: AppColors.gold,
          onTap: onCards,
        ),
        _ExploreTile(
          icon: Icons.business_center_outlined,
          title: 'Organizações',
          color: AppColors.petrolSoft,
          onTap: onOrganizations,
        ),
        _ExploreTile(
          icon: Icons.play_circle_outline,
          title: 'Conteúdos',
          color: AppColors.petrol,
          onTap: onContent,
        ),
        _ExploreTile(
          icon: Icons.auto_awesome,
          title: 'Premium',
          color: AppColors.goldBright,
          onTap: onPremium,
        ),
      ],
    );
  }
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedList extends StatelessWidget {
  const _FeaturedList({required this.items});

  final List<ContentItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _FeaturedCard(item: item);
        },
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 210,
      child: SoftCard(
        padding: EdgeInsets.zero,
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadii.lg),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: item.thumbnailPath == null
                    ? Container(
                        color: AppColors.petrol,
                        child: const Icon(Icons.play_circle_outline,
                            color: Colors.white, size: 32),
                      )
                    : Image.asset(item.thumbnailPath!, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category,
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B3B3E), AppColors.petrolDeep],
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium,
                color: AppColors.goldBright),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Viva a experiência completa',
                  style: theme.textTheme.titleLarge!.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cartas ilimitadas, conteúdos exclusivos e áudios.',
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.goldBright,
              foregroundColor: AppColors.petrolDeep,
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: const Text('Ver'),
          ),
        ],
      ),
    );
  }
}
