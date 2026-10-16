import 'dart:async';
import 'package:flutter/material.dart';
import '../data/catalog_repository.dart';
import '../models/catalog.dart';
import '../screens/cart_screen.dart';
import '../screens/category_screen.dart';
import '../screens/home_screen.dart';
import '../theme.dart';
import '../view_models/shop_view_model.dart';
import '../widgets/catalog_components.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/shop_header.dart';
import '../widgets/empty_animation.dart';

class ShopShell extends StatefulWidget {
  const ShopShell({super.key, this.repository});
  final CatalogRepository? repository;
  @override
  State<ShopShell> createState() => _ShopShellState();
}

class _ShopShellState extends State<ShopShell> {
  late final ShopViewModel _vm;
  final _search = TextEditingController();
  @override
  void initState() {
    super.initState();
    _vm = ShopViewModel(widget.repository ?? AssetCatalogRepository());
    unawaited(_vm.load());
  }

  @override
  void dispose() {
    _search.dispose();
    _vm.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    FocusScope.of(context).unfocus();
    _search.clear();
    _vm.selectTab(ShopTab.values[index]);
  }

  void _buy(Product product) {
    _vm.cart.add(product.id);
    // Snackbars and navigation are presentation effects, not ViewModel duties.
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        backgroundColor: AppColors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Text('Đã thêm sản phẩm vào giỏ hàng'),
        action: SnackBarAction(
          label: 'Xem giỏ',
          textColor: Colors.white,
          onPressed: () => _selectTab(1),
        ),
      ),
      snackBarAnimationStyle: AnimationStyle(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 240),
        reverseDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) {
      if (!_vm.ready) {
        return Scaffold(
          body: Center(
            child: _vm.error == null
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_vm.error!),
                      TextButton(
                        onPressed: _vm.load,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
          ),
        );
      }
      final showEmpty =
          _vm.tab == ShopTab.account ||
          (_vm.tab == ShopTab.cart && _vm.cart.lines.isEmpty);
      final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
      return Stack(
        children: [
          Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColors.blue,
            body: Column(
              children: [
                ShopHeader(
                  controller: _search,
                  onBack: _vm.returnTab != null
                      ? () {
                          FocusScope.of(context).unfocus();
                          _search.clear();
                          _vm.goBack();
                        }
                      : null,
                  onSearchTap: _vm.beginSearch,
                  onChanged: _vm.search,
                  onSubmitted: (_) {
                    FocusScope.of(context).unfocus();
                    _vm.submitSearch();
                  },
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: ColoredBox(
                      color: AppColors.background,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          IndexedStack(
                            index: _vm.tab.index,
                            children: [
                              HomeScreen(
                                viewModel: _vm.home,
                                active: _vm.tab == ShopTab.home,
                                onCategory: _vm.openCategory,
                                onBuy: _buy,
                                onNews: () => _selectTab(3),
                              ),
                              CartScreen(viewModel: _vm.cart),
                              CategoryScreen(
                                viewModel: _vm.categories,
                                onBuy: _buy,
                              ),
                              SingleChildScrollView(
                                child: Column(
                                  children: [
                                    const SectionHeading(
                                      title: 'Bài Viết Nổi Bật',
                                      icon: 'tab_news',
                                      iconColor: AppColors.blue,
                                      gap: 12,
                                      padding: EdgeInsets.all(12),
                                    ),
                                    ArticleList(
                                      gap: 12,
                                      cardPadding: 6,
                                      textGap: 12,
                                      articles: _vm.home.catalog.articles,
                                      onArticle: (article) =>
                                          openArticle(context, article),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox.shrink(),
                            ],
                          ),
                          Offstage(
                            offstage: !showEmpty,
                            child: SharedEmptyState(
                              active: showEmpty,
                              isCart: _vm.tab == ShopTab.cart,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: ShopNavigationBar(
              selected: _vm.tab.index,
              cartCount: _vm.cart.itemCount,
              onSelected: _selectTab,
            ),
          ),
          if (keyboardHeight > 0)
            Positioned(
              right: 16,
              bottom: keyboardHeight + 12,
              child: Material(
                color: const Color(0xFFF0F1F2),
                elevation: 4,
                shadowColor: const Color(0x22000000),
                shape: const CircleBorder(
                  side: BorderSide(color: Colors.white),
                ),
                child: IconButton(
                  tooltip: 'Đóng bàn phím',
                  color: const Color(0xFF1A1A1A),
                  constraints: const BoxConstraints.tightFor(
                    width: 52,
                    height: 52,
                  ),
                  iconSize: 20,
                  icon: const Icon(Icons.keyboard_hide_rounded),
                  onPressed: () =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
              ),
            ),
        ],
      );
    },
  );
}
