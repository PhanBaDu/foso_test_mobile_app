import Combine
import Foundation

/// Scene-owned dependencies; published state is always delivered on the main queue.
final class NativeAppContainer: ObservableObject {
    private let repository: CatalogRepository
    private var requestId = UUID()
    @Published private(set) var shop: ShopViewModel?
    @Published private(set) var error: String?
    init(repository: CatalogRepository = BundleCatalogRepository()) {
        self.repository = repository
        reload()
    }
    func reload() {
        let id = UUID()
        requestId = id
        error = nil
        repository.load { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                // Ignore stale requests when retrying or replacing dependencies.
                guard let self = self, self.requestId == id else { return }
                switch result {
                case .success(let catalog): self.shop = ShopViewModel(catalog: catalog)
                case .failure: self.error = "Không thể tải dữ liệu. Vui lòng thử lại."
                }
            }
        }
    }
}
