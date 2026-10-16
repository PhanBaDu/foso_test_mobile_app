import Foundation

// These value types mirror assets/data/catalog.json, the shared cross-platform contract.
struct Product: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let image: String
    let price: Int
    let originalPrice: Int
    let soldCount: Int
    var discountPercent: Int {
        guard originalPrice > price, originalPrice > 0 else { return 0 }
        return Int((Double(originalPrice - price) * 100 / Double(originalPrice)).rounded())
    }
}
struct CatalogFilter: Codable, Identifiable {
    let id: String
    let name: String
    let image: String
    let productId: String
}
struct CatalogCategory: Codable, Identifiable {
    let id: String
    let name: String
    let image: String
    let filterIds: [String]
}
struct Article: Codable, Identifiable {
    let id: String
    let title: String
    let image: String
    let date: String
}
struct CatalogData: Codable {
    let categories: [CatalogCategory]
    let featuredCategoryIds: [String]
    let filters: [CatalogFilter]
    let products: [Product]
    let articles: [Article]
    let flashSaleDurationSeconds: Int
    var featuredCategories: [CatalogCategory] {
        featuredCategoryIds.compactMap { id in categories.first { $0.id == id } }
    }
    func product(id: String) -> Product? { products.first { $0.id == id } }
    func validate() throws {
        let categoryIds = Set(categories.map(\.id))
        let productIds = Set(products.map(\.id))
        let filterIds = Set(filters.map(\.id))
        guard !categories.isEmpty, !products.isEmpty,
              categoryIds.count == categories.count, productIds.count == products.count,
              filterIds.count == filters.count, Set(articles.map(\.id)).count == articles.count,
              featuredCategoryIds.allSatisfy(categoryIds.contains),
              filters.allSatisfy({ productIds.contains($0.productId) }),
              categories.allSatisfy({ $0.filterIds.allSatisfy(filterIds.contains) }),
              products.allSatisfy({ $0.price >= 0 && $0.originalPrice >= 0 }),
              flashSaleDurationSeconds >= 0 else { throw CatalogError.invalidData }
    }
}
enum CatalogError: Error { case missingResource, invalidData }
