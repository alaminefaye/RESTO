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
    return Order(
      id: json['id'] as int,
      tableId: json['table_id'] as int,
      userId: json['user_id'] as int?,
      montantTotal: (json['montant_total'] as num).toDouble(),
      statut: OrderStatus.fromString(json['statut'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      produits: json['produits'] != null
          ? (json['produits'] as List)
              .map((p) => OrderItem(
                    produitId: p['id'] as int,
                    produitNom: p['nom'] as String,
                    prix: (p['pivot']['prix'] as num).toDouble(),
                    quantite: p['pivot']['quantite'] as int,
                    image: p['image'] as String?,
                  ))
              .toList()
          : null,
      table: json['table'] != null
          ? models.Table.fromJson(json['table'] as Map<String, dynamic>)
          : null,
    );
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

