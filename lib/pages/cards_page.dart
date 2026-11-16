import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/assets/asset_resolver.dart';
import '../design/components/gold_badge.dart';
import '../design/tokens.dart';
import '../features/favorites/favorites_repository.dart';
import '../services/subscription_service.dart';
import '../services/usage_restriction_service.dart';
import 'card_reader_page.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key, required this.isOrganization});

  final bool isOrganization;

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  final AssetResolver _resolver = AssetResolver();

  int? _selected;
  bool _isPremium = false;
  int _usedToday = 0;
  bool _loading = true;
  bool _onlyFavorites = false;
  Set<int> _favorites = <int>{};
  Timer? _ticker;
  Duration _untilTomorrow = Duration.zero;

  bool get _isOrg => widget.isOrganization;
  String get _folder =>
      _isOrg ? 'assets/cartas_do_dia_org' : 'assets/cartas_do_dia';
  String get _logo =>
      _isOrg ? 'assets/logo_carta_org.webp' : 'assets/logo_carta_dia.webp';
  String get _indexKey => _isOrg ? 'carta_org_index' : 'carta_dia_index';
  String get _dateKey => _isOrg ? 'carta_org_date' : 'carta_dia_date';
  String get _title => _isOrg
      ? 'Carta da organização'
      : 'Escolha sua carta';
  String get _subtitle => _isOrg
      ? 'Mensagens para levar propósito e equilíbrio ao ambiente de trabalho.'
      : 'Escolha uma carta e receba uma mensagem para o seu dia.';

  @override
  void initState() {
    super.initState();
    _load();
    _startTicker();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final isPremium = await SubscriptionService.isPremium();
    final used = _isOrg
        ? await UsageRestrictionService.getCartasOrganizacaoUsedToday()
        : await UsageRestrictionService.getCartasDiaUsedToday();
    final favorites = await FavoritesRepository.load(isOrganization: _isOrg);

    int? selected;
    if (prefs.getString(_dateKey) == today) {
      selected = prefs.getInt(_indexKey);
    }

    if (!mounted) return;
    setState(() {
      _isPremium = isPremium;
      _usedToday = used;
      _selected = selected;
      _favorites = favorites;
      _loading = false;
    });
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() => _untilTomorrow = _timeUntilTomorrow());
    });
    _untilTomorrow = _timeUntilTomorrow();
  }

  Duration _timeUntilTomorrow() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now);
  }

  String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  Future<void> _select(int index) async {
    if (_selected == index) {
      _openReader(index);
      return;
    }

    final canSelect = _isOrg
        ? await UsageRestrictionService.canSelectCartaOrganizacao()
        : await UsageRestrictionService.canSelectCartaDia();

    if (!canSelect) {
      if (!mounted) return;
      await UsageRestrictionService.showDailyLimitReachedDialog(
        context,
        isCartaDia: !_isOrg,
      );
      return;
    }

    if (_isOrg) {
      await UsageRestrictionService.registerCartaOrganizacaoUsage();
    } else {
      await UsageRestrictionService.registerCartaDiaUsage();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_indexKey, index);
    await prefs.setString(_dateKey, _todayKey());

    if (!mounted) return;
    setState(() {
      _selected = index;
      _usedToday += _isPremium ? 0 : 1;
    });
    _openReader(index);
  }

  Future<void> _openReader(int index) async {
    final assetPath = await _resolver.resolveCardBack(_folder, index);
    if (!mounted) return;
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CardReaderPage(
          index: index,
          isOrganization: _isOrg,
          assetPath: assetPath,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
    _load();
  }

  String get _countdown {
    final hours = _untilTomorrow.inHours.toString().padLeft(2, '0');
    final minutes =
        _untilTomorrow.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '${hours}h ${minutes}min';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasReachedLimit = !_isPremium && _usedToday >= 1;
    final indexes = _onlyFavorites
        ? (_favorites.toList()..sort())
        : List<int>.generate(50, (index) => index);

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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_title, style: theme.textTheme.displayMedium),
                    const SizedBox(height: 4),
                    Text(_subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GoldBadge(
                label: _isPremium ? 'Premium' : 'Gratuito',
                icon:
                    _isPremium ? Icons.workspace_premium : Icons.local_florist,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (hasReachedLimit)
            _LimitNotice(countdown: _countdown)
          else
            _DailyHint(
              isPremium: _isPremium,
              remaining: _isPremium ? null : 1 - _usedToday,
            ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Todas'),
                selected: !_onlyFavorites,
                onSelected: (_) => setState(() => _onlyFavorites = false),
              ),
              ChoiceChip(
                label: Text('Favoritas (${_favorites.length})'),
                selected: _onlyFavorites,
                onSelected: (_) => setState(() => _onlyFavorites = true),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (indexes.isEmpty)
            _FavoritesEmpty()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns =
                    (constraints.maxWidth / 108).floor().clamp(3, 5);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.64,
                  ),
                  itemCount: indexes.length,
                  itemBuilder: (context, position) {
                    final index = indexes[position];
                    final selected = _selected == index;
                    final locked = hasReachedLimit && !selected;
                    return _CardTile(
                      index: index,
                      logo: _logo,
                      selected: selected,
                      locked: locked,
                      isFavorite: _favorites.contains(index),
                      onTap: () => _select(index),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _DailyHint extends StatelessWidget {
  const _DailyHint({required this.isPremium, required this.remaining});

  final bool isPremium;
  final int? remaining;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isPremium
                  ? 'Sua assinatura libera todas as cartas, quantas vezes quiser.'
                  : 'Você tem ${remaining ?? 1} carta gratuita hoje. Escolha com calma.',
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitNotice extends StatelessWidget {
  const _LimitNotice({required this.countdown});

  final String countdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.petrol.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.petrol.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.nightlight_round, color: AppColors.petrol, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sua carta de hoje já foi escolhida. A próxima abre em $countdown.',
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/assinaturas'),
            child: const Text('Premium'),
          ),
        ],
      ),
    );
  }
}

class _FavoritesEmpty extends StatelessWidget {
  const _FavoritesEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(Icons.favorite_border,
              size: 44, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            'Nenhuma carta favoritada ainda',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Abra uma carta e toque no coração para guardar aqui.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.index,
    required this.logo,
    required this.selected,
    required this.locked,
    required this.isFavorite,
    required this.onTap,
  });

  final int index;
  final String logo;
  final bool selected;
  final bool locked;
  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: 'Carta ${index + 1}${locked ? ', exclusiva para premium' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color:
                  selected ? AppColors.gold : theme.colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected ? AppShadows.soft(theme.brightness) : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                logo,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: AppColors.petrol,
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
              if (locked)
                ColoredBox(color: Colors.black.withValues(alpha: 0.45)),
              Positioned(
                left: 8,
                bottom: 6,
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (selected)
                const Positioned(
                  top: 6,
                  right: 6,
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: AppColors.gold,
                    child: Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                )
              else if (locked)
                const Positioned(
                  top: 6,
                  right: 6,
                  child:
                      Icon(Icons.lock_outline, size: 16, color: Colors.white70),
                ),
              if (isFavorite)
                const Positioned(
                  right: 6,
                  bottom: 6,
                  child: Icon(
                    Icons.favorite,
                    size: 14,
                    color: AppColors.goldBright,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
