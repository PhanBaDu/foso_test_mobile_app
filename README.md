# FOSO Mobile App

One repository with two renderers: **iOS uses native SwiftUI**, **Android uses Flutter**. Web and desktop retain the Flutter renderer. Both follow MVVM and use the same Figma 3× assets and catalog JSON.

## Platform routing

- iOS: UIKit `AppDelegate` → `SceneDelegate` → `UIHostingController<NativeAppView>` → SwiftUI. No `FlutterViewController`, implicit Flutter engine, or Dart isolate is started. The main Flutter storyboard is no longer configured as the launch root.
- Android: existing `MainActivity : FlutterActivity` → Dart `main()` → Flutter `MyApp`.
- `lib/core/platform_renderer.dart` makes that policy explicit. Its iOS guard also prevents accidentally rendering Flutter if an engine is embedded later.

The iOS target keeps the Flutter-generated build integration/frameworks for compatibility with this repository's build tools. Its runtime interface and state are entirely native; it does not attach to Flutter hot reload. The deployment target remains iOS 13 (the banner pager has an iOS 13 fallback).

## MVVM boundaries

| Layer | Flutter | Native iOS | Responsibility |
| --- | --- | --- | --- |
| Model | `lib/models/` | `ios/Runner/Native/Models/` | Immutable catalog values and reference validation |
| Repository | `lib/data/` | `ios/Runner/Native/Data/` | Injected asynchronous catalog-loading boundary |
| ViewModel | `lib/view_models/` | `ios/Runner/Native/ViewModels/` | Selection/search, deadline-based countdown, cart lines/totals and tab state |
| View | `lib/screens/`, `lib/widgets/` | `ios/Runner/Native/Views/` | Layout, reusable components, input controllers and presentation |
| Composition | `lib/app/` | `ios/Runner/Native/App/`, `SceneDelegate.swift` | Dependency ownership, loading/error/retry and lifecycle cleanup |

ViewModels do not hold Flutter BuildContext, SwiftUI views, or view controllers. Dart uses ChangeNotifier/ListenableBuilder; Swift uses ObservableObject/@Published. Navigation IDs replace index remapping. Cart operations support multiple products and do not allow negative quantities. Countdown values derive from an absolute deadline, including after background suspension. Comments explain platform boundaries, data validation, ownership and cleanup.

## Shared resources

- `assets/data/catalog.json`: the canonical catalog for both platforms.
- `assets/images/` and `assets/images/3.0x/`: canonical Figma image/icon variants.
- `assets/fonts/`: Inter and its OFL license.
- `design/figma/`: unmodified 3× Figma exports and extraction manifest.
- `tools/export_figma_assets.py`: extracts density-correct assets without upscaling.
- `tools/sync_ios_resources.py`: idempotently generates iOS image sets, bundled catalog and font resources. Xcode runs it automatically before building. Change the canonical resources, then rebuild; do not edit generated native copies.

The source catalog/assets and their schema are shared across languages. ViewModels have equivalent responsibilities and behavior tests in Dart and Swift; Dart classes are not executed inside native iOS.

## Run

Install Flutter dependencies first:

```sh
flutter pub get
```

Android: install/configure the Android SDK and a JDK, select an Android device with `flutter devices`, then run `flutter run -d DEVICE_ID`.

iOS: open `ios/Runner.xcworkspace` in Xcode, select the Runner scheme and an iPhone/simulator, and press Run. Use Xcode/SwiftUI debugging for this native interface.

## Validation

```sh
flutter analyze
flutter test
flutter build web
flutter build ios --simulator --debug
```

For native tests, select an available simulator in Xcode and run Product → Test, or:

```sh
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

`CAPTURE_PREVIEWS=1 flutter test` writes 3× Flutter previews under `build/previews/`. Native XCTest attaches Home/Category renders to its result bundle. System status-bar content is provided by iOS, not drawn into widget snapshots.

## Current scope

Home, categories/search, product previews, cart quantities/totals, news/article previews and an account placeholder. Catalog data is bundled and carts are in memory. No backend, authentication, payment or image-search service is connected. Figma was only read/exported; no design edits or comments were posted.

Local validation: Flutter analyzer/tests and Web build; native iOS simulator build and XCTest. Android APK build requires the Android SDK, which is not installed on this machine.
