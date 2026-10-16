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

iOS native debugging: open `ios/Runner.xcworkspace` in Xcode, select the Runner scheme and an iPhone/simulator, and press **⌘R**. Runner's Run action already uses Debug + LLDB, so Swift breakpoints, variables and crash stacks are available. Rebuild native Swift changes with Xcode; Dart hot reload does not update SwiftUI.

For terminal builds and app logs, use:

```sh
python3 tools/run_ios_native.py
# Choose a device explicitly when several are available:
python3 tools/run_ios_native.py --list
python3 tools/run_ios_native.py --device DEVICE_ID
```

The script builds Debug, installs and launches the native app without waiting for a Dart VM Service. It prefers one connected iPhone, or one booted simulator when no phone is connected. Use `--no-console` to return after launching. Build logs are saved in `build/native_ios/build.log`. For Swift breakpoints use Xcode Run or attach Xcode's debugger to Runner; the terminal log command does not attach LLDB.

VS Code: **Terminal → Run Task** exposes the native Debug/logs command and a separate task to open Xcode.

`flutter run` is for the Flutter renderer. Native iOS does not start a FlutterEngine/Dart isolate, so Flutter's Debug runner cannot discover a VM Service and will wait. Package update notices are unrelated. The CLI's `Application finished.` message alone does not identify a native crash; inspect Xcode's process/crash logs.

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

## Presentation components

Android uses the native iOS layout as its reference, in logical pixels matching iOS points: 60-point tab content, 24-point top tab corners, 12-point section gaps, and the same catalog/image assets. Platform status bars, keyboards, haptic hardware and system-rounded iOS text remain platform-specific. Inter is the only bundled font family. App typography stays at its designed sizes and weights: Flutter fixes text scaling/Bold Text at the app boundary, and iOS fixes Dynamic Type/legibility at the native root. Other insets and accessibility preferences continue to update normally.

- `lib/screens/home_screen.dart` composes sections. `widgets/home/` owns the carousel timer and featured-list scroll progress; countdown notifications rebuild only the relevant animated components.
- `lib/screens/category_screen.dart` binds the ViewModel to `widgets/category/`. The sidebar owns its moving concave highlight; results use the available pane width for compact layout.
- `widgets/navigation_bar.dart` owns marker movement, glow, icon fades, haptics and cart badge digits. Marker ticks repaint a separate surface without relaying out the tab content.
- `widgets/section_heading.dart`, `see_all_button.dart`, `article_list.dart`, `product_card.dart` and `rolling_number.dart` are shared presentation components. `catalog_components.dart` preserves their existing imports.
- `lib/app/shop_content.dart` composes retained tabs through `widgets/retained_tab.dart`. The shell retains tab instances, fades between them and mounts one Lottie instance for Cart/Account. Search remembers its originating tab; choosing Category directly has no back arrow. The keyboard overlays the navigation and can be dismissed outside the field or with the dismiss button.

## Current scope

Home, categories/search, news and shared Cart/Account placeholders are active. Buying updates the in-memory cart badge and shows a toast with a Cart action. Product/article/notification sheets are removed. Catalog data is bundled. No backend, authentication, payment or image-search service is connected.

Android APK/device validation requires an Android SDK; set `ANDROID_HOME` or local `sdk.dir` before running `flutter build apk --debug`. `android/local.properties` is machine-local and ignored. Flutter widget tests exercise the UI and flow independently of the SDK.
