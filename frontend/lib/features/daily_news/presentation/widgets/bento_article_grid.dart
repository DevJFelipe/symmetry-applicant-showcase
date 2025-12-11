import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/animated_bento_card.dart';

/// A responsive Bento Grid layout for displaying articles.
///
/// Creates an asymmetric grid with:
/// - First article: Large card (featured)
/// - Next 2 articles: Medium cards side by side
/// - Remaining: Alternating pattern
class BentoArticleGrid extends StatelessWidget {
  final List<ArticleEntity> articles;
  final String? currentUserId;
  final Function(ArticleEntity)? onArticleTap;
  final Function(ArticleEntity)? onArticleLongPress;

  const BentoArticleGrid({
    super.key,
    required this.articles,
    this.currentUserId,
    this.onArticleTap,
    this.onArticleLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const SizedBox.shrink();
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildRow(context, index),
          childCount: _calculateRowCount(),
        ),
      ),
    );
  }

  int _calculateRowCount() {
    if (articles.isEmpty) return 0;
    if (articles.length == 1) return 1;
    if (articles.length == 2) return 2;
    if (articles.length == 3) return 2;
    
    // First large, then pairs
    // articles.length - 1 = remaining after first
    // (remaining + 1) / 2 = number of pair rows (ceil division)
    final remaining = articles.length - 1;
    final pairRows = (remaining + 1) ~/ 2;
    return 1 + pairRows;
  }

  Widget _buildRow(BuildContext context, int rowIndex) {
    // First row: Large featured card
    if (rowIndex == 0) {
      return Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.bentoGap),
        child: AnimatedBentoCard(
          article: articles[0],
          size: BentoCardSize.large,
          index: 0,
          currentUserId: currentUserId,
          onTap: () => onArticleTap?.call(articles[0]),
          onLongPress: () => onArticleLongPress?.call(articles[0]),
        ),
      );
    }

    // Calculate article indices for this row
    // Row 1: articles[1] and articles[2]
    // Row 2: articles[3] and articles[4]
    // etc.
    final firstIndex = 1 + (rowIndex - 1) * 2;
    final secondIndex = firstIndex + 1;

    // Single card if we only have one left
    if (secondIndex >= articles.length) {
      return Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.bentoGap),
        child: AnimatedBentoCard(
          article: articles[firstIndex],
          size: BentoCardSize.medium,
          index: firstIndex,
          currentUserId: currentUserId,
          onTap: () => onArticleTap?.call(articles[firstIndex]),
          onLongPress: () => onArticleLongPress?.call(articles[firstIndex]),
        ),
      );
    }

    // Two cards side by side
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.bentoGap),
      child: Row(
        children: [
          Expanded(
            child: AnimatedBentoCard(
              article: articles[firstIndex],
              size: BentoCardSize.medium,
              index: firstIndex,
              currentUserId: currentUserId,
              onTap: () => onArticleTap?.call(articles[firstIndex]),
              onLongPress: () => onArticleLongPress?.call(articles[firstIndex]),
            ),
          ),
          SizedBox(width: AppSpacing.bentoGap),
          Expanded(
            child: AnimatedBentoCard(
              article: articles[secondIndex],
              size: BentoCardSize.medium,
              index: secondIndex,
              currentUserId: currentUserId,
              onTap: () => onArticleTap?.call(articles[secondIndex]),
              onLongPress: () => onArticleLongPress?.call(articles[secondIndex]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Alternative staggered Bento Grid with varying heights.
class StaggeredBentoGrid extends StatelessWidget {
  final List<ArticleEntity> articles;
  final String? currentUserId;
  final Function(ArticleEntity)? onArticleTap;
  final Function(ArticleEntity)? onArticleLongPress;

  const StaggeredBentoGrid({
    super.key,
    required this.articles,
    this.currentUserId,
    this.onArticleTap,
    this.onArticleLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, sectionIndex) => _buildSection(context, sectionIndex),
          childCount: _calculateSectionCount(),
        ),
      ),
    );
  }

  int _calculateSectionCount() {
    // Each section has 3 articles:
    // - 1 large
    // - 2 medium
    return (articles.length / 3).ceil();
  }

  Widget _buildSection(BuildContext context, int sectionIndex) {
    final startIndex = sectionIndex * 3;
    
    // Get articles for this section
    final sectionArticles = <ArticleEntity>[];
    for (int i = 0; i < 3 && startIndex + i < articles.length; i++) {
      sectionArticles.add(articles[startIndex + i]);
    }

    if (sectionArticles.isEmpty) {
      return const SizedBox.shrink();
    }

    // Alternate the layout pattern
    final isEvenSection = sectionIndex % 2 == 0;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.bentoGap),
      child: Column(
        children: [
          if (sectionArticles.length >= 1)
            // Large card
            Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.bentoGap),
              child: AnimatedBentoCard(
                article: sectionArticles[0],
                size: BentoCardSize.large,
                index: startIndex,
                currentUserId: currentUserId,
                onTap: () => onArticleTap?.call(sectionArticles[0]),
                onLongPress: () => onArticleLongPress?.call(sectionArticles[0]),
              ),
            ),
          
          if (sectionArticles.length >= 2)
            // Medium cards row
            Row(
              children: [
                Expanded(
                  flex: isEvenSection ? 1 : 2,
                  child: AnimatedBentoCard(
                    article: sectionArticles[1],
                    size: isEvenSection ? BentoCardSize.small : BentoCardSize.medium,
                    index: startIndex + 1,
                    currentUserId: currentUserId,
                    onTap: () => onArticleTap?.call(sectionArticles[1]),
                    onLongPress: () => onArticleLongPress?.call(sectionArticles[1]),
                  ),
                ),
                if (sectionArticles.length >= 3) ...[
                  SizedBox(width: AppSpacing.bentoGap),
                  Expanded(
                    flex: isEvenSection ? 2 : 1,
                    child: AnimatedBentoCard(
                      article: sectionArticles[2],
                      size: isEvenSection ? BentoCardSize.medium : BentoCardSize.small,
                      index: startIndex + 2,
                      currentUserId: currentUserId,
                      onTap: () => onArticleTap?.call(sectionArticles[2]),
                      onLongPress: () => onArticleLongPress?.call(sectionArticles[2]),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
