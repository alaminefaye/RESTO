import 'package:dio/dio.dart';
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
        final data = response.data;
        // L'API peut retourner directement une liste ou dans 'data'
        List categoriesData;
        if (data is List) {
          categoriesData = data;
        } else if (data['data'] != null) {
          categoriesData = data['data'] as List;
        } else {
          return [];
        }
        return categoriesData.map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      // Log l'erreur pour le débogage
      print('Erreur lors de la récupération des catégories: ${e.message}');
      if (e.response != null) {
        print('Status: ${e.response?.statusCode}');
        print('Data: ${e.response?.data}');
      }
      return [];
    } catch (e) {
      print('Erreur inattendue lors de la récupération des catégories: $e');
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
        final data = response.data;
        // L'API peut retourner directement une liste ou dans 'data'
        List productsData;
        if (data is List) {
          productsData = data;
        } else if (data['data'] != null) {
          productsData = data['data'] as List;
        } else {
          return [];
        }
        return productsData.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      // Log l'erreur pour le débogage
      print('Erreur lors de la récupération des produits: ${e.message}');
      if (e.response != null) {
        print('Status: ${e.response?.statusCode}');
        print('Data: ${e.response?.data}');
      }
      return [];
    } catch (e) {
      print('Erreur inattendue lors de la récupération des produits: $e');
      return [];
    }
  }

  // Récupérer un produit par ID
  Future<Product?> getProduct(int id) async {
    try {
      final response = await _apiService.get('${ApiConfig.products}/$id');
      if (response.statusCode == 200) {
        final data = response.data;
        // L'API peut retourner directement l'objet ou dans 'data'
        Map<String, dynamic> productData;
        if (data is Map) {
          productData = data.containsKey('data') ? data['data'] as Map<String, dynamic> : data as Map<String, dynamic>;
        } else {
          return null;
        }
        return Product.fromJson(productData);
      }
      return null;
    } on DioException catch (e) {
      print('Erreur lors de la récupération du produit: ${e.message}');
      return null;
    } catch (e) {
      print('Erreur inattendue lors de la récupération du produit: $e');
      return null;
    }
  }
}

