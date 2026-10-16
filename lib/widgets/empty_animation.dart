import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyAnimation extends StatelessWidget {
  const EmptyAnimation({super.key, required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Lottie.asset(
      'assets/animations/404.json',
      width: 280,
      height: 190,
      fit: BoxFit.contain,
      frameRate: FrameRate.max,
      animate: active && !MediaQuery.disableAnimationsOf(context),
      repeat: true,
    ),
  );
}

class SharedEmptyState extends StatelessWidget {
  const SharedEmptyState({
    super.key,
    required this.active,
    required this.isCart,
  });
  final bool active;
  final bool isCart;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The shell retains this keyed instance when Cart and Account alternate.
          EmptyAnimation(
            key: const ValueKey('shared-empty-animation'),
            active: active,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 28,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isCart ? 'Giỏ hàng' : 'Tài khoản',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 22,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isCart
                    ? 'Khám phá sản phẩm tại Trang chủ'
                    : 'Chào mừng bạn đến với FOSO',
                style: const TextStyle(fontSize: 14, color: Color(0xFF919EAB)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
