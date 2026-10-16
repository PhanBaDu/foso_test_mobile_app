import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/catalog.dart';
import '../view_models/category_view_model.dart';
import '../theme.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({
    super.key,
    required this.viewModel,
    required this.onBuy,
  });
  final CategoryViewModel viewModel;
  final ValueChanged<Product> onBuy;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _contentController = ScrollController();
  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final matches = vm.matches;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 90,
              child: ColoredBox(
                color: AppColors.paleBlue,
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 240),
                        curve: Curves.easeInOutCubic,
                        top:
                            vm.catalog.categories.indexWhere(
                              (category) => category.id == vm.selectedId,
                            ) *
                            100.0,
                        left: 0,
                        width: 90,
                        height: 100,
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
                        children: List.generate(vm.catalog.categories.length, (
                          i,
                        ) {
                          final category = vm.catalog.categories[i];
                          return InkWell(
                            key: ValueKey('category-$i'),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              vm.select(category.id);
                              _contentController.jumpTo(0);
                            },
                            child: Container(
                              height: 100,
                              padding: const EdgeInsets.fromLTRB(12, 16, 8, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  assetImage(
                                    'category_air',
                                    width: 40,
                                    height: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Text(
                                      category.name.replaceFirst(
                                        'Bộ Lọc ',
                                        'Bộ Lọc\n',
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        height: 1.25,
                                        fontWeight: FontWeight.w600,
                                        color: vm.selectedId == category.id
                                            ? AppColors.text
                                            : const Color(0xFF003D80),
                                      ),
                                    ),
                                  ),
                                ],
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
            Expanded(
              child: CustomScrollView(
                controller: _contentController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        height: 56,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE7E9ED)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                vm.selected.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const FigmaIcon(
                              'arrow-right-2',
                              size: 24,
                              color: AppColors.text,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (matches.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Không tìm thấy sản phẩm',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  else
                    for (var section = 0; section < 3; section++) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 18, 12, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Sub Category ${section + 1}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: null,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Xem tất cả',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.brightBlue,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    FigmaIcon('chevrons', size: 12),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((context, row) {
                            final compact =
                                MediaQuery.sizeOf(context).width < 360;
                            return SizedBox(
                              height: row == 0 ? 134 : 106,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(3, (column) {
                                  final position = row * 3 + column;
                                  if (position >= matches.length) {
                                    return const Expanded(child: SizedBox());
                                  }
                                  final filter = matches[position];
                                  final label =
                                      filter.name == 'Bộ lọc trong cabin'
                                      ? 'Bộ lọc\ntrong\ncabin'
                                      : filter.name == 'Bộ lọc nhiên liệu'
                                      ? 'Bộ lọc\nnhiên liệu'
                                      : filter.name;
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: column < 2 ? 12 : 0,
                                      ),
                                      child: InkWell(
                                        onTap: null,
                                        child: Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: assetImage(
                                                filter.image,
                                                width: 72,
                                                height: compact ? 58 : 70,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              label,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: compact ? 11 : 12,
                                                height: 1.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          }, childCount: (matches.length / 3).ceil()),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Divider(height: 1, color: Color(0xFFE7E9ED)),
                        ),
                      ),
                    ],
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InverseCategorySelection extends ShapeBorder {
  const _InverseCategorySelection();
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
  @override
  ShapeBorder scale(double t) => this;
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    const r = 20.0;
    const k = 0.55228475;
    return Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(r),
          bottomLeft: const Radius.circular(r),
        ),
      )
      ..moveTo(rect.right - r, rect.top)
      ..cubicTo(
        rect.right - r + k * r,
        rect.top,
        rect.right,
        rect.top - r + k * r,
        rect.right,
        rect.top - r,
      )
      ..lineTo(rect.right, rect.top)
      ..close()
      ..moveTo(rect.right - r, rect.bottom)
      ..cubicTo(
        rect.right - r + k * r,
        rect.bottom,
        rect.right,
        rect.bottom + r - k * r,
        rect.right,
        rect.bottom + r,
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
