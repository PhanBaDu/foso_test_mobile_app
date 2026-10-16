import 'dart:io';
import 'dart:convert';
import 'package:foso_test_mobile_app/models/catalog.dart';
import 'package:foso_test_mobile_app/data/catalog_repository.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foso_test_mobile_app/main.dart';
import 'package:foso_test_mobile_app/widgets/empty_animation.dart';
import 'package:foso_test_mobile_app/widgets/category/category_results.dart';
import 'package:foso_test_mobile_app/widgets/flash_countdown.dart';

class TestCatalogRepository implements CatalogRepository {
  @override
  Future<CatalogData> load() async => CatalogData.fromJson(
    jsonDecode(File('assets/data/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );
}

Future<void> pumpShop(WidgetTester tester, {double width = 393}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 852);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MyApp(repository: TestCatalogRepository()));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
  });
  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher
        .clearAccessibilityFeaturesTestValue();
  });
  setUpAll(() async {
    final loader = FontLoader('Inter');
    for (final name in ['Regular', 'SemiBold', 'Bold']) {
      loader.addFont(
        File(
          'assets/fonts/Inter-$name.ttf',
        ).readAsBytes().then((bytes) => bytes.buffer.asByteData()),
      );
    }
    await loader.load();
  });
  testWidgets('Countdown rolls only the digit that changes', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: false);
    Widget clock(String seconds) => MaterialApp(
      home: Center(child: FlashCountdown(values: ['19', '24', seconds])),
    );
    await tester.pumpWidget(clock('32'));
    final seconds = find.byKey(const ValueKey('countdown-unit-2'));
    final unchangedDigit = tester.element(
      find.descendant(of: seconds, matching: find.text('3')),
    );
    await tester.pumpWidget(clock('31'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      identical(
        tester.element(find.descendant(of: seconds, matching: find.text('3'))),
        unchangedDigit,
      ),
      isTrue,
    );
    expect(
      find.descendant(of: seconds, matching: find.text('2')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: seconds, matching: find.text('1')),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.descendant(of: seconds, matching: find.text('2')),
      findsNothing,
    );
    expect(
      find.descendant(of: seconds, matching: find.text('1')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home, category selection and search work together', (
    tester,
  ) async {
    await pumpShop(tester);
    expect(find.text('Danh mục tiêu biểu'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('tab-2')));
    await tester.pumpAndSettle();
    expect(find.text('Sub Category 1'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('category-2')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(CategoryResults),
        matching: find.text('Bộ Lọc Nhiên Liệu'),
      ),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), 'không tồn tại');
    await tester.pumpAndSettle();
    expect(find.text('Không tìm thấy sản phẩm'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Keyboard overlays tabbar and an outside tap dismisses focus', (
    tester,
  ) async {
    await pumpShop(tester);
    final tab = find.byKey(const ValueKey('tab-2'));
    final originalTop = tester.getTopLeft(tab).dy;
    await tester.tap(find.byType(TextField));
    await tester.pump();
    final editor = tester.widget<EditableText>(find.byType(EditableText));
    expect(editor.focusNode.hasFocus, isTrue);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();
    expect(tester.getTopLeft(tab).dy, originalTop);
    expect(find.byTooltip('Đóng bàn phím'), findsOneWidget);
    await tester.tapAt(const Offset(200, 210));
    await tester.pump();
    expect(editor.focusNode.hasFocus, isFalse);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.tap(find.byTooltip('Đóng bàn phím'));
    await tester.pump();
    expect(editor.focusNode.hasFocus, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Featured category progress tracks horizontal scroll to both ends',
    (tester) async {
      await pumpShop(tester);
      final list = find.byKey(const ValueKey('featured-categories'));
      final controller = tester.widget<ListView>(list).controller!;
      final thumb = find.byKey(const ValueKey('featured-progress-thumb'));
      final start = tester.getTopLeft(thumb).dx;
      final viewport = controller.position.viewportDimension;
      const contentWidth = 10 * 77 + 9 * 6 + 24;
      final extent = contentWidth - viewport;
      expect(tester.getSize(thumb).width, 24);
      await tester.drag(list, const Offset(-160, 0));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(thumb).dx, greaterThan(start));
      expect(tester.getSize(thumb).width, 24);
      controller.jumpTo(extent / 2);
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(thumb).dx, closeTo(start + 17.5, 0.1));
      expect(tester.getSize(thumb).width, 24);
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(thumb).dx, closeTo(start + 35, 0.1));
      expect(tester.getSize(thumb).width, 24);
      controller.jumpTo(0);
      await tester.pump();
      expect(tester.getTopLeft(thumb).dx, closeTo(start, 0.1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Offer carousel supports manual swipes in both directions', (
    tester,
  ) async {
    await pumpShop(tester);
    final pager = find.byType(PageView);
    await tester.ensureVisible(pager);
    await tester.pumpAndSettle();
    final controller = tester.widget<PageView>(pager).controller!;
    expect(controller.page, 1);
    await tester.drag(pager, const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(controller.page, closeTo(2, 0.01));
    await tester.drag(pager, const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(controller.page, closeTo(1, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Touching and dragging a slide resets the autoplay countdown', (
    tester,
  ) async {
    await pumpShop(tester);
    final pager = find.byType(PageView);
    await tester.ensureVisible(pager);
    await tester.pumpAndSettle();
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: false);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 3));
    final controller = tester.widget<PageView>(pager).controller!;
    final gesture = await tester.startGesture(tester.getCenter(pager));
    await tester.pump(const Duration(seconds: 2));
    expect(controller.page, closeTo(1, 0.01));
    await gesture.moveBy(const Offset(-20, 0));
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.moveBy(const Offset(-280, 0));
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(controller.page, closeTo(2, 0.01));
    await tester.pump(const Duration(milliseconds: 3500));
    expect(controller.page, closeTo(2, 0.01));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 500));
    expect(controller.page, closeTo(0, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Offer slides autoplay and pause when Home is hidden', (
    tester,
  ) async {
    await pumpShop(tester);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: false);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    final pager = tester.widget<PageView>(find.byType(PageView));
    expect(pager.controller!.page, 1);
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
    expect(pager.controller!.page, closeTo(2, 0.01));
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    await tester.tap(find.byKey(const ValueKey('tab-4')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    expect(pager.controller!.page, closeTo(2, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cart and account retain one shared animation element', (
    tester,
  ) async {
    await pumpShop(tester);
    await tester.tap(find.byKey(const ValueKey('tab-1')));
    await tester.pumpAndSettle();
    final animation = find.byKey(const ValueKey('shared-empty-animation'));
    final original = tester.element(animation);
    expect(
      find.descendant(
        of: find.byType(SharedEmptyState),
        matching: find.text('Giỏ hàng'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('tab-4')));
    await tester.pumpAndSettle();
    expect(identical(tester.element(animation), original), isTrue);
    expect(find.text('Chào mừng bạn đến với FOSO'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('tab-1')));
    await tester.pumpAndSettle();
    expect(identical(tester.element(animation), original), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Account loads bundled Lottie without layout errors', (
    tester,
  ) async {
    await pumpShop(tester, width: 320);
    await tester.tap(find.byKey(const ValueKey('tab-4')));
    await tester.pumpAndSettle();
    expect(find.text('Chào mừng bạn đến với FOSO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Buying updates the badge while Cart keeps the shared Lottie', (
    tester,
  ) async {
    await pumpShop(tester);
    await tester.ensureVisible(find.text('Mua ngay').first);
    await tester.tap(find.text('Mua ngay').first);
    await tester.pumpAndSettle();
    final badge = find.byKey(const ValueKey('cart-count-badge'));
    expect(
      find.descendant(of: badge, matching: find.text('1')),
      findsOneWidget,
    );
    expect(find.text('Đã thêm sản phẩm vào giỏ hàng'), findsOneWidget);
    await tester.tap(find.text('Mua ngay').first);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: badge, matching: find.text('2')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('tab-1')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('shared-empty-animation')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(SharedEmptyState),
        matching: find.text('Giỏ hàng'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Tổng cộng:'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home scrolls through products to the articles', (tester) async {
    await pumpShop(tester);
    await tester.dragUntilVisible(
      find.text('Bài Viết Nổi Bật').first,
      find.byType(SingleChildScrollView).first,
      const Offset(0, -450),
    );
    await tester.pumpAndSettle();
    expect(find.text('13/02/2025'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 393.0, 430.0]) {
    testWidgets('Home and category fit ${width.toInt()}px', (tester) async {
      await pumpShop(tester, width: width);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('tab-2')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Figma images and icons resolve to native 3x assets', (
    tester,
  ) async {
    for (final name in [
      'product',
      'offer_banner',
      'filter_0',
      'brand_0',
      'ic_home',
      'ic_search',
      'ic_notification',
    ]) {
      final key = await AssetImage(
        'assets/images/$name.png',
      ).obtainKey(const ImageConfiguration(devicePixelRatio: 3));
      expect(key.scale, 3);
      expect(key.name, 'assets/images/3.0x/$name.png');
    }
  });

  testWidgets('Capture reference previews', (tester) async {
    if (!Platform.environment.containsKey('CAPTURE_PREVIEWS')) return;
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.padding = const FakeViewPadding(top: 132, bottom: 102);
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MyApp(repository: TestCatalogRepository()),
      ),
    );
    final imageContext = tester.element(find.byType(ShopShell));
    await tester.runAsync(() async {
      await Future.wait(
        Directory('assets/images')
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.png'))
            .map((file) => precacheImage(AssetImage(file.path), imageContext)),
      );
    });
    await tester.pumpAndSettle();
    await tester.pump();
    Future<void> capture(String name) async {
      final image =
          await (key.currentContext!.findRenderObject()
                  as RenderRepaintBoundary)
              .toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('build/previews/$name.png')
          .create(recursive: true)
          .then((f) => f.writeAsBytes(bytes!.buffer.asUint8List()));
      image.dispose();
    }

    await tester.runAsync(() => capture('home'));
    await tester.tap(find.byKey(const ValueKey('tab-2')));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future.wait(
        Directory('assets/images')
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.png'))
            .map((file) => precacheImage(AssetImage(file.path), imageContext)),
      );
    });
    await tester.pumpAndSettle();
    await tester.runAsync(() => capture('category'));
    expect(tester.takeException(), isNull);
    tester.view.resetPadding();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
