import 'package:flutter/material.dart';
import '../../models/catalog.dart';
import '../../theme.dart';
import '../catalog_components.dart';

class CategoryResults extends StatelessWidget {
  const CategoryResults({
    super.key,
    required this.title,
    required this.filters,
    required this.controller,
  });

  final String title;
  final List<CatalogFilter> filters;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => CustomScrollView(
      controller: controller,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
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
                const Divider(height: 1),
              ],
            ),
          ),
        ),
        if (filters.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('Không tìm thấy sản phẩm')),
          )
        else
          for (var section = 1; section <= 3; section++) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Sub Category $section',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Details are intentionally passive until a destination exists.
                    const SeeAllButton(),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverList.builder(
                itemCount: (filters.length / 3).ceil(),
                itemBuilder: (context, row) => SizedBox(
                  height: row == 0 ? 134 : 106,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var column = 0; column < 3; column++) ...[
                        if (column > 0) const SizedBox(width: 12),
                        Expanded(
                          child: row * 3 + column < filters.length
                              ? _FilterItem(
                                  filter: filters[row * 3 + column],
                                  compact: constraints.maxWidth < 260,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Divider(height: 1),
              ),
            ),
          ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    ),
  );
}

class _FilterItem extends StatelessWidget {
  const _FilterItem({required this.filter, required this.compact});
  final CatalogFilter filter;
  final bool compact;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: assetImage(filter.image, height: compact ? 58 : 70),
      ),
      const SizedBox(height: 8),
      Text(
        filter.name == 'Bộ lọc trong cabin'
            ? 'Bộ lọc\ntrong\ncabin'
            : filter.name,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: compact ? 11 : 12, height: 1.2),
      ),
    ],
  );
}
