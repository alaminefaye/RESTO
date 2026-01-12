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
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.purple.shade900,
        elevation: 0,
        title: const Text(
          'Réservations',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
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
            tooltip: 'Nouvelle réservation',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadReservations,
            tooltip: 'Actualiser',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'Toutes'),
                  const SizedBox(width: 8),
                  _buildFilterChip('a_venir', 'À venir'),
                  const SizedBox(width: 8),
                  _buildFilterChip('attente', 'En attente'),
                  const SizedBox(width: 8),
                  _buildFilterChip('confirmee', 'Confirmées'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
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
                      Icon(
                        Icons.event_busy,
                        size: 80,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Aucune réservation',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vos réservations apparaîtront ici',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReservations,
                  color: Colors.orange,
                  backgroundColor: Colors.grey[800],
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = _reservations[index];
                      return _buildReservationCard(context, reservation);
                    },
                  ),
                ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filter = value;
        });
        _loadReservations();
      },
      selectedColor: Colors.purple,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[300],
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: Colors.grey[800],
    );
  }

  Widget _buildReservationCard(BuildContext context, Reservation reservation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
      ),
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.event,
                          color: Colors.purple,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                          if (reservation.table != null)
                            Text(
                              reservation.table!.type.displayName,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(reservation.statut),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      reservation.statut.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    Formatters.formatDate(reservation.dateReservation),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    '${reservation.heureDebut} - ${reservation.heureFin ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    '${reservation.nombrePersonnes} personne(s)',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    Formatters.formatCurrency(reservation.prixTotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.attente:
        return Colors.orange.shade700;
      case ReservationStatus.confirmee:
        return Colors.green.shade700;
      case ReservationStatus.enCours:
        return Colors.blue.shade700;
      case ReservationStatus.terminee:
        return Colors.grey.shade700;
      case ReservationStatus.annulee:
        return Colors.red.shade700;
    }
  }
}
