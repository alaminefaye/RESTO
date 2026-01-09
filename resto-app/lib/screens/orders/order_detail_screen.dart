import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/api_config.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../services/order_service.dart';
import '../../services/menu_service.dart';
import '../../utils/formatters.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  final MenuService _menuService = MenuService();
  Order? _order;
  bool _isLoading = true;
  bool _canAddProducts = true; // Vérifier si la commande peut être modifiée

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final order = await _orderService.getOrder(widget.orderId);

      if (mounted) {
        setState(() {
          _order = order;
          _isLoading = false;
          // La commande peut être modifiée si elle est en attente ou en préparation
          _canAddProducts = order != null && 
              (order.statut == OrderStatus.attente || 
               order.statut == OrderStatus.preparation);
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement de la commande: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        title: Text(
          'Commande #${widget.orderId}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_order != null && _canAddProducts)
            IconButton(
              icon: const Icon(Icons.add_shopping_cart, color: Colors.orange),
              onPressed: _showAddProductDialog,
              tooltip: 'Ajouter un produit',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadOrder,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : _order == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Commande non trouvée',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Impossible de charger les détails de la commande',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadOrder,
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
              : RefreshIndicator(
                  onRefresh: _loadOrder,
                  color: Colors.orange,
                  backgroundColor: Colors.grey[800],
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Statut
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Statut',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(_order!.statut),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  _order!.statut.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Informations
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informations',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.table_restaurant,
                                'Table',
                                _order!.table != null && 
                                        _order!.table!.numero.isNotEmpty
                                    ? 'Table ${_order!.table!.numero}'
                                    : _order!.tableId > 0
                                        ? 'Table ${_order!.tableId}'
                                        : 'Table non assignée',
                              ),
                              _buildInfoRow(
                                Icons.calendar_today,
                                'Date',
                                Formatters.formatDateTime(_order!.createdAt),
                              ),
                              if (_order!.updatedAt != null)
                                _buildInfoRow(
                                  Icons.update,
                                  'Dernière mise à jour',
                                  Formatters.formatDateTime(_order!.updatedAt!),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Produits
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Articles',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_order!.produits != null && _order!.produits!.isNotEmpty)
                                ..._order!.produits!.map((item) => _buildProductItem(item))
                              else
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'Aucun article',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              if (_canAddProducts) ...[
                                const SizedBox(height: 12),
                                const Divider(color: Colors.grey),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _showAddProductDialog,
                                    icon: const Icon(Icons.add, color: Colors.orange),
                                    label: const Text(
                                      'Ajouter un produit',
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.orange),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Total
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                Formatters.formatCurrency(_order!.montantTotal),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
            child: Icon(icon, size: 20, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.image != null && item.image!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item.image!.startsWith('http')
                        ? item.image!
                        : '${ApiConfig.serverBaseUrl}/storage/${item.image}',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[700],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[700],
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 24,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[700],
                    child: const Icon(
                      Icons.restaurant_menu,
                      size: 24,
                      color: Colors.grey,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.produitNom,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${Formatters.formatCurrency(item.prix)} x ${item.quantite}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Total
          Text(
            Formatters.formatCurrency(item.total),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.attente:
        return Colors.orange.shade700;
      case OrderStatus.preparation:
        return Colors.blue.shade700;
      case OrderStatus.servie:
        return Colors.purple.shade700;
      case OrderStatus.terminee:
        return Colors.green.shade700;
      case OrderStatus.annulee:
        return Colors.red.shade700;
    }
  }

  Future<void> _showAddProductDialog() async {
    if (_order == null) return;

    // Charger les produits disponibles
    List<Product> products = [];
    bool isLoadingProducts = true;

    try {
      products = await _menuService.getProducts();
      products = products.where((p) => p.disponible).toList();
    } catch (e) {
      debugPrint('Erreur lors du chargement des produits: $e');
    } finally {
      isLoadingProducts = false;
    }

    if (!mounted) return;

    int? selectedProductId;
    final quantityController = TextEditingController(text: '1');

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Ajouter un produit',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: isLoadingProducts
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? const Text(
                        'Aucun produit disponible',
                        style: TextStyle(color: Colors.grey),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Sélection du produit
                          DropdownButtonFormField<int>(
                            value: selectedProductId,
                            decoration: InputDecoration(
                              labelText: 'Produit',
                              labelStyle: const TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[700],
                            ),
                            dropdownColor: Colors.grey[700],
                            style: const TextStyle(color: Colors.white),
                            items: products.map((product) {
                              return DropdownMenuItem<int>(
                                value: product.id,
                                child: Text(product.nom),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedProductId = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          // Quantité
                          TextFormField(
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Quantité',
                              labelStyle: const TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[700],
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                quantityController.dispose();
                Navigator.pop(context, null);
              },
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            if (!isLoadingProducts && products.isNotEmpty)
              ElevatedButton(
                onPressed: selectedProductId == null
                    ? null
                    : () {
                        final quantity = int.tryParse(quantityController.text) ?? 1;
                        quantityController.dispose();
                        Navigator.pop(context, {
                          'produitId': selectedProductId,
                          'quantite': quantity,
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ajouter'),
              ),
          ],
        ),
      ),
    );

    if (result != null && result['produitId'] != null && result['quantite'] != null) {
      final produitId = result['produitId'] as int;
      final quantite = result['quantite'] as int;
      if (quantite > 0) {
        await _addProductToOrder(produitId, quantite);
      }
    }
  }

  Future<void> _addProductToOrder(int produitId, int quantite) async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );

    final result = await _orderService.addProductToOrder(
      orderId: widget.orderId,
      produitId: produitId,
      quantite: quantite,
    );

    if (!mounted) return;
    Navigator.pop(context); // Fermer le loading

    if (result['success'] == true) {
      // Recharger la commande
      await _loadOrder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit ajouté avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur lors de l\'ajout'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}

