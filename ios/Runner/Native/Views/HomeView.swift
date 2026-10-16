import SwiftUI
import Combine

struct NativeHomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    let onCategory: (String) -> Void
    let onBuy: (Product) -> Void
    let onNews: () -> Void
    var isActive = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var bannerDeadline = Date().addingTimeInterval(4)
    @State private var isInteractingWithBanner = false
    private let bannerTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ShopImage(name: "welcome_banner").aspectRatio(369 / 65, contentMode: .fit).cornerRadius(8).padding(.horizontal, 12).padding(.top, 12)
                    featuredCategories
                    carousel(width: max(1, geometry.size.width - 24))
                    flashSale
                    SectionHeader(spacing: 12, topPadding: 18, title: "Thương Hiệu Nổi Bật", icon: "brand")
                    brands
                    SectionHeader(spacing: 12, topPadding: 18, title: "Sản Phẩm Bán Chạy", icon: "like", iconColor: ShopTheme.blue, action: { onCategory("air") })
                    productRow(limited: true)
                    promos(width: max(1, geometry.size.width - 24))
                    SectionHeader(spacing: 12, topPadding: 18, title: "Dành Cho Bạn", icon: "star", iconColor: ShopTheme.blue, action: { onCategory("air") })
                    recommended
                    VStack(spacing: 0) {
                        SectionHeader(spacing: 12, title: "Hàng Mới Về", icon: "new-arrivals", color: .white, actionColor: .white, action: { onCategory("air") })
                        productRow().padding(.bottom, 12)
                    }.background(ShopTheme.blue).padding(.top, 18)
                    SectionHeader(spacing: 12, topPadding: 18, title: "Bài Viết Nổi Bật", icon: "tab_news", iconColor: ShopTheme.blue, action: onNews)
                    NativeArticleList(articles: viewModel.catalog.articles, gap: 12, textGap: 12).padding(.bottom, 36)
                }
            }.accessibility(identifier: "native-home")
                .onReceive(bannerTimer) { _ in
                    guard isActive, !reduceMotion, !isInteractingWithBanner, Date() >= bannerDeadline,
                          UIApplication.shared.applicationState == .active else { return }
                    bannerDeadline = Date().addingTimeInterval(4)
                    withAnimation(.easeInOut(duration: 0.45)) {
                        viewModel.banner = (viewModel.banner + 1) % 3
                    }
                }
        }
    }
    private var featuredCategories: some View {
        NativeFeaturedCategories(categories: viewModel.catalog.featuredCategories, onCategory: onCategory)
    }
    @ViewBuilder private func carousel(width: CGFloat) -> some View {
        if #available(iOS 14.0, *) {
            TabView(selection: $viewModel.banner) {
                ForEach(0..<3) { index in
                    ShopImage(name: "offer_banner", width: width, height: 170, fit: .fill).cornerRadius(8).tag(index)
                }
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)).frame(height: 170)
                .background(BannerTouchObserver { touching in
                    isInteractingWithBanner = touching
                    bannerDeadline = Date().addingTimeInterval(4)
                })
                .onReceive(viewModel.$banner.dropFirst()) { _ in
                    bannerDeadline = Date().addingTimeInterval(4)
                }
        } else {
            // Maintain iOS 13 support without requiring PageTabViewStyle.
            ScrollView(.horizontal, showsIndicators: false) { HStack { ShopImage(name: "offer_banner", width: width, height: 170, fit: .fill).cornerRadius(8) }.padding(.horizontal, 12) }
        }
        HStack(spacing: 3) {
            ForEach(0..<3) { index in
                Capsule()
                    .fill(viewModel.banner == index ? ShopTheme.brightBlue : Color(hex: 0xC4CDD5))
                    .frame(width: 20, height: 3)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.20))
        .frame(maxWidth: .infinity).padding(.top, 12).padding(.bottom, 18)
    }
    private var flashSale: some View {
        VStack(spacing: 0) {
            SectionHeader(spacing: 12, title: "FLASH SALE", icon: "flash",
                          iconColor: ShopTheme.flash, color: ShopTheme.text,
                          accessory: AnyView(FlashCountdown(values: viewModel.clock)), actionColor: ShopTheme.flash, action: { onCategory("air") })
            productRow(flash: true).padding(.bottom, 12)
        }.background(LinearGradient(gradient: Gradient(colors: [Color(hex: 0xFFE4BF), Color(hex: 0xFFFAF4)]), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
    private var brands: some View {
        VStack(spacing: 6) {
            ForEach(0..<2) { row in
                HStack(spacing: 6) {
                    ForEach(0..<5) { column in
                        Button(action: { onCategory("air") }) {
                            GeometryReader { geometry in
                                Image("brand_\(row * 5 + column)").resizable().scaledToFill()
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                            }.aspectRatio(1.3, contentMode: .fit)
                        }.buttonStyle(PlainButtonStyle()).frame(maxWidth: .infinity)
                    }
                }
            }
        }.padding(.horizontal, 12)
    }
    private func productRow(flash: Bool = false, limited: Bool = false) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.catalog.products) { product in
                    NativeProductCard(product: product, flash: flash, limited: limited, onBuy: { onBuy(product) })
                }
            }
        }.clipped().padding(.horizontal, 12)
    }
    private func promo(_ name: String) -> some View {
        Button(action: { onCategory("air") }) { ShopImage(name: name, fit: .fill).cornerRadius(12) }.buttonStyle(PlainButtonStyle())
    }
    private func promos(width: CGFloat) -> some View {
        HStack(spacing: 12) {
            VStack(spacing: 12) { promo("promo_red"); promo("promo_yellow") }
            promo("promo_blue")
        }.frame(height: width * 270 / 369).padding(.horizontal, 12).padding(.top, 12)
    }
    private var recommended: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                promo("recommend_banner").frame(width: 150, height: 291)
                ForEach(viewModel.catalog.products) { product in
                    NativeProductCard(product: product, onBuy: { onBuy(product) })
                }
            }
        }.clipped().padding(.horizontal, 12)
    }
}

// Own scroll geometry locally so progress updates do not rebuild the whole Home.
private struct NativeFeaturedCategories: View {
    let categories: [CatalogCategory]
    let onCategory: (String) -> Void
    @State private var progress: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(spacing: 12, topPadding: 18, title: "Danh mục tiêu biểu", color: ShopTheme.featuredCategoryTitle)
            FeaturedCategoriesScroller(categories: categories, onCategory: onCategory) { value in
                progress = value
            }.frame(height: 98)
            ZStack(alignment: .leading) {
                Capsule().fill(Color(hex: 0xDFE3E8)).frame(width: 59, height: 6)
                Capsule().fill(ShopTheme.blue).frame(width: 24, height: 6)
                    .offset(x: (59 - 24) * progress)
            }.frame(maxWidth: .infinity).padding(.top, 12).padding(.bottom, 12)
        }
    }
}

// Read UIScrollView's real contentOffset rather than SwiftUI layout preferences.
struct FeaturedCategoriesScroller: UIViewRepresentable {
    let categories: [CatalogCategory]
    let onCategory: (String) -> Void
    let onProgress: (CGFloat) -> Void

    func makeUIView(context: Context) -> FeaturedCategoriesScrollView {
        FeaturedCategoriesScrollView()
    }
    func updateUIView(_ view: FeaturedCategoriesScrollView, context: Context) {
        view.configure(categories: categories, onCategory: onCategory, onProgress: onProgress)
    }
}

final class FeaturedCategoriesScrollView: UIScrollView, UIScrollViewDelegate {
    private let stack = UIStackView()
    private var categories: [CatalogCategory] = []
    private var signature: [String] = []
    private var onCategory: (String) -> Void = { _ in }
    private var onProgress: (CGFloat) -> Void = { _ in }

    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isDirectionalLockEnabled = true
        contentInsetAdjustmentBehavior = .never
        accessibilityIdentifier = "featured-category-scroll"
        stack.axis = .horizontal
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            stack.heightAnchor.constraint(equalTo: frameLayoutGuide.heightAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(categories: [CatalogCategory], onCategory: @escaping (String) -> Void,
                   onProgress: @escaping (CGFloat) -> Void) {
        self.onCategory = onCategory
        self.onProgress = onProgress
        self.categories = categories
        let newSignature = categories.map { $0.id + $0.name + $0.image }
        guard signature != newSignature else { return }
        signature = newSignature
        stack.arrangedSubviews.forEach { stack.removeArrangedSubview($0); $0.removeFromSuperview() }
        for index in 0..<(categories.count * 2) {
            let category = categories[index % categories.count]
            let button = UIButton(type: .custom)
            button.tag = index
            button.backgroundColor = .white
            button.layer.cornerRadius = 6
            button.accessibilityLabel = category.name
            button.addTarget(self, action: #selector(selectCategory(_:)), for: .touchUpInside)
            let image = UIImageView(image: UIImage(named: category.image))
            image.contentMode = .scaleAspectFit
            image.isUserInteractionEnabled = false
            let title = UILabel()
            title.text = category.name
            title.font = UIFont(name: "Inter-Regular", size: 11) ?? .systemFont(ofSize: 11)
            title.textColor = UIColor(red: 28.0/255, green: 37.0/255, blue: 46.0/255, alpha: 1)
            title.numberOfLines = 2
            title.textAlignment = .center
            for child in [image, title] {
                child.translatesAutoresizingMaskIntoConstraints = false
                button.addSubview(child)
            }
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 77),
                image.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 6),
                image.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -6),
                image.topAnchor.constraint(equalTo: button.topAnchor, constant: 6),
                image.heightAnchor.constraint(equalToConstant: 48),
                title.leadingAnchor.constraint(equalTo: image.leadingAnchor),
                title.trailingAnchor.constraint(equalTo: image.trailingAnchor),
                title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 6),
                title.heightAnchor.constraint(equalToConstant: 32)
            ])
            stack.addArrangedSubview(button)
        }
    }
    @objc private func selectCategory(_ button: UIButton) {
        guard !categories.isEmpty else { return }
        onCategory(categories[button.tag % categories.count].id)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let extent = max(0, contentSize.width - bounds.width)
        onProgress(extent > 0 ? min(1, max(0, contentOffset.x / extent)) : 0)
    }
}

// Observe touches without competing with the pager's own pan recognizer.
private struct BannerTouchObserver: UIViewRepresentable {
    let onTouch: (Bool) -> Void
    func makeUIView(context: Context) -> BannerTouchSurface { BannerTouchSurface() }
    func updateUIView(_ view: BannerTouchSurface, context: Context) { view.onTouch = onTouch }
}

private final class BannerTouchSurface: UIView, UIGestureRecognizerDelegate {
    var onTouch: (Bool) -> Void = { _ in }
    private weak var observedWindow: UIWindow?
    private lazy var observer: BannerTouchRecognizer = {
        let gesture = BannerTouchRecognizer()
        gesture.cancelsTouchesInView = false
        gesture.delaysTouchesBegan = false
        gesture.delegate = self
        gesture.changed = { [weak self] touching in self?.onTouch(touching) }
        return gesture
    }()
    override func didMoveToWindow() {
        super.didMoveToWindow()
        observedWindow?.removeGestureRecognizer(observer)
        observedWindow = window
        window?.addGestureRecognizer(observer)
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let window = window else { return false }
        return bounds.contains(convert(touch.location(in: window), from: window))
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { true }
    deinit { observedWindow?.removeGestureRecognizer(observer) }
}

private final class BannerTouchRecognizer: UIGestureRecognizer {
    var changed: (Bool) -> Void = { _ in }
    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool { false }
    override func canBePrevented(by preventingGestureRecognizer: UIGestureRecognizer) -> Bool { false }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .began
        changed(true)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) { state = .changed }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if numberOfTouches <= touches.count { changed(false); state = .ended }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) { changed(false); state = .cancelled }
}
