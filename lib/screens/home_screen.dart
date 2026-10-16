import 'package:flutter/material.dart';
import '../models/catalog.dart';
import '../theme.dart';
import '../widgets/product_card.dart';
import '../widgets/catalog_components.dart';
import '../view_models/home_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onCategory,
    required this.onBuy,
    required this.onNews,
    required this.viewModel,
  });
  final ValueChanged<String> onCategory;
  final HomeViewModel viewModel;
  final ValueChanged<Product> onBuy;
  final VoidCallback onNews;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController(initialPage: 1);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.viewModel,
    builder: (context, _) => SingleChildScrollView(
      key: const PageStorageKey('home-scroll'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: assetImage('welcome_banner', fit: BoxFit.fill),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 24, 12, 16),
            child: Text(
              'Danh mục tiêu biểu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 98,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: widget.viewModel.catalog.featuredCategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, i) => InkWell(
                onTap: () => widget.onCategory(
                  widget.viewModel.catalog.featuredCategories[i].id,
                ),
                child: Container(
                  width: 77,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      assetImage(
                        widget.viewModel.catalog.featuredCategories[i].image,
                        height: 39,
                        width: 55,
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Center(
                          child: Text(
                            widget.viewModel.catalog.featuredCategories[i].name,
                            textAlign: TextAlign.center,
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
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 16, bottom: 28),
              width: 59,
              height: 6,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: const Color(0xFFDFE3E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                width: 24,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 170,
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => widget.viewModel.selectBanner(i),
              children: ['welcome_banner', 'offer_banner', 'offer_banner']
                  .map(
                    (name) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: assetImage(name, fit: BoxFit.fill),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.fromLTRB(3, 9, 3, 24),
                width: widget.viewModel.banner == i ? 20 : 10,
                height: 3,
                decoration: BoxDecoration(
                  color: widget.viewModel.banner == i
                      ? AppColors.brightBlue
                      : const Color(0xFFC4CDD5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFE4BF), Color(0xFFFFFAF4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 369,
                      child: Row(
                        children: [
                          const FigmaIcon('flash', size: 25, color: AppColors.flash),
                          const SizedBox(width: 6),
                          const Text(
                            'FLASH SALE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ..._clock(),
                          const Spacer(),
                          seeAll(
                            () => widget.onCategory('air'),
                            color: const Color(0xFFFF6948),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _products(flash: true),
              ],
            ),
          ),
          SectionHeading(title: 'Thương Hiệu Nổi Bật', icon: 'brand'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.3,
              ),
              itemBuilder: (_, i) => InkWell(
                onTap: () => widget.onCategory('air'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: assetImage('brand_$i', fit: BoxFit.fill),
                ),
              ),
            ),
          ),
          SectionHeading(
            title: 'Sản Phẩm Bán Chạy',
            icon: 'bestseller',
            onSeeAll: () => widget.onCategory('air'),
          ),
          _products(limited: true),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
            child: AspectRatio(
              aspectRatio: 369 / 270,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: _promo('promo_red')),
                        const SizedBox(height: 12),
                        Expanded(child: _promo('promo_yellow')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _promo('promo_blue')),
                ],
              ),
            ),
          ),
          SectionHeading(
            title: 'Dành Cho Bạn',
            icon: 'recommend',
            onSeeAll: () => widget.onCategory('air'),
          ),
          SizedBox(
            height: 291,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 5,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => i == 0
                  ? SizedBox(width: 150, child: _promo('recommend_banner'))
                  : ProductCard(
                      product:
                          widget.viewModel.catalog.products[(i - 1) %
                              widget.viewModel.catalog.products.length],
                      onBuy: () => widget.onBuy(
                        widget.viewModel.catalog.products[(i - 1) %
                            widget.viewModel.catalog.products.length],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            color: AppColors.blue,
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                SectionHeading(
                  title: 'Hàng Mới Về',
                  icon: 'new_arrivals',
                  light: true,
                  onSeeAll: () => widget.onCategory('air'),
                ),
                _products(height: 290),
              ],
            ),
          ),
          SectionHeading(
            title: 'Bài Viết Nổi Bật',
            icon: 'article',
            onSeeAll: widget.onNews,
          ),
          ArticleList(
            articles: widget.viewModel.catalog.articles,
            onArticle: (article) => openArticle(context, article),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );

  Widget _promo(String name) => InkWell(
    onTap: () => widget.onCategory('air'),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: assetImage(
        name,
        fit: BoxFit.fill,
        width: double.infinity,
        height: double.infinity,
      ),
    ),
  );

  List<Widget> _clock() {
    final values = [
      widget.viewModel.remainingSeconds ~/ 3600,
      (widget.viewModel.remainingSeconds % 3600) ~/ 60,
      widget.viewModel.remainingSeconds % 60,
    ];
    return [
      for (var i = 0; i < 3; i++) ...[
        if (i > 0)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Text(':', style: TextStyle(color: AppColors.red)),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.red,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            values[i].toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ];
  }

  Widget _products({
    bool flash = false,
    bool limited = false,
    double? height,
  }) => SizedBox(
    height: height ?? (flash ? 340 : 320),
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      scrollDirection: Axis.horizontal,
      itemCount: widget.viewModel.catalog.products.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) => ProductCard(
        product: widget.viewModel.catalog.products[i],
        onBuy: () => widget.onBuy(widget.viewModel.catalog.products[i]),
        flash: flash,
        limited: limited,
      ),
    ),
  );
}
