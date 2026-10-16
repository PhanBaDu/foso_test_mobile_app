import 'package:flutter/material.dart';

abstract final class AppColors {
  static const featuredCategoryTitle = Color(0xFF013065);
  static const blue = Color(0xFF025FCA);
  static const brightBlue = Color(0xFF037AFF);
  static const background = Color(0xFFF7F9FA);
  static const paleBlue = Color(0xFFE6F1FF);
  static const text = Color(0xFF1C252E);
  static const muted = Color(0xFF919EAB);
  static const salesProgressStart = Color(0xFFFF5630);
  static const salesProgressEnd = Color(0xFFB71D18);
  static const salesProgressTrack = Color(0xFFF5D5D4);
  static const salesProgressBadge = Color(0xFFFFF3D9);
  static const flash = Color(0xFFFF6948);
  static const limitedStockText = Color(0xFF7A0916);
  static const red = Color(0xFFEF382F);
}

Widget assetImage(
  String name, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
}) => Image.asset(
  'assets/images/$name.png',
  width: width,
  height: height,
  fit: fit,
  filterQuality: FilterQuality.high,
);

class FigmaIcon extends StatelessWidget {
  const FigmaIcon(this.name, {super.key, this.size = 24, this.color});
  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/ic_$name.png',
    width: size,
    height: size,
    color: color,
    filterQuality: FilterQuality.high,
    excludeFromSemantics: true,
  );
}
