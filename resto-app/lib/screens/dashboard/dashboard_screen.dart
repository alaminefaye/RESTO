import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/fcm_service.dart';
import '../../models/order.dart';
import '../../utils/formatters.dart';
import '../orders/orders_screen.dart';
import '../tables/tables_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeOrdersCount = 0;
  int _dailyOrderCount = 0;
  double _dailyRevenue = 0.0;
  final OrderService _orderService = OrderService();
  late Timer _timer;
  StreamSubscription? _orderUpdateSubscription;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _startClock();

    // Écouter les mises à jour des commandes via FCM
    _orderUpdateSubscription = FCMService.orderUpdateStream.listen((_) {
      if (mounted) {
        _loadDashboardData();
        // Optionnel: Jouer un petit son ou vibration ici aussi si l'app est ouverte
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nouvelle commande reçue ! 🔔'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _orderUpdateSubscription?.cancel();
    super.dispose();
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  String _getFormattedDate() {
    return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_currentTime);
  }

  String _getFormattedTime() {
    return DateFormat('HH:mm:ss', 'fr_FR').format(_currentTime);
  }

  Future<void> _loadDashboardData() async {
    try {
      // Charger les commandes en cours et l'historique
      final currentOrders = await _orderService.getCurrentOrders();
      final historyOrders = await _orderService.getHistoryOrders();

      final now = DateTime.now();

      // Combiner et filtrer pour aujourd'hui
      final allOrders = [...currentOrders, ...historyOrders];
      final todayOrders = allOrders.where((o) {
        return o.createdAt.year == now.year &&
            o.createdAt.month == now.month &&
            o.createdAt.day == now.day;
      }).toList();

      // Calculer la recette (exclure les annulées)
      double revenue = 0;
      for (var o in todayOrders) {
        if (o.statut != OrderStatus.annulee) {
          revenue += o.montantTotal;
        }
      }

      if (mounted) {
        setState(() {
          _activeOrdersCount = currentOrders.length;
          _dailyOrderCount = todayOrders.length;
          _dailyRevenue = revenue;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement dashboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    // Si pas d'utilisateur, rediriger ou afficher erreur
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Déterminer le rôle principal
    final bool isAdmin = user.hasRole('admin');
    final bool isManager = user.hasRole('manager');
    final bool isServeur = user.hasRole('serveur');
    final bool isCaissier = user.hasRole('caissier');

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER CUSTOM
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DOLCE VITA',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bonjour, ${user.name}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      // Date et Heure
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_getFormattedDate().substring(0, 1).toUpperCase()}${_getFormattedDate().substring(1)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 1,
                              height: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getFormattedTime(),
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orange, width: 2),
                      ),
                      child: const CircleAvatar(
                        backgroundColor: Color(0xFF252525),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // STATS CARD (Pour Admin, Manager, Caissier)
            if (isAdmin || isManager || isCaissier)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      offset: const Offset(4, 4),
                      blurRadius: 8,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.05),
                      offset: const Offset(-2, -2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Statistiques du jour',
                            style: TextStyle(
                              color: Colors.orange[300],
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Commandes',
                          '$_dailyOrderCount',
                          Icons.receipt_long,
                          Colors.blue,
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.grey[800]!,
                                Colors.grey[600]!,
                                Colors.grey[800]!,
                              ],
                            ),
                          ),
                        ),
                        _buildStatItem(
                          'Recette',
                          Formatters.formatCurrency(
                            _dailyRevenue,
                          ).replaceAll(' FCFA', ''),
                          Icons.monetization_on,
                          Colors.green,
                          subtitle: 'FCFA',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // GRID MENU
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    // MENU & COMMANDES
                    _buildDashboardCard(
                      context,
                      'Commandes & Menu',
                      Icons.restaurant_menu,
                      Colors.orange,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const OrdersScreen(showBackButton: true),
                        ),
                      ).then((_) => _loadDashboardData()),
                      badgeCount: _activeOrdersCount,
                    ),

                    // CAISSE & PAIEMENTS
                    if (isCaissier || isManager || isAdmin)
                      _buildDashboardCard(
                        context,
                        'Caisse & Paiements',
                        Icons.point_of_sale,
                        Colors.green,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const OrdersScreen(showBackButton: true),
                          ),
                        ).then((_) => _loadDashboardData()),
                      ),

                    // TABLES
                    if (isServeur || isManager || isAdmin || isCaissier)
                      _buildDashboardCard(
                        context,
                        'Tables',
                        Icons.table_restaurant,
                        Colors.purple,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TablesScreen(),
                          ),
                        ),
                      ),

                    // STATISTIQUES
                    if (isAdmin || isManager)
                      _buildDashboardCard(
                        context,
                        'Statistiques',
                        Icons.bar_chart,
                        Colors.teal,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Module Statistiques en cours de développement',
                              ),
                            ),
                          );
                        },
                      ),

                    // UTILISATEURS
                    if (isAdmin)
                      _buildDashboardCard(
                        context,
                        'Utilisateurs',
                        Icons.people,
                        Colors.indigo,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Module Utilisateurs en cours de développement',
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500], fontSize: 10),
          ),
      ],
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    int badgeCount = 0,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF252525),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 40, color: color),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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
}
