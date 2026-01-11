import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/invoice.dart';
import 'api_service.dart';

class InvoiceService {
  final ApiService _apiService = ApiService();

  // Récupérer la facture d'une commande
  Future<Map<String, dynamic>> getInvoiceByOrder(int orderId) async {
    try {
      final response = await _apiService.get(
        ApiConfig.orderInvoice(orderId),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        Map<String, dynamic> invoiceData;
        if (data is Map && data.containsKey('data')) {
          invoiceData = data['data'] as Map<String, dynamic>;
        } else {
          return {
            'success': false,
            'message': 'Format de réponse invalide',
          };
        }

        try {
          return {
            'success': true,
            'data': Invoice.fromJson(invoiceData),
          };
        } catch (e) {
          debugPrint('Erreur parsing Invoice: $e');
          return {
            'success': false,
            'message': 'Erreur lors du parsing de la facture: ${e.toString()}',
          };
        }
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Erreur lors de la récupération de la facture',
        };
      }
    } on DioException catch (e) {
      String message = 'Erreur lors de la récupération de la facture';
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          message = data['message'] as String;
        }
        if (e.response?.statusCode == 404) {
          message = 'Aucune facture disponible pour cette commande';
        }
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
}
