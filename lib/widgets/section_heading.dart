import 'package:flutter/material.dart';

import '../theme.dart';
import 'see_all_button.dart';

/// Matches the native section header, with an optional icon, accessory and action.
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.icon,
    this.onSeeAll,
    this.light = false,
    this.iconColor,
    this.color,
    this.accessory,
    this.actionColor,
    this.gap = 9,
    this.padding = const EdgeInsets.fromLTRB(12, 24, 12, 16),
  });

  final String title;
  final String? icon;
  final VoidCallback? onSeeAll;
  final bool light;
  final Color? iconColor, color, actionColor;
  final Widget? accessory;
  final double gap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Row(
      children: [
        if (icon != null) ...[
          FigmaIcon(icon!, size: 24, color: iconColor),
          SizedBox(width: gap),
        ],
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: SizedBox(
                  height: 24,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color ?? (light ? Colors.white : AppColors.text),
                      ),
                    ),
                  ),
                ),
              ),
              if (accessory != null) ...[SizedBox(width: gap), accessory!],
            ],
          ),
        ),
        if (onSeeAll != null) ...[
          const SizedBox(width: 4),
          SeeAllButton(
            onTap: onSeeAll!,
            color: actionColor ?? (light ? Colors.white : AppColors.blue),
          ),
        ],
      ],
    ),
  );
}
