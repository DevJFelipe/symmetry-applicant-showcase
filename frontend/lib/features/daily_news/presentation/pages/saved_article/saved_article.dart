import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/app_radius.dart';
import 'package:news_app_clean_architecture/core/services/haptic_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/shared/widgets/widgets.dart';

/// Premium Saved Articles page with immersive dark theme.
///
/// Features:
/// - Animated list with stagger effect
/// - Swipe to delete with haptic feedback
/// - Empty state with illustration
/// - Premium loading states
/// - Glassmorphism app bar
class SavedArticles extends StatefulWidget {
  const SavedArticles({super.key});

  @override
  State<SavedArticles> createState() => _SavedArticlesState();
}

class _SavedArticlesState extends State<SavedArticles> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>()..add(const GetSavedArticles()),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      leading: _buildBackButton(),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(
          left: 56,
          bottom: 16,
        ),
        title: Text(
          'Saved Articles',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryDark.withValues(alpha: 0.3),
                AppColors.background,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        HapticService.lightImpact();
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
      builder: (context, state) {
        if (state is LocalArticlesLoading) {
          return const SliverFillRemaining(
            child: Center(child: PremiumLoading()),
          );
        }

        if (state is LocalArticlesDone) {
          final articles = state.articles ?? [];

          if (articles.isEmpty) {
            return SliverFillRemaining(
              child: EmptyStateWidget.noSavedArticles(
                onBrowse: () => Navigator.pop(context),
              ),
            );
          }

          return _buildArticlesList(articles);
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildArticlesList(List<ArticleEntity> articles) {
    return SliverPadding(
      padding: AppSpacing.page,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final article = articles[index];
            return _SavedArticleCard(
              article: article,
              index: index,
              onTap: () => _onArticlePressed(article),
              onRemove: () => _onRemoveArticle(context, article),
            );
          },
          childCount: articles.length,
        ),
      ),
    );
  }

  void _onRemoveArticle(BuildContext context, ArticleEntity article) {
    HapticService.warning();
    BlocProvider.of<LocalArticleBloc>(context).add(RemoveArticle(article));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Article removed',
          style: AppTypography.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.accent,
          onPressed: () {
            context.read<LocalArticleBloc>().add(SaveArticle(article));
          },
        ),
      ),
    );
  }

  void _onArticlePressed(ArticleEntity article) {
    HapticService.lightImpact();
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }
}

/// Premium saved article card with swipe to delete.
class _SavedArticleCard extends StatelessWidget {
  final ArticleEntity article;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SavedArticleCard({
    required this.article,
    required this.index,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(article.url ?? article.title ?? index.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: _buildDismissBackground(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.surfaceLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowDark,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image
              _buildImage(),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source tag
                      _buildSourceTag(),
                      const SizedBox(height: AppSpacing.xs),

                      // Title
                      Text(
                        article.title ?? 'Untitled',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // Date
                      _buildMetaRow(),
                    ],
                  ),
                ),
              ),

              // Remove button
              _buildRemoveButton(),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 50 * index))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildImage() {
    final imageUrl = article.urlToImage;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppRadius.lg),
        bottomLeft: Radius.circular(AppRadius.lg),
      ),
      child: SizedBox(
        width: 100,
        height: 100,
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.surfaceLight,
                  child: const Center(
                    child: PremiumSpinner(size: 20),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceLight,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textMuted,
                    size: 24,
                  ),
                ),
              )
            : Container(
                color: AppColors.surfaceLight,
                child: Icon(
                  Icons.article_outlined,
                  color: AppColors.textMuted,
                  size: 32,
                ),
              ),
      ),
    );
  }

  Widget _buildSourceTag() {
    final source = article.source?.name ?? 'News';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        source,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMetaRow() {
    return Row(
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 14,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            _formatDate(article.publishedAt),
            style: AppTypography.caption.copyWith(
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRemoveButton() {
    return GestureDetector(
      onTap: onRemove,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Icon(
          Icons.bookmark_remove_outlined,
          color: AppColors.error,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      child: Icon(
        Icons.delete_outline_rounded,
        color: AppColors.error,
        size: 28,
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';

    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        if (diff.inHours == 0) {
          return '${diff.inMinutes}m ago';
        }
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      } else {
        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      }
    } catch (_) {
      return dateStr;
    }
  }
}
