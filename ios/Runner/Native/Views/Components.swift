import SwiftUI
import UIKit

struct ShopImage: View {
    let name: String
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var fit: ContentMode = .fit
    var body: some View {
        Image(name).resizable().aspectRatio(contentMode: fit).frame(width: width, height: height).clipped()
    }
}
struct FigmaIcon: View {
    let name: String
    var size: CGFloat = 24
    var color: Color? = nil
    var body: some View {
        Group {
            if color != nil {
                Image("ic_" + name).renderingMode(.template).resizable().aspectRatio(contentMode: .fit).foregroundColor(color)
            } else {
                Image("ic_" + name).renderingMode(.original).resizable().aspectRatio(contentMode: .fit)
            }
        }.frame(width: size, height: size).accessibility(hidden: true)
    }
}
struct SeeAllButton: View {
    var color: Color = ShopTheme.blue
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Text("Xem tất cả").font(ShopTheme.font(9))
                FigmaIcon(name: "chevrons", size: 12, color: color)
            }.foregroundColor(color).padding(.vertical, 4)
        }.buttonStyle(PlainButtonStyle())
    }
}
struct SectionHeader: View {
    let title: String
    let icon: String
    var light = false
    var action: (() -> Void)? = nil
    var body: some View {
        HStack(spacing: 9) {
            FigmaIcon(name: icon)
            Text(title).font(ShopTheme.font(16, .semibold)).foregroundColor(light ? .white : ShopTheme.text)
            Spacer(minLength: 4)
            if let action = action { SeeAllButton(color: light ? .white : ShopTheme.blue, action: action) }
        }.padding(.horizontal, 12).padding(.top, 24).padding(.bottom, 16)
    }
}
struct TopRoundedShape: Shape {
    var radius: CGFloat = 16
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
}
struct NativeHeader: View {
    @ObservedObject var viewModel: ShopViewModel
    var body: some View {
        HStack(spacing: 18) {
            if viewModel.tab == .category {
                Button(action: { viewModel.selectTab(.home) }) { FigmaIcon(name: "back", size: 21) }
                    .accessibility(label: Text("Trang chủ"))
            }
            HStack(spacing: 8) {
                FigmaIcon(name: "search", size: 20, color: ShopTheme.muted)
                TextField("Tìm kiếm sản phẩm", text: Binding(get: { viewModel.query }, set: viewModel.search), onCommit: viewModel.submitSearch)
                    .font(ShopTheme.font(15)).autocapitalization(.none).disableAutocorrection(true)
                    .accessibility(identifier: "search-field")
                Button(action: { viewModel.sheet = .notice("Tìm kiếm bằng hình ảnh sẽ sớm được cập nhật.") }) { FigmaIcon(name: "camera", size: 20, color: ShopTheme.blue) }
                    .accessibility(label: Text("Tìm kiếm bằng hình ảnh"))
            }.padding(.horizontal, 12).frame(height: 38).background(Color.white).cornerRadius(24)
            Button(action: { viewModel.sheet = .notice("Bạn chưa có thông báo mới.") }) { FigmaIcon(name: "notification", size: 40) }
                .accessibility(label: Text("Thông báo"))
        }.buttonStyle(PlainButtonStyle()).padding(.horizontal, 12).padding(.top, 10).padding(.bottom, 11).background(ShopTheme.blue)
    }
}
// UIKit animates only this small surface; tab content does not need per-frame layout.
private struct NativeTabIndicator: UIViewRepresentable {
    let selection: ShopTab
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeUIView(context: Context) -> TabIndicatorSurface {
        TabIndicatorSurface(selection: selection.rawValue)
    }
    func updateUIView(_ view: TabIndicatorSurface, context: Context) {
        view.select(selection.rawValue, animated: !reduceMotion)
    }
}

private final class TabIndicatorSurface: UIView {
    private let marker = UIView()
    private let bar = UIView()
    private let glow = UIView()
    private let gradient = CAGradientLayer()
    private var selection: Int
    private var generation = 0
    private var previousSize: CGSize = .zero

    init(selection: Int) {
        self.selection = selection
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        addSubview(marker)
        marker.addSubview(glow)
        marker.addSubview(bar)
        bar.backgroundColor = ShopTheme.tabIndicatorUIColor
        bar.layer.cornerRadius = 4
        bar.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradient.colors = [ShopTheme.tabGlowUIColor.cgColor,
                           ShopTheme.tabGlowUIColor.withAlphaComponent(0).cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        glow.layer.addSublayer(gradient)
        glow.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private var tabWidth: CGFloat { max(0, bounds.width - 16) / CGFloat(ShopTab.allCases.count) }
    private var targetX: CGFloat { 8 + tabWidth * (CGFloat(selection) + 0.5) }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.size != previousSize else { return }
        previousSize = bounds.size
        generation += 1
        marker.layer.removeAllAnimations()
        glow.layer.removeAllAnimations()
        UIView.performWithoutAnimation {
            let width = min(50, tabWidth * 0.72)
            marker.bounds = CGRect(x: 0, y: 0, width: width, height: 20)
            marker.center = CGPoint(x: targetX, y: 10)
            bar.frame = CGRect(x: 0, y: 0, width: width, height: 4)
            glow.transform = .identity
            glow.bounds = CGRect(x: 0, y: 0, width: width, height: 16)
            glow.layer.position = CGPoint(x: width / 2, y: 4)
            glow.alpha = 1
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradient.frame = glow.bounds
        CATransaction.commit()
    }

    func select(_ value: Int, animated: Bool) {
        guard value != selection else { return }
        selection = value
        generation += 1
        let token = generation
        guard bounds.width > 0 else { return }
        // Hide the glow during travel, even when a previous reveal is interrupted.
        glow.layer.removeAllAnimations()
        glow.alpha = 0
        glow.transform = CGAffineTransform(scaleX: 1, y: 0.01)
        guard animated else {
            marker.layer.removeAllAnimations()
            marker.center.x = targetX
            glow.transform = .identity
            glow.alpha = 1
            return
        }
        UIView.animate(withDuration: 0.20, delay: 0,
                       options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut],
                       animations: { self.marker.center.x = self.targetX }) { [weak self] finished in
            guard let self = self, finished, self.generation == token else { return }
            UIView.animate(withDuration: 0.12, delay: 0,
                           options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut]) {
                self.glow.alpha = 1
                self.glow.transform = .identity
            }
        }
    }
}

private struct TabAppearanceAnimation: ViewModifier {
    let active: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ViewBuilder func body(content: Content) -> some View {
        let fade = Animation.easeInOut(duration: reduceMotion ? 0.08 : 0.16)
        if #available(iOS 15.0, *) {
            content.animation(fade, value: active)
        } else {
            content.animation(fade)
        }
    }
}

struct NativeNavigationBar: View {
    @ObservedObject var viewModel: ShopViewModel
    let selectedTab: ShopTab
    @State private var haptics = UIImpactFeedbackGenerator(style: .light)
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ShopTab.allCases, id: \.rawValue) { tab in
                Button(action: {
                    haptics.impactOccurred(intensity: 0.4)
                    haptics.prepare()
                    viewModel.selectTab(tab)
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    VStack(spacing: 4) {
                        Color.clear.frame(height: 4)
                        ZStack(alignment: .topTrailing) {
                            // Keep both assets mounted so shape and color crossfade together.
                            ZStack {
                                FigmaIcon(name: "tab_" + tab.icon, size: 25, color: Color(hex: 0xC4CDD5))
                                    .opacity(selectedTab == tab ? 0 : 1)
                                FigmaIcon(name: "tab_" + tab.icon + "_active", size: 25, color: ShopTheme.brightBlue)
                                    .opacity(selectedTab == tab ? 1 : 0)
                            }
                            .modifier(TabAppearanceAnimation(active: selectedTab == tab))
                            if tab == .cart && viewModel.cart.itemCount > 0 {
                                Text("\(viewModel.cart.itemCount)").font(ShopTheme.font(9)).foregroundColor(.white).padding(3).background(ShopTheme.red).clipShape(Circle()).offset(x: 8, y: -5)
                            }
                        }.padding(.top, 3)
                        ZStack {
                            Text(tab.title).foregroundColor(ShopTheme.muted)
                                .opacity(selectedTab == tab ? 0 : 1)
                            Text(tab.title).foregroundColor(ShopTheme.brightBlue)
                                .opacity(selectedTab == tab ? 1 : 0)
                        }
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .lineLimit(1).minimumScaleFactor(0.7)
                        .accessibility(hidden: true)
                        .modifier(TabAppearanceAnimation(active: selectedTab == tab))
                        Spacer(minLength: 0)
                    }.frame(maxWidth: .infinity).frame(height: 60).contentShape(Rectangle())
                }.buttonStyle(PlainButtonStyle()).accessibility(identifier: "tab-\(tab.rawValue)").accessibility(label: Text(tab.title)).accessibility(addTraits: selectedTab == tab ? .isSelected : [])
            }
        }
        .padding(.horizontal, 8)
        .background(
            NativeTabIndicator(selection: selectedTab)
            .allowsHitTesting(false)
            .accessibility(hidden: true)
        )
        .background(
            TopRoundedShape(radius: 24).fill(Color.white)
                .edgesIgnoringSafeArea(.bottom)
                .shadow(color: Color.black.opacity(0.035), radius: 5, x: 0, y: -2)
        )
        .onAppear { haptics.prepare() }
    }
}
struct NativeProductCard: View {
    let product: Product
    var flash = false
    var limited = false
    let onDetails: () -> Void
    let onBuy: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onDetails) { ShopImage(name: product.image).frame(maxWidth: .infinity, maxHeight: .infinity) }.buttonStyle(PlainButtonStyle())
            if limited {
                HStack(spacing: 2) { FigmaIcon(name: "fire", size: 10); Text("Chỉ còn 1 sản phẩm").font(ShopTheme.font(8, .semibold)) }
                    .padding(3).background(Color(hex: 0xFFB200)).cornerRadius(10).padding(.bottom, 12)
            }
            Button(action: onDetails) { Text(product.name).font(ShopTheme.font(14, .semibold)).lineLimit(2).multilineTextAlignment(.leading).frame(height: 38, alignment: .topLeading) }.buttonStyle(PlainButtonStyle()).foregroundColor(ShopTheme.text)
            Text(ShopFormat.money(product.price)).font(ShopTheme.font(14, .bold)).foregroundColor(Color(hex: 0xCF1717)).padding(.top, 12)
            HStack(spacing: 10) {
                Text(ShopFormat.money(product.originalPrice)).strikethrough().foregroundColor(ShopTheme.muted)
                Text("-\(product.discountPercent)%").foregroundColor(ShopTheme.red)
            }.font(ShopTheme.font(10)).padding(.top, 10)
            if flash {
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: 0xF5D5D4)).frame(height: 6)
                    Capsule().fill(Color(hex: 0xFF653D)).frame(width: 83, height: 6)
                    FigmaIcon(name: "fire", size: 18).offset(x: 72)
                }.padding(.top, 15)
                Text("Đã bán \(product.soldCount) sản phẩm").font(ShopTheme.font(10)).foregroundColor(Color(hex: 0x454F5B)).padding(.top, 6)
            }
            Button(action: onBuy) {
                Text("Mua ngay").font(ShopTheme.font(11, .bold)).foregroundColor(ShopTheme.blue).frame(maxWidth: .infinity).frame(height: 26).background(ShopTheme.paleBlue).cornerRadius(4)
            }.buttonStyle(PlainButtonStyle()).padding(.top, 12).accessibility(identifier: "buy-\(product.id)")
        }.padding(8).frame(width: 148, height: flash ? 340 : limited ? 320 : 290).background(Color.white).cornerRadius(12)
    }
}
struct NativeArticleList: View {
    let articles: [Article]
    let onSelect: (Article) -> Void
    var body: some View {
        VStack(spacing: 16) {
            ForEach(articles) { article in
                Button(action: { onSelect(article) }) {
                    HStack(spacing: 16) {
                        ShopImage(name: article.image, width: 120, height: 81, fit: .fill).cornerRadius(8)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(article.title).font(ShopTheme.font(14, .semibold)).lineLimit(2).foregroundColor(ShopTheme.text)
                            Spacer(minLength: 0)
                            Text(ShopFormat.date(article.date)).font(ShopTheme.font(12)).foregroundColor(ShopTheme.blue)
                        }.frame(maxWidth: .infinity, alignment: .leading).frame(height: 81)
                    }.padding(4).background(Color.white).cornerRadius(12)
                }.buttonStyle(PlainButtonStyle())
            }
        }.padding(.horizontal, 12)
    }
}
