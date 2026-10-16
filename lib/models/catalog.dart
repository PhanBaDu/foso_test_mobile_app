/// Immutable domain models. Both renderers decode the same catalog.json contract.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.originalPrice,
    required this.soldCount,
  });
  final String id, name, image;
  final int price, originalPrice, soldCount;
  int get discountPercent => originalPrice > price && originalPrice > 0
      ? ((originalPrice - price) * 100 / originalPrice).round()
      : 0;
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    image: json['image'] as String,
    price: json['price'] as int,
    originalPrice: json['originalPrice'] as int,
    soldCount: json['soldCount'] as int,
  );
}

class CatalogFilter {
  const CatalogFilter({
    required this.id,
    required this.name,
    required this.image,
    required this.productId,
  });
  final String id, name, image, productId;
  factory CatalogFilter.fromJson(Map<String, dynamic> json) => CatalogFilter(
    id: json['id'] as String,
    name: json['name'] as String,
    image: json['image'] as String,
    productId: json['productId'] as String,
  );
}

class CatalogCategory {
  CatalogCategory({
    required this.id,
    required this.name,
    required this.image,
    required List<String> filterIds,
  }) : filterIds = List.unmodifiable(filterIds);
  final String id, name, image;
  final List<String> filterIds;
  factory CatalogCategory.fromJson(Map<String, dynamic> json) =>
      CatalogCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        image: json['image'] as String,
        filterIds: (json['filterIds'] as List).cast<String>(),
      );
}

class Article {
  const Article({
    required this.id,
    required this.title,
    required this.image,
    required this.date,
  });
  final String id, title, image;
  final DateTime date;
  factory Article.fromJson(Map<String, dynamic> json) => Article(
    id: json['id'] as String,
    title: json['title'] as String,
    image: json['image'] as String,
    date: DateTime.parse(json['date'] as String),
  );
}

class CatalogData {
  CatalogData({
    required List<CatalogCategory> categories,
    required List<String> featuredCategoryIds,
    required List<CatalogFilter> filters,
    required List<Product> products,
    required List<Article> articles,
    required this.flashSaleDurationSeconds,
  }) : categories = List.unmodifiable(categories),
       featuredCategoryIds = List.unmodifiable(featuredCategoryIds),
       filters = List.unmodifiable(filters),
       products = List.unmodifiable(products),
       articles = List.unmodifiable(articles) {
    // Reject broken references at the data boundary, rather than crashing a view.
    final categoryIds = categories.map((e) => e.id).toSet();
    final productIds = products.map((e) => e.id).toSet();
    final filterIds = filters.map((e) => e.id).toSet();
    if (categories.isEmpty ||
        products.isEmpty ||
        categoryIds.length != categories.length ||
        productIds.length != products.length ||
        filterIds.length != filters.length ||
        articles.map((e) => e.id).toSet().length != articles.length ||
        featuredCategoryIds.any((id) => !categoryIds.contains(id)) ||
        filters.any((e) => !productIds.contains(e.productId)) ||
        categories.any(
          (e) => e.filterIds.any((id) => !filterIds.contains(id)),
        ) ||
        products.any((e) => e.price < 0 || e.originalPrice < 0) ||
        flashSaleDurationSeconds < 0) {
      throw const FormatException('Invalid catalog references or values');
    }
  }
  final List<CatalogCategory> categories;
  final List<String> featuredCategoryIds;
  final List<CatalogFilter> filters;
  final List<Product> products;
  final List<Article> articles;
  final int flashSaleDurationSeconds;
  List<CatalogCategory> get featuredCategories => featuredCategoryIds
      .map((id) => categories.firstWhere((e) => e.id == id))
      .toList(growable: false);
  Product productById(String id) => products.firstWhere((e) => e.id == id);
  factory CatalogData.fromJson(Map<String, dynamic> json) => CatalogData(
    categories: (json['categories'] as List)
        .map((e) => CatalogCategory.fromJson(e as Map<String, dynamic>))
        .toList(),
    featuredCategoryIds: (json['featuredCategoryIds'] as List).cast<String>(),
    filters: (json['filters'] as List)
        .map((e) => CatalogFilter.fromJson(e as Map<String, dynamic>))
        .toList(),
    products: (json['products'] as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList(),
    articles: (json['articles'] as List)
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList(),
    flashSaleDurationSeconds: json['flashSaleDurationSeconds'] as int,
  );
}
