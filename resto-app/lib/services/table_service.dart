import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/table.dart' as models;
import 'api_service.dart';

class TableService {
  final ApiService _apiService = ApiService();

  // Récupérer une table par numéro
  Future<models.Table?> getTableByNumber(int numero) async {
    try {
      // Récupérer toutes les tables et filtrer par numéro
      final tables = await getTables();
      for (var table in tables) {
        if (table.numero == numero) {
          return table;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Récupérer une table par ID
  Future<models.Table?> getTable(int id) async {
    try {
      final response = await _apiService.get('${ApiConfig.tables}/$id');
      if (response.statusCode == 200) {
        final data = response.data;
        // L'API peut retourner directement l'objet ou dans 'data'
        Map<String, dynamic> tableData;
        if (data is Map) {
          tableData = data.containsKey('data') 
              ? data['data'] as Map<String, dynamic> 
              : data as Map<String, dynamic>;
        } else {
          return null;
        }
        return models.Table.fromJson(tableData);
      }
      print('Erreur lors de la récupération de la table $id: Status ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      print('Erreur Dio lors de la récupération de la table $id: ${e.message}');
      if (e.response != null) {
        print('Status: ${e.response?.statusCode}');
        print('Data: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('Erreur inattendue lors de la récupération de la table $id: $e');
      return null;
    }
  }

  // Récupérer une table via l'endpoint menu (pour le scan QR)
  Future<models.Table?> getTableFromMenuEndpoint(int id) async {
    try {
      final response = await _apiService.get('${ApiConfig.tables}/$id/menu');
      if (response.statusCode == 200) {
        final data = response.data;
        // L'API retourne les données dans 'data.table'
        Map<String, dynamic>? tableData;
        if (data is Map) {
          if (data.containsKey('data') && data['data'] is Map) {
            final dataMap = data['data'] as Map<String, dynamic>;
            if (dataMap.containsKey('table')) {
              tableData = dataMap['table'] as Map<String, dynamic>;
            } else {
              // Fallback: utiliser directement data['data']
              tableData = dataMap;
            }
          } else if (data.containsKey('table')) {
            tableData = data['table'] as Map<String, dynamic>;
          }
        }
        
        if (tableData != null) {
          return models.Table.fromJson(tableData);
        }
      }
      print('Erreur lors de la récupération de la table $id via menu: Status ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      print('Erreur Dio lors de la récupération de la table $id via menu: ${e.message}');
      if (e.response != null) {
        print('Status: ${e.response?.statusCode}');
        print('Data: ${e.response?.data}');
        // Lancer une exception avec le message d'erreur de l'API
        final errorData = e.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        }
      }
      throw Exception('Table introuvable (ID: $id). Vérifiez le QR code scanné.');
    } catch (e) {
      print('Erreur inattendue lors de la récupération de la table $id via menu: $e');
      rethrow;
    }
  }

  // Récupérer toutes les tables
  Future<List<models.Table>> getTables() async {
    try {
      final response = await _apiService.get(ApiConfig.tables);
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => models.Table.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

