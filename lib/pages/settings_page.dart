import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/demo/demo_config.dart';
import '../design/components/gold_badge.dart';
import '../design/components/soft_card.dart';
import '../design/tokens.dart';
import '../features/settings/theme_controller.dart';
import '../services/secure_storage_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          Text('Aparência', style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tema do aplicativo', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Escolha entre claro, escuro ou acompanhar o sistema.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_outlined),
                        label: Text('Sistema'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Claro'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Escuro'),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (selection) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setMode(selection.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Demonstração', style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const GoldBadge(
                      label: 'Modo demonstração',
                      icon: Icons.science_outlined,
                    ),
                    const Spacer(),
                    Text(
                      kDemoMode ? 'Ativo' : 'Desativado',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Pagamentos, login por e-mail e assinatura são simulados localmente. '
                  'Nenhum dado é enviado e nenhuma cobrança é realizada.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => _confirmReset(context),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Restaurar dados de demonstração'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Sobre', style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AboutRow(label: 'Versão', value: '2.0.0+7'),
                const Divider(height: 22),
                _AboutRow(
                    label: 'Base', value: 'Flutter • Riverpod • Material 3'),
                const Divider(height: 22),
                _AboutRow(label: 'Projeto', value: 'Portfólio'),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'A identidade visual, os textos e os conteúdos pertencem ao projeto '
                  'Mais Vida em Nossas Vidas.',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurar demonstração?'),
        content: const Text(
          'Isso remove a assinatura simulada, o histórico de cartas, o tema e a conta local. '
          'O aplicativo volta ao estado inicial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final prefs = await SharedPreferences.getInstance();
    for (final key in const [
      'onboarding_v2_done',
      'carta_dia_index',
      'carta_dia_date',
      'carta_org_index',
      'carta_org_date',
      'cartas_dia_used_count',
      'cartas_dia_date',
      'cartas_org_used_count',
      'cartas_org_date',
      'theme_mode',
    ]) {
      await prefs.remove(key);
    }
    for (final key in const [
      'device_id',
      'subscription_status',
      'subscription_expiry',
      'subscription_transaction_id',
      'subscription_last_check',
      'profile_name',
      'profile_email',
    ]) {
      await SecureStorageService.delete(key);
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados de demonstração restaurados.')),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}
