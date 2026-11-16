import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../design/components/app_background.dart';
import '../design/components/gold_badge.dart';
import '../design/components/soft_card.dart';
import '../design/tokens.dart';

class EspiritualidadeDiaPage extends StatelessWidget {
  const EspiritualidadeDiaPage({super.key});

  static const List<Map<String, String>> _parceiros = [
    {
      'nome': 'Bele Beauty Store',
      'descricao':
          'A Bele Beauty é uma empresa espiritualizada porque nasceu com um propósito que vai além da estética: cuidar da beleza que começa na alma e transborda para o mundo. Cada peça, cada criação e cada atendimento carrega intenção, presença e energia boa — porque acreditamos que beleza verdadeira é aquela que eleva, conecta e inspira.',
      'whatsapp': 'http://wa.me/5548998171948',
      'instagram':
          'https://www.instagram.com/belebeautystore?igsh=YWFoOHF0OWU0djkw',
      'site': 'http://www.belebeauty.com.br/',
      'contato': 'Site: www.belebeauty.com.br',
    },
    {
      'nome': 'Reffinatto Brazil',
      'descricao':
          'Na Reffinatto Brazil, o atendimento humanizado é o coração que transforma projetos em lares e móveis em experiências de bem-estar.',
      'whatsapp': 'http://wa.me/554891005888',
      'instagram':
          'https://www.instagram.com/reffinattobrazil?igsh=MW9yb3A4NzFpc2pm',
      'site': 'https://share.google/gx3lfudnBuqC5IhJC',
      'contato': 'Instagram: @reffinattobrazil',
    },
    {
      'nome': 'Marangoni Marcas',
      'descricao':
          'Uma empresa que preza por valores, propósito e conexões humanas genuínas, que vão além do lucro financeiro, trazendo uma cultura que envolve o equilíbrio das emoções.',
      'whatsapp': 'https://wa.me/message/D3JYFXNU6NTTK1',
      'instagram': 'https://www.instagram.com/marangonimarcas',
      'site': 'http://www.marangonimarcas.com.br/',
      'contato': 'Site: www.marangonimarcas.com.br',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Patrocinadores')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.xs,
            AppSpacing.page,
            AppSpacing.xxl,
          ),
          children: [
            Text(
              'Marcas que caminham\ncom o propósito',
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Empresas que acreditam na espiritualidade como parte da vida e dos negócios.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final parceiro in _parceiros) ...[
              _PartnerCard(
                parceiro: parceiro,
                onOpen: () => _mostrarDetalhes(context, parceiro),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: AppSpacing.sm),
            SoftCard(
              color: AppColors.petrol,
              borderColor: Colors.transparent,
              child: Row(
                children: [
                  const Icon(Icons.handshake_outlined,
                      color: AppColors.goldBright, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Quer caminhar com o projeto? Fale com a Helô pelo canal de contato.',
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: Colors.white,
                      ),
                    ),
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

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({required this.parceiro, required this.onOpen});

  final Map<String, String> parceiro;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nome = parceiro['nome'] ?? '';
    return SoftCard(
      padding: EdgeInsets.zero,
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadii.lg),
            ),
            child: Container(
              height: 130,
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                _parceiroImagePath(nome),
                fit: BoxFit.contain,
                cacheWidth: 600,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.storefront_outlined,
                      color: AppColors.petrol, size: 40),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(nome, style: theme.textTheme.headlineMedium),
                    ),
                    const GoldBadge(label: 'Parceiro', icon: Icons.handshake),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  parceiro['descricao'] ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (parceiro['whatsapp'] != null)
                      _MiniAction(
                        icon: Icons.chat_bubble_outline,
                        label: 'WhatsApp',
                        onTap: () => _abrirLink(parceiro['whatsapp']!),
                      ),
                    if (parceiro['instagram'] != null)
                      _MiniAction(
                        icon: Icons.camera_alt_outlined,
                        label: 'Instagram',
                        onTap: () => _abrirLink(parceiro['instagram']!),
                      ),
                    if (parceiro['site'] != null)
                      _MiniAction(
                        icon: Icons.public,
                        label: 'Site',
                        onTap: () => _abrirLink(parceiro['site']!),
                      ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.outline,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.gold),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

void _mostrarDetalhes(BuildContext context, Map<String, String> parceiro) {
  final theme = Theme.of(context);
  showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.petrolDeep, AppColors.petrol],
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.handshake_outlined,
                      color: AppColors.goldBright, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      parceiro['nome'] ?? '',
                      style: theme.textTheme.headlineMedium!.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Container(
                color: theme.colorScheme.surface,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parceiro['descricao'] ?? '',
                        style: theme.textTheme.bodyLarge!.copyWith(height: 1.6),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (parceiro['whatsapp'] != null)
                            FilledButton.icon(
                              onPressed: () =>
                                  _abrirLink(parceiro['whatsapp']!),
                              icon: const Icon(Icons.chat_bubble_outline,
                                  size: 18),
                              label: const Text('WhatsApp'),
                            ),
                          if (parceiro['instagram'] != null)
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _abrirLink(parceiro['instagram']!),
                              icon: const Icon(Icons.camera_alt_outlined,
                                  size: 18),
                              label: const Text('Instagram'),
                            ),
                          if (parceiro['site'] != null)
                            OutlinedButton.icon(
                              onPressed: () => _abrirLink(parceiro['site']!),
                              icon: const Icon(Icons.public, size: 18),
                              label: const Text('Site'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String _parceiroImagePath(String nome) {
  final simple = nome
      .toLowerCase()
      .replaceAll('ç', 'c')
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ã', 'a')
      .replaceAll('õ', 'o')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  final extension = simple == 'marangoni_marcas' ? 'jpg' : 'png';
  return 'assets/parceiros/$simple.$extension';
}

Future<void> _abrirLink(String url) async {
  try {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  } catch (_) {
    // Ignora falhas de abertura de link externo.
  }
}
