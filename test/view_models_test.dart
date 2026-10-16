import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foso_test_mobile_app/core/platform_renderer.dart';
import 'package:foso_test_mobile_app/data/catalog_repository.dart';
import 'package:foso_test_mobile_app/models/catalog.dart';
import 'package:foso_test_mobile_app/view_models/cart_view_model.dart';
import 'package:foso_test_mobile_app/view_models/category_view_model.dart';
import 'package:foso_test_mobile_app/view_models/home_view_model.dart';
import 'package:foso_test_mobile_app/view_models/shop_view_model.dart';

Map<String, dynamic> fixtureJson() =>
    jsonDecode(File('assets/data/catalog.json').readAsStringSync())
        as Map<String, dynamic>;
CatalogData fixture() => CatalogData.fromJson(fixtureJson());

class StubRepository implements CatalogRepository {
  StubRepository(this.fetch);
  final Future<CatalogData> Function() fetch;
  @override
  Future<CatalogData> load() => fetch();
}

void main() {
  test('Platform routing sends only native iOS to SwiftUI', () {
    expect(rendererFor(TargetPlatform.iOS), AppRenderer.nativeIOS);
    expect(rendererFor(TargetPlatform.android), AppRenderer.flutter);
    expect(rendererFor(TargetPlatform.iOS, isWeb: true), AppRenderer.flutter);
  });
  test('Cart totals separate product lines and never goes negative', () {
    final vm = CartViewModel(fixture());
    addTearDown(vm.dispose);
    vm.add('product-0');
    vm.add('product-0');
    vm.add('product-1');
    expect(vm.itemCount, 3);
    expect(vm.lines.length, 2);
    expect(vm.total, 897000);
    vm.remove('product-0');
    vm.remove('product-0');
    vm.remove('product-0');
    expect(vm.itemCount, 1);
    expect(vm.total, 299000);
    expect(() => vm.add('missing'), throwsStateError);
  });
  test('Category search respects selection, trims input and ignores case', () {
    final json = fixtureJson();
    (json['categories'] as List).first['filterIds'] = ['filter-1'];
    final vm = CategoryViewModel(CatalogData.fromJson(json));
    addTearDown(vm.dispose);
    vm.select('oil');
    vm.search('  CABIN ');
    expect(vm.matches.map((e) => e.id), ['filter-1']);
    vm.search('nhiên liệu');
    expect(vm.matches, isEmpty);
    vm.select('missing');
    expect(vm.selectedId, 'oil');
  });
  test(
    'Countdown uses elapsed wall time after suspension and clamps expiry',
    () {
      var now = DateTime.utc(2026);
      final vm = HomeViewModel(fixture(), now: () => now, startTimer: false);
      addTearDown(vm.dispose);
      expect(vm.clock, ['19', '25', '00']);
      now = now.add(const Duration(hours: 2, seconds: 7));
      vm.refreshCountdown();
      expect(vm.clock, ['17', '24', '53']);
      now = now.add(const Duration(days: 2));
      vm.refreshCountdown();
      expect(vm.remainingSeconds, 0);
    },
  );
  test(
    'Shop recovers from loading errors and routes featured category by ID',
    () async {
      var attempts = 0;
      final vm = ShopViewModel(
        StubRepository(() async {
          if (++attempts == 1) throw Exception('offline');
          return fixture();
        }),
      );
      addTearDown(vm.dispose);
      await vm.load();
      expect(vm.error, isNotNull);
      expect(vm.ready, isFalse);
      await vm.load();
      expect(vm.error, isNull);
      expect(vm.ready, isTrue);
      vm.openCategory('cabin');
      expect(vm.categories.selectedId, 'cabin');
      expect(vm.tab, ShopTab.category);
      vm.search('gió');
      expect(vm.categories.matches, isNotEmpty);
      vm.selectTab(ShopTab.home);
      expect(vm.categories.query, isEmpty);
    },
  );
  test('Completing a disposed load never notifies a dead ViewModel', () async {
    final completer = Completer<CatalogData>();
    final vm = ShopViewModel(StubRepository(() => completer.future));
    final load = vm.load();
    vm.dispose();
    completer.complete(fixture());
    await load;
  });
  test(
    'Catalog rejects dangling references and exposes immutable collections',
    () {
      final json = fixtureJson();
      (json['filters'] as List).first['productId'] = 'missing';
      expect(() => CatalogData.fromJson(json), throwsFormatException);
      expect(() => fixture().products.clear(), throwsUnsupportedError);
    },
  );
}
