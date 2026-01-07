import 'package:flutter/material.dart';

enum TableType {
  simple,
  vip,
  espaceJeux;

  static TableType fromString(String value) {
    switch (value) {
      case 'simple':
        return TableType.simple;
      case 'vip':
        return TableType.vip;
      case 'espace_jeux':
        return TableType.espaceJeux;
      default:
        return TableType.simple;
    }
  }

  String get displayName {
    switch (this) {
      case TableType.simple:
        return 'Simple';
      case TableType.vip:
        return 'VIP';
      case TableType.espaceJeux:
        return 'Espace Jeux';
    }
  }
}

enum TableStatus {
  libre,
  occupee,
  reservee,
  enPaiement;

  static TableStatus fromString(String value) {
    switch (value) {
      case 'libre':
        return TableStatus.libre;
      case 'occupee':
        return TableStatus.occupee;
      case 'reservee':
        return TableStatus.reservee;
      case 'en_paiement':
        return TableStatus.enPaiement;
      default:
        return TableStatus.libre;
    }
  }

  String get displayName {
    switch (this) {
      case TableStatus.libre:
        return 'Libre';
      case TableStatus.occupee:
        return 'Occupée';
      case TableStatus.reservee:
        return 'Réservée';
      case TableStatus.enPaiement:
        return 'En paiement';
    }
  }

  Color get color {
    switch (this) {
      case TableStatus.libre:
        return Colors.green;
      case TableStatus.occupee:
        return Colors.red;
      case TableStatus.reservee:
        return Colors.orange;
      case TableStatus.enPaiement:
        return Colors.blue;
    }
  }
}

class Table {
  final int id;
  final int numero;
  final TableType type;
  final int capacite;
  final double? prix;
  final double? prixParHeure;
  final TableStatus statut;
  final String? qrCode;
  final bool actif;

  Table({
    required this.id,
    required this.numero,
    required this.type,
    required this.capacite,
    this.prix,
    this.prixParHeure,
    required this.statut,
    this.qrCode,
    this.actif = true,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'] as int,
      numero: json['numero'] as int,
      type: TableType.fromString(json['type'] as String),
      capacite: json['capacite'] as int,
      prix: json['prix'] != null ? (json['prix'] as num).toDouble() : null,
      prixParHeure: json['prix_par_heure'] != null
          ? (json['prix_par_heure'] as num).toDouble()
          : null,
      statut: TableStatus.fromString(json['statut'] as String),
      qrCode: json['qr_code'] as String?,
      actif: json['actif'] == 1 || json['actif'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'type': type.name,
      'capacite': capacite,
      'prix': prix,
      'prix_par_heure': prixParHeure,
      'statut': statut.name,
      'qr_code': qrCode,
      'actif': actif,
    };
  }

  String get qrCodeUrl {
    if (qrCode == null) return '';
    if (qrCode!.startsWith('http')) return qrCode!;
    return 'http://restaurant.universaltechnologiesafrica.com/storage/$qrCode';
  }
}

