import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tables/qr_scan_screen.dart';
import '../orders/cart_screen.dart';
import '../profile/profile_screen.dart';
import '../home/home_screen.dart';
import '../favorites/favorites_screen.dart';
import '../auth/login_screen.dart';
import '../../models/cart.dart';
import '../../models/favorites.dart';
import '../../services/auth_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _currentIndex = 0;

  List<Widget> _buildScreens(BuildContext context) {
    final favorites = Provider.of<Favorites>(context, listen: false);
    return [
      const HomeScreen(), // Index 0 - Accueil
      FavoritesScreen(key: ValueKey('favorites_${favorites.count}')), // Index 1 - Favoris avec clé unique
      const SizedBox.shrink(), // Index 2 - Non utilisé
      const CartScreen(tableId: null), // Index 3 - Panier
      const ProfileScreen(), // Index 4 - Profil
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Favorites>(
      builder: (context, favorites, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey[900],
            elevation: 0,
            title: Text(
              _currentIndex == 1
                  ? 'Favoris'
                  : _currentIndex == 3
                      ? 'Panier'
                      : _currentIndex == 4
                          ? 'Mon Profil'
                          : 'Resto App',
              style: const TextStyle(color: Colors.white),
            ),
            actions: _currentIndex == 1
                ? [] // Pas d'actions pour la page favoris
                : _currentIndex == 4
                    ? [
                        // Bouton de déconnexion pour la page profil
                        TextButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.red, size: 20),
                  label: const Text(
                    'Déconnexion',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    final authService = Provider.of<AuthService>(context, listen: false);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text(
                          'Déconnexion',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          'Êtes-vous sûr de vouloir vous déconnecter ?',
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
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Déconnexion',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      await authService.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    }
                  },
                        ),
                      ]
                    : _currentIndex == 3
                        ? [
                            // Bouton vider le panier
                            Consumer<Cart>(
                      builder: (context, cart, _) {
                        if (cart.isNotEmpty) {
                          return IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Colors.grey[800],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text(
                                    'Vider le panier',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: const Text(
                                    'Êtes-vous sûr de vouloir vider votre panier ?',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'Annuler',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        cart.clear();
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'Vider',
                                        style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                                ),
                              );
                            },
                            tooltip: 'Vider le panier',
                  );
              }
              return const SizedBox.shrink();
            },
          ),
                          ]
                        : [
          IconButton(
                              icon: const Icon(Icons.qr_code_scanner, color: Colors.orange),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrScanScreen()),
              );
            },
            tooltip: 'Scanner QR Code',
          ),
                          ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: _buildScreens(context),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Chariot (Panier)
                    _buildNavItem(Icons.shopping_cart, _currentIndex == 3, () {
                      setState(() => _currentIndex = 3);
                    }, isCart: true),
                    // Accueil
                    _buildNavItem(Icons.home, _currentIndex == 0, () {
                      setState(() => _currentIndex = 0);
                    }, isHome: true),
                    // Favoris
                    _buildNavItem(Icons.favorite, _currentIndex == 1, () {
                      setState(() => _currentIndex = 1);
                    }),
                    // Profil
                    _buildNavItem(Icons.person, _currentIndex == 4, () {
                      setState(() => _currentIndex = 4);
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    IconData icon,
    bool isSelected,
    VoidCallback onTap, {
    bool isCart = false,
    bool isHome = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(isHome ? 16 : 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(isHome ? 16 : 12),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.orange : Colors.grey[400],
              size: isHome ? 28 : 24,
              ),
            ),
          if (isCart)
            Consumer<Cart>(
              builder: (context, cart, _) {
                if (cart.itemCount > 0) {
                  return Positioned(
                    right: isHome ? 12 : 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
    );
  }
}

