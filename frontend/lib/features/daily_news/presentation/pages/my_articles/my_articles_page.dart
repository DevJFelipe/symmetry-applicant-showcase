import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/app_radius.dart';
import 'package:news_app_clean_architecture/core/services/haptic_service.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_state.dart';
import 'package:news_app_clean_architecture/shared/widgets/widgets.dart';

/// My Articles page showing user's created articles.
///
/// Uses [MyArticlesCubit] for state management following Clean Architecture.
/// Integrated with [MainNavigationShell] for bottom navigation.
class MyArticlesPage extends StatefulWidget {
  const MyArticlesPage({super.key});

  @override
  State<MyArticlesPage> createState() => _MyArticlesPageState();
}

class _MyArticlesPageState extends State<MyArticlesPage> {
  @override
  void initState() {
    super.initState();
    _loadArticlesIfNeeded();
  }

  void _loadArticlesIfNeeded() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated && authState.user != null) {
      context.read<MyArticlesCubit>().loadArticles(authState.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<MyArticlesCubit, MyArticlesState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                _buildContent(state),
              ],
            );
          },
        ),
        floatingActionButton: AnimatedFAB(
          icon: Icons.add_rounded,
          label: 'New Article',
          onPressed: _onCreateArticle,
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, MyArticlesState state) {
    if (state is MyArticleDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is MyArticlesError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: AppSpacing.screenPaddingH,
          bottom: AppSpacing.md,
        ),
        title: Text(
          'My Articles',
          style: AppTypography.headlineLarge.copyWith(fontSize: 24),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background,
                AppColors.background.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(MyArticlesState state) {
    return switch (state) {
      MyArticlesInitial() || MyArticlesLoading() => _buildLoadingState(),
      MyArticlesLoaded(:final articles) => _buildArticlesList(articles),
      MyArticleDeleting(:final articles) => _buildArticlesList(articles),
      MyArticleDeleted(:final articles) => _buildArticlesList(articles),
      MyArticlesError(:final message) => _buildErrorState(message),
    };
  }

  Widget _buildLoadingState() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      sliver: SliverToBoxAdapter(
        child: ShimmerBentoGrid(itemCount: 3),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: ErrorStateWidget(
          title: 'Something went wrong',
          message: message,
          onRetry: _loadArticlesIfNeeded,
        ),
      ),
    );
  }

  Widget _buildArticlesList(List<ArticleEntity> articles) {
    if (articles.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: EmptyStateWidget(
            icon: Icons.edit_note_rounded,
            title: 'No Articles Yet',
            message: 'Start sharing your stories with the world.\nYour published articles will appear here.',
            actionLabel: 'Write Your First Article',
            onAction: _onCreateArticle,
          ),
        ).animate().fadeIn(duration: 400.ms),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) return _buildStatsCard(articles);
            return _buildArticleItem(articles[index - 1], index - 1);
          },
          childCount: articles.length + 1,
        ),
      ),
    );
  }

  Widget _buildStatsCard(List<ArticleEntity> articles) {
    final totalReactions = articles.fold<int>(
      0, (sum, article) => sum + article.totalReactions);
    final avgReactions = articles.isEmpty 
        ? '0' 
        : (totalReactions / articles.length).toStringAsFixed(1);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.lg),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: 0.15),
            AppColors.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(value: articles.length.toString(), label: 'Published', icon: Icons.article_outlined),
          _buildDivider(),
          _StatItem(value: totalReactions.toString(), label: 'Reactions', icon: Icons.favorite_outline),
          _buildDivider(),
          _StatItem(value: avgReactions, label: 'Avg. per article', icon: Icons.trending_up_rounded),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: AppColors.accent.withValues(alpha: 0.2));
  }

  Widget _buildArticleItem(ArticleEntity article, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Dismissible(
        key: Key(article.documentId ?? article.id.toString()),
        direction: DismissDirection.endToStart,
        background: _buildDismissBackground(),
        confirmDismiss: (_) => _confirmDelete(article),
        child: _ArticleListItem(
          article: article,
          onTap: () => _onArticleTapped(article),
          onEdit: () => _onEditArticle(article),
          onDelete: () => _onDeleteArticle(article),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 + (index * 50)));
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 28),
    );
  }

  Future<bool> _confirmDelete(ArticleEntity article) async {
    HapticService.warning();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmationModal(
        title: 'Delete Article',
        message: 'Are you sure you want to delete "${article.title}"?\n\nThis action cannot be undone.',
        confirmLabel: 'Delete',
        isDanger: true,
        onConfirm: () => Navigator.pop(ctx, true),
        onCancel: () => Navigator.pop(ctx, false),
      ),
    );

    if (result == true && article.documentId != null) {
      context.read<MyArticlesCubit>().deleteArticle(article.documentId!);
    }
    return false; // Deletion handled by cubit
  }

  void _onArticleTapped(ArticleEntity article) {
    HapticService.lightImpact();
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  void _onEditArticle(ArticleEntity article) {
    HapticService.lightImpact();
    // TODO: Navigate to edit article page
  }

  void _onDeleteArticle(ArticleEntity article) => _confirmDelete(article);

  void _onCreateArticle() {
    HapticService.lightImpact();
    Navigator.pushNamed(context, '/create-article');
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 20),
        SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary)),
        Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
      ],
    );
  }
}

class _ArticleListItem extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ArticleListItem({required this.article, this.onTap, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(),
            SizedBox(width: AppSpacing.md),
            Expanded(child: _buildContent()),
            _buildActionsMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: 80,
        height: 80,
        color: AppColors.surfaceLight,
        child: article.urlToImage?.isNotEmpty == true
            ? Image.network(article.urlToImage!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Center(child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 32));

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(article.title ?? 'Untitled', style: AppTypography.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
        SizedBox(height: AppSpacing.xs),
        Text(_formatDate(article.publishedAt), style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _MetricChip(icon: Icons.favorite_outline, value: article.totalReactions.toString()),
            SizedBox(width: AppSpacing.sm),
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Text('PUBLISHED', style: AppTypography.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 9)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: AppColors.textMuted, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      color: AppColors.surface,
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'edit', child: Row(children: [
          Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
          SizedBox(width: AppSpacing.sm),
          Text('Edit', style: AppTypography.bodyMedium),
        ])),
        PopupMenuItem(value: 'delete', child: Row(children: [
          Icon(Icons.delete_outline, size: 18, color: AppColors.error),
          SizedBox(width: AppSpacing.sm),
          Text('Delete', style: AppTypography.bodyMedium.copyWith(color: AppColors.error)),
        ])),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays} days ago';
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MetricChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        SizedBox(width: AppSpacing.xxs),
        Text(value, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
      ],
    );
  }
}
