import SwiftUI
import Lottie

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
                Text("Giỏ hàng").opacity(isCart ? 1 : 0)
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
