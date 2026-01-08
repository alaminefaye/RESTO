import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/cart.dart';
import '../../services/menu_service.dart';
import '../../services/auth_service.dart';
import '../../utils/formatters.dart';
import '../menu/products_screen.dart';
import '../menu/product_detail_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MenuService _menuService = MenuService();
  List<Category> _categories = [];
  List<Product> _products = [];
  int? _selectedCategoryId;
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _menuService.getCategories(),
        _menuService.getProducts(),
      ]);

      if (mounted) {
        setState(() {
          _categories = results[0] as List<Category>;
          _products = results[1] as List<Product>;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Product> get _filteredProducts {
    if (_selectedCategoryId != null) {
      return _products
          .where((p) => p.categorieId == _selectedCategoryId && p.disponible)
          .toList();
    }
    return _products.where((p) => p.disponible).toList();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userName = authService.currentUser?.name ?? 'Guest';
    final userPhone = authService.currentUser?.phone ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Fond sombre
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header avec salutation et profil
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Photo de profil
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfileScreen(),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey[800],
                                child: userPhone.isNotEmpty
                                    ? Text(
                                        userPhone[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : const Icon(Icons.person, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Barre de recherche
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Find your dishes',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                                  suffixIcon: Icon(Icons.tune, color: Colors.grey[500]),
                                  filled: true,
                                  fillColor: Colors.grey[900],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value.toLowerCase();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Section Categories
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Categories',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProductsScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'All →',
                                style: TextStyle(color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Liste horizontale des catégories
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: _categories.length + 1, // +1 pour "All"
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // Bouton "All"
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: FilterChip(
                                  label: const Text('All'),
                                  selected: _selectedCategoryId == null,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedCategoryId = null;
                                    });
                                  },
                                  selectedColor: Colors.orange,
                                  labelStyle: TextStyle(
                                    color: _selectedCategoryId == null
                                        ? Colors.white
                                        : Colors.grey[300],
                                    fontWeight: FontWeight.bold,
                                  ),
                                  backgroundColor: Colors.grey[800],
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                              );
                            }

                            final category = _categories[index - 1];
                            final isSelected = _selectedCategoryId == category.id;

                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: FilterChip(
                                avatar: Text(
                                  _getCategoryEmoji(category.nom),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                label: Text(category.nom),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategoryId = selected ? category.id : null;
                                  });
                                },
                                selectedColor: Colors.orange,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[300],
                                  fontWeight: FontWeight.bold,
                                ),
                                backgroundColor: Colors.grey[800],
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Section New Dishes
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'New dishes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProductsScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'All →',
                                style: TextStyle(color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Grille de produits
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: _buildProductsGrid(),
                      ),

                      const SizedBox(height: 20), // Espace en bas
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    final filtered = _searchQuery.isEmpty
        ? _filteredProducts
        : _filteredProducts
            .where((p) => p.nom.toLowerCase().contains(_searchQuery))
            .toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text(
            'No dishes found',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.78, // Augmenté pour des cartes plus compactes
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final product = filtered[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        // Navigation vers les détails du produit
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du produit (sans bordure)
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Hero(
                tag: 'product_${product.id}',
                child: product.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[800],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.restaurant_menu, color: Colors.grey, size: 36),
                        ),
                      )
                    : Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.restaurant_menu,
                            size: 36, color: Colors.grey),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Info du produit
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.nom,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 12),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          '4.8(163)',
                          style: TextStyle(color: Colors.grey[400], fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.access_time, color: Colors.grey, size: 12),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          '20 min',
                          style: TextStyle(color: Colors.grey[400], fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          Formatters.formatCurrency(product.prix),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Bouton Ajouter - stoppe la propagation du tap
                      AbsorbPointer(
                        absorbing: false,
                        child: GestureDetector(
                          onTap: product.disponible
                              ? () {
                                  _addToCart(product);
                                }
                              : null,
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (_) {
                            // Capture le tapDown pour stopper la propagation
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: product.disponible
                                  ? Colors.orange
                                  : Colors.grey[700],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add_shopping_cart,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _addToCart(Product product) {
    if (!product.disponible) return;

    try {
      final cart = Provider.of<Cart>(context, listen: false);
      cart.addProduct(product);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.nom} added to cart'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout au panier: $e');
    }
  }

  String _getCategoryEmoji(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('burger')) return '🍔';
    if (name.contains('pizza')) return '🍕';
    if (name.contains('sandwich')) return '🌭';
    if (name.contains('boisson') || name.contains('drink')) return '🥤';
    if (name.contains('dessert')) return '🍰';
    if (name.contains('salad')) return '🥗';
    if (name.contains('entrée') || name.contains('entree')) return '🥗';
    if (name.contains('plat') || name.contains('main')) return '🍽️';
    if (name.contains('grillade')) return '🥩';
    return '🍴';
  }
}
