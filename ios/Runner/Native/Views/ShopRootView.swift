import SwiftUI

struct NativeAppView: View {
    @ObservedObject var container: NativeAppContainer
    var body: some View {
        Group {
            if let shop = container.shop {
                NativeShopRootView(viewModel: shop)
            } else {
                VStack(spacing: 16) {
                    Text(container.error ?? "Đang tải dữ liệu…").font(ShopTheme.font(14))
                    if container.error != nil { Button("Thử lại", action: container.reload) }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.environment(\.colorScheme, .light).foregroundColor(ShopTheme.text)
    }
}
struct NativeShopRootView: View {
    @ObservedObject var viewModel: ShopViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var visibleToast: String?
    @State private var displayedTab: ShopTab

    init(viewModel: ShopViewModel) {
        self.viewModel = viewModel
        _displayedTab = State(initialValue: viewModel.tab)
    }

    var body: some View {
        VStack(spacing: 0) {
            NativeHeader(viewModel: viewModel)
            ZStack {
                NativeHomeView(viewModel: viewModel.home, onCategory: viewModel.openCategory, onProduct: { viewModel.sheet = .product($0) }, onBuy: viewModel.buy, onArticle: { viewModel.sheet = .article($0) }, onNews: { viewModel.selectTab(.news) }, isActive: viewModel.tab == .home)
                    .modifier(tabPresentation(.home))
                NativeCategoryView(viewModel: viewModel.categories, onProduct: { viewModel.sheet = .product($0) })
                    .modifier(tabPresentation(.category))
                news.modifier(tabPresentation(.news))
                // A single persistent Lottie instance serves both empty-state tabs.
                NativeEmptyState(isCart: displayedTab == .cart, isPlaying: showsEmptyState(viewModel.tab))
                    .opacity(showsEmptyState(displayedTab) ? 1 : 0)
                    .allowsHitTesting(false)
                    .accessibility(hidden: !showsEmptyState(viewModel.tab))
            }.frame(maxWidth: .infinity, maxHeight: .infinity).background(ShopTheme.background).clipShape(TopRoundedShape())
                // Let real screen content continue behind the tabbar’s rounded top corners.
                .padding(.bottom, -24)
            NativeNavigationBar(viewModel: viewModel, selectedTab: displayedTab)
                .zIndex(1)
        }.background(ShopTheme.blue.edgesIgnoringSafeArea(.top))
            .overlay(
                VStack {
                    Spacer(minLength: 0)
                    if let message = visibleToast {
                        Button(action: {
                            viewModel.dismissToast()
                            viewModel.selectTab(.cart)
                        }) {
                            Text(message + " · Xem giỏ")
                                .font(ShopTheme.font(12, .semibold)).foregroundColor(.white)
                                .padding(12).frame(maxWidth: .infinity)
                                .background(RoundedRectangle(cornerRadius: 12).fill(ShopTheme.blue))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibility(identifier: "cart-toast")
                        .transition(reduceMotion ? .opacity : .opacity.combined(with: .offset(y: 12)))
                        .padding(.horizontal, 12)
                        .padding(.bottom, 72)
                    }
                }
            )
            .onReceive(viewModel.$toast.removeDuplicates()) { message in
                withAnimation(.easeInOut(duration: reduceMotion ? 0.10 : 0.24)) {
                    visibleToast = message
                }
            }
            .modifier(KeyboardOverlayLayout())
            // Animate tab presentation only; countdown/cart updates remain immediate.
            .onReceive(viewModel.$tab.removeDuplicates()) { tab in
                guard tab != displayedTab else { return }
                withAnimation(.easeOut(duration: reduceMotion ? 0.08 : 0.12)) {
                    displayedTab = tab
                }
            }
            .sheet(item: $viewModel.sheet) { NativeSheetView(destination: $0, onBuy: viewModel.buy) }
            .accessibility(identifier: "native-shop-root")
    }
    private func tabPresentation(_ tab: ShopTab) -> NativeTabPresentation {
        NativeTabPresentation(tab: tab, selected: displayedTab,
                              interactive: viewModel.tab == tab)
    }

    private var news: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                SectionHeader(spacing: 12, title: "Bài Viết Nổi Bật", icon: "tab_news", iconColor: ShopTheme.blue)
                NativeArticleList(articles: viewModel.home.catalog.articles,
                                  onSelect: { viewModel.sheet = .article($0) },
                                  gap: 12, cardPadding: 6, textGap: 12)
                    .padding(.bottom, 36)
            }
        }
    }
    private func showsEmptyState(_ tab: ShopTab) -> Bool {
        tab == .account || tab == .cart
    }

}

// Keep each tab mounted so switching preserves its local state and scroll position.
private struct NativeTabPresentation: ViewModifier {
    let tab: ShopTab
    let selected: ShopTab
    let interactive: Bool

    func body(content: Content) -> some View {
        content
            .opacity(selected == tab ? 1 : 0)
            .allowsHitTesting(interactive)
            .accessibility(hidden: !interactive)
    }
}

// Keep the app at full height while the system keyboard overlays the tabbar.
private struct KeyboardOverlayLayout: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 14.0, *) {
            content.ignoresSafeArea(.keyboard, edges: .bottom)
        } else {
            content
        }
    }
}
