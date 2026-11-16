import 'dart:math';

import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/demo/demo_config.dart';
import '../../core/payments/br_code_generator.dart';
import '../../design/components/gold_badge.dart';
import '../../design/tokens.dart';
import '../../services/subscription_service.dart';

class DemoPaymentSheet extends StatefulWidget {
  const DemoPaymentSheet({super.key, required this.amount});

  final double amount;

  @override
  State<DemoPaymentSheet> createState() => _DemoPaymentSheetState();
}

class _DemoPaymentSheetState extends State<DemoPaymentSheet> {
  static const _pixKey = 'demo@maisvidaemnossasvidas.app';

  late final String _pixPayload;
  String _method = 'pix';
  bool _processing = false;
  bool _success = false;
  String? _transactionId;

  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _name = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  String? _brand;

  final _numberMask = MaskTextInputFormatter(
    mask: '#### #### #### ####',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _expiryMask = MaskTextInputFormatter(
    mask: '##/##',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _cvvMask = MaskTextInputFormatter(
    mask: '###',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    final txid = 'DEMO${DateTime.now().millisecondsSinceEpoch % 100000000}';
    _pixPayload = BrCodeGenerator.generate(
      pixKey: _pixKey,
      merchantName: 'MAIS VIDA EM NOSSAS VIDAS',
      merchantCity: 'SAO PAULO',
      amount: widget.amount,
      description: 'Assinatura demonstracao',
      txid: txid,
    );
    _number.addListener(_detectBrand);
  }

  void _detectBrand() {
    final digits = _number.text.replaceAll(' ', '');
    String? brand;
    if (digits.startsWith('4')) {
      brand = 'Visa';
    } else if (digits.startsWith('5') || digits.startsWith('2')) {
      brand = 'Mastercard';
    } else if (digits.startsWith('3')) {
      brand = 'Amex';
    } else if (digits.startsWith('6')) {
      brand = 'Discover';
    }
    if (brand != _brand) setState(() => _brand = brand);
  }

  Future<void> _activate(String method) async {
    setState(() => _processing = true);
    final txid =
        'DEMO-${method.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';
    final ok = await SubscriptionService.activateSubscription(
      transactionId: txid,
      paymentMethod: method,
      amount: widget.amount,
    );
    if (!mounted) return;
    setState(() {
      _processing = false;
      _success = ok;
      _transactionId = txid;
    });
  }

  Future<void> _copyPix() async {
    await Clipboard.setData(ClipboardData(text: _pixPayload));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código PIX copiado.')),
    );
  }

  void _fillTestCard() {
    _number.text = '4242 4242 4242 4242';
    _name.text = 'CLIENTE DEMONSTRACAO';
    _expiry.text = '12/30';
    _cvv.text = '123';
    setState(() => _brand = 'Visa');
  }

  bool _luhn(String value) {
    var sum = 0;
    var alternate = false;
    for (var i = value.length - 1; i >= 0; i--) {
      var digit = int.parse(value[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  String? _validateCardNumber(String? value) {
    final digits = (value ?? '').replaceAll(' ', '');
    if (digits.length < 13) return 'Número incompleto';
    if (!_luhn(digits)) return 'Número inválido';
    return null;
  }

  String? _validateName(String? value) {
    if ((value ?? '').trim().length < 3) return 'Informe o nome';
    return null;
  }

  String? _validateExpiry(String? value) {
    final text = value ?? '';
    if (text.length != 5) return 'MM/AA';
    final parts = text.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null || month < 1 || month > 12) {
      return 'Data inválida';
    }
    final now = DateTime.now();
    final expiry = DateTime(2000 + year, month + 1);
    if (expiry.isBefore(now)) return 'Vencido';
    return null;
  }

  String? _validateCvv(String? value) {
    if ((value ?? '').length < 3) return 'CVV inválido';
    return null;
  }

  void _submitCard() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _activate('card');
  }

  @override
  void dispose() {
    _number.dispose();
    _name.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: _success
          ? _SuccessView(
              transactionId: _transactionId,
              onDone: () => Navigator.of(context).pop(true),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Assinar premium',
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                      const GoldBadge(
                        label: kDemoLabel,
                        icon: Icons.science_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${widget.amount.toStringAsFixed(2)} por mês • cancele quando quiser',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'pix',
                        icon: Icon(Icons.pix),
                        label: Text('PIX'),
                      ),
                      ButtonSegment(
                        value: 'card',
                        icon: Icon(Icons.credit_card),
                        label: Text('Cartão'),
                      ),
                    ],
                    selected: {_method},
                    onSelectionChanged: (value) {
                      setState(() => _method = value.first);
                    },
                  ),
                  const SizedBox(height: 18),
                  if (_method == 'pix') _buildPix(theme) else _buildCard(theme),
                  const SizedBox(height: 14),
                  Text(
                    'Demonstração: nenhum valor é cobrado e nenhum dado sai do aparelho.',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPix(ThemeData theme) {
    return Column(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: QrImageView(
              data: _pixPayload,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SelectableText(
          _pixPayload,
          maxLines: 3,
          style: theme.textTheme.labelSmall!.copyWith(
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _copyPix,
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copiar código'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: _processing ? null : () => _activate('pix'),
                icon: _processing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline, size: 18),
                label: Text(_processing ? 'Ativando...' : 'Simular pagamento'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _number,
            inputFormatters: [_numberMask],
            keyboardType: TextInputType.number,
            validator: _validateCardNumber,
            decoration: InputDecoration(
              labelText: 'Número do cartão',
              hintText: '4242 4242 4242 4242',
              prefixIcon: const Icon(Icons.credit_card),
              suffixText: _brand,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.characters,
            validator: _validateName,
            decoration: const InputDecoration(
              labelText: 'Nome impresso no cartão',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiry,
                  inputFormatters: [_expiryMask],
                  keyboardType: TextInputType.number,
                  validator: _validateExpiry,
                  decoration: const InputDecoration(labelText: 'Validade'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cvv,
                  inputFormatters: [_cvvMask],
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  validator: _validateCvv,
                  decoration: const InputDecoration(labelText: 'CVV'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: _fillTestCard,
                icon: const Icon(Icons.auto_fix_high, size: 18),
                label: const Text('Usar cartão de teste'),
              ),
              const Spacer(),
              if (_processing)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _processing ? null : _submitCard,
              child: Text(
                _processing ? 'Processando...' : 'Pagar simulação',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.transactionId, required this.onDone});

  final String? transactionId;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final random = Random();
    final id = transactionId ??
        'DEMO-${random.nextInt(999999).toString().padLeft(6, '0')}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded,
              color: AppColors.success, size: 46),
        ),
        const SizedBox(height: 16),
        Text('Assinatura ativada!', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'Sua experiência premium está liberada por 30 dias.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Text(
          'Transação $id',
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onDone,
            child: const Text('Começar a explorar'),
          ),
        ),
      ],
    );
  }
}
