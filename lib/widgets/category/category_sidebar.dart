import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/catalog.dart';
import '../../theme.dart';

/// One persistent background moves inside the scroll content, behind every row.
class CategorySidebar extends StatelessWidget {
  const CategorySidebar({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<CatalogCategory> categories;
  final String selectedId;
  final ValueChanged<String> onSelect;

  static const width = 90.0;
  static const rowHeight = 100.0;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = categories.indexWhere(
      (item) => item.id == selectedId,
    );
    return SizedBox(
      width: width,
      child: ColoredBox(
        color: AppColors.paleBlue,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 240),
                  curve: Curves.easeInOut,
                  top: (selectedIndex < 0 ? 0 : selectedIndex) * rowHeight,
                  left: 0,
                  width: width,
                  height: rowHeight,
                  child: const IgnorePointer(
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        color: AppColors.background,
                        shape: _InverseCategorySelection(),
                      ),
                    ),
                  ),
                ),
                Column(
                  children: List.generate(categories.length, (index) {
                    final category = categories[index];
                    final selected = category.id == selectedId;
                    return Semantics(
                      selected: selected,
                      button: true,
                      child: InkWell(
                        key: ValueKey('category-$index'),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onSelect(category.id);
                        },
                        child: SizedBox(
                          width: width,
                          height: rowHeight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                assetImage(
                                  'category_air',
                                  width: 40,
                                  height: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category.name,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.2,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? AppColors.text
                                        : const Color(0xFF003D80),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The right connectors extend into adjacent rows to join the content pane.
class _InverseCategorySelection extends ShapeBorder {
  const _InverseCategorySelection();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
  @override
  ShapeBorder scale(double t) => this;
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    const radius = 20.0;
    const k = 0.55228475;
    return Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(radius),
          bottomLeft: const Radius.circular(radius),
        ),
      )
      ..moveTo(rect.right - radius, rect.top)
      ..cubicTo(
        rect.right - radius + k * radius,
        rect.top,
        rect.right,
        rect.top - radius + k * radius,
        rect.right,
        rect.top - radius,
      )
      ..lineTo(rect.right, rect.top)
      ..close()
      ..moveTo(rect.right - radius, rect.bottom)
      ..cubicTo(
        rect.right - radius + k * radius,
        rect.bottom,
        rect.right,
        rect.bottom + radius - k * radius,
        rect.right,
        rect.bottom + radius,
      )
      ..lineTo(rect.right, rect.bottom)
      ..close();
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
}
