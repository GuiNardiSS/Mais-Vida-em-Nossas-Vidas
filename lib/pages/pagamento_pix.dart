
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PagamentoPixPage extends StatefulWidget {
  const PagamentoPixPage({super.key});
  @override
  State<PagamentoPixPage> createState() => _PagamentoPixPageState();
}

class _PagamentoPixPageState extends State<PagamentoPixPage> {
  String? copiaCola;
  Uint8List? qrBytes;

  Future<void> _gerar() async {
    final resp = await http.post(
      Uri.parse('http://10.0.2.2:3000/pix/gerar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'valor': 1990}),
    );
    if (!mounted) return;
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      copiaCola = data['copiaECola'];
      final b64 = (data['imagemQrCode'] as String).split(',').last;
      qrBytes = base64Decode(b64);
      setState((){});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao gerar Pix')));
    }
  }

  @override
  void initState() {
    super.initState();
    _gerar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagamento via Pix')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: qrBytes == null ? const Center(child: CircularProgressIndicator()) : Column(
          children: [
            Image.memory(qrBytes!),
            const SizedBox(height: 12),
            SelectableText(copiaCola ?? ''),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: (){}, child: const Text('Já paguei')),
          ],
        ),
      ),
    );
  }
}
