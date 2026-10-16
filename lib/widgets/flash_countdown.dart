import 'package:flutter/material.dart';
import '../theme.dart';

class FlashCountdown extends StatelessWidget {
  const FlashCountdown({super.key, required this.values});
  final List<String> values;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < values.length; i++) ...[
        if (i > 0)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.red,
              ),
            ),
          ),
        _CountdownTile(key: ValueKey('countdown-unit-$i'), value: values[i]),
      ],
    ],
  );
}

class _CountdownTile extends StatelessWidget {
  const _CountdownTile({super.key, required this.value});
  final String value;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Container(
      width: 26,
      height: 26,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xE6FFFFFF), Color(0x1FFFFFFF)],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(3.5),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < value.length; i++)
                _RollingDigit(value: value[i]),
            ],
          ),
        ),
      ),
    ),
  );
}

class _RollingDigit extends StatelessWidget {
  const _RollingDigit({required this.value, this.fontSize = 13});
  final String value;
  final double fontSize;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: fontSize * 0.62,
    height: fontSize * 1.4,
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
                begin: Offset(0, incoming ? -0.65 : 0.65),
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
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ),
    ),
  );
}

class RollingNumber extends StatelessWidget {
  const RollingNumber({super.key, required this.value, this.fontSize = 9});
  final String value;
  final double fontSize;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < value.length; i++)
        _RollingDigit(value: value[i], fontSize: fontSize),
    ],
  );
}
