import 'package:flutter/material.dart';
import '../../models/catalog.dart';
import '../../theme.dart';

/// Owns scroll position and its thumb; no ViewModel notifications per drag frame.
class FeaturedCategories extends StatefulWidget {
  const FeaturedCategories({
    super.key,
    required this.categories,
    required this.onCategory,
  });
  final List<CatalogCategory> categories;
  final ValueChanged<String> onCategory;
  @override
  State<FeaturedCategories> createState() => _FeaturedCategoriesState();
}

class _FeaturedCategoriesState extends State<FeaturedCategories> {
  final _featuredController = ScrollController();
  final _featuredMetrics = ValueNotifier<int>(0);
  @override
  void dispose() {
    _featuredController.dispose();
    _featuredMetrics.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 98,
        child: NotificationListener<ScrollMetricsNotification>(
          onNotification: (_) {
            _featuredMetrics.value++;
            return false;
          },
          child: ListView.separated(
            key: const ValueKey('featured-categories'),
            controller: _featuredController,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: widget.categories.length * 2,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (_, i) => InkWell(
              onTap: () => widget.onCategory(
                widget.categories[i % widget.categories.length].id,
              ),
              child: Container(
                width: 77,
                padding: const EdgeInsets.all(6),
                clipBehavior: Clip.none,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    assetImage(
                      widget.categories[i % widget.categories.length].image,
                      height: 48,
                      width: 65,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.categories[i % widget.categories.length].name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, height: 1.3),
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
      Center(
        child: Container(
          margin: const EdgeInsets.only(top: 12, bottom: 12),
          width: 59,
          height: 6,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xFFDFE3E8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _featuredController,
              _featuredMetrics,
            ]),
            builder: (context, child) {
              final ready =
                  _featuredController.hasClients &&
                  _featuredController.position.hasContentDimensions;
              final viewport = ready
                  ? _featuredController.position.viewportDimension
                  : MediaQuery.sizeOf(context).width;
              final count = widget.categories.length * 2;
              // Items have a fixed width; avoid the lazy list's estimated extent.
              final content =
                  (count * 77 + (count > 0 ? count - 1 : 0) * 6 + 24)
                      .toDouble();
              final offset = ready ? _featuredController.offset : 0.0;
              final progress = content > viewport
                  ? (offset / (content - viewport)).clamp(0.0, 1.0)
                  : 0.0;
              return Transform.translate(
                offset: Offset((59 - 24) * progress, 0),
                child: Container(
                  key: const ValueKey('featured-progress-thumb'),
                  width: 24,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}
