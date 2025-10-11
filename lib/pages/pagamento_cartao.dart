import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:convert';

class PagamentoCartaoPage extends StatefulWidget {
  const PagamentoCartaoPage({super.key});
  @override
  State<PagamentoCartaoPage> createState() => _PagamentoCartaoPageState();
}

class _PagamentoCartaoPageState extends State<PagamentoCartaoPage> {
  final _formKey = GlobalKey<FormState>();
  final _numeroCartaoController = TextEditingController();
  final _nomeController = TextEditingController();
  final _validadeController = TextEditingController();
  final _cvvController = TextEditingController();

  bool loading = false;
  String? tipoCartao;

  // Formatadores de máscara
  final _numeroCartaoFormatter = MaskTextInputFormatter(
    mask: '#### #### #### ####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  final _validadeFormatter = MaskTextInputFormatter(
    mask: '##/##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  final _cvvFormatter = MaskTextInputFormatter(
    mask: '###',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _numeroCartaoController.addListener(_detectarTipoCartao);
  }

  @override
  void dispose() {
    _numeroCartaoController.dispose();
    _nomeController.dispose();
    _validadeController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _detectarTipoCartao() {
    final numero = _numeroCartaoController.text.replaceAll(' ', '');
    setState(() {
      if (numero.startsWith('4')) {
        tipoCartao = 'Visa';
      } else if (numero.startsWith('5') || numero.startsWith('2')) {
        tipoCartao = 'Mastercard';
      } else if (numero.startsWith('3')) {
        tipoCartao = 'American Express';
      } else if (numero.startsWith('6')) {
        tipoCartao = 'Discover';
      } else {
        tipoCartao = null;
      }
    });
  }

  String? _validarNumeroCartao(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite o número do cartão';
    }
    final numero = value.replaceAll(' ', '');
    if (numero.length < 13 || numero.length > 19) {
      return 'Número do cartão inválido';
    }
    if (!_validarLuhn(numero)) {
      return 'Número do cartão inválido';
    }
    return null;
  }

  bool _validarLuhn(String numero) {
    int sum = 0;
    bool alternate = false;
    for (int i = numero.length - 1; i >= 0; i--) {
      int digit = int.parse(numero[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  String? _validarNome(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite o nome como está no cartão';
    }
    if (value.length < 3) {
      return 'Nome muito curto';
    }
    return null;
  }

  String? _validarValidade(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite a validade do cartão';
    }
    if (value.length != 5) {
      return 'Formato inválido (MM/AA)';
    }
    final partes = value.split('/');
    final mes = int.tryParse(partes[0]);
    final ano = int.tryParse(partes[1]);

    if (mes == null || ano == null || mes < 1 || mes > 12) {
      return 'Data inválida';
    }

    final agora = DateTime.now();
    final anoCompleto = 2000 + ano;
    final dataVencimento = DateTime(anoCompleto, mes);

    if (dataVencimento.isBefore(DateTime(agora.year, agora.month))) {
      return 'Cartão vencido';
    }

    return null;
  }

  String? _validarCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite o CVV';
    }
    if (value.length < 3 || value.length > 4) {
      return 'CVV inválido';
    }
    return null;
  }

  Future<void> _pagar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => loading = true);
    try {
      final resp = await http.post(
        Uri.parse('http://10.0.2.2:3000/pagamento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'valor': 1990}),
      );
      final data = jsonDecode(resp.body);
      final clientSecret = data['clientSecret'];

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Mais Vida',
      ));
      await Stripe.instance.presentPaymentSheet();
      if (!mounted) return;
      _ok();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    if (!mounted) return;
    setState(() => loading = false);
  }

  void _ok() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text(
          'Pagamento confirmado',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento com Cartão'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho
              const Text(
                'Assinatura Premium',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Valor: R\$ 19,90/mês',
                style: TextStyle(fontSize: 20, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Formulário do Cartão
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.credit_card, color: Color(0xFF0b4c52)),
                        const SizedBox(width: 8),
                        const Text(
                          'Dados do Cartão',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (tipoCartao != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0b4c52),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tipoCartao!,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Número do Cartão
                    TextFormField(
                      controller: _numeroCartaoController,
                      inputFormatters: [_numeroCartaoFormatter],
                      keyboardType: TextInputType.number,
                      validator: _validarNumeroCartao,
                      decoration: const InputDecoration(
                        labelText: 'Número do Cartão',
                        hintText: '1234 5678 9012 3456',
                        prefixIcon: Icon(Icons.credit_card),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nome no Cartão
                    TextFormField(
                      controller: _nomeController,
                      textCapitalization: TextCapitalization.characters,
                      validator: _validarNome,
                      decoration: const InputDecoration(
                        labelText: 'Nome no Cartão',
                        hintText: 'Como está impresso no cartão',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Validade e CVV
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _validadeController,
                            inputFormatters: [_validadeFormatter],
                            keyboardType: TextInputType.number,
                            validator: _validarValidade,
                            decoration: const InputDecoration(
                              labelText: 'Validade',
                              hintText: 'MM/AA',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            inputFormatters: [_cvvFormatter],
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            validator: _validarCVV,
                            decoration: const InputDecoration(
                              labelText: 'CVV',
                              hintText: '123',
                              prefixIcon: Icon(Icons.security),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Informação de Segurança
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0b4c52).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF0b4c52).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.security, color: Color(0xFF0b4c52)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Seus dados são protegidos com criptografia SSL e processados via Stripe',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF0b4c52)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Botão de Pagamento
              if (loading)
                const Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF0b4c52)),
                    SizedBox(height: 16),
                    Text('Processando pagamento...'),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: _pagar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0b4c52),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirmar Pagamento - R\$ 19,90',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

              const SizedBox(height: 16),
              const Text(
                'Após a confirmação, o acesso premium será liberado imediatamente.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
