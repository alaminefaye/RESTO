import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tables/qr_scan_screen.dart';
import '../orders/cart_screen.dart';
import '../profile/profile_screen.dart';
import '../home/home_screen.dart';
import '../../models/cart.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(), // Index 0 - Accueil
    const SizedBox.shrink(), // Index 1 - Non utilisé
    const SizedBox.shrink(), // Index 2 - Non utilisé
    const CartScreen(tableId: null), // Index 3 - Panier
    const ProfileScreen(), // Index 4 - Profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900], // Couleur du projet (gris foncé)
        elevation: 0,
        title: Text(
          _currentIndex == 4 ? 'Mon Profil' : 'Resto App',
          style: const TextStyle(color: Colors.white),
        ),
        actions: _currentIndex == 4
            ? [] // Pas d'actions pour la page profil
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
        children: _screens,
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
                // Accueil (au milieu)
                _buildNavItem(Icons.home, _currentIndex == 0, () {
                  setState(() => _currentIndex = 0);
                }, isHome: true),
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

