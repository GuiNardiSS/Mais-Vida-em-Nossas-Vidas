import 'package:material_ui/material_ui.dart';

import '../core/demo/demo_config.dart';
import '../design/components/gold_badge.dart';
import '../design/components/soft_card.dart';
import '../design/tokens.dart';
import '../services/device_service.dart';
import '../services/secure_storage_service.dart';
import '../services/subscription_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _nameKey = 'profile_name';
  static const _emailKey = 'profile_email';
  static const _demoCode = '123456';

  String? _name;
  String? _email;
  String? _deviceId;
  bool _premium = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await SecureStorageService.read(_nameKey);
    final email = await SecureStorageService.read(_emailKey);
    final deviceId = await DeviceService.getDeviceId();
    final premium = await SubscriptionService.isPremium();
    if (!mounted) return;
    setState(() {
      _name = name;
      _email = email;
      _deviceId = deviceId;
      _premium = premium;
      _loading = false;
    });
  }

  Future<void> _startEmailLogin() async {
    final controller = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Entrar com e-mail'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sua conta é opcional. Ela serve para restaurar o acesso premium em outro aparelho.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                hintText: 'voce@exemplo.com',
              ),
            ),
            const SizedBox(height: 12),
            const GoldBadge(
              label: 'Demonstração',
              icon: Icons.science_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (!value.contains('@') || !value.contains('.')) {
                return;
              }
              Navigator.of(ctx).pop(value);
            },
            child: const Text('Enviar código'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || email == null) return;
    await _confirmCode(email);
  }

  Future<void> _confirmCode(String email) async {
    final controller = TextEditingController();
    String? error;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Confirme seu e-mail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enviamos um código para $email.'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Modo demonstração — use o código $_demoCode',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Código',
                  errorText: error,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim() == _demoCode) {
                  Navigator.of(ctx).pop(true);
                } else {
                  setDialogState(() => error = 'Código incorreto');
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (!mounted || confirmed != true) return;

    final name = email.split('@').first.replaceAll('.', ' ');
    await SecureStorageService.write(_nameKey, name);
    await SecureStorageService.write(_emailKey, email);
    if (!mounted) return;
    setState(() {
      _name = name;
      _email = email;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conta de demonstração conectada.')),
    );
  }

  Future<void> _signOut() async {
    await SecureStorageService.delete(_nameKey);
    await SecureStorageService.delete(_emailKey);
    if (!mounted) return;
    setState(() {
      _name = null;
      _email = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logged = _email != null;
    final shortDevice = _deviceId == null || _deviceId!.length < 8
        ? '—'
        : '${_deviceId!.substring(0, 8)}...';

    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.page),
              children: [
                Center(
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: AppColors.petrol,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 2),
                    ),
                    child: Center(
                      child: logged
                          ? Text(
                              (_name ?? '?').characters.first.toUpperCase(),
                              style: theme.textTheme.displayMedium!.copyWith(
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.person_outline,
                              color: Colors.white, size: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  logged
                      ? (_name ?? 'Bem-vindo')
                      : 'Você está no modo visitante',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  logged
                      ? _email!
                      : 'Continue sem conta ou entre para salvar seu acesso.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Center(
                  child: GoldBadge(
                    label: _premium ? 'Assinante premium' : 'Plano gratuito',
                    icon: _premium
                        ? Icons.workspace_premium
                        : Icons.local_florist,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SoftCard(
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.fingerprint,
                        label: 'Identificação do aparelho',
                        value: shortDevice,
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.shield_outlined,
                        label: 'Privacidade',
                        value: 'Dados ficam neste aparelho',
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.science_outlined,
                        label: 'Modo',
                        value: kDemoMode ? kDemoLabel : 'Produção',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (logged)
                  OutlinedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair da conta'),
                  )
                else ...[
                  FilledButton.icon(
                    onPressed: _startEmailLogin,
                    icon: const Icon(Icons.mail_outline),
                    label: const Text('Entrar com e-mail'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Continuar sem conta'),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'A conta é opcional e existe para restaurar a assinatura em outro aparelho. '
                  'Nesta demonstração, o código é exibido na tela e nada é enviado pela internet.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.gold),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(value, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
