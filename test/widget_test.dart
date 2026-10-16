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
    expect(find.text('Bộ Lọc Nhiên Liệu'), findsOneWidget);
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
    await tester.tapAt(const Offset(200, 210));
    await tester.pump();
    expect(editor.focusNode.hasFocus, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Buying updates cart and quantity can be removed', (
    tester,
  ) async {
    await pumpShop(tester);
    await tester.ensureVisible(find.text('Mua ngay').first);
    await tester.tap(find.text('Mua ngay').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tab-1')));
    await tester.pumpAndSettle();
    expect(find.text('Tổng cộng: 299,000 đ'), findsOneWidget);
    await tester.tap(find.byTooltip('Giảm số lượng'));
    await tester.pumpAndSettle();
    expect(find.text('Giỏ hàng của bạn đang trống'), findsOneWidget);
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
