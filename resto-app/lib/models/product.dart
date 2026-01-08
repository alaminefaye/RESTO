import '../config/api_config.dart';

class Product {
  final int id;
  final String nom;
  final String? description;
  final double prix;
  final String? image;
  final int categorieId;
  final String? categorieNom;
  final bool disponible;
  final bool actif;

  Product({
    required this.id,
    required this.nom,
    this.description,
    required this.prix,
    this.image,
    required this.categorieId,
    this.categorieNom,
    this.disponible = true,
    this.actif = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Fonction helper pour convertir en int de manière sécurisée
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    // Fonction helper pour convertir en double de manière sécurisée
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Fonction helper pour convertir en bool de manière sécurisée
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    return Product(
      id: parseInt(json['id']),
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String?,
      prix: parseDouble(json['prix']),
      // L'API retourne image_url directement, sinon utiliser image
      image: json['image_url'] as String? ?? json['image'] as String?,
      categorieId: parseInt(json['categorie_id']),
      categorieNom: json['categorie']?['nom'] as String?,
      disponible: parseBool(json['disponible']),
      actif: parseBool(json['actif']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'prix': prix,
      'image': image,
      'categorie_id': categorieId,
      'disponible': disponible,
      'actif': actif,
    };
  }

  String get imageUrl {
    if (image == null) return '';
    // Si l'image est déjà une URL complète, la retourner telle quelle
    if (image!.startsWith('http://') || image!.startsWith('https://')) {
      return image!;
    }
    // Sinon, construire l'URL avec l'URL de base du serveur depuis ApiConfig
    return '${ApiConfig.serverBaseUrl}/storage/$image';
  }
}

