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
        return models.Table.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null;
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

