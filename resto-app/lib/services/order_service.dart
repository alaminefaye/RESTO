import '../config/api_config.dart';
import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  // Créer une commande
  Future<Map<String, dynamic>> createOrder({
    required int tableId,
    required List<Map<String, dynamic>> produits,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.orders,
        data: {
          'table_id': tableId,
          'produits': produits,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'order': Order.fromJson(response.data['data']),
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Erreur lors de la création',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Récupérer toutes les commandes
  Future<List<Order>> getOrders() async {
    try {
      final response = await _apiService.get(ApiConfig.orders);
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Récupérer une commande par ID
  Future<Order?> getOrder(int id) async {
    try {
      final response = await _apiService.get('${ApiConfig.orders}/$id');
      if (response.statusCode == 200) {
        return Order.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Mettre à jour le statut d'une commande
  Future<bool> updateOrderStatus(int id, OrderStatus status) async {
    try {
      final response = await _apiService.patch(
        ApiConfig.orderStatus(id),
        data: {'statut': status.name},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

