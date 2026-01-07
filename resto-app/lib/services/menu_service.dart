import '../config/api_config.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'api_service.dart';

class MenuService {
  final ApiService _apiService = ApiService();

  // Récupérer toutes les catégories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiService.get(ApiConfig.categories);
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Récupérer tous les produits
  Future<List<Product>> getProducts({int? categoryId}) async {
    try {
      final response = await _apiService.get(
        ApiConfig.products,
        queryParameters: categoryId != null ? {'categorie_id': categoryId} : null,
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Récupérer un produit par ID
  Future<Product?> getProduct(int id) async {
    try {
      final response = await _apiService.get('${ApiConfig.products}/$id');
      if (response.statusCode == 200) {
        return Product.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

