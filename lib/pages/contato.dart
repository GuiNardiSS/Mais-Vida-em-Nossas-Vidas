import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Página de Contato

class ContatoPage extends StatefulWidget {
  const ContatoPage({super.key});

  @override
  State<ContatoPage> createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  // Nenhum estado adicional necessário após a remoção da seção "Conteúdo"

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // Título principal
            const Text(
              'Quem é Helô Coelho?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0b4c52),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Layout responsivo: foto e texto lado a lado em desktop, empilhados em mobile
            if (isMobile) _buildMobileLayout() else _buildDesktopLayout(),

            const SizedBox(height: 48),

            // Seção de contatos
            const Text(
              'Entre em Contato',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0b4c52),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Grid de contatos clicáveis
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildContactButton(
                  context,
                  'E-mail',
                  FontAwesomeIcons.envelope,
                  'mailto:helocoelho10@outlook.com',
                ),
                _buildContactButton(
                  context,
                  'Instagram',
                  FontAwesomeIcons.instagram,
                  'https://www.instagram.com/helocoelhoconsultoria',
                ),
                _buildContactButton(
                  context,
                  'WhatsApp',
                  FontAwesomeIcons.whatsapp,
                  'https://api.whatsapp.com/message/5TM3HXDZJ77NL1?autoload=1&app_absent=0',
                ),
                _buildContactButton(
                  context,
                  'YouTube',
                  FontAwesomeIcons.youtube,
                  'https://www.youtube.com/@helocoelho10',
                ),
                _buildContactButton(
                  context,
                  'LinkedIn',
                  FontAwesomeIcons.linkedin,
                  'https://www.linkedin.com/in/helôcoelho',
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Layout para mobile (empilhado)
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Foto
        _buildProfilePhoto(),
        const SizedBox(height: 24),
        // Texto
        _buildBioText(),
      ],
    );
  }

  // Layout para desktop (lado a lado)
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Foto à esquerda
        Expanded(
          flex: 2,
          child: _buildProfilePhoto(),
        ),
        const SizedBox(width: 40),
        // Texto à direita
        Expanded(
          flex: 3,
          child: _buildBioText(),
        ),
      ],
    );
  }

  // Widget da foto de perfil
  Widget _buildProfilePhoto() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/perfil/helo_coelho.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFFa99045).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, size: 80, color: Color(0xFF0b4c52)),
                    SizedBox(height: 16),
                    Text(
                      'Helô Coelho',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0b4c52),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget do texto biográfico
  Widget _buildBioText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Helô Coelho, com uma trajetória de três décadas de dedicação e sucesso, fundadora da Helô Coelho Consultoria, Terapeuta Empresarial, Palestrante, Administradora, Mentora e consultora. Idealizadora e Apresentadora do Podcast Mais Vida em Nossas Vidas, do Método Interseção do Ser Integral, Das Cartas de Mensagens Mais Vida em Nossas Vidas e das Espiritualidade nas Organizações e impulsioner pequenos negócios artesanal.',
          style: TextStyle(fontSize: 16, height: 1.6),
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 16),
        Text(
          'Sua vasta experiência abrange o empreendedorismo e a comunicação, como Ceo e apresentadora de TV Pedra Branca do Jornal Cotidiano. Nessa jornada, dedicou-se a conectar histórias, inspirar pessoas e amplificar iniciativas que promovem impacto social positivo.',
          style: TextStyle(fontSize: 16, height: 1.6),
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 16),
        Text(
          'Mais de três décadas de estudo e prática em espiritualidade, autoconhecimento e amor ao próximo, guiar pessoas e organizações a integrarem a espiritualidade de forma harmoniosa e significativa, criando pontes entre a essência do indivíduo com a essência da organização, na construção de um mundo mais humano, ético e consciente.',
          style: TextStyle(fontSize: 16, height: 1.6),
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 16),
        Text(
          'É pós-graduanda em Neurociência do Comportamento e Desempenho, e em Introdução da Espiritualidade na Prática Clínica.',
          style: TextStyle(fontSize: 16, height: 1.6),
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 16),
        Text(
          'Gestora no terceiro setor, liderando projetos sociais, estudos, acolhimento fraterno, que geram impacto comunitário significativo e transformação.',
          style: TextStyle(fontSize: 16, height: 1.6),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildContactButton(
    BuildContext context,
    String label,
    IconData icon,
    String url,
  ) {
    // Cores específicas para cada rede social
    Color iconColor;
    Color borderColor;

    switch (label.toLowerCase()) {
      case 'instagram':
        iconColor = const Color(0xFFE4405F); // Rosa do Instagram
        borderColor = const Color(0xFFE4405F).withValues(alpha: 0.3);
        break;
      case 'whatsapp':
        iconColor = const Color(0xFF25D366); // Verde do WhatsApp
        borderColor = const Color(0xFF25D366).withValues(alpha: 0.3);
        break;
      case 'youtube':
        iconColor = const Color(0xFFFF0000); // Vermelho do YouTube
        borderColor = const Color(0xFFFF0000).withValues(alpha: 0.3);
        break;
      case 'linkedin':
        iconColor = const Color(0xFF0077B5); // Azul do LinkedIn
        borderColor = const Color(0xFF0077B5).withValues(alpha: 0.3);
        break;
      case 'e-mail':
        iconColor = const Color(0xFF34495E); // Cinza escuro para email
        borderColor = const Color(0xFF34495E).withValues(alpha: 0.3);
        break;
      default:
        iconColor = const Color(0xFF0b4c52);
        borderColor = const Color(0xFF0b4c52).withValues(alpha: 0.3);
    }

    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              color: iconColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: iconColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Handle error - could show a snackbar or dialog
      debugPrint('Could not launch $url');
    }
  }
}
