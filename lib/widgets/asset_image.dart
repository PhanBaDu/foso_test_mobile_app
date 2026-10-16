import 'package:flutter/material.dart';

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
