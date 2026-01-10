import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/payment.dart';
import '../../services/payment_service.dart';
import '../../services/auth_service.dart';
import '../../utils/formatters.dart';

class PaymentScreen extends StatefulWidget {
  final Order order;

  const PaymentScreen({super.key, required this.order});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  PaymentMethod? _selectedPaymentMethod;
  final TextEditingController _transactionIdController = TextEditingController();
  final TextEditingController _amountReceivedController = TextEditingController();
  bool _isProcessing = false;
  bool _isClient = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _amountReceivedController.text = widget.order.montantTotal.toStringAsFixed(0);
  }

  Future<void> _checkUserRole() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      setState(() {
        _isClient = user.roles.contains('client');
      });
    }
  }

  @override
  void dispose() {
    _transactionIdController.dispose();
    _amountReceivedController.dispose();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un mode de paiement'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Pour Wave et Orange Money, le client peut initier
    if (_isClient && ![_selectedPaymentMethod!.value, PaymentMethod.wave.value, PaymentMethod.orangeMoney.value].contains(_selectedPaymentMethod!.value)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pour le paiement en espèces, veuillez contacter le serveur'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Pour espèces (gérant uniquement), utiliser payerEspeces
    if (_selectedPaymentMethod == PaymentMethod.especes && !_isClient) {
      final montantRecu = double.tryParse(_amountReceivedController.text) ?? 0.0;
      if (montantRecu < widget.order.montantTotal) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Le montant reçu (${Formatters.formatCurrency(montantRecu)}) est inférieur au montant total (${Formatters.formatCurrency(widget.order.montantTotal)})'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final result = await _paymentService.payCash(
        commandeId: widget.order.id,
        montantRecu: montantRecu,
      );

      setState(() {
        _isProcessing = false;
      });

      if (result['success'] == true && mounted) {
        final monnaieRendue = result['monnaie_rendue'] as double? ?? 0.0;
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paiement espèces effectué ! Monnaie rendue: ${Formatters.formatCurrency(monnaieRendue)}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur lors du paiement'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Pour Wave et Orange Money
    if (_selectedPaymentMethod == PaymentMethod.wave || _selectedPaymentMethod == PaymentMethod.orangeMoney) {
      // Vérifier que transaction_id est fourni
      if (_transactionIdController.text.isEmpty) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez saisir le numéro de transaction'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Initier le paiement
      final result = await _paymentService.initiatePayment(
        commandeId: widget.order.id,
        moyenPaiement: _selectedPaymentMethod!,
        transactionId: _transactionIdController.text.trim(),
      );

      if (result['success'] == true && mounted) {
        final payment = result['data'] as Payment;
        
        // Si c'est le client, confirmer immédiatement
        if (_isClient) {
          final confirmResult = await _paymentService.confirmPayment(
            paymentId: payment.id,
            transactionId: _transactionIdController.text.trim(),
          );

          setState(() {
            _isProcessing = false;
          });

          if (confirmResult['success'] == true && mounted) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Paiement confirmé ! En attente de validation par le gérant.'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(confirmResult['message'] ?? 'Erreur lors de la confirmation'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Gérant : valider directement
          final validateResult = await _paymentService.validatePayment(payment.id);
          
          setState(() {
            _isProcessing = false;
          });

          if (validateResult['success'] == true && mounted) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Paiement validé avec succès !'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(validateResult['message'] ?? 'Erreur lors de la validation'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        setState(() {
          _isProcessing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Erreur lors de l\'initiation du paiement'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }

    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Paiement - Commande #${widget.order.id}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Montant à payer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Montant à payer:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(widget.order.montantTotal),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sélection du mode de paiement
            const Text(
              'Mode de paiement',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Options de paiement
            _buildPaymentMethodOption(
              PaymentMethod.wave,
              'Wave',
              'Paiement mobile via Wave',
              Icons.phone_android,
            ),
            _buildPaymentMethodOption(
              PaymentMethod.orangeMoney,
              'Orange Money',
              'Paiement mobile via Orange Money',
              Icons.phone_android,
            ),
            if (!_isClient)
              _buildPaymentMethodOption(
                PaymentMethod.especes,
                'Espèces',
                'Paiement en espèces (gérant uniquement)',
                Icons.money,
              ),

            const SizedBox(height: 24),

            // Champs conditionnels selon le mode de paiement
            if (_selectedPaymentMethod == PaymentMethod.wave || _selectedPaymentMethod == PaymentMethod.orangeMoney) ...[
              TextField(
                controller: _transactionIdController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Numéro de transaction',
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: 'Entrez le numéro de transaction',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.receipt, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_selectedPaymentMethod == PaymentMethod.especes && !_isClient) ...[
              TextField(
                controller: _amountReceivedController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant reçu',
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: 'Montant reçu du client',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.money, color: Colors.orange),
                  suffixText: 'FCFA',
                  suffixStyle: TextStyle(color: Colors.grey[400]),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              if (_amountReceivedController.text.isNotEmpty)
                Builder(
                  builder: (context) {
                    final montantRecu = double.tryParse(_amountReceivedController.text) ?? 0.0;
                    final difference = montantRecu - widget.order.montantTotal;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: difference >= 0 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            difference >= 0 ? Icons.check_circle : Icons.error,
                            color: difference >= 0 ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              difference >= 0
                                  ? 'Monnaie à rendre: ${Formatters.formatCurrency(difference)}'
                                  : 'Montant insuffisant: ${Formatters.formatCurrency(-difference)}',
                              style: TextStyle(
                                color: difference >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],

            const SizedBox(height: 32),

            // Bouton de paiement
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing || _selectedPaymentMethod == null
                    ? null
                    : _initiatePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[700],
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Procéder au paiement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(
    PaymentMethod method,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedPaymentMethod == method;
    final isDisabled = _isClient && method == PaymentMethod.especes;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isDisabled ? null : () {
          setState(() {
            _selectedPaymentMethod = method;
            if (method != PaymentMethod.especes) {
              _amountReceivedController.clear();
            } else {
              _amountReceivedController.text = widget.order.montantTotal.toStringAsFixed(0);
            }
            if (method == PaymentMethod.especes) {
              _transactionIdController.clear();
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDisabled 
                ? (isSelected ? Colors.orange.withOpacity(0.1) : Colors.grey[800]!.withOpacity(0.5))
                : (isSelected ? Colors.orange.withOpacity(0.2) : Colors.grey[800]!),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.orange : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange.withOpacity(0.2) : Colors.grey[700],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.orange : Colors.grey[400],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[300],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
