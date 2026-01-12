import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/api_config.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../services/order_service.dart';
import '../../services/menu_service.dart';
import '../../services/payment_service.dart';
import '../../utils/formatters.dart';
import 'payment_screen.dart';
import 'invoice_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  final MenuService _menuService = MenuService();
  final PaymentService _paymentService = PaymentService();
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
          if (_order != null && _order!.statut == OrderStatus.terminee)
            IconButton(
              icon: const Icon(Icons.receipt_long, color: Colors.purple),
              onPressed: _showInvoiceScreen,
              tooltip: 'Reçu',
            ),
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
                        const SizedBox(height: 16),

                        // Boutons d'action
                        if (_order!.statut == OrderStatus.attente && _order!.produits != null && _order!.produits!.isNotEmpty)
                          // Bouton "Lancer la commande" si en attente
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _launchOrder,
                              icon: const Icon(Icons.send, color: Colors.white),
                              label: const Text(
                                'Lancer la commande',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          )
                        else if (_order!.statut == OrderStatus.servie || _order!.statut == OrderStatus.preparation)
                          // Bouton "Payer" si servie ou en préparation
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showPaymentScreen,
                              icon: const Icon(Icons.payment, color: Colors.white),
                              label: const Text(
                                'Payer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
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

    // Charger les catégories et produits disponibles
    List<Category> categories = [];
    List<Product> products = [];
    bool isLoadingProducts = true;

    try {
      final results = await Future.wait([
        _menuService.getCategories(),
        _menuService.getProducts(),
      ]);
      categories = results[0] as List<Category>;
      products = (results[1] as List<Product>).where((p) => p.disponible).toList();
    } catch (e) {
      debugPrint('Erreur lors du chargement des produits: $e');
    } finally {
      isLoadingProducts = false;
    }

    if (!mounted) return;

    // Organiser les produits par catégorie
    Map<int, List<Product>> productsByCategory = {};
    for (var product in products) {
      final categoryId = product.categorieId;
      if (!productsByCategory.containsKey(categoryId)) {
        productsByCategory[categoryId] = [];
      }
      productsByCategory[categoryId]!.add(product);
    }

    // Trier les catégories par ordre
    categories.sort((a, b) => a.ordre.compareTo(b.ordre));

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => _AddProductDialog(
        categories: categories,
        productsByCategory: productsByCategory,
        isLoading: isLoadingProducts,
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

  Future<void> _launchOrder() async {
    if (_order == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Lancer la commande',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Voulez-vous lancer cette commande pour la préparation ?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lancer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );

    final result = await _paymentService.launchOrder(widget.orderId);

    if (!mounted) return;
    Navigator.pop(context); // Fermer le loading

    if (result['success'] == true) {
      // Recharger la commande
      await _loadOrder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande lancée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur lors du lancement'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPaymentScreen() {
    if (_order == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(order: _order!),
      ),
    ).then((_) {
      // Recharger la commande après paiement
      _loadOrder();
    });
  }

  void _showInvoiceScreen() {
    if (_order == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceScreen(orderId: _order!.id),
      ),
    );
  }

}

// Widget pour le dialogue d'ajout de produit
class _AddProductDialog extends StatefulWidget {
  final List<Category> categories;
  final Map<int, List<Product>> productsByCategory;
  final bool isLoading;

  const _AddProductDialog({
    required this.categories,
    required this.productsByCategory,
    required this.isLoading,
  });

  @override
  State<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<_AddProductDialog> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedCategoryId;
  Product? _selectedProduct;
  int _quantity = 1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    String searchQuery = _searchController.text.toLowerCase();
    List<Product> products;

    if (_selectedCategoryId == null) {
      // Tous les produits
      products = widget.productsByCategory.values
          .expand((list) => list)
          .toList();
    } else {
      // Produits de la catégorie sélectionnée
      products = widget.productsByCategory[_selectedCategoryId] ?? [];
    }

    // Filtrer par recherche
    if (searchQuery.isNotEmpty) {
      products = products.where((product) {
        return product.nom.toLowerCase().contains(searchQuery) ||
            (product.description?.toLowerCase().contains(searchQuery) ?? false) ||
            (product.categorieNom?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context, null),
                  ),
                  const Expanded(
                    child: Text(
                      'Ajouter un produit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Espace pour équilibrer
                ],
              ),
            ),

            // Barre de recherche
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[400]),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            // Filtres de catégories
            if (widget.categories.isNotEmpty)
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Bouton "Tous"
                      final isSelected = _selectedCategoryId == null;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: FilterChip(
                          label: const Text('Tous'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryId = null;
                              _selectedProduct = null;
                            });
                          },
                          selectedColor: Colors.orange,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[300],
                            fontWeight: FontWeight.bold,
                          ),
                          backgroundColor: Colors.grey[800],
                        ),
                      );
                    }

                    final category = widget.categories[index - 1];
                    final isSelected = _selectedCategoryId == category.id;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(category.nom),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryId = selected ? category.id : null;
                            _selectedProduct = null;
                          });
                        },
                        selectedColor: Colors.orange,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[300],
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: Colors.grey[800],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Liste des produits
            Expanded(
              child: widget.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                  : _filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun produit trouvé',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            final isSelected = _selectedProduct?.id == product.id;

                            return _buildProductCard(product, isSelected);
                          },
                        ),
            ),

            // Footer avec quantité et bouton d'ajout
            if (_selectedProduct != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Quantité:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Bouton moins
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.orange),
                          onPressed: _quantity > 1
                              ? () {
                                  setState(() {
                                    _quantity--;
                                  });
                                }
                              : null,
                        ),
                        Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Bouton plus
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.orange),
                          onPressed: () {
                            setState(() {
                              _quantity++;
                            });
                          },
                        ),
                        const Spacer(),
                        Text(
                          Formatters.formatCurrency(_selectedProduct!.prix * _quantity),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            'produitId': _selectedProduct!.id,
                            'quantite': _quantity,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Ajouter au panier',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange.withOpacity(0.2) : Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.orange : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedProduct = product;
            _quantity = 1;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image du produit
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: product.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[700],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[700],
                          child: Icon(
                            Icons.restaurant_menu,
                            color: Colors.grey[400],
                            size: 30,
                          ),
                        ),
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[700],
                        child: Icon(
                          Icons.restaurant_menu,
                          color: Colors.grey[400],
                          size: 30,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // Informations du produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nom,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.description != null && product.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.description!,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      Formatters.formatCurrency(product.prix),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Checkbox de sélection
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
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

