import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/catalog_repository.dart';
import '../models/catalog.dart';
import '../theme.dart';
import '../view_models/shop_view_model.dart';
import '../widgets/keyboard_dismiss_button.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/shop_header.dart';
import 'shop_content.dart';

/// Composes feature ViewModels and keeps presentation effects out of them.
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

  void _goBack() {
    FocusScope.of(context).unfocus();
    _search.clear();
    _vm.goBack();
  }

  void _buy(Product product) {
    _vm.cart.add(product.id);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        backgroundColor: AppColors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Text(
          'Đã thêm sản phẩm vào giỏ hàng',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        action: SnackBarAction(
          label: 'Xem giỏ',
          textColor: Colors.white,
          onPressed: () => _selectTab(1),
        ),
      ),
      snackBarAnimationStyle: AnimationStyle(
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 240),
        reverseDuration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
    child: ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        if (!_vm.ready) {
          return _CatalogLoadState(error: _vm.error, onRetry: _vm.load);
        }
        final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
        final barHeight =
            ShopNavigationBar.contentHeight +
            MediaQuery.viewPaddingOf(context).bottom;
        return Stack(
          children: [
            Scaffold(
              // Keep the native IME above the entire shell, including navigation.
              resizeToAvoidBottomInset: false,
              extendBody: true,
              backgroundColor: AppColors.blue,
              body: Column(
                children: [
                  ShopHeader(
                    controller: _search,
                    onBack: _vm.returnTab != null ? _goBack : null,
                    onSearchTap: _vm.beginSearch,
                    onChanged: _vm.search,
                    onSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                      _vm.submitSearch();
                    },
                  ),
                  Expanded(
                    // Real content continues under the rounded bar corners.
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: barHeight - ShopNavigationBar.topRadius,
                      ),
                      child: ShopContent(
                        viewModel: _vm,
                        onBuy: _buy,
                        onNews: () => _selectTab(3),
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
                child: const KeyboardDismissButton(),
              ),
          ],
        );
      },
    ),
  );
}

class _CatalogLoadState extends StatelessWidget {
  const _CatalogLoadState({required this.error, required this.onRetry});

  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: error == null
          ? const CircularProgressIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(error!),
                TextButton(onPressed: onRetry, child: const Text('Thử lại')),
              ],
            ),
    ),
  );
}
