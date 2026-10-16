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
    var fontSize: CGFloat = 12
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Text("Xem tất cả").font(ShopTheme.font(fontSize)).lineLimit(1).fixedSize()
                FigmaIcon(name: "chevrons", size: 12, color: color).offset(y: 1)
            }.foregroundColor(color).padding(.vertical, 4)
        }.buttonStyle(PlainButtonStyle())
    }
}
struct SectionHeader: View {
    var spacing: CGFloat? = nil
    var topPadding: CGFloat? = nil
    let title: String
    var icon: String? = nil
    var iconColor: Color? = nil
    var color: Color? = nil
    var light = false
    var accessory: AnyView? = nil
    var actionColor: Color? = nil
    var action: (() -> Void)? = nil
    var body: some View {
        HStack(spacing: spacing ?? 9) {
            if let icon = icon { FigmaIcon(name: icon, color: iconColor) }
            Text(title).font(ShopTheme.font(16, .semibold)).foregroundColor(color ?? (light ? .white : ShopTheme.text)).lineLimit(1).minimumScaleFactor(0.7).frame(minHeight: 24)
            if let accessory = accessory { accessory }
            Spacer(minLength: 4)
            if let action = action { SeeAllButton(color: actionColor ?? (light ? .white : ShopTheme.blue), action: action) }
        }.padding(.horizontal, 12).padding(.top, topPadding ?? spacing ?? 24).padding(.bottom, spacing ?? 16)
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
        HStack(spacing: 0) {
            // Keep the input and arrow identities stable while animating only the slot width.
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.8)
                viewModel.goBack()
            }) { FigmaIcon(name: "arrow-left", size: 21) }
                .accessibility(label: Text("Quay lại"))
                .frame(width: 21, height: 38)
                .opacity(viewModel.returnTab != nil ? 1 : 0)
                .offset(x: viewModel.returnTab != nil ? 0 : -8)
                .frame(width: viewModel.returnTab != nil ? 39 : 0, alignment: .leading)
                .clipped()
                .allowsHitTesting(viewModel.returnTab != nil)
                .accessibility(hidden: viewModel.returnTab == nil)
            HStack(spacing: 8) {
                FigmaIcon(name: "search", size: 20, color: ShopTheme.muted)
                TextField("Tìm kiếm sản phẩm", text: Binding(get: { viewModel.query }, set: viewModel.search), onEditingChanged: { editing in
                    if editing { viewModel.beginSearch() }
                }, onCommit: viewModel.submitSearch)
                    .font(ShopTheme.font(15)).autocapitalization(.none).disableAutocorrection(true)
                    .accessibility(identifier: "search-field")
                FigmaIcon(name: "camera", size: 20, color: ShopTheme.blue)
                    .accessibility(label: Text("Tìm kiếm bằng hình ảnh"))
            }.padding(.horizontal, 12).frame(height: 38).background(Color.white).cornerRadius(24).padding(.trailing, 18)
            FigmaIcon(name: "notification", size: 40)
                .accessibility(label: Text("Thông báo"))
        }.buttonStyle(PlainButtonStyle()).padding(.horizontal, 12).padding(.top, 10).padding(.bottom, 11).background(ShopTheme.blue)
            .modifier(HeaderSearchTransition(showsBack: viewModel.returnTab != nil))
    }
}

private struct HeaderSearchTransition: ViewModifier {
    let showsBack: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ViewBuilder func body(content: Content) -> some View {
        let animation: Animation? = reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 1, blendDuration: 0.08)
        if #available(iOS 15.0, *) {
            content.animation(animation, value: showsBack)
        } else {
            content.animation(animation)
        }
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
                            if tab == .cart {
                                CartCountBadge(count: viewModel.cart.itemCount).offset(x: 8, y: -5)
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
    let onBuy: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ShopImage(name: product.image).frame(maxWidth: .infinity, maxHeight: .infinity)
            if limited {
                HStack(spacing: 3) {
                    FigmaIcon(name: "flashsale", size: 12)
                    Text("Chỉ còn 1 sản phẩm").font(ShopTheme.font(10, .semibold))
                        .foregroundColor(ShopTheme.limitedStockText).lineLimit(1)
                }
                .padding(.horizontal, 4).padding(.vertical, 3)
                .background(Color(hex: 0xFFB200)).clipShape(Capsule())
            }
            Group { Text(product.name).font(ShopTheme.font(15, .semibold)).lineLimit(2).truncationMode(.tail).multilineTextAlignment(.leading).frame(height: 40, alignment: .topLeading) }.buttonStyle(PlainButtonStyle()).foregroundColor(ShopTheme.text)
            VStack(alignment: .leading, spacing: 6) {
                Text(ShopFormat.money(product.price)).font(ShopTheme.font(16, .bold)).foregroundColor(Color(hex: 0xCF1717))
                HStack(spacing: 12) {
                    Text(ShopFormat.money(product.originalPrice)).strikethrough().foregroundColor(ShopTheme.muted)
                    Text("-\(product.discountPercent)%").foregroundColor(ShopTheme.red)
                }.font(ShopTheme.font(11))
            }
            if flash {
                SalesProgress(value: 0.63)
                Text("Đã bán \(product.soldCount) sản phẩm").font(ShopTheme.font(11)).foregroundColor(Color(hex: 0x454F5B))
            }
            Button(action: onBuy) {
                Text("Mua ngay").font(ShopTheme.font(12, .bold)).foregroundColor(ShopTheme.blue).frame(maxWidth: .infinity).frame(height: 30).background(ShopTheme.paleBlue).cornerRadius(4)
            }.buttonStyle(PlainButtonStyle()).accessibility(identifier: "buy-\(product.id)")
        }.padding(12).frame(width: 148, height: flash ? 340 : limited ? 320 : 290).background(Color.white).cornerRadius(12)
    }
}
struct NativeArticleList: View {
    let articles: [Article]
    var gap: CGFloat = 16
    var cardPadding: CGFloat = 6
    var textGap: CGFloat = 8
    var body: some View {
        VStack(spacing: gap) {
            ForEach(articles) { article in
                Group {
                    HStack(spacing: gap) {
                        ShopImage(name: article.image, width: 120, height: 96, fit: .fill).cornerRadius(12)
                        VStack(alignment: .leading, spacing: textGap) {
                            Text(article.title).font(ShopTheme.font(14, .semibold)).lineLimit(3).truncationMode(.tail).foregroundColor(ShopTheme.text)
                            Spacer(minLength: 0)
                            Text(ShopFormat.date(article.date)).font(ShopTheme.font(12)).foregroundColor(ShopTheme.blue)
                        }.frame(maxWidth: .infinity, alignment: .leading).frame(height: 96)
                    }.padding(cardPadding).background(Color.white).cornerRadius(16)
                }.buttonStyle(PlainButtonStyle())
            }
        }.padding(.horizontal, 12)
    }
}

struct FlashCountdown: View {
    let values: [String]
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<values.count, id: \.self) { index in
                if index > 0 { Text(":").font(ShopTheme.font(13, .semibold)).foregroundColor(ShopTheme.red) }
                CountdownTile(value: values[index])
            }
        }.fixedSize()
    }
}

private struct CountdownTile: View {
    let value: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5).fill(ShopTheme.red)
            HStack(spacing: 0) {
                ForEach(Array(value).indices, id: \.self) { index in
                    ZStack {
                        Text(String(Array(value)[index]))
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white).id(Array(value)[index])
                            .transition(.asymmetric(
                                insertion: .offset(y: -12).combined(with: .opacity),
                                removal: .offset(y: 12).combined(with: .opacity)))
                    }
                    .frame(width: 8, height: 18).clipped()
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.22))
                }
            }
            RoundedRectangle(cornerRadius: 5).stroke(
                LinearGradient(gradient: Gradient(colors: [.white.opacity(0.9), .white.opacity(0.12)]),
                               startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
        }.frame(width: 26, height: 26)
            .accessibilityElement(children: .ignore).accessibility(label: Text(value))
    }
}

struct SalesProgress: View {
    var value: CGFloat = 0.63
    var body: some View {
        GeometryReader { geometry in
            let progress = min(1, max(0, value))
            ZStack(alignment: .leading) {
                Capsule().fill(ShopTheme.salesProgressTrack).frame(height: 6)
                Capsule().fill(LinearGradient(
                    gradient: Gradient(colors: [ShopTheme.salesProgressStart, ShopTheme.salesProgressEnd]),
                    startPoint: .leading, endPoint: .trailing))
                    .frame(width: geometry.size.width * progress, height: 6)
                FigmaIcon(name: "flashsale", size: 22)
                    .zIndex(1)
                    .offset(x: min(max(0, geometry.size.width - 22), max(0, geometry.size.width * progress - 11)))
            }.frame(height: 22)
        }.frame(height: 22).accessibility(hidden: true)
    }
}

private struct CartCountBadge: View {
    let count: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(String(count)).indices, id: \.self) { index in
                ZStack {
                    Text(String(Array(String(count))[index]))
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white).id(Array(String(count))[index])
                        .transition(.asymmetric(insertion: .offset(y: -8).combined(with: .opacity),
                                                removal: .offset(y: 8).combined(with: .opacity)))
                }.frame(width: 6, height: 12).clipped()
            }
        }
        .padding(.horizontal, 4).frame(minWidth: 16, minHeight: 16)
        .background(Capsule().fill(ShopTheme.red))
        .scaleEffect(count > 0 ? 1 : 0.5).opacity(count > 0 ? 1 : 0)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.22))
        .accessibilityElement(children: .ignore).accessibility(label: Text("Giỏ hàng, \(count) sản phẩm"))
        .accessibility(hidden: count == 0)
    }
}
