import 'package:flutter/material.dart';
import '../models/catalog.dart';
import '../core/formatters.dart';
import '../theme.dart';

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
  final Color? iconColor;
  final Color? color, actionColor;
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
          child: Text(
            title,
            strutStyle: const StrutStyle(
              fontSize: 16,
              height: 1.5,
              forceStrutHeight: true,
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color ?? (light ? Colors.white : AppColors.text),
            ),
          ),
        ),
        if (accessory != null) ...[SizedBox(width: gap), accessory!],
        if (onSeeAll != null) ...[
          if (accessory != null) SizedBox(width: gap),
          seeAll(
            onSeeAll!,
            color: actionColor ?? (light ? Colors.white : AppColors.blue),
          ),
        ],
      ],
    ),
  );
}

class SeeAllButton extends StatelessWidget {
  const SeeAllButton({
    super.key,
    required this.onTap,
    this.color = AppColors.blue,
    this.fontSize = 12,
  });
  final VoidCallback onTap;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Xem tất cả',
            style: TextStyle(fontSize: fontSize, color: color),
          ),
          const SizedBox(width: 3),
          Transform.translate(
            offset: const Offset(0, 1),
            child: FigmaIcon('chevrons', size: 12, color: color),
          ),
        ],
      ),
    ),
  );
}

Widget seeAll(
  VoidCallback onTap, {
  Color color = AppColors.blue,
  double fontSize = 12,
}) => SeeAllButton(onTap: onTap, color: color, fontSize: fontSize);

class ArticleList extends StatelessWidget {
  const ArticleList({
    super.key,
    required this.articles,
    this.gap = 16,
    this.cardPadding = 6,
    this.textGap = 0,
  });
  final List<Article> articles;
  final double gap, cardPadding, textGap;
  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      3,
      (i) => Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, gap),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: assetImage(
                      articles[i].image,
                      width: 120,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: SizedBox(
                      height: 96,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            articles[i].title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          SizedBox(height: textGap),
                          Text(
                            formatDate(articles[i].date),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
