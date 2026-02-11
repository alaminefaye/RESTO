import 'table.dart';

enum ReservationStatus {
  attente,
  confirmee,
  enCours,
  terminee,
  annulee;

  String get displayName {
    switch (this) {
      case ReservationStatus.attente:
        return 'En attente';
      case ReservationStatus.confirmee:
        return 'Confirmée';
      case ReservationStatus.enCours:
        return 'En cours';
      case ReservationStatus.terminee:
        return 'Terminée';
      case ReservationStatus.annulee:
        return 'Annulée';
    }
  }

  static ReservationStatus fromString(String value) {
    switch (value) {
      case 'attente':
        return ReservationStatus.attente;
      case 'confirmee':
        return ReservationStatus.confirmee;
      case 'en_cours':
        return ReservationStatus.enCours;
      case 'terminee':
        return ReservationStatus.terminee;
      case 'annulee':
        return ReservationStatus.annulee;
      default:
        return ReservationStatus.attente;
    }
  }
}

class Reservation {
  final int id;
  final int? tableId;
  final Table? table;
  final int? userId;
  final String nomClient;
  final String telephone;
  final String? email;
  final DateTime dateReservation;
  final String heureDebut;
  final String? heureFin;
  final int duree;
  final int nombrePersonnes;
  final double prixTotal;
  final double? acompte;
  final ReservationStatus statut;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reservation({
    required this.id,
    this.tableId,
    this.table,
    this.userId,
    required this.nomClient,
    required this.telephone,
    this.email,
    required this.dateReservation,
    required this.heureDebut,
    this.heureFin,
    required this.duree,
    required this.nombrePersonnes,
    required this.prixTotal,
    this.acompte,
    required this.statut,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    // Helper pour convertir en int de manière sécurisée
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Helper pour convertir en double de manière sécurisée
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Reservation(
      id: parseInt(json['id']),
      tableId: json['table_id'] != null ? parseInt(json['table_id']) : null,
      table: json['table'] != null
          ? Table.fromJson(json['table'] as Map<String, dynamic>)
          : null,
      userId: json['user_id'] != null ? parseInt(json['user_id']) : null,
      nomClient: json['nom_client'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      email: json['email'] as String?,
      dateReservation: DateTime.parse(
          json['date_reservation'] as String? ?? DateTime.now().toIso8601String()),
      heureDebut: json['heure_debut'] as String? ?? '00:00',
      heureFin: json['heure_fin'] as String?,
      duree: parseInt(json['duree']),
      nombrePersonnes: parseInt(json['nombre_personnes']),
      prixTotal: parseDouble(json['prix_total']),
      acompte: json['acompte'] != null ? parseDouble(json['acompte']) : null,
      statut: ReservationStatus.fromString(json['statut'] as String? ?? 'attente'),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}
