class ApiConfig {
  // TODO: Remplacer par l'URL de votre serveur
  static const String baseUrl =
      'http://restaurant.universaltechnologiesafrica.com/api';

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
