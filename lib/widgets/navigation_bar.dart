import 'package:flutter/material.dart';
import '../theme.dart';
import 'flash_countdown.dart';

class ShopNavigationBar extends StatelessWidget {
  const ShopNavigationBar({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.cartCount,
  });
  final int selected;
  final ValueChanged<int> onSelected;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    const labels = [
      'Trang chủ',
      'Giỏ hàng',
      'Danh mục',
      'Tin tức',
      'Tài khoản',
    ];
    const icons = ['home', 'cart', 'category', 'news', 'account'];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        maintainBottomViewPadding: true,
        child: SizedBox(
          height: 74,
          child: Row(
            children: List.generate(5, (i) {
              final active = selected == i;
              final color = active
                  ? AppColors.brightBlue
                  : const Color(0xFFC4CDD5);
              return Expanded(
                child: InkWell(
                  key: ValueKey('tab-$i'),
                  onTap: () => onSelected(i),
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        width: 50,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.brightBlue
                              : Colors.transparent,
                          boxShadow: active
                              ? [
                                  const BoxShadow(
                                    color: Color(0x66037AFF),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          FigmaIcon(
                            'tab_${icons[i]}${active ? "_active" : ""}',
                            color: color,
                            size: 25,
                          ),
                          if (i == 1)
                            Positioned(
                              right: -8,
                              top: -5,
                              child: AnimatedScale(
                                scale: cartCount > 0 ? 1 : 0,
                                duration:
                                    MediaQuery.disableAnimationsOf(context)
                                    ? Duration.zero
                                    : const Duration(milliseconds: 220),
                                child: Container(
                                  key: const ValueKey('cart-count-badge'),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: RollingNumber(value: '$cartCount'),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 10,
                          color: active
                              ? AppColors.brightBlue
                              : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
