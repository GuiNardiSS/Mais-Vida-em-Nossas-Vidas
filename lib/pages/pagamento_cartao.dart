
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
    setState(()=>loading=true);
    try {
      final resp = await http.post(
        Uri.parse('http://10.0.2.2:3000/pagamento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'valor': 1990}),
      );
      final data = jsonDecode(resp.body);
      final clientSecret = data['clientSecret'];

      await Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Mais Vida',
      ));
      await Stripe.instance.presentPaymentSheet();
      if (!mounted) return;
      _ok();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    if (!mounted) return;
    setState(()=>loading=false);
  }

  void _ok() {
    showDialog(context: context, builder: (_)=> const AlertDialog(title: Text('Pagamento confirmado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagamento com Cartão')),
      body: Center(
        child: loading ? const CircularProgressIndicator() : ElevatedButton(
          onPressed: _pagar,
          child: const Text('Pagar R\$ 19,90'),
        ),
      ),
    );
  }
}
