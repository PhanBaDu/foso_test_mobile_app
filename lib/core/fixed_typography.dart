import 'package:flutter/widgets.dart';

/// Keeps the app's designed type sizes/weights while retaining all other insets
/// and accessibility settings, including keyboard and reduced-motion updates.
class FixedTypography extends StatelessWidget {
  const FixedTypography({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(textScaler: TextScaler.noScaling, boldText: false),
      child: child,
    );
  }
}
