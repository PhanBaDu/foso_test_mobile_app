import 'package:flutter/foundation.dart';
import '../models/catalog.dart';

class CategoryViewModel extends ChangeNotifier {
  CategoryViewModel(this.catalog)
    : _selectedId = catalog.categories.any((e) => e.id == 'air')
          ? 'air'
          : catalog.categories.first.id;
  final CatalogData catalog;
  String _selectedId;
  String _query = '';
  String get selectedId => _selectedId;
  String get query => _query;
  CatalogCategory get selected =>
      catalog.categories.firstWhere((e) => e.id == _selectedId);
  List<CatalogFilter> get matches {
    final query = _query.trim().toLowerCase();
    return catalog.filters
        .where(
          (e) =>
              selected.filterIds.contains(e.id) &&
              e.name.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  void select(String id) {
    if (!catalog.categories.any((e) => e.id == id) || _selectedId == id) return;
    _selectedId = id;
    notifyListeners();
  }

  void search(String query) {
    if (_query == query) return;
    _query = query;
    notifyListeners();
  }
}
