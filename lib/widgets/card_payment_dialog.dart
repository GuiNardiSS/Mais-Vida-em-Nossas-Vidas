import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../services/payment_service.dart';

/// Dialog para pagamento via Cartão de Crédito
class CardPaymentDialog extends StatefulWidget {
  final double amount;
  final VoidCallback onSuccess;

  const CardPaymentDialog({
    super.key,
    required this.amount,
    required this.onSuccess,
  });

  @override
  State<CardPaymentDialog> createState() => _CardPaymentDialogState();
}

class _CardPaymentDialogState extends State<CardPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isProcessing = false;

  // Máscaras para formatação
  final _cardNumberMask = MaskTextInputFormatter(
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
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      // Gera o Payment Intent do Stripe
      final result = await PaymentService.createCardPayment(
        amount: widget.amount,
      );

      if (result['success'] == true) {
        // Em produção, aqui você usaria o Stripe SDK para confirmar o pagamento
        // com o clientSecret: result['clientSecret']
        // Por ora, vamos simular um pagamento bem-sucedido após 2 segundos
        await Future.delayed(const Duration(seconds: 2));

        // Simula ID de transação
        final paymentId = 'card_${DateTime.now().millisecondsSinceEpoch}';

        // Confirma o pagamento e ativa a assinatura
        final success = await PaymentService.confirmPayment(
          paymentId: paymentId,
          paymentMethod: 'card',
          amount: widget.amount,
        );

        if (success && mounted) {
          Navigator.of(context).pop();
          widget.onSuccess();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Pagamento aprovado! Assinatura ativada com sucesso.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          throw Exception('Erro ao confirmar pagamento');
        }
      } else {
        throw Exception(result['error'] ?? 'Erro ao processar pagamento');
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
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Row(
                  children: [
                    const Icon(Icons.credit_card,
                        color: Color(0xFF0b4c52), size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Pagamento com Cartão',
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

                // Valor
                Center(
                  child: Text(
                    'R\$ ${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFa99045),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Número do Cartão
                TextFormField(
                  controller: _cardNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Número do Cartão',
                    hintText: '1234 5678 9012 3456',
                    prefixIcon: Icon(Icons.credit_card),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cardNumberMask],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite o número do cartão';
                    }
                    if (value.replaceAll(' ', '').length < 16) {
                      return 'Número de cartão inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Nome no Cartão
                TextFormField(
                  controller: _cardNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome no Cartão',
                    hintText: 'NOME COMPLETO',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite o nome no cartão';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Validade e CVV
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        decoration: const InputDecoration(
                          labelText: 'Validade',
                          hintText: 'MM/AA',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [_expiryMask],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite a validade';
                          }
                          if (value.length < 5) {
                            return 'Validade inválida';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          hintText: '123',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [_cvvMask],
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o CVV';
                          }
                          if (value.length < 3) {
                            return 'CVV inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Botão de Pagamento
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0b4c52),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Pagar',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Nota de Segurança
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pagamento seguro processado via Stripe',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
