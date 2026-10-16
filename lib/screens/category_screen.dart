import 'package:flutter/material.dart';
import '../models/catalog.dart';
import '../view_models/category_view_model.dart';
import '../theme.dart';
import '../widgets/product_card.dart';

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
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: vm.catalog.categories.length,
                  itemBuilder: (_, i) => InkWell(
                    key: ValueKey('category-$i'),
                    onTap: () {
                      vm.select(vm.catalog.categories[i].id);
                      _contentController.jumpTo(0);
                    },
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.fromLTRB(12, 16, 8, 12),
                      decoration: BoxDecoration(
                        color: vm.selectedId == vm.catalog.categories[i].id
                            ? AppColors.background
                            : AppColors.paleBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          assetImage('category_air', width: 40, height: 32),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              vm.catalog.categories[i].name.replaceFirst(
                                'Bộ Lọc ',
                                'Bộ Lọc\n',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.25,
                                fontWeight: FontWeight.w600,
                                color:
                                    vm.selectedId == vm.catalog.categories[i].id
                                    ? AppColors.text
                                    : const Color(0xFF003D80),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                                onTap: () => showProductDetails(
                                  context,
                                  vm.catalog.products.first,
                                  () => widget.onBuy(vm.catalog.products.first),
                                ),
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
                                  final product = vm.catalog.productById(
                                    filter.productId,
                                  );
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
                                        onTap: () => showProductDetails(
                                          context,
                                          product,
                                          () => widget.onBuy(product),
                                        ),
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
