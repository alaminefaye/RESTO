import 'package:flutter/material.dart';
import '../../models/reservation.dart';
import '../../services/reservation_service.dart';
import '../../utils/formatters.dart';
import 'create_reservation_screen.dart';
import 'reservation_detail_screen.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final ReservationService _reservationService = ReservationService();
  List<Reservation> _reservations = [];
  bool _isLoading = true;
  String _filter = 'all'; // all, a_venir, attente, confirmee

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      bool? aVenir;
      String? statut;
      
      if (_filter == 'a_venir') {
        aVenir = true;
      } else if (_filter != 'all') {
        statut = _filter;
      }

      final reservations = await _reservationService.getReservations(
        statut: statut,
        aVenir: aVenir,
      );

      if (mounted) {
        setState(() {
          _reservations = reservations;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des réservations: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // New 3D Dark Theme
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Deep dark background
      body: SafeArea(
        child: Column(
          children: [
            // Custom 3D AppBar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Réservations',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _build3DIconButton(
                            icon: Icons.add,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateReservationScreen(),
                                ),
                              );
                              if (result == true) {
                                _loadReservations();
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          _build3DIconButton(
                            icon: Icons.refresh,
                            onTap: _loadReservations,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _build3DFilterChip('all', 'Toutes'),
                        const SizedBox(width: 12),
                        _build3DFilterChip('a_venir', 'À venir'),
                        const SizedBox(width: 12),
                        _build3DFilterChip('attente', 'En attente'),
                        const SizedBox(width: 12),
                        _build3DFilterChip('confirmee', 'Confirmées'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.orange,
                      ),
                    )
                  : _reservations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF252525),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      offset: const Offset(8, 8),
                                      blurRadius: 16,
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      offset: const Offset(-6, -6),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.event_busy,
                                  size: 60,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'Aucune réservation',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      offset: const Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Vos réservations apparaîtront ici',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadReservations,
                          color: Colors.orange,
                          backgroundColor: const Color(0xFF1E1E1E),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _reservations.length,
                            itemBuilder: (context, index) {
                              final reservation = _reservations[index];
                              return _buildReservationCard(context, reservation);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DIconButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF252525),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: const Offset(4, 4),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                offset: const Offset(-2, -2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.orange, size: 22),
        ),
      ),
    );
  }

  Widget _build3DFilterChip(String value, String label) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filter = value;
        });
        _loadReservations();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : const Color(0xFF252525),
          borderRadius: BorderRadius.circular(30),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange, Colors.deepOrange],
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.4),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.05),
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontWeight: FontWeight.bold,
            fontSize: 14,
            shadows: isSelected
                ? [
                    const Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    )
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildReservationCard(BuildContext context, Reservation reservation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(8, 8),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.05),
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReservationDetailScreen(
                  reservationId: reservation.id,
                ),
              ),
            ).then((_) => _loadReservations());
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.05),
                                offset: const Offset(-2, -2),
                                blurRadius: 4,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                offset: const Offset(3, 3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.table_restaurant,
                            color: Colors.orange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reservation.table != null
                                  ? 'Table ${reservation.table!.numero}'
                                  : 'Réservation #${reservation.id}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (reservation.table != null)
                              Text(
                                reservation.table!.type.displayName,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(reservation.statut).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(reservation.statut).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        reservation.statut.displayName,
                        style: TextStyle(
                          color: _getStatusColor(reservation.statut),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.02),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(Icons.calendar_today, Formatters.formatDate(reservation.dateReservation)),
                      _buildVerticalDivider(),
                      _buildInfoItem(Icons.access_time, '${reservation.heureDebut} - ${reservation.heureFin ?? 'N/A'}'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(Icons.people, size: 16, color: Colors.grey[400]),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${reservation.nombrePersonnes} personne(s)',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      Formatters.formatCurrency(reservation.prixTotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.orange,
                        shadows: [
                          Shadow(
                            color: Colors.orangeAccent,
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.grey[800],
    );
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.attente:
        return Colors.orangeAccent;
      case ReservationStatus.confirmee:
        return Colors.greenAccent;
      case ReservationStatus.enCours:
        return Colors.lightBlueAccent;
      case ReservationStatus.terminee:
        return Colors.grey;
      case ReservationStatus.annulee:
        return Colors.redAccent;
    }
  }
}
