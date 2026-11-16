import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/demo/demo_config.dart';
import '../design/components/app_background.dart';
import '../design/tokens.dart';
import '../features/settings/theme_controller.dart';
import 'cards_page.dart';
import 'contato.dart';
import 'conteudo.dart';
import 'dashboard.dart';
import 'espiritualidade_dia.dart';
import 'inicio.dart';
import 'more_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = demoInitialTab;

  static const _titles = [
    'Início',
    'Cartas do Dia',
    'Conteúdo',
    'Organizações',
    'Mais',
  ];

  late final List<Widget> _pages = [
    DashboardPage(onNavigate: _goTo),
    const CardsPage(isOrganization: false),
    const ConteudoPage(embedded: true),
    const CardsPage(isOrganization: true),
    const MorePage(),
  ];

  void _goTo(int index) {
    if (index < 0 || index >= _pages.length) return;
    setState(() => _index = index);
  }

  void _toggleTheme() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ref
        .read(themeModeProvider.notifier)
        .setMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    );
  }

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Abrir menu',
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Alternar tema',
            onPressed: _toggleTheme,
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Meu perfil',
              onPressed: _openProfile,
              icon: const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.petrol,
                child:
                    Icon(Icons.person_outline, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      drawer: _AppDrawer(
        selectedIndex: _index,
        onSelect: _goTo,
        onPush: _push,
      ),
      body: AppBackground(
        child: IndexedStack(index: _index, children: _pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style_rounded),
            label: 'Cartas',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle_fill),
            label: 'Conteúdo',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_center_outlined),
            selectedIcon: Icon(Icons.business_center),
            label: 'Empresas',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Mais',
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.selectedIndex,
    required this.onSelect,
    required this.onPush,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final ValueChanged<Widget> onPush;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      (label: 'Início', icon: Icons.home_outlined, index: 0),
      (label: 'Cartas do Dia', icon: Icons.style_outlined, index: 1),
      (label: 'Conteúdo', icon: Icons.play_circle_outline, index: 2),
      (
        label: 'Espiritualidade nas Organizações',
        icon: Icons.business_center_outlined,
        index: 3
      ),
      (label: 'Mais', icon: Icons.grid_view_outlined, index: 4),
    ];

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.petrolDeep, AppColors.petrol],
                ),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/icon.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.spa,
                        color: AppColors.petrol,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mais Vida em\nNossas Vidas',
                    style: theme.textTheme.headlineMedium!.copyWith(
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Espiritualidade para o dia a dia',
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            ...items.map((item) {
              final selected = selectedIndex == item.index;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: ListTile(
                  selected: selected,
                  selectedTileColor: AppColors.gold.withValues(alpha: 0.16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    item.icon,
                    color:
                        selected ? AppColors.gold : theme.colorScheme.onSurface,
                  ),
                  title: Text(
                    item.label,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? AppColors.gold
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelect(item.index);
                  },
                ),
              );
            }),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(),
            ),
            _DrawerLink(
              icon: Icons.menu_book_outlined,
              label: 'Conheça Mais',
              onTap: () {
                Navigator.of(context).pop();
                onPush(const ConhecaMaisPage());
              },
            ),
            _DrawerLink(
              icon: Icons.mail_outline,
              label: 'Contato',
              onTap: () {
                Navigator.of(context).pop();
                onPush(const ContatoPage());
              },
            ),
            _DrawerLink(
              icon: Icons.handshake_outlined,
              label: 'Patrocinadores',
              onTap: () {
                Navigator.of(context).pop();
                onPush(const EspiritualidadeDiaPage());
              },
            ),
            _DrawerLink(
              icon: Icons.person_outline,
              label: 'Meu perfil',
              onTap: () {
                Navigator.of(context).pop();
                onPush(const ProfilePage());
              },
            ),
            _DrawerLink(
              icon: Icons.settings_outlined,
              label: 'Configurações',
              onTap: () {
                Navigator.of(context).pop();
                onPush(const SettingsPage());
              },
            ),
            const SizedBox(height: 12),
            Center(
              child: Text('v2.0.0 • demonstração',
                  style: theme.textTheme.labelSmall),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DrawerLink extends StatelessWidget {
  const _DrawerLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: theme.colorScheme.onSurface),
      title: Text(label, style: theme.textTheme.bodyMedium),
      onTap: onTap,
    );
  }
}
