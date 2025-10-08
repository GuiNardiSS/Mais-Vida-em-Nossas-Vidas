import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PagamentoCartaoPage extends StatefulWidget {
  const PagamentoCartaoPage({super.key});
  @override
  State<PagamentoCartaoPage> createState() => _PagamentoCartaoPageState();
}

class _PagamentoCartaoPageState extends State<PagamentoCartaoPage> {
  bool loading = false;

  Future<void> _pagar() async {
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Assinatura Premium',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Valor: R\$ 19,90/mês',
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Column(
                children: [
                  Icon(Icons.security, size: 48, color: Color(0xFF0b4c52)),
                  SizedBox(height: 12),
                  Text(
                    'Pagamento Seguro',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Processado via Stripe com criptografia de ponta a ponta',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (loading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processando pagamento...'),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: _pagar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0b4c52),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.credit_card),
                label: const Text(
                  'Pagar R\$ 19,90',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Após a confirmação do pagamento, o acesso premium será liberado imediatamente.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
