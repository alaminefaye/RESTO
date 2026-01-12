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
    return Reservation(
      id: json['id'] as int,
      tableId: json['table_id'] as int?,
      table: json['table'] != null ? Table.fromJson(json['table'] as Map<String, dynamic>) : null,
      userId: json['user_id'] as int?,
      nomClient: json['nom_client'] as String,
      telephone: json['telephone'] as String,
      email: json['email'] as String?,
      dateReservation: DateTime.parse(json['date_reservation'] as String),
      heureDebut: json['heure_debut'] as String,
      heureFin: json['heure_fin'] as String?,
      duree: json['duree'] as int,
      nombrePersonnes: json['nombre_personnes'] as int,
      prixTotal: (json['prix_total'] as num).toDouble(),
      acompte: json['acompte'] != null ? (json['acompte'] as num).toDouble() : null,
      statut: ReservationStatus.fromString(json['statut'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_id': tableId,
      'user_id': userId,
      'nom_client': nomClient,
      'telephone': telephone,
      'email': email,
      'date_reservation': dateReservation.toIso8601String().split('T')[0],
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
      'duree': duree,
      'nombre_personnes': nombrePersonnes,
      'prix_total': prixTotal,
      'acompte': acompte,
      'statut': statut.name,
      'notes': notes,
    };
  }
}
