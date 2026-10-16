import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/catalog.dart';

/// Replace this boundary with an API implementation without changing the views.
abstract interface class CatalogRepository {
  Future<CatalogData> load();
}

class AssetCatalogRepository implements CatalogRepository {
  AssetCatalogRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;
  final AssetBundle _bundle;
  @override
  Future<CatalogData> load() async => CatalogData.fromJson(
    jsonDecode(await _bundle.loadString('assets/data/catalog.json'))
        as Map<String, dynamic>,
  );
}
