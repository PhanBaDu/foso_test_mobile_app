import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foso_test_mobile_app/app/app.dart';
import 'package:foso_test_mobile_app/app/shop_shell.dart';
import 'package:foso_test_mobile_app/data/catalog_repository.dart';
import 'package:foso_test_mobile_app/models/catalog.dart';
import 'package:foso_test_mobile_app/widgets/navigation_bar.dart';

class _CatalogRepository implements CatalogRepository {
  @override
  Future<CatalogData> load() async => CatalogData.fromJson(
    jsonDecode(File('assets/data/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );
}

class _TextPresentation {
  const _TextPresentation(this.bounds, this.style);
  final Rect bounds;
  final TextStyle style;
}

Finder get _title => find.text('Danh mục tiêu biểu');
Finder get _tabLabel => find.descendant(
  of: find.byType(ShopNavigationBar),
  matching: find.text('Trang chủ'),
);

_TextPresentation _textPresentation(WidgetTester tester, Finder text) {
  final richText = tester.widget<RichText>(
    find.descendant(of: text, matching: find.byType(RichText)),
  );
  expect(richText.textScaler.scale(16), 16);
  return _TextPresentation(tester.getRect(text), richText.text.style!);
}

Map<String, _TextPresentation> _presentations(WidgetTester tester) {
  final editable = tester.state<EditableTextState>(find.byType(EditableText));
  expect(editable.renderEditable.textScaler.scale(15), 15);
  return {
    'input': _TextPresentation(
      tester.getRect(find.byType(TextField)),
      editable.renderEditable.text!.style!,
    ),
    'title': _textPresentation(tester, _title),
    'tab': _textPresentation(tester, _tabLabel),
  };
}

void _expectFixedMedia(WidgetTester tester) {
  for (final finder in [find.byType(TextField), _title, _tabLabel]) {
    final media = MediaQuery.of(tester.element(finder));
    expect(media.textScaler.scale(10), 10);
    expect(media.textScaler.scale(24), 24);
    expect(media.boldText, isFalse);
  }
}

Future<void> _pumpShop(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(393, 852);
  tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 20);
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 20);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetViewPadding);
  addTearDown(tester.view.resetPadding);
  await tester.pumpWidget(MyApp(repository: _CatalogRepository()));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    final loader = FontLoader('Inter');
    for (final weight in ['Regular', 'SemiBold', 'Bold']) {
      loader.addFont(
        File(
          'assets/fonts/Inter-$weight.ttf',
        ).readAsBytes().then((bytes) => bytes.buffer.asByteData()),
      );
    }
    await loader.load();
  });

  tearDown(() {
    final dispatcher =
        TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher;
    dispatcher.clearTextScaleFactorTestValue();
    dispatcher.clearAccessibilityFeaturesTestValue();
  });

  testWidgets('OS font size and Bold Text changes retain designed typography', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    await _pumpShop(tester);
    final before = _presentations(tester);
    _expectFixedMedia(tester);
    expect(before['input']!.style.fontSize, 15);
    expect(before['input']!.style.fontWeight, FontWeight.w400);
    expect(before['title']!.style.fontSize, 16);
    expect(before['tab']!.style.fontSize, 10);
    expect(before['title']!.style.fontWeight, FontWeight.w600);
    expect(before['tab']!.style.fontWeight, FontWeight.w600);

    tester.platformDispatcher.textScaleFactorTestValue = 2;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(
          boldText: true,
          disableAnimations: true,
        );
    await tester.pumpAndSettle();
    _expectFixedMedia(tester);
    final enlarged = _presentations(tester);
    for (final name in before.keys) {
      expect(enlarged[name]!.bounds, before[name]!.bounds, reason: name);
      expect(
        enlarged[name]!.style.fontSize,
        before[name]!.style.fontSize,
        reason: name,
      );
      expect(
        enlarged[name]!.style.fontWeight,
        before[name]!.style.fontWeight,
        reason: name,
      );
      expect(enlarged[name]!.style.fontFamily, 'Inter', reason: name);
    }

    tester.platformDispatcher.textScaleFactorTestValue = .8;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    await tester.pumpAndSettle();
    _expectFixedMedia(tester);
    final reduced = _presentations(tester);
    for (final name in before.keys) {
      expect(reduced[name]!.bounds, before[name]!.bounds, reason: name);
      expect(
        reduced[name]!.style.fontWeight,
        before[name]!.style.fontWeight,
        reason: name,
      );
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Fixed typography preserves insets and other accessibility flags',
    (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(
            boldText: true,
            disableAnimations: true,
            accessibleNavigation: true,
            highContrast: true,
            invertColors: true,
          );
      await _pumpShop(tester);
      _expectFixedMedia(tester);
      final initial = _presentations(tester);
      expect(initial['input']!.style.fontWeight, FontWeight.w400);
      expect(initial['title']!.style.fontSize, 16);
      expect(initial['tab']!.style.fontWeight, FontWeight.w600);
      MediaQueryData media() =>
          MediaQuery.of(tester.element(find.byType(ShopShell)));
      expect(media().disableAnimations, isTrue);
      expect(media().accessibleNavigation, isTrue);
      expect(media().highContrast, isTrue);
      expect(media().invertColors, isTrue);
      expect(media().size, const Size(393, 852));
      expect(media().viewPadding, const EdgeInsets.only(top: 24, bottom: 20));

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(boldText: true);
      await tester.pump();
      _expectFixedMedia(tester);
      expect(media().viewInsets.bottom, 300);
      expect(media().viewPadding, const EdgeInsets.only(top: 24, bottom: 20));
      expect(media().disableAnimations, isFalse);
      expect(media().accessibleNavigation, isFalse);
      expect(media().highContrast, isFalse);
      expect(media().invertColors, isFalse);
      expect(find.byTooltip('Đóng bàn phím'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
