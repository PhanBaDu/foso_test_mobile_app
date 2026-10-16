import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'core/platform_renderer.dart';
import 'theme.dart';
export 'app/app.dart';
export 'app/shop_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // iOS creates a UIHostingController in SceneDelegate and never starts Dart.
  // Keep the guard explicit in case a Flutter engine is embedded there later.
  if (rendererFor(defaultTargetPlatform, isWeb: kIsWeb) ==
      AppRenderer.nativeIOS) {
    return;
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.blue,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}
