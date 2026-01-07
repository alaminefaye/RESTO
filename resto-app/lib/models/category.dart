class Category {
  final int id;
  final String nom;
  final String? description;
  final int ordre;
  final bool actif;
  final int? produitsCount;

  Category({
    required this.id,
    required this.nom,
    this.description,
    this.ordre = 0,
    this.actif = true,
    this.produitsCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      nom: json['nom'] as String,
      description: json['description'] as String?,
      ordre: json['ordre'] as int? ?? 0,
      actif: json['actif'] == 1 || json['actif'] == true,
      produitsCount: json['produits_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'ordre': ordre,
      'actif': actif,
      'produits_count': produitsCount,
    };
  }
}

