import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/payment_service.dart';

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
  String? _qrCodeText;
  String? _errorMessage;
  String? _paymentId;

  @override
  void initState() {
    super.initState();
    _generatePixPayment();
  }

  Future<void> _generatePixPayment() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await PaymentService.generatePixPayment(
        amount: widget.amount,
      );

      if (result['success'] == true) {
        setState(() {
          _qrCodeText = result['qrCodeText'];
          // _qrCodeImage = result['qrCodeImage']; // Disponível se necessário
          _paymentId = 'pix_${DateTime.now().millisecondsSinceEpoch}';
          _isLoading = false;
        });

        // Simula verificação de pagamento (em produção, usar webhook)
        _startPaymentMonitoring();
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = result['error'] ?? 'Erro ao gerar PIX';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Erro de conexão: $e';
        _isLoading = false;
      });
    }
  }

  void _startPaymentMonitoring() {
    // Em produção, isso seria feito via webhook ou polling do backend
    // Por ora, vamos simular com um botão de confirmação manual
  }

  Future<void> _confirmPayment() async {
    if (_paymentId == null) return;

    setState(() => _isLoading = true);

    try {
      final success = await PaymentService.confirmPayment(
        paymentId: _paymentId!,
        paymentMethod: 'pix',
        amount: widget.amount,
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onSuccess();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Pagamento confirmado! Assinatura ativada com sucesso.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao confirmar pagamento. Tente novamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _copyToClipboard() {
    if (_qrCodeText != null) {
      Clipboard.setData(ClipboardData(text: _qrCodeText!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código PIX copiado!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
                      data: _qrCodeText ?? '',
                      version: QrVersions.auto,
                      size: 200,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Instruções
                  const Text(
                    'Escaneie o QR Code no app do seu banco',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Botão Copiar e Colar
                  OutlinedButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar código PIX'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botão Confirmar Pagamento (simulação)
                  ElevatedButton.icon(
                    onPressed: _confirmPayment,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Já paguei'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0b4c52),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nota
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Após realizar o pagamento, clique em "Já paguei" para ativar sua assinatura.',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
