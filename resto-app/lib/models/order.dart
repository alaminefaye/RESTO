import 'package:flutter/foundation.dart';
import 'table.dart' as models;

enum OrderStatus {
  attente,
  preparation,
  servie,
  terminee,
  annulee;

  static OrderStatus fromString(String value) {
    switch (value) {
      case 'attente':
        return OrderStatus.attente;
      case 'preparation':
        return OrderStatus.preparation;
      case 'servie':
        return OrderStatus.servie;
      case 'terminee':
        return OrderStatus.terminee;
      case 'annulee':
        return OrderStatus.annulee;
      default:
        return OrderStatus.attente;
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.attente:
        return 'En attente';
      case OrderStatus.preparation:
        return 'En préparation';
      case OrderStatus.servie:
        return 'Servie';
      case OrderStatus.terminee:
        return 'Terminée';
      case OrderStatus.annulee:
        return 'Annulée';
    }
  }
}

class OrderItem {
  final int produitId;
  final String produitNom;
  final double prix;
  final int quantite;
  final String? image;

  OrderItem({
    required this.produitId,
    required this.produitNom,
    required this.prix,
    required this.quantite,
    this.image,
  });

  double get total => prix * quantite;

  Map<String, dynamic> toJson() {
    return {
      'produit_id': produitId,
      'quantite': quantite,
    };
  }
}

class Order {
  final int id;
  final int tableId;
  final int? userId;
  final double montantTotal;
  final OrderStatus statut;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItem>? produits;
  final models.Table? table;

  Order({
    required this.id,
    required this.tableId,
    this.userId,
    required this.montantTotal,
    required this.statut,
    required this.createdAt,
    this.updatedAt,
    this.produits,
    this.table,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    try {
      // Parsing sécurisé des produits
      List<OrderItem>? produits;
      if (json['produits'] != null && json['produits'] is List) {
        try {
          produits = (json['produits'] as List)
              .map((p) {
                try {
                  if (p is! Map) return null;
                  
                  final pivot = p['pivot'] as Map<String, dynamic>?;
                  final produitId = p['id'] as int? ?? 0;
                  final produitNom = p['nom'] as String? ?? 'Produit inconnu';
                  
                  // L'API formatCommande retourne prix_unitaire directement dans le produit
                  // Mais peut aussi être dans pivot selon le contexte
                  double prix = 0.0;
                  if (p['prix_unitaire'] != null) {
                    prix = (p['prix_unitaire'] as num).toDouble();
                  } else if (pivot != null && pivot['prix_unitaire'] != null) {
                    prix = (pivot['prix_unitaire'] as num).toDouble();
                  } else if (pivot != null && pivot['prix'] != null) {
                    prix = (pivot['prix'] as num).toDouble();
                  } else if (p['prix'] != null) {
                    prix = (p['prix'] as num).toDouble();
                  }
                  
                  int quantite = 1;
                  if (p['quantite'] != null) {
                    quantite = (p['quantite'] as int? ?? 1);
                  } else if (pivot != null && pivot['quantite'] != null) {
                    quantite = (pivot['quantite'] as int? ?? 1);
                  }
                  
                  return OrderItem(
                    produitId: produitId,
                    produitNom: produitNom,
                    prix: prix,
                    quantite: quantite,
                    image: p['image'] as String?,
                  );
                } catch (e) {
                  debugPrint('Erreur parsing produit: $e');
                  debugPrint('Produit JSON: $p');
                  return null;
                }
              })
              .whereType<OrderItem>()
              .toList();
        } catch (e) {
          debugPrint('Erreur parsing liste produits: $e');
          produits = null;
        }
      }

      // Parsing sécurisé de la table
      models.Table? table;
      if (json['table'] != null && json['table'] is Map) {
        try {
          table = models.Table.fromJson(json['table'] as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Erreur parsing table: $e');
          table = null;
        }
      }

      return Order(
        id: json['id'] as int? ?? 0,
        tableId: json['table_id'] as int? ?? 0,
        userId: json['user_id'] as int?,
        montantTotal: ((json['montant_total'] ?? 0) as num).toDouble(),
        statut: OrderStatus.fromString(json['statut'] as String? ?? 'attente'),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        produits: produits,
        table: table,
      );
    } catch (e) {
      debugPrint('Erreur parsing Order: $e');
      debugPrint('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_id': tableId,
      'user_id': userId,
      'montant_total': montantTotal,
      'statut': statut.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

