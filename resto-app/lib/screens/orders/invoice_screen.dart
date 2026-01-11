import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/invoice.dart';
import '../../models/payment.dart';
import '../../services/invoice_service.dart';
import '../../config/api_config.dart';
import '../../utils/formatters.dart';

class InvoiceScreen extends StatefulWidget {
  final int orderId;

  const InvoiceScreen({super.key, required this.orderId});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  Invoice? _invoice;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _invoiceService.getInvoiceByOrder(widget.orderId);

      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _invoice = result['data'] as Invoice;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Erreur inconnue';
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement de la facture: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors du chargement de la facture: ${e.toString()}';
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.purple.shade900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _invoice != null ? 'Facture #${_invoice!.numeroFacture}' : 'Facture',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_invoice?.pdfUrl != null)
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () {
                // TODO: Implémenter le téléchargement du PDF
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Téléchargement du PDF non implémenté'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              tooltip: 'Télécharger le PDF',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadInvoice,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadInvoice,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : _invoice == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Facture non trouvée',
                            style: TextStyle(color: Colors.grey[300]),
                          ),
                        ],
                      ),
                    )
                  : _buildInvoiceContent(),
    );
  }

  Widget _buildInvoiceContent() {
    final commande = _invoice!.commande;
    final paiement = _invoice!.paiement;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la facture
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.shade900,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'FACTURE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _invoice!.numeroFacture,
                  style: TextStyle(
                    color: Colors.purple.shade200,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  Formatters.formatDateTime(_invoice!.createdAt),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Informations de la commande
          if (commande != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.restaurant, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Informations de la commande',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.table_restaurant,
                    'Table',
                    commande.table != null && commande.table!.numero.isNotEmpty
                        ? 'Table ${commande.table!.numero}'
                        : 'Table non assignée',
                  ),
                  _buildInfoRow(
                    Icons.receipt,
                    'Commande',
                    'Commande #${commande.id}',
                  ),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Date',
                    Formatters.formatDateTime(commande.createdAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Articles commandés
            if (commande.produits != null && commande.produits!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.restaurant_menu, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Articles commandés',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...commande.produits!.map((item) => _buildOrderItem(item)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],

          // Informations de paiement
          if (paiement != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Paiement',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.account_balance_wallet,
                    'Moyen de paiement',
                    _getPaymentMethodName(paiement.moyenPaiement),
                  ),
                  _buildInfoRow(
                    Icons.money,
                    'Montant payé',
                    Formatters.formatCurrency(paiement.montant),
                  ),
                  if (paiement.montantRecu != null && paiement.montantRecu! > paiement.montant)
                    _buildInfoRow(
                      Icons.receipt_long,
                      'Montant reçu',
                      Formatters.formatCurrency(paiement.montantRecu!),
                    ),
                  if (paiement.monnaieRendue != null && paiement.monnaieRendue! > 0)
                    _buildInfoRow(
                      Icons.change_circle,
                      'Monnaie rendue',
                      Formatters.formatCurrency(paiement.monnaieRendue!),
                    ),
                  if (paiement.transactionId != null && paiement.transactionId!.isNotEmpty)
                    _buildInfoRow(
                      Icons.receipt,
                      'Référence transaction',
                      paiement.transactionId!,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Totaux
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.purple.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                if (_invoice!.montantTaxe > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sous-total',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        Formatters.formatCurrency(_invoice!.montantTotal - _invoice!.montantTaxe),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Taxe',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        Formatters.formatCurrency(_invoice!.montantTaxe),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white30, height: 24),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(_invoice!.montantTotal),
                      style: TextStyle(
                        color: Colors.purple.shade300,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Message de remerciement
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Merci pour votre visite !\nNous espérons vous revoir bientôt.',
                    style: TextStyle(
                      color: Colors.green.shade200,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(orderItem) {
    // orderItem est un OrderItem (from Order model)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Image (si disponible)
          if (orderItem.image != null && orderItem.image!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: orderItem.image!.startsWith('http')
                    ? orderItem.image!
                    : '${ApiConfig.serverBaseUrl}/storage/${orderItem.image}',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[700],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[700],
                  child: Icon(Icons.restaurant_menu, size: 20, color: Colors.grey[400]),
                ),
              ),
            )
          else
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.restaurant_menu, size: 20, color: Colors.grey[400]),
            ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderItem.produitNom,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${Formatters.formatCurrency(orderItem.prix)} x ${orderItem.quantite}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
          ),
          // Total
          Text(
            Formatters.formatCurrency(orderItem.total),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName(dynamic moyenPaiement) {
    if (moyenPaiement is PaymentMethod) {
      return moyenPaiement.displayName;
    }
    // Si c'est une string
    switch (moyenPaiement.toString()) {
      case 'especes':
        return 'Espèces';
      case 'wave':
        return 'Wave';
      case 'orange_money':
        return 'Orange Money';
      case 'carte_bancaire':
        return 'Carte Bancaire';
      default:
        return moyenPaiement.toString();
    }
  }
}
