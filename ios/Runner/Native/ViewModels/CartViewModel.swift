import Combine
import Foundation

struct CartLine: Identifiable {
    var id: String { product.id }
    let product: Product
    let quantity: Int
    var subtotal: Int { product.price * quantity }
}
final class CartViewModel: ObservableObject {
    @Published private(set) var quantities: [String: Int] = [:]
    private let catalog: CatalogData
    init(catalog: CatalogData) { self.catalog = catalog }
    var lines: [CartLine] {
        // Catalog order keeps rows stable when a quantity changes.
        catalog.products.compactMap { product in
            guard let quantity = quantities[product.id] else { return nil }
            return CartLine(product: product, quantity: quantity)
        }
    }
    var itemCount: Int { quantities.values.reduce(0, +) }
    var total: Int { lines.reduce(0) { $0 + $1.subtotal } }
    func add(_ product: Product) {
        guard catalog.product(id: product.id) != nil else { return }
        quantities[product.id, default: 0] += 1
    }
    func remove(_ id: String) {
        guard let quantity = quantities[id] else { return }
        if quantity <= 1 { quantities.removeValue(forKey: id) }
        else { quantities[id] = quantity - 1 }
    }
}
