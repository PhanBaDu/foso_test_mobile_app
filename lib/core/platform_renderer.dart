import 'package:flutter/foundation.dart';

enum AppRenderer { nativeIOS, flutter }

/// iOS is bootstrapped by SceneDelegate; Android and web retain Flutter.
AppRenderer rendererFor(TargetPlatform platform, {bool isWeb = false}) =>
    !isWeb && platform == TargetPlatform.iOS
    ? AppRenderer.nativeIOS
    : AppRenderer.flutter;
