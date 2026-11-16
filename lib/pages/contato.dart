import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../design/components/app_background.dart';
import '../design/components/gold_badge.dart';
import '../design/components/section_header.dart';
import '../design/components/soft_card.dart';
import '../design/tokens.dart';

class ContatoPage extends StatefulWidget {
  const ContatoPage({super.key});

  @override
  State<ContatoPage> createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  bool _expanded = false;

  static const _email = 'mailto:eu@helocoelhoterapeuta.com';
  static const _instagram = 'https://www.instagram.com/helocoelhoconsultoria';
  static const _whatsapp =
      'https://api.whatsapp.com/message/5TM3HXDZJ77NL1?autoload=1&app_absent=0';
  static const _youtube = 'https://www.youtube.com/@helocoelho10';
  static const _linkedin = 'https://www.linkedin.com/in/helôcoelho';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Contato')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.xs,
            AppSpacing.page,
            AppSpacing.xxl,
          ),
          children: [
            Center(
              child: Container(
                width: 148,
                height: 148,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 3),
                  boxShadow: AppShadows.soft(theme.brightness),
                  image: const DecorationImage(
                    image: AssetImage('assets/perfil/helo_coelho.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Helô Coelho',
              textAlign: TextAlign.center,
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Terapeuta empresarial • Palestrante • Mentora',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            const Center(
              child: GoldBadge(
                label: 'Espiritualidade nas organizações',
                icon: Icons.business_center_outlined,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
              title: 'Sobre',
              trailing: TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? 'Recolher' : 'Ler mais'),
              ),
            ),
            SoftCard(
              child: AnimatedSize(
                duration: AppDurations.medium,
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: Text(
                  _bio(expanded: _expanded),
                  style: theme.textTheme.bodyLarge!.copyWith(height: 1.65),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(
              title: 'Vamos conversar',
              subtitle: 'Escolha o canal que preferir',
            ),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _launchUrl(_whatsapp),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('WhatsApp'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _launchUrl(_email),
                    icon: const Icon(Icons.mail_outline, size: 18),
                    label: const Text('E-mail'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.1,
              children: [
                _SocialTile(
                  label: 'Instagram',
                  handle: '@helocoelhoconsultoria',
                  icon: FontAwesomeIcons.instagram,
                  color: const Color(0xFFE4405F),
                  onTap: () => _launchUrl(_instagram),
                ),
                _SocialTile(
                  label: 'YouTube',
                  handle: '@helocoelho10',
                  icon: FontAwesomeIcons.youtube,
                  color: const Color(0xFFFF0000),
                  onTap: () => _launchUrl(_youtube),
                ),
                _SocialTile(
                  label: 'LinkedIn',
                  handle: 'Helô Coelho',
                  icon: FontAwesomeIcons.linkedin,
                  color: const Color(0xFF0077B5),
                  onTap: () => _launchUrl(_linkedin),
                ),
                _SocialTile(
                  label: 'E-mail',
                  handle: 'eu@helocoelhoterapeuta.com',
                  icon: FontAwesomeIcons.envelope,
                  color: AppColors.petrol,
                  onTap: () => _launchUrl(_email),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SoftCard(
              color: AppColors.petrol,
              borderColor: Colors.transparent,
              child: Row(
                children: [
                  const Icon(Icons.format_quote_rounded,
                      color: AppColors.goldBright, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Espiritualidade é o fio que conecta propósito, pessoas e resultados.',
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: Colors.white,
                        height: 1.45,
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

  String _bio({required bool expanded}) {
    const paragraphs = [
      'Com uma trajetória de três décadas de dedicação e sucesso, Helô Coelho é fundadora da Helô Coelho Consultoria, terapeuta empresarial, palestrante, administradora, mentora e consultora. Idealizadora e apresentadora do podcast Mais Vida em Nossas Vidas, do Método Interseção do Ser Integral, das Cartas de Mensagens Mais Vida em Nossas Vidas e da Espiritualidade nas Organizações.',
      'Sua experiência abrange empreendedorismo e comunicação, como CEO e apresentadora da TV Pedra Branca no Jornal Cotidiano. Nessa jornada, dedica-se a conectar histórias, inspirar pessoas e amplificar iniciativas de impacto social positivo.',
      'São mais de três décadas de estudo e prática em espiritualidade, autoconhecimento e amor ao próximo, guiando pessoas e organizações a integrarem a espiritualidade de forma harmoniosa e significativa — criando pontes entre a essência do indivíduo e a essência da organização.',
      'É pós-graduanda em Neurociência do Comportamento e Desempenho e em Introdução da Espiritualidade na Prática Clínica. Também atua na gestão do terceiro setor, liderando projetos sociais, estudos e acolhimento fraterno.',
    ];

    if (expanded) return paragraphs.join('\n\n');
    return '${paragraphs[0]}\n\n${paragraphs[1]}';
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _showError('Não foi possível abrir o link.');
      }
    } catch (_) {
      _showError('Erro ao tentar abrir o link ou e-mail.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _SocialTile extends StatelessWidget {
  const _SocialTile({
    required this.label,
    required this.handle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String handle;
  final FaIconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      radius: AppRadii.md,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: FaIcon(icon, color: color, size: 17),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: theme.textTheme.titleMedium),
                Text(
                  handle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
