import 'package:flutter/material.dart';

/// Keeps unchanged digits mounted for both the countdown and cart badge.
class RollingNumber extends StatelessWidget {
  const RollingNumber({
    super.key,
    required this.value,
    this.fontSize = 9,
    this.digitWidth = 6,
    this.digitHeight = 12,
  });

  final String value;
  final double fontSize, digitWidth, digitHeight;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < value.length; i++)
        _RollingDigit(
          key: ValueKey(i),
          value: value[i],
          fontSize: fontSize,
          width: digitWidth,
          height: digitHeight,
        ),
    ],
  );
}

class _RollingDigit extends StatelessWidget {
  const _RollingDigit({
    super.key,
    required this.value,
    required this.fontSize,
    required this.width,
    required this.height,
  });

  final String value;
  final double fontSize, width, height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: ClipRect(
      child: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          final incoming = child.key == ValueKey(value);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, incoming ? -2 / 3 : 2 / 3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Text(
          value,
          key: ValueKey(value),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    ),
  );
}
