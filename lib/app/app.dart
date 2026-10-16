import 'package:flutter/material.dart';
import '../data/catalog_repository.dart';
import '../core/fixed_typography.dart';
import '../theme.dart';
import 'shop_shell.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.repository});
  final CatalogRepository? repository;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'FOSO',
    builder: (context, child) =>
        FixedTypography(child: child ?? const SizedBox.shrink()),
    scrollBehavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        primary: AppColors.blue,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: ThemeData.light().textTheme.apply(
        fontFamily: 'Inter',
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    ),
    home: ShopShell(repository: repository),
  );
}
