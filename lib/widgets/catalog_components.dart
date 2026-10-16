import 'package:flutter/material.dart';
import '../models/catalog.dart';
import '../core/formatters.dart';
import '../theme.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    required this.icon,
    this.onSeeAll,
    this.light = false,
  });
  final String title;
  final String icon;
  final VoidCallback? onSeeAll;
  final bool light;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
    child: Row(
      children: [
        FigmaIcon(icon, size: 24),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: light ? Colors.white : const Color(0xFF454F5B),
            ),
          ),
        ),
        if (onSeeAll != null)
          seeAll(onSeeAll!, color: light ? Colors.white : AppColors.blue),
      ],
    ),
  );
}

Widget seeAll(VoidCallback onTap, {Color color = AppColors.blue}) => InkWell(
  onTap: onTap,
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Xem tất cả', style: TextStyle(fontSize: 8, color: color)),
        FigmaIcon('chevrons', size: 12, color: color),
      ],
    ),
  ),
);

class ArticleList extends StatelessWidget {
  const ArticleList({
    super.key,
    required this.onArticle,
    required this.articles,
  });
  final ValueChanged<Article> onArticle;
  final List<Article> articles;
  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      3,
      (i) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => onArticle(articles[i]),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: assetImage(
                      articles[i].image,
                      width: 120,
                      height: 81,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 81,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            articles[i].title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
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

void openArticle(BuildContext context, Article article) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              assetImage(
                article.image,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
              Text(
                article.title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                formatDate(article.date),
                style: TextStyle(color: AppColors.blue),
              ),
            ],
          ),
        ),
      ),
    );
