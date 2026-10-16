import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foso_test_mobile_app/models/catalog.dart';
import 'package:foso_test_mobile_app/screens/category_screen.dart';
import 'package:foso_test_mobile_app/theme.dart';
import 'package:foso_test_mobile_app/view_models/category_view_model.dart';
import 'package:foso_test_mobile_app/widgets/article_list.dart';
import 'package:foso_test_mobile_app/widgets/category/category_results.dart';
import 'package:foso_test_mobile_app/widgets/navigation_bar.dart';

CatalogData _catalog() => CatalogData.fromJson(
  jsonDecode(File('assets/data/catalog.json').readAsStringSync())
      as Map<String, dynamic>,
);

Future<void> _setPhoneSize(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(393, 852);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpNavigation(WidgetTester tester) async {
  await _setPhoneSize(tester);
  var selected = 0;
  await tester.pumpWidget(
    MaterialApp(
      home: StatefulBuilder(
        builder: (context, setState) => Scaffold(
          bottomNavigationBar: ShopNavigationBar(
            selected: selected,
            cartCount: 0,
            onSelected: (value) => setState(() => selected = value),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

class _IndicatorSnapshot {
  const _IndicatorSnapshot(this.centerX, this.glowAlpha);
  final double centerX;
  final int glowAlpha;
}

/// Inspect the rendered marker rather than reaching into private controllers.
Future<_IndicatorSnapshot> _indicator(WidgetTester tester) async {
  final surface = find.descendant(
    of: find.byType(ShopNavigationBar),
    matching: find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter != null,
    ),
  );
  expect(surface, findsOneWidget);
  final paint = tester.widget<CustomPaint>(surface);
  final size = tester.getSize(surface);
  return (await tester.runAsync(() async {
    final recorder = ui.PictureRecorder();
    paint.painter!.paint(Canvas(recorder), size);
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.ceil(), size.height.ceil());
    try {
      final data = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      final width = image.width;
      final markerPixels = <int>[];
      var glowAlpha = 0;
      for (var x = 0; x < width; x++) {
        final marker = (2 * width + x) * 4;
        if (data.getUint8(marker) == 2 &&
            data.getUint8(marker + 1) == 95 &&
            data.getUint8(marker + 2) == 202 &&
            data.getUint8(marker + 3) > 250) {
          markerPixels.add(x);
        }
        glowAlpha += data.getUint8((6 * width + x) * 4 + 3);
      }
      expect(markerPixels, isNotEmpty);
      return _IndicatorSnapshot(
        (markerPixels.first + markerPixels.last + 1) / 2,
        glowAlpha,
      );
    } finally {
      image.dispose();
      picture.dispose();
    }
  }))!;
}

double _activeIconOpacity(WidgetTester tester, String icon) {
  final fade = find.ancestor(
    of: find.byWidgetPredicate(
      (widget) => widget is FigmaIcon && widget.name == icon,
    ),
    matching: find.byType(FadeTransition),
  );
  return tester.widget<FadeTransition>(fade.first).opacity.value;
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: false,
    );
  });

  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher
        .clearAccessibilityFeaturesTestValue();
  });

  testWidgets(
    'Tab marker travels continuously after rapid taps and reveals glow on arrival',
    (tester) async {
      await _pumpNavigation(tester);
      expect(tester.getSize(find.byType(ShopNavigationBar)).height, 60);
      final initial = await _indicator(tester);
      expect(initial.glowAlpha, greaterThan(0));

      await tester.tap(find.byKey(const ValueKey('tab-4')));
      await tester.pump();
      expect((await _indicator(tester)).glowAlpha, 0);
      await tester.pump(const Duration(milliseconds: 80));
      final travelling = await _indicator(tester);
      expect(travelling.centerX, greaterThan(initial.centerX));
      expect(
        travelling.centerX,
        lessThan(tester.getCenter(find.byKey(const ValueKey('tab-4'))).dx),
      );
      expect(travelling.glowAlpha, 0);

      await tester.tap(find.byKey(const ValueKey('tab-1')));
      await tester.pump();
      final interrupted = await _indicator(tester);
      expect(interrupted.centerX, closeTo(travelling.centerX, 1));
      await tester.pump(const Duration(milliseconds: 80));
      final returning = await _indicator(tester);
      final destination = tester
          .getCenter(find.byKey(const ValueKey('tab-1')))
          .dx;
      expect(returning.centerX, lessThan(interrupted.centerX));
      expect(returning.centerX, greaterThan(destination));
      expect(returning.glowAlpha, 0);

      await tester.pump(const Duration(milliseconds: 120));
      final arrived = await _indicator(tester);
      expect(arrived.centerX, closeTo(destination, 1));
      // Allow the travel completion and the reveal's first frame to commit.
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 60));
      final revealing = await _indicator(tester);
      expect(revealing.glowAlpha, greaterThan(0));
      expect(revealing.glowAlpha, lessThan(initial.glowAlpha));
      await tester.pump(const Duration(milliseconds: 100));
      expect((await _indicator(tester)).glowAlpha, initial.glowAlpha);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Tab icons crossfade and tab/category taps share light feedback',
    (tester) async {
      final feedback = <Object?>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            feedback.add(call.arguments);
          }
          return null;
        },
      );
      addTearDown(() {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });
      await _pumpNavigation(tester);
      expect(_activeIconOpacity(tester, 'tab_account_active'), 0);
      await tester.tap(find.byKey(const ValueKey('tab-4')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      expect(
        _activeIconOpacity(tester, 'tab_account_active'),
        inExclusiveRange(0, 1),
      );
      expect(
        _activeIconOpacity(tester, 'tab_home_active'),
        inExclusiveRange(0, 1),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(_activeIconOpacity(tester, 'tab_account_active'), 1);
      expect(_activeIconOpacity(tester, 'tab_home_active'), 0);

      final vm = CategoryViewModel(_catalog());
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CategoryScreen(viewModel: vm)),
        ),
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('category-0')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(vm.selectedId, 'oil');
      expect(feedback, [
        'HapticFeedbackType.lightImpact',
        'HapticFeedbackType.lightImpact',
      ]);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Category lists are visible before searching and after whitespace',
    (tester) async {
      await _setPhoneSize(tester);
      final vm = CategoryViewModel(_catalog());
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CategoryScreen(viewModel: vm)),
        ),
      );
      await tester.pump();
      final initialIds = vm.matches.map((item) => item.id).toList();
      expect(initialIds, isNotEmpty);
      expect(find.text('Sub Category 1'), findsOneWidget);
      expect(find.text('Không tìm thấy sản phẩm'), findsNothing);

      vm.search('không tồn tại');
      await tester.pump();
      expect(find.text('Không tìm thấy sản phẩm'), findsOneWidget);
      vm.search('   ');
      await tester.pump();
      expect(vm.matches.map((item) => item.id), initialIds);
      expect(find.text('Sub Category 1'), findsOneWidget);
      expect(find.text('Không tìm thấy sản phẩm'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('category-2')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(vm.selectedId, 'fuel');
      expect(
        find.descendant(
          of: find.byType(CategoryResults),
          matching: find.text('Bộ Lọc Nhiên Liệu'),
        ),
        findsOneWidget,
      );
      expect(find.text('Sub Category 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final count in [1, 4]) {
    testWidgets('News list renders all $count supplied articles', (
      tester,
    ) async {
      await _setPhoneSize(tester);
      final articles = List.generate(
        count,
        (index) => Article(
          id: 'article-$index',
          title: 'Bài viết $index',
          image: _catalog().articles.first.image,
          date: DateTime(2025, 2, 13),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: ArticleList(articles: articles)),
          ),
        ),
      );
      await tester.pump();
      for (final article in articles) {
        expect(find.text(article.title), findsOneWidget);
      }
      expect(find.text('13/02/2025'), findsNWidgets(count));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
