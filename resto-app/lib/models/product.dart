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
    return Product(
      id: json['id'] as int,
      nom: json['nom'] as String,
      description: json['description'] as String?,
      prix: (json['prix'] as num).toDouble(),
      image: json['image'] as String?,
      categorieId: json['categorie_id'] as int,
      categorieNom: json['categorie']?['nom'] as String?,
      disponible: json['disponible'] == 1 || json['disponible'] == true,
      actif: json['actif'] == 1 || json['actif'] == true,
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
    if (image!.startsWith('http')) return image!;
    return 'http://restaurant.universaltechnologiesafrica.com/storage/$image';
  }
}

