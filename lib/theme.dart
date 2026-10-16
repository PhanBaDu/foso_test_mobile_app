import 'package:flutter/material.dart';

// Preserve existing imports while asset widgets live in the presentation layer.
export 'widgets/asset_image.dart';
export 'widgets/figma_icon.dart';

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
