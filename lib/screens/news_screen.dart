import 'package:flutter/material.dart';
import '../models/catalog.dart';
import '../theme.dart';
import '../widgets/catalog_components.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key, required this.articles});

  final List<Article> articles;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      children: [
        const SectionHeading(
          title: 'Bài Viết Nổi Bật',
          icon: 'tab_news',
          iconColor: AppColors.blue,
          gap: 12,
          padding: EdgeInsets.all(12),
        ),
        ArticleList(gap: 12, cardPadding: 6, textGap: 12, articles: articles),
        const SizedBox(height: 36),
      ],
    ),
  );
}
