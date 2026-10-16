import 'package:flutter/material.dart';
import '../models/catalog.dart';
import '../theme.dart';
import '../widgets/product_card.dart';
import '../widgets/flash_countdown.dart';
import '../widgets/catalog_components.dart';
import '../widgets/home/featured_categories.dart';
import '../widgets/home/offer_carousel.dart';
import '../view_models/home_view_model.dart';

/// Composes sections only; each animated section owns its presentation state.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onCategory,
    required this.onBuy,
    required this.onNews,
    required this.viewModel,
    this.active = true,
  });
  final ValueChanged<String> onCategory;
  final HomeViewModel viewModel;
  final bool active;
  final ValueChanged<Product> onBuy;
  final VoidCallback onNews;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: const PageStorageKey('home-scroll'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: assetImage('welcome_banner', fit: BoxFit.fill),
          ),
        ),
        const SectionHeading(
          title: 'Danh mục tiêu biểu',
          color: AppColors.featuredCategoryTitle,
          gap: 12,
          padding: EdgeInsets.fromLTRB(12, 18, 12, 12),
        ),
        FeaturedCategories(
          categories: viewModel.catalog.featuredCategories,
          onCategory: onCategory,
        ),
        OfferCarousel(viewModel: viewModel, active: active),
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
                padding: const EdgeInsets.all(12),
                child: SectionHeading(
                  title: 'FLASH SALE',
                  icon: 'flash',
                  iconColor: AppColors.flash,
                  color: AppColors.text,
                  gap: 12,
                  padding: EdgeInsets.zero,
                  accessory: ListenableBuilder(
                    listenable: viewModel,
                    builder: (context, _) =>
                        FlashCountdown(values: viewModel.clock),
                  ),
                  actionColor: AppColors.flash,
                  onSeeAll: () => onCategory('air'),
                ),
              ),
              _products(flash: true),
            ],
          ),
        ),
        SectionHeading(
          gap: 12,
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
          title: 'Thương Hiệu Nổi Bật',
          icon: 'brand',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (_, i) => InkWell(
              onTap: () => onCategory('air'),
              borderRadius: BorderRadius.circular(6),
              child: assetImage('brand_$i', fit: BoxFit.cover),
            ),
          ),
        ),
        SectionHeading(
          gap: 12,
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
          title: 'Sản Phẩm Bán Chạy',
          icon: 'like',
          iconColor: AppColors.blue,
          onSeeAll: () => onCategory('air'),
        ),
        _products(limited: true),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
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
          gap: 12,
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
          title: 'Dành Cho Bạn',
          icon: 'star',
          iconColor: AppColors.blue,
          onSeeAll: () => onCategory('air'),
        ),
        SizedBox(
          height: 291,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: viewModel.catalog.products.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => i == 0
                  ? SizedBox(width: 150, child: _promo('recommend_banner'))
                  : ProductCard(
                      product:
                          viewModel.catalog.products[(i - 1) %
                              viewModel.catalog.products.length],
                      onBuy: () => onBuy(
                        viewModel.catalog.products[(i - 1) %
                            viewModel.catalog.products.length],
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          color: AppColors.blue,
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              SectionHeading(
                gap: 12,
                padding: const EdgeInsets.all(12),
                title: 'Hàng Mới Về',
                icon: 'new-arrivals',
                color: Colors.white,
                actionColor: Colors.white,
                onSeeAll: () => onCategory('air'),
              ),
              _products(height: 290),
            ],
          ),
        ),
        SectionHeading(
          gap: 12,
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
          title: 'Bài Viết Nổi Bật',
          icon: 'tab_news',
          iconColor: AppColors.blue,
          onSeeAll: onNews,
        ),
        ArticleList(gap: 12, textGap: 12, articles: viewModel.catalog.articles),
        const SizedBox(height: 36),
      ],
    ),
  );

  Widget _promo(String name) => InkWell(
    onTap: () => onCategory('air'),
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

  Widget _products({
    bool flash = false,
    bool limited = false,
    double? height,
  }) => SizedBox(
    height:
        height ??
        (flash
            ? 340
            : limited
            ? 320
            : 290),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.catalog.products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => ProductCard(
          product: viewModel.catalog.products[i],
          onBuy: () => onBuy(viewModel.catalog.products[i]),
          flash: flash,
          limited: limited,
        ),
      ),
    ),
  );
}
