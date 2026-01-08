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
      print('=== APPEL API CATEGORIES ===');
      print('URL: ${ApiConfig.baseUrl}${ApiConfig.categories}');
      final response = await _apiService.get(ApiConfig.categories);
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Data Type: ${response.data.runtimeType}');
      print('Response Data (preview): ${response.data.toString().substring(0, response.data.toString().length > 500 ? 500 : response.data.toString().length)}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        print('Parsing response data...');
        
        // L'API peut retourner directement une liste ou dans 'data'
        List categoriesData;
        if (data is List) {
          print('Data est une liste directe, longueur: ${data.length}');
          categoriesData = data;
        } else if (data is Map && data.containsKey('data')) {
          print('Data est dans data.data, type: ${data['data'].runtimeType}');
          if (data['data'] is List) {
            categoriesData = data['data'] as List;
            print('Nombre de catégories dans data.data: ${categoriesData.length}');
          } else {
            print('ERREUR: data.data n\'est pas une liste');
            return [];
          }
        } else if (data is Map && data.containsKey('success')) {
          print('Format avec success trouvé');
          if (data['data'] != null && data['data'] is List) {
            categoriesData = data['data'] as List;
            print('Nombre de catégories: ${categoriesData.length}');
          } else {
            print('ERREUR: data.data est null ou n\'est pas une liste');
            print('Keys dans data: ${data.keys}');
            return [];
          }
        } else {
          print('ERREUR: Format de réponse non reconnu');
          print('Type de data: ${data.runtimeType}');
          print('Keys si Map: ${data is Map ? data.keys : "N/A"}');
          return [];
        }
        
        print('Tentative de parsing de ${categoriesData.length} catégories...');
        final categories = categoriesData.map((json) {
          try {
            return Category.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            print('ERREUR lors du parsing d\'une catégorie: $e');
            print('JSON: $json');
            rethrow;
          }
        }).toList();
        
        print('✅ ${categories.length} catégories parsées avec succès');
        return categories;
      }
      print('❌ Status code n\'est pas 200: ${response.statusCode}');
      return [];
    } on DioException catch (e) {
      // Log l'erreur pour le débogage
      print('❌ Erreur DioException lors de la récupération des catégories: ${e.message}');
      print('Type: ${e.type}');
      if (e.response != null) {
        print('Status: ${e.response?.statusCode}');
        print('Headers: ${e.response?.headers}');
        print('Data: ${e.response?.data}');
      } else {
        print('Pas de réponse (erreur réseau probable)');
      }
      rethrow; // Relancer l'exception pour qu'elle soit visible
    } catch (e, stackTrace) {
      print('❌ Erreur inattendue lors de la récupération des catégories: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Récupérer tous les produits
  Future<List<Product>> getProducts({int? categoryId}) async {
    try {
      print('=== APPEL API PRODUITS ===');
      final url = ApiConfig.products + (categoryId != null ? '?categorie_id=$categoryId' : '');
      print('URL: ${ApiConfig.baseUrl}$url');
      final response = await _apiService.get(
        ApiConfig.products,
        queryParameters: categoryId != null ? {'categorie_id': categoryId} : null,
      );
      print('Status Code: ${response.statusCode}');
      print('Response Data Type: ${response.data.runtimeType}');
      print('Response Data (preview): ${response.data.toString().substring(0, response.data.toString().length > 500 ? 500 : response.data.toString().length)}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        print('Parsing response data...');
        
        // L'API peut retourner directement une liste ou dans 'data'
        List productsData;
        if (data is List) {
          print('Data est une liste directe, longueur: ${data.length}');
          productsData = data;
        } else if (data is Map && data.containsKey('data')) {
          print('Data est dans data.data, type: ${data['data'].runtimeType}');
          if (data['data'] is List) {
            productsData = data['data'] as List;
            print('Nombre de produits dans data.data: ${productsData.length}');
          } else {
            print('ERREUR: data.data n\'est pas une liste');
            return [];
          }
        } else if (data is Map && data.containsKey('success')) {
          print('Format avec success trouvé');
          if (data['data'] != null && data['data'] is List) {
            productsData = data['data'] as List;
            print('Nombre de produits: ${productsData.length}');
          } else {
            print('ERREUR: data.data est null ou n\'est pas une liste');
            print('Keys dans data: ${data.keys}');
            return [];
          }
        } else {
          print('ERREUR: Format de réponse non reconnu');
          print('Type de data: ${data.runtimeType}');
          print('Keys si Map: ${data is Map ? data.keys : "N/A"}');
          return [];
        }
        
        print('Tentative de parsing de ${productsData.length} produits...');
        final products = productsData.map((json) {
          try {
            return Product.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            print('ERREUR lors du parsing d\'un produit: $e');
            print('JSON: $json');
            rethrow;
          }
        }).toList();
        
        print('✅ ${products.length} produits parsés avec succès');
        return products;
      }
      print('❌ Status code n\'est pas 200: ${response.statusCode}');
      return [];
    } on DioException catch (e) {
      // Log l'erreur pour le débogage
      print('❌ Erreur DioException lors de la récupération des produits: ${e.message}');
      print('Type: ${e.type}');
      if (e.response != null) {
        print('Status: ${e.response?.statusCode}');
        print('Headers: ${e.response?.headers}');
        print('Data: ${e.response?.data}');
      } else {
        print('Pas de réponse (erreur réseau probable)');
      }
      rethrow;
    } catch (e, stackTrace) {
      print('❌ Erreur inattendue lors de la récupération des produits: $e');
      print('Stack trace: $stackTrace');
      rethrow;
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

