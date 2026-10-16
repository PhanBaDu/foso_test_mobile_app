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
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã thêm sản phẩm vào giỏ hàng'),
        action: SnackBarAction(
          label: 'Xem giỏ',
          onPressed: () => _selectTab(1),
        ),
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
      return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.blue,
        body: Column(
          children: [
            ShopHeader(
              controller: _search,
              onBack: _vm.tab == ShopTab.category ? () => _selectTab(0) : null,
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
                  child: IndexedStack(
                    index: _vm.tab.index,
                    children: [
                      HomeScreen(
                        viewModel: _vm.home,
                        onCategory: _vm.openCategory,
                        onBuy: _buy,
                        onNews: () => _selectTab(3),
                      ),
                      CartScreen(viewModel: _vm.cart),
                      CategoryScreen(viewModel: _vm.categories, onBuy: _buy),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            const SectionHeading(
                              title: 'Bài Viết Nổi Bật',
                              icon: 'article',
                            ),
                            ArticleList(
                              articles: _vm.home.catalog.articles,
                              onArticle: (article) =>
                                  openArticle(context, article),
                            ),
                          ],
                        ),
                      ),
                      const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: AppColors.paleBlue,
                              child: FigmaIcon(
                                'account',
                                size: 44,
                                color: AppColors.blue,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tài khoản',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Chào mừng bạn đến với FOSO',
                              style: TextStyle(color: AppColors.muted),
                            ),
                          ],
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
      );
    },
  );
}
