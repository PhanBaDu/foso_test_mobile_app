import XCTest
import SwiftUI
@testable import Runner

final class RunnerTests: XCTestCase {
    private func catalog() throws -> CatalogData { try BundleCatalogRepository().load() }

    func testCartMaintainsSeparateLinesAndTotals() throws {
        let catalog = try catalog()
        let vm = CartViewModel(catalog: catalog)
        vm.add(catalog.products[0]); vm.add(catalog.products[0]); vm.add(catalog.products[1])
        XCTAssertEqual(vm.itemCount, 3)
        XCTAssertEqual(vm.total, 897000)
        XCTAssertEqual(vm.lines.count, 2)
        vm.remove(catalog.products[0].id); vm.remove(catalog.products[0].id); vm.remove(catalog.products[0].id)
        XCTAssertEqual(vm.itemCount, 1)
        XCTAssertEqual(vm.total, 299000)
    }
    func testCategorySearchAndIdentityRouting() throws {
        let vm = CategoryViewModel(catalog: try catalog())
        XCTAssertEqual(vm.selectedId, "air")
        XCTAssertEqual(vm.matches.map(\.id), vm.catalog.filters.filter { vm.selected.filterIds.contains($0.id) }.map(\.id))
        XCTAssertFalse(vm.matches.isEmpty)
        vm.search("   "); XCTAssertFalse(vm.matches.isEmpty)
        vm.search("  CABIN  "); XCTAssertEqual(vm.matches.map(\.id), ["filter-1"])
        vm.select("fuel"); XCTAssertEqual(vm.selected.name, "Bộ Lọc Nhiên Liệu")
        vm.select("missing"); XCTAssertEqual(vm.selectedId, "fuel")
        vm.search("không tồn tại"); XCTAssertTrue(vm.matches.isEmpty)
    }
    func testCountdownUsesAbsoluteTimeAndClampsExpiry() throws {
        var now = Date(timeIntervalSince1970: 0)
        let vm = HomeViewModel(catalog: try catalog(), now: { now }, startTimer: false)
        XCTAssertEqual(vm.clock, ["19", "25", "00"])
        now.addTimeInterval(7207); vm.refreshCountdown()
        XCTAssertEqual(vm.clock, ["17", "24", "53"])
        now.addTimeInterval(172800); vm.refreshCountdown()
        XCTAssertEqual(vm.remainingSeconds, 0)
    }
    func testShopSharesCartAndClearsSearchOnTabChange() throws {
        let vm = ShopViewModel(catalog: try catalog())
        vm.search("gió"); XCTAssertEqual(vm.tab, .category)
        vm.openCategory("cabin"); XCTAssertEqual(vm.categories.selectedId, "cabin")
        vm.buy(vm.home.catalog.products[0]); XCTAssertEqual(vm.cart.itemCount, 1)
        vm.selectTab(.home); XCTAssertTrue(vm.query.isEmpty); XCTAssertTrue(vm.categories.query.isEmpty)
    }
    func testSearchReturnsToOriginAndDirectCategoryHasNoBackRoute() throws {
        let vm = ShopViewModel(catalog: try catalog())
        vm.selectTab(.category)
        vm.beginSearch()
        XCTAssertNil(vm.returnTab)
        for origin in [ShopTab.home, .cart, .news, .account] {
            vm.selectTab(origin)
            vm.beginSearch()
            vm.search("gió")
            vm.search("gió động cơ")
            XCTAssertEqual(vm.tab, .category)
            XCTAssertEqual(vm.returnTab, origin)
            vm.goBack()
            XCTAssertEqual(vm.tab, origin)
            XCTAssertNil(vm.returnTab)
        }
        vm.openCategory("cabin")
        XCTAssertEqual(vm.returnTab, .account)
        vm.selectTab(.category)
        XCTAssertNil(vm.returnTab)
    }

    @MainActor
    func testFeaturedScrollReportsRealProgressAndKeepsItemsMounted() throws {
        let scroll = FeaturedCategoriesScrollView(frame: CGRect(x: 0, y: 0, width: 393, height: 98))
        var progress: CGFloat = 0
        let categories = try catalog().featuredCategories
        scroll.configure(categories: categories, onCategory: { _ in }, onProgress: { progress = $0 })
        scroll.layoutIfNeeded()
        let extent = scroll.contentSize.width - scroll.bounds.width
        XCTAssertGreaterThan(extent, 0)
        scroll.setContentOffset(CGPoint(x: extent / 2, y: 0), animated: false)
        XCTAssertEqual(progress, 0.5, accuracy: 0.001)
        scroll.setContentOffset(CGPoint(x: extent, y: 0), animated: false)
        XCTAssertEqual(progress, 1, accuracy: 0.001)
        scroll.configure(categories: categories, onCategory: { _ in }, onProgress: { progress = $0 })
        XCTAssertEqual(scroll.contentOffset.x, extent, accuracy: 0.001)
        scroll.setContentOffset(.zero, animated: false)
        XCTAssertEqual(progress, 0, accuracy: 0.001)
    }

    func testCatalogRejectsBrokenReferences() throws {
        let catalog = try catalog()
        let invalid = CatalogData(categories: catalog.categories, featuredCategoryIds: ["missing"], filters: catalog.filters, products: catalog.products, articles: catalog.articles, flashSaleDurationSeconds: 0)
        XCTAssertThrowsError(try invalid.validate())
    }
    func testNativeAssetsAndFontsAreBundled() throws {
        let names = try catalog().products.map(\.image) + ["ic_home", "ic_search", "ic_notification", "filter_0", "offer_banner"]
        for name in names { XCTAssertNotNil(UIImage(named: name), name) }
        XCTAssertNotNil(UIFont(name: "Inter-Regular", size: 14))
    }
    func testSceneBootsNativeHostingControllerWithoutFlutterRoot() {
        let delegate = UIApplication.shared.connectedScenes.compactMap { $0.delegate as? SceneDelegate }.first
        XCTAssertNotNil(delegate?.window)
        XCTAssertTrue(delegate?.window?.rootViewController is NativeHostingController<NativeAppView>)
        XCTAssertTrue(UIApplication.shared.delegate is AppDelegate)
    }
    func testBootstrapCanRetryAndIgnoresStaleRequests() throws {
        let repository = ControlledCatalogRepository()
        let container = NativeAppContainer(repository: repository)
        container.reload()
        let loaded = expectation(description: "Latest catalog request is applied on main")
        repository.requests[0](.failure(CatalogError.missingResource))
        repository.requests[1](.success(try catalog()))
        DispatchQueue.main.async {
            XCTAssertNotNil(container.shop)
            XCTAssertNil(container.error)
            loaded.fulfill()
        }
        wait(for: [loaded], timeout: 3)
    }

    @MainActor
    func testNativeHomeAndCategorySnapshots() throws {
        let vm = ShopViewModel(catalog: try catalog())
        let original = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first?.windows.first(where: \.isKeyWindow)
        let host = NativeHostingController(rootView: NativeShopRootView(viewModel: vm))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = host
        window.makeKeyAndVisible()
        defer { window.isHidden = true; original?.makeKeyAndVisible() }
        for tab in [ShopTab.home, .category, .cart, .account] {
            vm.selectTab(tab)
            host.view.setNeedsLayout()
            host.view.layoutIfNeeded()
            // Allow SwiftUI to commit its layout before producing review artifacts.
            RunLoop.main.run(until: Date().addingTimeInterval(0.25))
            let format = UIGraphicsImageRendererFormat()
            format.scale = 3
            let image = UIGraphicsImageRenderer(bounds: host.view.bounds, format: format).image { _ in
                host.view.drawHierarchy(in: host.view.bounds, afterScreenUpdates: true)
            }
            XCTAssertEqual(image.size.width, 393)
            let attachment = XCTAttachment(image: image)
            attachment.name = "native-tab-\(tab.rawValue)"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }

}


private final class ControlledCatalogRepository: CatalogRepository {
    var requests: [(Result<CatalogData, Error>) -> Void] = []
    func load(completion: @escaping (Result<CatalogData, Error>) -> Void) { requests.append(completion) }
}
