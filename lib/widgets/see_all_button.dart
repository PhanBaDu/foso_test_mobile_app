import 'package:flutter/material.dart';

import '../theme.dart';

class SeeAllButton extends StatelessWidget {
  const SeeAllButton({
    super.key,
    this.onTap,
    this.color = AppColors.blue,
    this.fontSize = 12,
  });

  final VoidCallback? onTap;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final label = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Xem tất cả',
            maxLines: 1,
            style: TextStyle(fontSize: fontSize, color: color),
          ),
          const SizedBox(width: 3),
          Transform.translate(
            offset: const Offset(0, 1),
            child: FigmaIcon('chevrons', size: 12, color: color),
          ),
        ],
      ),
    );
    return onTap == null ? label : InkWell(onTap: onTap, child: label);
  }
}

Widget seeAll(
  VoidCallback onTap, {
  Color color = AppColors.blue,
  double fontSize = 12,
}) => SeeAllButton(onTap: onTap, color: color, fontSize: fontSize);
