import 'dart:async';
import 'package:flutter/material.dart';
import '../models/catalog.dart';
import '../theme.dart';
import '../widgets/product_card.dart';
import '../widgets/flash_countdown.dart';
import '../widgets/catalog_components.dart';
import '../view_models/home_view_model.dart';

class HomeScreen extends StatefulWidget {
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController(initialPage: 1);
  final _featuredController = ScrollController();
  final _featuredMetrics = ValueNotifier<int>(0);
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _restartBannerTimer();
  }

  void _restartBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      if (!widget.active ||
          !_pageController.hasClients ||
          MediaQuery.disableAnimationsOf(context) ||
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed ||
          _pageController.position.isScrollingNotifier.value) {
        _restartBannerTimer();
        return;
      }
      _pageController
          .animateToPage(
            (widget.viewModel.banner + 1) % 3,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOutCubic,
          )
          .then((_) {
            if (mounted) _restartBannerTimer();
          });
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    _featuredController.dispose();
    _featuredMetrics.dispose();
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
                itemCount:
                    widget.viewModel.catalog.featuredCategories.length * 2,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (_, i) => InkWell(
                  onTap: () => widget.onCategory(
                    widget
                        .viewModel
                        .catalog
                        .featuredCategories[i %
                            widget.viewModel.catalog.featuredCategories.length]
                        .id,
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
                          widget
                              .viewModel
                              .catalog
                              .featuredCategories[i %
                                  widget
                                      .viewModel
                                      .catalog
                                      .featuredCategories
                                      .length]
                              .image,
                          height: 48,
                          width: 65,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Center(
                            child: Text(
                              widget
                                  .viewModel
                                  .catalog
                                  .featuredCategories[i %
                                      widget
                                          .viewModel
                                          .catalog
                                          .featuredCategories
                                          .length]
                                  .name,
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
                  final count =
                      widget.viewModel.catalog.featuredCategories.length * 2;
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
          SizedBox(
            height: 170,
            child: Listener(
              onPointerDown: (_) => _bannerTimer?.cancel(),
              onPointerUp: (_) => _restartBannerTimer(),
              onPointerCancel: (_) => _restartBannerTimer(),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification &&
                      notification.dragDetails != null) {
                    _bannerTimer?.cancel();
                  } else if (notification is ScrollEndNotification) {
                    _restartBannerTimer();
                  }
                  return false;
                },
                child: PageView(
                  physics: const PageScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: (i) => widget.viewModel.selectBanner(i),
                  children: ['offer_banner', 'offer_banner', 'offer_banner']
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.only(right: index < 2 ? 3 : 0),
                  child: AnimatedContainer(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 20,
                    height: 3,
                    decoration: BoxDecoration(
                      color: widget.viewModel.banner == index
                          ? AppColors.brightBlue
                          : const Color(0xFFC4CDD5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
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
                    vertical: 12,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 369,
                      child: SectionHeading(
                        title: 'FLASH SALE',
                        icon: 'flash',
                        iconColor: AppColors.flash,
                        color: AppColors.text,
                        gap: 12,
                        padding: EdgeInsets.zero,
                        accessory: FlashCountdown(
                          values: widget.viewModel.clock,
                        ),
                        actionColor: AppColors.flash,
                        onSeeAll: () => widget.onCategory('air'),
                      ),
                    ),
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
                onTap: () => widget.onCategory('air'),
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
            onSeeAll: () => widget.onCategory('air'),
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
            onSeeAll: () => widget.onCategory('air'),
          ),
          SizedBox(
            height: 291,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: 5,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
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
                  onSeeAll: () => widget.onCategory('air'),
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
            onSeeAll: widget.onNews,
          ),
          ArticleList(
            gap: 12,
            textGap: 12,
            articles: widget.viewModel.catalog.articles,
          ),
          const SizedBox(height: 12),
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

  Widget _products({
    bool flash = false,
    bool limited = false,
    double? height,
  }) => SizedBox(
    height: height ?? (flash ? 340 : 320),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: widget.viewModel.catalog.products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => ProductCard(
          product: widget.viewModel.catalog.products[i],
          onBuy: () => widget.onBuy(widget.viewModel.catalog.products[i]),
          flash: flash,
          limited: limited,
        ),
      ),
    ),
  );
}
