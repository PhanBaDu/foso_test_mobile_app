import 'package:flutter/foundation.dart';
import '../models/catalog.dart';

class CartLine {
  const CartLine(this.product, this.quantity);
  final Product product;
  final int quantity;
  int get subtotal => product.price * quantity;
}

/// Cart arithmetic lives here and never depends on widgets or BuildContext.
class CartViewModel extends ChangeNotifier {
  CartViewModel(this._catalog);
  final CatalogData _catalog;
  final Map<String, int> _quantities = {};
  List<CartLine> get lines => List.unmodifiable(
    _quantities.entries.map(
      (e) => CartLine(_catalog.productById(e.key), e.value),
    ),
  );
  int get itemCount => _quantities.values.fold(0, (a, b) => a + b);
  int get total => lines.fold(0, (sum, line) => sum + line.subtotal);
  void add(String productId) {
    _catalog.productById(productId);
    _quantities.update(productId, (value) => value + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void remove(String productId) {
    final quantity = _quantities[productId];
    if (quantity == null) return;
    if (quantity == 1) {
      _quantities.remove(productId);
    } else {
      _quantities[productId] = quantity - 1;
    }
    notifyListeners();
  }
}
