class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final List<String> roles;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.roles = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Helper pour convertir en int de manière sécurisée
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Gérer les rôles qui peuvent être soit une liste de strings, soit une liste d'objets
    List<String> rolesList = [];
    if (json['roles'] != null) {
      final roles = json['roles'];
      if (roles is List) {
        for (var role in roles) {
          if (role is String) {
            rolesList.add(role);
          } else if (role is Map && role['name'] != null) {
            rolesList.add(role['name'] as String);
          }
        }
      }
    }

    return User(
      id: parseInt(json['id']),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      roles: rolesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'roles': roles,
    };
  }

  bool hasRole(String role) {
    return roles.contains(role);
  }
}
