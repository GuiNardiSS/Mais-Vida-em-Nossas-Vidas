import 'package:material_ui/material_ui.dart';

import '../design/components/gold_badge.dart';
import '../design/components/section_header.dart';
import '../design/components/soft_card.dart';
import '../design/tokens.dart';
import 'assinaturas.dart';
import 'contato.dart';
import 'espiritualidade_dia.dart';
import 'inicio.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xs,
        AppSpacing.page,
        AppSpacing.xxl,
      ),
      children: [
        Text('Mais', style: theme.textTheme.displayMedium),
        const SizedBox(height: 4),
        Text(
          'Sua conta, conteúdos e preferências em um só lugar.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        const _ProfileCard(),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Jornada'),
        _MenuTile(
          icon: Icons.menu_book_outlined,
          title: 'Conheça Mais',
          subtitle: 'Espiritualidade, propósito e autoconhecimento',
          onTap: () => _push(context, const ConhecaMaisPage()),
        ),
        const SizedBox(height: 8),
        _MenuTile(
          icon: Icons.handshake_outlined,
          title: 'Patrocinadores',
          subtitle: 'Marcas que caminham com o projeto',
          onTap: () => _push(context, const EspiritualidadeDiaPage()),
        ),
        const SizedBox(height: 8),
        _MenuTile(
          icon: Icons.mail_outline,
          title: 'Contato',
          subtitle: 'Fale com Helô Coelho e acompanhe as redes',
          onTap: () => _push(context, const ContatoPage()),
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Assinatura'),
        _MenuTile(
          icon: Icons.workspace_premium_outlined,
          title: 'Assinaturas',
          subtitle: 'Conheça o plano premium',
          trailing:
              const GoldBadge(label: 'Demo', icon: Icons.science_outlined),
          onTap: () => _push(context, const AssinaturasPage()),
        ),
        const SizedBox(height: 8),
        _MenuTile(
          icon: Icons.person_outline,
          title: 'Meu perfil',
          subtitle: 'Conta opcional e restauração de acesso',
          onTap: () => _push(context, const ProfilePage()),
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Preferências'),
        _MenuTile(
          icon: Icons.settings_outlined,
          title: 'Configurações',
          subtitle: 'Tema, dados locais e privacidade',
          onTap: () => _push(context, const SettingsPage()),
        ),
        const SizedBox(height: 8),
        _MenuTile(
          icon: Icons.info_outline,
          title: 'Sobre o app',
          subtitle: 'Versão 2.0.0 • projeto de portfólio',
          onTap: () => showAboutDialog(
            context: context,
            applicationName: 'Mais Vida em Nossas Vidas',
            applicationVersion: '2.0.0+7',
            applicationLegalese:
                'Projeto de portfólio. Pagamentos em modo demonstração.',
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Text(
            'Feito com cuidado para inspirar o seu dia.',
            style: theme.textTheme.labelSmall,
          ),
        ),
      ],
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      ),
      color: AppColors.petrol,
      borderColor: Colors.transparent,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.person_outline, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seu espaço',
                  style: theme.textTheme.titleLarge!.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Entre com e-mail ou continue sem conta.',
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white70),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      radius: AppRadii.md,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.petrol, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (trailing != null) trailing!,
          const SizedBox(width: 6),
          Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline),
        ],
      ),
    );
  }
}
