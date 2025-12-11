import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/app_radius.dart';
import 'package:news_app_clean_architecture/core/services/haptic_service.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/bento_article_grid.dart';
import 'package:news_app_clean_architecture/shared/widgets/widgets.dart';

/// Premium redesigned Daily News feed with Bento Grid layout.
///
/// Features:
/// - Bento Grid for articles
/// - Animated cards with stagger
/// - Pull to refresh with haptic
/// - Premium app bar with search
/// - Glassmorphism modals
/// - Smooth transitions
class PremiumDailyNews extends StatefulWidget {
  const PremiumDailyNews({super.key});

  @override
  State<PremiumDailyNews> createState() => _PremiumDailyNewsState();
}

class _PremiumDailyNewsState extends State<PremiumDailyNews>
    with SingleTickerProviderStateMixin {
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();
  bool _showFab = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final direction = offset - _lastScrollOffset;
    _lastScrollOffset = offset;

    // Hide FAB when scrolling down, show when scrolling up
    if (direction > 10 && _showFab) {
      setState(() => _showFab = false);
    } else if (direction < -10 && !_showFab) {
      setState(() => _showFab = true);
    }
  }

  Future<void> _onRefresh() async {
    HapticService.lightImpact();
    context.read<RemoteArticlesBloc>().add(const GetArticles());
    
    // Wait for state change
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
          builder: (context, state) {
            return Stack(
              children: [
                // Main content
                _buildContent(context, state),
                
                // FAB
                _buildFab(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RemoteArticlesState state) {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      header: _buildRefreshHeader(),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium App Bar
          _buildSliverAppBar(context),
          
          // Content based on state
          ...switch (state) {
            RemoteArticlesLoading() => [_buildLoadingState()],
            RemoteArticlesError(error: final e) => [
              _buildErrorState(e?.message ?? 'An error occurred')
            ],
            RemoteArticlesEmpty() => [_buildEmptyState()],
            RemoteArticlesDone(articles: final articles) => [
              _buildArticlesContent(context, articles ?? [])
            ],
          },
          
          // Bottom spacing
          SliverPadding(
            padding: EdgeInsets.only(bottom: AppSpacing.xxxl),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshHeader() {
    return CustomHeader(
      builder: (context, mode) {
        Widget body;
        if (mode == RefreshStatus.idle) {
          body = Text(
            'Pull to refresh',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          );
        } else if (mode == RefreshStatus.refreshing) {
          body = SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          );
        } else if (mode == RefreshStatus.canRefresh) {
          body = Text(
            'Release to refresh',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.accent,
            ),
          );
        } else if (mode == RefreshStatus.completed) {
          body = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 18,
                color: AppColors.success,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Updated',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          );
        } else {
          body = const SizedBox.shrink();
        }
        return Container(
          height: 60,
          alignment: Alignment.center,
          child: body,
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      snap: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: AppSpacing.screenPaddingH,
          bottom: AppSpacing.md,
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily News',
              style: AppTypography.headlineLarge.copyWith(
                fontSize: 24,
              ),
            ),
          ],
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
      actions: [
        // Search button
        IconButton(
          onPressed: () => _onSearchTapped(context),
          icon: Icon(
            Icons.search_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        // Saved articles
        IconButton(
          onPressed: () => _onSavedArticlesTapped(context),
          icon: Icon(
            Icons.bookmark_border_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        // Profile/Menu
        _buildProfileMenu(context),
        SizedBox(width: AppSpacing.sm),
      ],
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final userName = state.user?.displayName ?? 'User';
        final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
        
        return PopupMenuButton<String>(
          offset: Offset(0, AppSpacing.xl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          color: AppColors.surface,
          onSelected: (value) => _onMenuSelected(context, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: AppTypography.titleSmall,
                  ),
                  Text(
                    state.user?.email ?? '',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: AppColors.textSecondary),
                  SizedBox(width: AppSpacing.sm),
                  Text('Profile', style: AppTypography.bodyMedium),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'my_articles',
              child: Row(
                children: [
                  Icon(Icons.article_outlined, color: AppColors.textSecondary),
                  SizedBox(width: AppSpacing.sm),
                  Text('My Articles', style: AppTypography.bodyMedium),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: AppColors.error),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Sign Out',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xs),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.accent,
              child: Text(
                initial,
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      sliver: SliverToBoxAdapter(
        child: ShimmerBentoGrid(itemCount: 5),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: ErrorStateWidget.network(
          onRetry: () {
            HapticService.lightImpact();
            context.read<RemoteArticlesBloc>().add(const GetArticles());
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: EmptyStateWidget.noArticles(
          onAction: () => _onCreateArticle(context),
        ),
      ),
    );
  }

  Widget _buildArticlesContent(
    BuildContext context,
    List<ArticleEntity> articles,
  ) {
    if (articles.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }

    final currentUserId = context.read<AuthCubit>().state.user?.uid;

    return BentoArticleGrid(
      articles: articles,
      currentUserId: currentUserId,
      onArticleTap: (article) => _onArticleTapped(context, article),
      onArticleLongPress: (article) => _onArticleLongPressed(context, article),
    );
  }

  Widget _buildFab(BuildContext context) {
    return Positioned(
      right: AppSpacing.screenPaddingH,
      bottom: AppSpacing.xl,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        offset: _showFab ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _showFab ? 1.0 : 0.0,
          child: AnimatedFAB(
            icon: Icons.edit_outlined,
            label: 'Write',
            onPressed: () => _onCreateArticle(context),
          ),
        ),
      ),
    );
  }

  // Navigation methods
  void _onSearchTapped(BuildContext context) {
    Navigator.pushNamed(context, '/search');
  }

  void _onSavedArticlesTapped(BuildContext context) {
    HapticService.lightImpact();
    Navigator.pushNamed(context, '/SavedArticles');
  }

  void _onArticleLongPressed(BuildContext context, ArticleEntity article) {
    HapticService.mediumImpact();
    // Show article preview modal
    ArticlePreviewModal.show(
      context: context,
      title: article.title ?? 'Untitled',
      description: article.description ?? '',
      imageUrl: article.urlToImage,
      author: article.author,
      date: article.publishedAt,
      onReadMore: () => _onArticleTapped(context, article),
    );
  }

  void _onCreateArticle(BuildContext context) {
    HapticService.lightImpact();
    final bloc = context.read<RemoteArticlesBloc>();
    Navigator.pushNamed(context, '/create-article').then((result) {
      // Refresh feed if article was created
      if (result == true) {
        bloc.add(const GetArticles());
      }
    });
  }

  void _onArticleTapped(BuildContext context, ArticleEntity article) {
    HapticService.lightImpact();
    final bloc = context.read<RemoteArticlesBloc>();
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article).then((_) {
      // Refresh feed when returning from article detail (in case reactions changed)
      bloc.add(const GetArticles());
    });
  }

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        Navigator.pushNamed(context, '/profile');
        break;
      case 'my_articles':
        Navigator.pushNamed(context, '/my-articles');
        break;
      case 'logout':
        _showLogoutConfirmation(context);
        break;
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationModal(
        title: 'Sign Out',
        message: 'Are you sure you want to sign out?',
        confirmLabel: 'Sign Out',
        isDanger: true,
        onConfirm: () {
          Navigator.pop(context);
          context.read<AuthCubit>().signOut();
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}
