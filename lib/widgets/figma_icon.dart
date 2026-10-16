import 'package:flutter/material.dart';

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
