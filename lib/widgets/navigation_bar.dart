import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'flash_countdown.dart';

/// Owns tab feedback and indicator motion; routing remains in ShopViewModel.
class ShopNavigationBar extends StatefulWidget {
  const ShopNavigationBar({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.cartCount,
  });

  static const contentHeight = 60.0;
  static const topRadius = 24.0;

  final int selected;
  final ValueChanged<int> onSelected;
  final int cartCount;

  @override
  State<ShopNavigationBar> createState() => _ShopNavigationBarState();
}

class _ShopNavigationBarState extends State<ShopNavigationBar>
    with TickerProviderStateMixin {
  late final _position = AnimationController.unbounded(
    vsync: this,
    value: widget.selected.toDouble(),
  );
  late final _glow = AnimationController(
    vsync: this,
    value: 1,
    duration: const Duration(milliseconds: 120),
  );
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _position.value = widget.selected.toDouble();
      _glow.value = 1;
    }
  }

  @override
  void didUpdateWidget(ShopNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) unawaited(_moveIndicator());
  }

  Future<void> _moveIndicator() async {
    if (_reduceMotion) {
      _position.value = widget.selected.toDouble();
      _glow.value = 1;
      return;
    }
    _glow.value = 0;
    try {
      // Cancelling a previous travel also cancels its pending glow reveal.
      await _position
          .animateTo(
            widget.selected.toDouble(),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
          )
          .orCancel;
      if (mounted) await _glow.forward().orCancel;
    } on TickerCanceled {
      // A new selection or disposal owns the animation from this point.
    }
  }

  @override
  void dispose() {
    _position.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ShopNavigationBar.topRadius),
      ),
      boxShadow: [
        BoxShadow(
          color: Color(0x09000000),
          blurRadius: 10,
          offset: Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      maintainBottomViewPadding: true,
      child: SizedBox(
        height: ShopNavigationBar.contentHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _TabIndicatorPainter(
                      position: _position,
                      glow: _glow,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: List.generate(
                  _TabButton.labels.length,
                  (index) => Expanded(
                    child: _TabButton(
                      index: index,
                      active: widget.selected == index,
                      cartCount: widget.cartCount,
                      reduceMotion: _reduceMotion,
                      onTap: () {
                        unawaited(HapticFeedback.lightImpact());
                        widget.onSelected(index);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.index,
    required this.active,
    required this.cartCount,
    required this.reduceMotion,
    required this.onTap,
  });

  static const labels = [
    'Trang chủ',
    'Giỏ hàng',
    'Danh mục',
    'Tin tức',
    'Tài khoản',
  ];
  static const icons = ['home', 'cart', 'category', 'news', 'account'];

  final int index;
  final bool active;
  final int cartCount;
  final bool reduceMotion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 160);
    return Semantics(
      label: labels[index],
      button: true,
      selected: active,
      child: GestureDetector(
        key: ValueKey('tab-$index'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Column(
            children: [
              const SizedBox(height: 11),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Both assets retain their identity as the shape crossfades.
                  Stack(
                    children: [
                      AnimatedOpacity(
                        opacity: active ? 0 : 1,
                        duration: duration,
                        curve: Curves.easeInOut,
                        child: FigmaIcon(
                          'tab_${icons[index]}',
                          color: const Color(0xFFC4CDD5),
                          size: 25,
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: active ? 1 : 0,
                        duration: duration,
                        curve: Curves.easeInOut,
                        child: FigmaIcon(
                          'tab_${icons[index]}_active',
                          color: AppColors.brightBlue,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                  if (index == 1)
                    Positioned(
                      right: -8,
                      top: -5,
                      child: _CartCountBadge(
                        count: cartCount,
                        reduceMotion: reduceMotion,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: duration,
                curve: Curves.easeInOut,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  fontSize: 10,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.brightBlue : AppColors.muted,
                ),
                child: Text(
                  labels[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartCountBadge extends StatelessWidget {
  const _CartCountBadge({required this.count, required this.reduceMotion});

  final int count;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: count > 0 ? 1 : 0,
    duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 220),
    child: Container(
      key: const ValueKey('cart-count-badge'),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: RollingNumber(value: '$count'),
    ),
  );
}

/// Repaints only the small marker surface, leaving the tab layout untouched.
class _TabIndicatorPainter extends CustomPainter {
  _TabIndicatorPainter({required this.position, required this.glow})
    : super(repaint: Listenable.merge([position, glow]));

  final Animation<double> position;
  final Animation<double> glow;

  @override
  void paint(Canvas canvas, Size size) {
    final tabWidth = math.max(0.0, size.width - 16) / _TabButton.labels.length;
    final markerWidth = math.min(50.0, tabWidth * .72);
    final left = 8 + tabWidth * (position.value + .5) - markerWidth / 2;
    if (glow.value > 0) {
      final rect = Rect.fromLTWH(left, 4, markerWidth, 16 * glow.value);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.brightBlue.withValues(alpha: .1 * glow.value),
              AppColors.brightBlue.withValues(alpha: 0),
            ],
          ).createShader(rect),
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(left, 0, markerWidth, 4),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      ),
      Paint()..color = AppColors.blue,
    );
  }

  @override
  bool shouldRepaint(_TabIndicatorPainter oldDelegate) =>
      position != oldDelegate.position || glow != oldDelegate.glow;
}
