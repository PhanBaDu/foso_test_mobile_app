import SwiftUI
import Lottie

struct NativeCartView: View {
    @ObservedObject var viewModel: CartViewModel
    var body: some View {
        Group {
            if viewModel.lines.isEmpty {
                Color.clear
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Giỏ hàng").font(.system(size: 22, weight: .bold, design: .rounded))
                        ForEach(viewModel.lines) { line in
                            HStack(spacing: 12) {
                                ShopImage(name: line.product.image, width: 96, height: 100)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(line.product.name).font(ShopTheme.font(14, .semibold))
                                    Text(ShopFormat.money(line.product.price)).font(ShopTheme.font(14, .bold)).foregroundColor(ShopTheme.red)
                                    HStack(spacing: 20) {
                                        Button("−") { viewModel.remove(line.id) }.accessibility(label: Text("Giảm số lượng"))
                                        Text("\(line.quantity)").foregroundColor(ShopTheme.text)
                                        Button("+") { viewModel.add(line.product) }.accessibility(label: Text("Tăng số lượng"))
                                    }.font(ShopTheme.font(22)).foregroundColor(ShopTheme.blue)
                                }
                            }.padding(12).background(Color.white).cornerRadius(12)
                        }
                        Text("Tổng cộng: \(ShopFormat.money(viewModel.total))").font(ShopTheme.font(18, .bold)).accessibility(identifier: "cart-total")
                    }.padding(16).padding(.bottom, 24)
                }
            }
        }.accessibility(identifier: "native-cart")
    }
}
struct NativeSheetView: View {
    let destination: ShopSheet
    let onBuy: (Product) -> Void
    @Environment(\.presentationMode) private var presentation
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                HStack { Spacer(); Button("Đóng") { presentation.wrappedValue.dismiss() }.font(ShopTheme.font(14)).foregroundColor(ShopTheme.blue) }
                if case .product(let product) = destination {
                    ShopImage(name: product.image, height: 180).frame(maxWidth: .infinity)
                    Text(product.name).font(ShopTheme.font(20, .semibold))
                    Text(ShopFormat.money(product.price)).font(ShopTheme.font(22, .bold)).foregroundColor(ShopTheme.red)
                    Button(action: { presentation.wrappedValue.dismiss(); onBuy(product) }) {
                        Text("Thêm vào giỏ hàng").font(ShopTheme.font(14, .semibold)).foregroundColor(.white).frame(maxWidth: .infinity).padding(16).background(ShopTheme.blue).cornerRadius(12)
                    }
                } else if case .article(let article) = destination {
                    ShopImage(name: article.image, height: 180).frame(maxWidth: .infinity)
                    Text(article.title).font(ShopTheme.font(20, .semibold))
                    Text(ShopFormat.date(article.date)).font(ShopTheme.font(12)).foregroundColor(ShopTheme.blue)
                } else if case .notice(let message) = destination {
                    Text(message).font(ShopTheme.font(16)).padding(.vertical, 40)
                }
            }.padding(24)
        }
    }
}

struct NativeEmptyAnimation: UIViewRepresentable {
    let isPlaying: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let animation = context.coordinator.animation
        animation.animation = LottieAnimation.named("404", subdirectory: "NativeResources/animations")
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        animation.backgroundBehavior = .pauseAndRestore
        animation.respectAnimationFrameRate = false
        animation.translatesAutoresizingMaskIntoConstraints = false
        animation.isAccessibilityElement = false
        container.addSubview(animation)
        NSLayoutConstraint.activate([
            animation.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animation.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animation.topAnchor.constraint(equalTo: container.topAnchor),
            animation.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }
    func updateUIView(_ view: UIView, context: Context) {
        let animation = context.coordinator.animation
        if isPlaying && !reduceMotion {
            if !animation.isAnimationPlaying { animation.play() }
        } else {
            animation.pause()
        }
    }
    static func dismantleUIView(_ view: UIView, coordinator: Coordinator) {
        coordinator.animation.stop()
    }
    func makeCoordinator() -> Coordinator { Coordinator() }
    final class Coordinator {
        let animation = LottieAnimationView(configuration: LottieConfiguration(renderingEngine: .automatic))
    }
}

// Shared geometry keeps the illustration and text baselines aligned across tabs.
struct NativeEmptyState: View {
    let isCart: Bool
    let isPlaying: Bool

    var body: some View {
        VStack(spacing: 0) {
            NativeEmptyAnimation(isPlaying: isPlaying)
                .frame(maxWidth: 280).frame(height: 190)
            ZStack {
                Text("Giỏ hàng của bạn đang trống").opacity(isCart ? 1 : 0)
                Text("Tài khoản").opacity(isCart ? 0 : 1)
            }
                .font(ShopTheme.emptyTitleFont)
                .foregroundColor(ShopTheme.text)
                .lineLimit(1).minimumScaleFactor(0.8)
                .frame(height: 28)
                .padding(.top, 16)
            ZStack {
                Text("Khám phá sản phẩm tại Trang chủ").opacity(isCart ? 1 : 0)
                Text("Chào mừng bạn đến với FOSO").opacity(isCart ? 0 : 1)
            }
                .font(ShopTheme.emptyDescriptionFont)
                .foregroundColor(ShopTheme.muted)
                .lineLimit(1).minimumScaleFactor(0.8)
                .frame(height: 22)
                .padding(.top, 8)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
