import 'package:flutter/foundation.dart';
import '../data/catalog_repository.dart';
import 'cart_view_model.dart';
import 'category_view_model.dart';
import 'home_view_model.dart';

enum ShopTab { home, cart, category, news, account }

/// Composition root for feature VMs. Views own only controllers and presentation.
class ShopViewModel extends ChangeNotifier {
  ShopViewModel(this._repository);
  final CatalogRepository _repository;
  HomeViewModel? _home;
  CategoryViewModel? _categories;
  CartViewModel? _cart;
  HomeViewModel get home => _home!;
  CategoryViewModel get categories => _categories!;
  CartViewModel get cart => _cart!;
  ShopTab _tab = ShopTab.home;
  ShopTab get tab => _tab;
  bool _loading = false, _disposed = false;
  String? _error;
  bool get loading => _loading;
  bool get ready => _home != null;
  String? get error => _error;

  Future<void> load() async {
    if (_loading || ready) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final catalog = await _repository.load();
      if (_disposed) return;
      _home = HomeViewModel(catalog);
      _categories = CategoryViewModel(catalog);
      _cart = CartViewModel(catalog)..addListener(notifyListeners);
    } catch (_) {
      if (!_disposed) _error = 'Không thể tải dữ liệu. Vui lòng thử lại.';
    } finally {
      if (!_disposed) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  void selectTab(ShopTab value) {
    _tab = value;
    categories.search('');
    notifyListeners();
  }

  void openCategory(String id) {
    categories.select(id);
    _tab = ShopTab.category;
    notifyListeners();
  }

  void search(String value) {
    categories.search(value);
    if (value.isNotEmpty) _tab = ShopTab.category;
    notifyListeners();
  }

  void submitSearch() {
    _tab = ShopTab.category;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cart?.removeListener(notifyListeners);
    _home?.dispose();
    _categories?.dispose();
    _cart?.dispose();
    super.dispose();
  }
}
