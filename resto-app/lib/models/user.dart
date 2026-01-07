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
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      roles: json['roles'] != null
          ? List<String>.from(json['roles'])
          : [],
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

