import Combine
import Foundation

enum ShopTab: Int, CaseIterable {
    case home, cart, category, news, account
    var title: String { ["Trang chủ", "Giỏ hàng", "Danh mục", "Tin tức", "Tài khoản"][rawValue] }
    var icon: String { ["home", "cart", "category", "news", "account"][rawValue] }
}
enum ShopSheet: Identifiable {
    case product(Product), article(Article), notice(String)
    var id: String {
        switch self {
        case .product(let value): return "product-\(value.id)"
        case .article(let value): return "article-\(value.id)"
        case .notice(let value): return "notice-\(value)"
        }
    }
}
final class ShopViewModel: ObservableObject {
    let home: HomeViewModel
    let categories: CategoryViewModel
    let cart: CartViewModel
    @Published private(set) var tab: ShopTab = .home
    @Published private(set) var returnTab: ShopTab?
    @Published private(set) var query = ""
    @Published var sheet: ShopSheet?
    @Published private(set) var toast: String?
    private var subscriptions = Set<AnyCancellable>()
    private var toastDismissal: DispatchWorkItem?
    init(catalog: CatalogData) {
        home = HomeViewModel(catalog: catalog)
        categories = CategoryViewModel(catalog: catalog)
        cart = CartViewModel(catalog: catalog)
        // Forward only shared cart state; Home owns its own countdown updates.
        cart.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }.store(in: &subscriptions)
    }
    func selectTab(_ value: ShopTab) {
        returnTab = nil
        query = ""; categories.search(""); tab = value
    }
    func beginSearch() {
        guard tab != .category else { return }
        returnTab = tab
        tab = .category
    }
    func goBack() {
        guard let previous = returnTab else { return }
        selectTab(previous)
    }
    func openCategory(_ id: String) { categories.select(id); beginSearch() }
    func search(_ value: String) {
        query = value; categories.search(value)
        if !value.isEmpty { beginSearch() }
    }
    func submitSearch() { beginSearch() }
    func buy(_ product: Product) {
        cart.add(product)
        toastDismissal?.cancel()
        toast = "Đã thêm sản phẩm vào giỏ hàng"
        let work = DispatchWorkItem { [weak self] in self?.toast = nil }
        toastDismissal = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: work)
    }
    func dismissToast() {
        toastDismissal?.cancel()
        toast = nil
    }
    deinit { toastDismissal?.cancel() }
}
