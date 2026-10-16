import Combine
import Foundation

final class CategoryViewModel: ObservableObject {
    let catalog: CatalogData
    @Published private(set) var selectedId: String
    @Published private(set) var query = ""
    init(catalog: CatalogData) {
        self.catalog = catalog
        selectedId = catalog.categories.first(where: { $0.id == "air" })?.id ?? catalog.categories[0].id
    }
    var selected: CatalogCategory { catalog.categories.first { $0.id == selectedId }! }
    var matches: [CatalogFilter] {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return catalog.filters.filter { selected.filterIds.contains($0.id) && (normalized.isEmpty || $0.name.lowercased().contains(normalized)) }
    }
    func select(_ id: String) {
        guard catalog.categories.contains(where: { $0.id == id }) else { return }
        selectedId = id
    }
    func search(_ value: String) { query = value }
}
