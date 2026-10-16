import 'package:flutter/material.dart';
import '../models/catalog.dart';
import '../screens/category_screen.dart';
import '../screens/home_screen.dart';
import '../screens/news_screen.dart';
import '../theme.dart';
import '../view_models/shop_view_model.dart';
import '../widgets/empty_animation.dart';
import '../widgets/retained_tab.dart';

/// Retains feature views; the shell owns routing and cross-feature actions.
class ShopContent extends StatelessWidget {
  const ShopContent({
    super.key,
    required this.viewModel,
    required this.onBuy,
    required this.onNews,
  });

  final ShopViewModel viewModel;
  final ValueChanged<Product> onBuy;
  final VoidCallback onNews;

  @override
  Widget build(BuildContext context) {
    final tab = viewModel.tab;
    final showEmpty = tab == ShopTab.account || tab == ShopTab.cart;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: ColoredBox(
        color: AppColors.background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RetainedTab(
              active: tab == ShopTab.home,
              child: HomeScreen(
                viewModel: viewModel.home,
                active: tab == ShopTab.home,
                onCategory: viewModel.openCategory,
                onBuy: onBuy,
                onNews: onNews,
              ),
            ),
            RetainedTab(
              active: tab == ShopTab.category,
              child: CategoryScreen(viewModel: viewModel.categories),
            ),
            RetainedTab(
              active: tab == ShopTab.news,
              child: NewsScreen(articles: viewModel.home.catalog.articles),
            ),
            // Cart/account share one mounted Lottie instance and playback state.
            RetainedTab(
              active: showEmpty,
              child: SharedEmptyState(
                active: showEmpty,
                isCart: tab == ShopTab.cart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
