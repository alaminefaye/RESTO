import 'package:dio/dio.dart';
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
        final data = response.data;
        // L'API peut retourner directement l'objet ou dans 'data'
        Map<String, dynamic> orderData;
        if (data is Map) {
          orderData = data.containsKey('data') ? data['data'] as Map<String, dynamic> : data as Map<String, dynamic>;
        } else {
          return {
            'success': false,
            'message': 'Format de réponse invalide',
          };
        }
        return {
          'success': true,
          'order': Order.fromJson(orderData),
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Erreur lors de la création',
        };
      }
    } on DioException catch (e) {
      String message = 'Erreur lors de la création de la commande';
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          message = data['message'] as String;
        } else if (data is Map && data['errors'] != null) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            message = (errors.values.first as List).first as String;
          }
        }
        if (e.response?.statusCode == 422) {
          message = message;
        } else if (e.response?.statusCode == 401) {
          message = 'Non autorisé. Veuillez vous reconnecter.';
        } else if (e.response?.statusCode == 403) {
          message = 'Accès refusé';
        } else if (e.response?.statusCode == 500) {
          message = 'Erreur serveur. Veuillez réessayer plus tard.';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        message = 'Délai d\'attente dépassé. Vérifiez votre connexion internet.';
      } else if (e.type == DioExceptionType.connectionError) {
        message = 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur inattendue: ${e.toString()}',
      };
    }
  }

  // Récupérer toutes les commandes
  Future<List<Order>> getOrders() async {
    try {
      final response = await _apiService.get(ApiConfig.orders);
      if (response.statusCode == 200) {
        final data = response.data;
        // L'API peut retourner directement une liste ou dans 'data'
        List ordersData;
        if (data is List) {
          ordersData = data;
        } else if (data['data'] != null) {
          ordersData = data['data'] as List;
        } else {
          return [];
        }
        return ordersData.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Erreur lors de la récupération des commandes: ${e.message}');
      return [];
    } catch (e) {
      print('Erreur inattendue lors de la récupération des commandes: $e');
      return [];
    }
  }

  // Récupérer une commande par ID
  Future<Order?> getOrder(int id) async {
    try {
      final response = await _apiService.get('${ApiConfig.orders}/$id');
      if (response.statusCode == 200) {
        final data = response.data;
        // L'API peut retourner directement l'objet ou dans 'data'
        Map<String, dynamic> orderData;
        if (data is Map) {
          orderData = data.containsKey('data') ? data['data'] as Map<String, dynamic> : data as Map<String, dynamic>;
        } else {
          return null;
        }
        return Order.fromJson(orderData);
      }
      return null;
    } on DioException catch (e) {
      print('Erreur lors de la récupération de la commande: ${e.message}');
      return null;
    } catch (e) {
      print('Erreur inattendue lors de la récupération de la commande: $e');
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

