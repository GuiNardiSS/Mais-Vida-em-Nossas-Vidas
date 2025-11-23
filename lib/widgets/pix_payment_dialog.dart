import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/payment_service.dart';
import 'dart:convert';

/// Dialog para pagamento via PIX
class PixPaymentDialog extends StatefulWidget {
  final double amount;
  final VoidCallback onSuccess;

  const PixPaymentDialog({
    super.key,
    required this.amount,
    required this.onSuccess,
  });

  @override
  State<PixPaymentDialog> createState() => _PixPaymentDialogState();
}

class _PixPaymentDialogState extends State<PixPaymentDialog> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _qrCodePayload; // O código "Copia e Cola" completo
  String? _pixKeyDisplay; // A chave para exibição
  String? _errorMessage;
  String? _paymentId;
  final TextEditingController _codeController = TextEditingController();
  bool _isVerifyingCode = false;

  // Chave PIX fixa fornecida
  static const String _staticPixKey = '0b0437c5-82c1-4351-974b-4cc35dcdd551';

  // Códigos de ativação válidos (hardcoded para funcionamento sem backend)
  static const List<String> _validCodes = [
    'MAISVIDA2025',
    'LUZ2025',
    'GRATIDAO',
    'AMOR',
    'PROSPERIDADE'
  ];

  @override
  void initState() {
    super.initState();
    _generatePixPayment();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _generatePixPayment() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // Simula um pequeno delay para parecer processamento
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Gera o payload BR Code válido
      final payload = _generateBrCode(
        key: _staticPixKey,
        amount: widget.amount.toStringAsFixed(2),
        name: 'MAIS VIDA APP', // Nome do recebedor (max 25 chars)
        city: 'SAO PAULO', // Cidade do recebedor (max 15 chars)
      );

      setState(() {
        _qrCodePayload = payload;
        _pixKeyDisplay = _staticPixKey;
        _paymentId = 'pix_${DateTime.now().millisecondsSinceEpoch}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Erro ao gerar PIX: $e';
        _isLoading = false;
      });
    }
  }

  /// Gera o payload do Pix (BR Code)
  String _generateBrCode({
    required String key,
    required String amount,
    required String name,
    required String city,
  }) {
    final StringBuffer sb = StringBuffer();

    // Payload Format Indicator
    sb.write(_formatField('00', '01'));
    // Point of Initiation Method (12 = Dynamic)
    sb.write(_formatField('01', '12'));

    // Merchant Account Information (GUI + Key)
    final StringBuffer merchantInfo = StringBuffer();
    merchantInfo.write(_formatField('00', 'br.gov.bcb.pix'));
    merchantInfo.write(_formatField('01', key));
    sb.write(_formatField('26', merchantInfo.toString()));

    // Merchant Category Code (0000 = Not specified / General)
    sb.write(_formatField('52', '0000'));

    // Transaction Currency (986 = BRL)
    sb.write(_formatField('53', '986'));

    // Transaction Amount
    sb.write(_formatField('54', amount));

    // Country Code
    sb.write(_formatField('58', 'BR'));

    // Merchant Name
    sb.write(_formatField('59', name));

    // Merchant City
    sb.write(_formatField('60', city));

    // Additional Data Field Template (TxID)
    final StringBuffer additionalData = StringBuffer();
    additionalData.write(
        _formatField('05', '***')); // *** = Auto generated TxID or specific
    sb.write(_formatField('62', additionalData.toString()));

    // CRC16
    final String payloadWithoutCrc = '${sb.toString()}6304';
    final String crc = _calculateCRC16(payloadWithoutCrc);

    return payloadWithoutCrc + crc;
  }

  String _formatField(String id, String value) {
    final String len = value.length.toString().padLeft(2, '0');
    return '$id$len$value';
  }

  String _calculateCRC16(String payload) {
    int crc = 0xFFFF;
    final List<int> bytes = utf8.encode(payload);

    for (final int byte in bytes) {
      crc ^= byte << 8;
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = (crc << 1) ^ 0x1021;
        } else {
          crc = crc << 1;
        }
      }
      crc &= 0xFFFF;
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }

  Future<void> _sendReceiptViaWhatsApp() async {
    const phoneNumber = '5511999999999'; // Substitua pelo número real
    final message =
        'Olá! Realizei o pagamento da assinatura do app Mais Vida em Nossas Vidas. Segue o comprovante. Aguardo meu código de ativação.';
    final url =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
        );
      }
    }
  }

  Future<void> _verifyCodeAndActivate() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o código de ativação')),
      );
      return;
    }

    setState(() => _isVerifyingCode = true);
    await Future.delayed(const Duration(seconds: 1)); // Simula verificação

    if (_validCodes.contains(code)) {
      // Código válido! Ativa a assinatura
      if (_paymentId == null) return;

      try {
        final success = await PaymentService.confirmPayment(
          paymentId: _paymentId!,
          paymentMethod: 'pix_code_$code',
          amount: widget.amount,
        );

        if (success) {
          if (mounted) {
            Navigator.of(context).pop();
            widget.onSuccess();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Código válido! Assinatura ativada com sucesso.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao ativar: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código inválido. Verifique e tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isVerifyingCode = false);
    }
  }

  void _copyPayload() {
    if (_qrCodePayload != null) {
      Clipboard.setData(ClipboardData(text: _qrCodePayload!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código Pix Copia e Cola copiado!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _copyKey() {
    if (_pixKeyDisplay != null) {
      Clipboard.setData(ClipboardData(text: _pixKeyDisplay!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chave Pix copiada!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              Row(
                children: [
                  const Icon(Icons.pix, color: Color(0xFF0b4c52), size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Pagamento via PIX',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Conteúdo
              if (_isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Gerando código PIX...'),
                  ],
                )
              else if (_hasError)
                Column(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage ?? 'Erro ao gerar PIX',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _generatePixPayment,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar Novamente'),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    // Valor
                    Text(
                      'R\$ ${widget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFa99045),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: QrImageView(
                        data: _qrCodePayload ?? '',
                        version: QrVersions.auto,
                        size: 180,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botões de Cópia
                    OutlinedButton.icon(
                      onPressed: _copyPayload,
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copiar Código Pix'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _copyKey,
                      icon: const Icon(Icons.key, size: 16),
                      label: Text('Copiar chave: $_pixKeyDisplay'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                    ),

                    const Divider(height: 32),

                    // Seção de Validação Manual
                    const Text(
                      'Validação do Pagamento',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Envie o comprovante pelo WhatsApp.\n2. Receba seu código de ativação.\n3. Digite o código abaixo para liberar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Botão WhatsApp
                    ElevatedButton.icon(
                      onPressed: _sendReceiptViaWhatsApp,
                      icon: const Icon(Icons.chat),
                      label: const Text('Enviar Comprovante'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo de Código
                    TextField(
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Código de Ativação',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.check_circle,
                              color: Color(0xFF0b4c52)),
                          onPressed:
                              _isVerifyingCode ? null : _verifyCodeAndActivate,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isVerifyingCode) const LinearProgressIndicator(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
