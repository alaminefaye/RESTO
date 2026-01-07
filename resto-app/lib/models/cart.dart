import 'package:flutter/foundation.dart';
import 'product.dart';

class CartItem {
  final Product product;
  int quantite;

  CartItem({
    required this.product,
    this.quantite = 1,
  });

  double get total => product.prix * quantite;
}

class Cart extends ChangeNotifier {
  final List<CartItem> _items = [];
  int? _tableId;

  List<CartItem> get items => List.unmodifiable(_items);
  int? get tableId => _tableId;

  double get total {
    return _items.fold(0.0, (sum, item) => sum + item.total);
  }

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantite);
  }

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  void setTable(int tableId) {
    _tableId = tableId;
    notifyListeners();
  }

  void addProduct(Product product, {int quantite = 1}) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantite += quantite;
    } else {
      _items.add(CartItem(product: product, quantite: quantite));
    }
    notifyListeners();
  }

  void removeProduct(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantite) {
    if (quantite <= 0) {
      removeProduct(productId);
      return;
    }

    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => throw Exception('Produit non trouvé'),
    );
    item.quantite = quantite;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _tableId = null;
    notifyListeners();
  }

  List<Map<String, dynamic>> toJson() {
    return _items.map((item) => {
          'produit_id': item.product.id,
          'quantite': item.quantite,
        }).toList();
  }
}

