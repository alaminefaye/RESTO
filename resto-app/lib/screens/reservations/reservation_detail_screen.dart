import 'package:flutter/material.dart';
import '../../models/reservation.dart';
import '../../services/reservation_service.dart';
import '../../utils/formatters.dart';

class ReservationDetailScreen extends StatefulWidget {
  final int reservationId;

  const ReservationDetailScreen({super.key, required this.reservationId});

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  final ReservationService _reservationService = ReservationService();
  Reservation? _reservation;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadReservation();
  }

  Future<void> _loadReservation() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final reservation = await _reservationService.getReservation(widget.reservationId);

      if (mounted) {
        setState(() {
          _reservation = reservation;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement de la réservation: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _annulerReservation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Annuler la réservation',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette réservation ?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Non',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isProcessing = true;
    });

    final result = await _reservationService.annulerReservation(widget.reservationId);

    setState(() {
      _isProcessing = false;
    });

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Réservation annulée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur lors de l\'annulation'),
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
        backgroundColor: Colors.purple.shade900,
        elevation: 0,
        title: Text(
          _reservation != null
              ? 'Réservation #${_reservation!.id}'
              : 'Réservation',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadReservation,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : _reservation == null
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
                        'Réservation non trouvée',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statut
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.purple.shade900,
                              Colors.purple.shade800,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Statut',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _reservation!.statut.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.event,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Informations de la table
                      if (_reservation!.table != null) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[700]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.table_restaurant, color: Colors.orange, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Table réservée',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.table_restaurant,
                                'Table',
                                'Table ${_reservation!.table!.numero}',
                              ),
                              const Divider(color: Colors.grey, height: 24),
                              _buildInfoRow(
                                Icons.category,
                                'Type',
                                _reservation!.table!.type.displayName,
                              ),
                              const Divider(color: Colors.grey, height: 24),
                              _buildInfoRow(
                                Icons.people,
                                'Capacité',
                                '${_reservation!.table!.capacite} personne(s)',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Informations de la réservation
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey[700]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.event, color: Colors.purple, size: 24),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Détails de la réservation',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              Icons.calendar_today,
                              'Date',
                              Formatters.formatDate(_reservation!.dateReservation),
                            ),
                            const Divider(color: Colors.grey, height: 24),
                            _buildInfoRow(
                              Icons.access_time,
                              'Heure',
                              '${_reservation!.heureDebut} - ${_reservation!.heureFin ?? 'N/A'}',
                            ),
                            const Divider(color: Colors.grey, height: 24),
                            _buildInfoRow(
                              Icons.timer,
                              'Durée',
                              '${_reservation!.duree} heure(s)',
                            ),
                            const Divider(color: Colors.grey, height: 24),
                            _buildInfoRow(
                              Icons.people,
                              'Nombre de personnes',
                              '${_reservation!.nombrePersonnes}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Informations client
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey[700]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.person, color: Colors.blue, size: 24),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Informations client',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              Icons.person,
                              'Nom',
                              _reservation!.nomClient,
                            ),
                            const Divider(color: Colors.grey, height: 24),
                            _buildInfoRow(
                              Icons.phone,
                              'Téléphone',
                              _reservation!.telephone,
                            ),
                            if (_reservation!.email != null && _reservation!.email!.isNotEmpty) ...[
                              const Divider(color: Colors.grey, height: 24),
                              _buildInfoRow(
                                Icons.email,
                                'Email',
                                _reservation!.email!,
                              ),
                            ],
                            if (_reservation!.notes != null && _reservation!.notes!.isNotEmpty) ...[
                              const Divider(color: Colors.grey, height: 24),
                              _buildInfoRow(
                                Icons.note,
                                'Notes',
                                _reservation!.notes!,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Prix
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.orange.withOpacity(0.25),
                              Colors.orange.shade900.withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.6),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Prix total',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              Formatters.formatCurrency(_reservation!.prixTotal),
                              style: TextStyle(
                                color: Colors.orange.shade100,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Boutons d'action
                      if (_reservation!.statut == ReservationStatus.attente ||
                          _reservation!.statut == ReservationStatus.confirmee) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing ? null : _annulerReservation,
                            icon: _isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.cancel, color: Colors.white),
                            label: Text(
                              _isProcessing ? 'Annulation...' : 'Annuler la réservation',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
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
    );
  }
}
