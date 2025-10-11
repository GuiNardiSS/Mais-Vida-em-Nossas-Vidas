import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PagamentoPixPage extends StatefulWidget {
  const PagamentoPixPage({super.key});
  @override
  State<PagamentoPixPage> createState() => _PagamentoPixPageState();
}

class _PagamentoPixPageState extends State<PagamentoPixPage> {
  String? chavePix;
  String? codigoPixCopiaECola;
  bool loading = true;
  bool pagamentoConfirmado = false;
  String? transactionId;

  @override
  void initState() {
    super.initState();
    _gerarPixLocal();
  }

  void _gerarPixLocal() {
    setState(() => loading = true);

    // Simula geração de PIX local
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      final random = Random();
      transactionId = 'TXN${random.nextInt(999999).toString().padLeft(6, '0')}';

      // Gera uma chave PIX aleatória (simulada)
      chavePix = _gerarChavePixAleatoria();

      // Gera código PIX padrão
      codigoPixCopiaECola = _gerarCodigoPixBRCode();

      setState(() => loading = false);
    });
  }

  String _gerarChavePixAleatoria() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(32, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  String _gerarCodigoPixBRCode() {
    // Formato simplificado do BR Code PIX
    final valor = '19.90';
    final cidade = 'SAO PAULO';
    final nomeRecebedor = 'MAIS VIDA EM NOSSAS VIDAS';

    return '00020126580014BR.GOV.BCB.PIX0136$chavePix'
        '520400005303986540$valor'
        '5802BR59${nomeRecebedor.length.toString().padLeft(2, '0')}$nomeRecebedor'
        '60${cidade.length.toString().padLeft(2, '0')}$cidade'
        '62070503***'
        '6304'; // CRC seria calculado aqui
  }

  void _copiarCodigo() async {
    if (codigoPixCopiaECola != null) {
      await Clipboard.setData(ClipboardData(text: codigoPixCopiaECola!));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código PIX copiado para a área de transferência!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _simularPagamento() {
    setState(() => loading = true);

    // Simula verificação de pagamento
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        loading = false;
        pagamentoConfirmado = true;
      });

      _mostrarConfirmacao();
    });
  }

  void _mostrarConfirmacao() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Pagamento confirmado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transação: $transactionId'),
            const SizedBox(height: 8),
            const Text('Valor: R\$ 19,90'),
            const SizedBox(height: 8),
            const Text('Seu acesso premium foi liberado!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha dialog
              Navigator.of(context).pop(); // Volta para tela anterior
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento via PIX'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Modo simulado: após escanear o QR, pressione o botão para confirmar. Exibiremos "Pagamento Confirmado!".',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
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

            if (loading && !pagamentoConfirmado)
              const Column(
                children: [
                  CircularProgressIndicator(color: Color(0xFFa99045)),
                  SizedBox(height: 16),
                  Text('Gerando PIX...'),
                ],
              )
            else if (pagamentoConfirmado)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Pagamento confirmado!',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Transação: $transactionId'),
                    const SizedBox(height: 16),
                    const Text('Seu acesso premium foi liberado com sucesso!'),
                  ],
                ),
              )
            else
              Column(
                children: [
                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Escaneie o QR Code',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: QrImageView(
                            data: codigoPixCopiaECola ?? '',
                            version: QrVersions.auto,
                            size: 200,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: Color(0xFFa99045), size: 16),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Use o app do seu banco para escanear',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Chave PIX
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFa99045).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              const Color(0xFFa99045).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.key, color: Color(0xFFa99045)),
                            SizedBox(width: 8),
                            Text(
                              'Chave PIX Aleatória',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          chavePix ?? '',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Código Copia e Cola
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.content_copy, color: Color(0xFF0b4c52)),
                            SizedBox(width: 8),
                            Text(
                              'Código PIX (Copia e Cola)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: SelectableText(
                            codigoPixCopiaECola ?? '',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _copiarCodigo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0b4c52),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          icon: const Icon(Icons.copy),
                          label: const Text('Copiar Código PIX'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botão de confirmação
                  ElevatedButton.icon(
                    onPressed: loading ? null : _simularPagamento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFa99045),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(
                      loading
                          ? 'Verificando pagamento...'
                          : 'Já realizei o pagamento',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Após realizar o PIX, clique em "Já realizei o pagamento" para confirmar.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
