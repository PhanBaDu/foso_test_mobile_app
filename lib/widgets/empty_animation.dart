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
