import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/catalog.dart';
import '../theme.dart';

class ArticleList extends StatelessWidget {
  const ArticleList({
    super.key,
    required this.articles,
    this.gap = 16,
    this.cardPadding = 6,
    this.textGap = 8,
  });

  final List<Article> articles;
  final double gap, cardPadding, textGap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Column(
      children: [
        for (var i = 0; i < articles.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          _ArticleCard(
            key: ValueKey(articles[i].id),
            article: articles[i],
            gap: gap,
            padding: cardPadding,
            textGap: textGap,
          ),
        ],
      ],
    ),
  );
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({
    super.key,
    required this.article,
    required this.gap,
    required this.padding,
    required this.textGap,
  });

  final Article article;
  final double gap, padding, textGap;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: assetImage(
            article.image,
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
                  article.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                SizedBox(height: textGap),
                Text(
                  formatDate(article.date),
                  style: const TextStyle(fontSize: 12, color: AppColors.blue),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
