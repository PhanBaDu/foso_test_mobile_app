import 'package:flutter/material.dart';
import '../theme.dart';

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
                      Badge(
                        isLabelVisible: i == 1 && cartCount > 0,
                        label: Text(
                          '$cartCount',
                          style: const TextStyle(fontSize: 9),
                        ),
                        backgroundColor: const Color(0xFFFF4545),
                        child: FigmaIcon(
                          'tab_${icons[i]}${active ? "_active" : ""}',
                          color: color,
                          size: 25,
                        ),
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
