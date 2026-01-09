import 'package:flutter/foundation.dart';
import 'product.dart';

class Favorites extends ChangeNotifier {
  final List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);

  bool isFavorite(Product product) {
    return _products.any((p) => p.id == product.id);
  }

  void addFavorite(Product product) {
    if (!isFavorite(product)) {
      _products.add(product);
      debugPrint('✅ Favori ajouté: ${product.nom} (Total: ${_products.length})');
      notifyListeners();
    } else {
      debugPrint('⚠️ Produit déjà en favoris: ${product.nom}');
    }
  }

  void removeFavorite(Product product) {
    _products.removeWhere((p) => p.id == product.id);
    notifyListeners();
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      debugPrint('🔄 Retrait des favoris: ${product.nom}');
      removeFavorite(product);
    } else {
      debugPrint('🔄 Ajout aux favoris: ${product.nom}');
      addFavorite(product);
    }
  }

  void clear() {
    _products.clear();
    notifyListeners();
  }

  int get count => _products.length;
}
