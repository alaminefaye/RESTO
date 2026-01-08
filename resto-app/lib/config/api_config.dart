class ApiConfig {
  // URL de base de l'API - Changez cette URL selon votre serveur de déploiement
  // Pour la production: http://restaurant.universaltechnologiesafrica.com/api
  // Pour le développement local: http://localhost:8000/api
  // Pour un autre serveur: http://votre-domaine.com/api
  static const String baseUrl =
      'http://restaurant.universaltechnologiesafrica.com/api';

  // URL de base du serveur (sans /api)
  static String get serverBaseUrl {
    return baseUrl.replaceAll('/api', '');
  }

  // Endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Tables
  static const String tables = '/tables';

  // Menu
  static const String categories = '/categories';
  static const String products = '/produits';

  // Orders
  static const String orders = '/commandes';
  static String orderStatus(int id) => '/commandes/$id/status';

  // Headers
  static Map<String, String> getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
