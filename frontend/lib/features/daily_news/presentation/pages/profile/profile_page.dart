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
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/shared/widgets/widgets.dart';

/// Premium Profile screen with user info and inline tabs for Articles/Saved.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 0 = Articles, 1 = Saved
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated && authState.user != null) {
      context.read<MyArticlesCubit>().loadArticles(authState.user!.uid);
    }
    // LocalArticleBloc is already loading via routes injection
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () => _onSettingsTapped(context),
              icon: Icon(
                Icons.settings_outlined,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),
          ],
          body: _buildTabContent(),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final displayName = user?.displayName ?? 'Journalist';
        final email = user?.email ?? '';
        final initial =
            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'J';

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
          child: Column(
            children: [
              _buildAvatarSection(initial, displayName, email)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              SizedBox(height: AppSpacing.xxl),
              _buildStatsRow(context)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms),
              SizedBox(height: AppSpacing.lg),
              _buildSignOutButton(context)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms),
              SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabContent() {
    if (_selectedTab == 0) {
      return BlocBuilder<MyArticlesCubit, MyArticlesState>(
        builder: (context, state) {
          if (state is MyArticlesLoading) {
            return const Center(child: PremiumLoading());
          }
          if (state is MyArticlesError) {
            return Center(
                child: Text(state.message,
                    style: TextStyle(color: AppColors.error)));
          }
          if (state is MyArticlesLoaded) {
            final articles = state.articles;
            if (articles.isEmpty) {
              return _buildEmptyState(
                  'No articles yet', Icons.article_outlined);
            }
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(AppSpacing.screenPaddingH),
              itemCount: articles.length + 1, // +1 for extra padding at bottom
              separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                if (index == articles.length) {
                  return SizedBox(height: AppSpacing.xxxl);
                }
                return _ArticleListItem(
                  article: articles[index],
                  onTap: () => Navigator.pushNamed(context, '/ArticleDetails',
                      arguments: articles[index]),
                );
              },
            );
          }
          return SizedBox.shrink();
        },
      );
    } else {
      return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
        builder: (context, state) {
          if (state is LocalArticlesLoading) {
            return const Center(child: PremiumLoading());
          }
          if (state is LocalArticlesDone) {
            final articles = state.articles ?? [];
            if (articles.isEmpty) {
              return _buildEmptyState(
                  'No saved articles', Icons.bookmark_border);
            }
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(AppSpacing.screenPaddingH),
              itemCount: articles.length + 1,
              separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                if (index == articles.length) {
                  return SizedBox(height: AppSpacing.xxxl);
                }
                final article = articles[index];
                return _SavedArticleCard(
                  article: article,
                  index: index,
                  onTap: () => Navigator.pushNamed(context, '/ArticleDetails',
                      arguments: article),
                  onRemove: () => context
                      .read<LocalArticleBloc>()
                      .add(RemoveArticle(article)),
                );
              },
            );
          }
          return SizedBox.shrink();
        },
      );
    }
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.textMuted),
          SizedBox(height: AppSpacing.md),
          Text(message,
              style:
                  AppTypography.bodyLarge.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(String initial, String name, String email) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.accentGradient,
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.surface,
            child: Text(
              initial,
              style: AppTypography.displaySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(name, style: AppTypography.headlineMedium),
        SizedBox(height: AppSpacing.xxs),
        Text(email,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        SizedBox(height: AppSpacing.sm),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
              SizedBox(width: AppSpacing.xxs),
              Text(
                'JOURNALIST',
                style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm), // compact padding
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Articles', _selectedTab == 0, Icons.article_outlined,
              () => setState(() => _selectedTab = 0)),
          _buildStatDivider(),
          _buildStatItem('Saved', _selectedTab == 1, Icons.bookmark_outline,
              () => setState(() => _selectedTab = 1)),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, bool isSelected, IconData icon, VoidCallback onTap) {
    final color = isSelected ? AppColors.primary : AppColors.textMuted;

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticService.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: isSelected
              ? BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                )
              : null,
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(height: AppSpacing.xs),
              Text(label,
                  style: AppTypography.labelSmall.copyWith(
                      color: color,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 40, color: AppColors.border);
  }

  Widget _buildSignOutButton(BuildContext context) {
    // Keep simpler version or move to settings,
    // User asked to remove specific buttons but didn't explicitly ask to remove Logout from bottom.
    // However, usually logout is at bottom.
    // Since I am using NestedScrollView, I'll put Logout in settings or at bottom of the list?
    // Actually, checking user request: "he wants articles below".
    // I'll add Logout as an IconButton in AppBar or keep it at bottom of header if space permits?
    // Let's put logout button in settings to clean up UI, or leave it in header?
    // I'll leave it in the header for now to avoid removing functionality unless requested.
    return GestureDetector(
      onTap: () => _showSignOutConfirmation(context),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            SizedBox(width: AppSpacing.sm),
            Text('Sign Out',
                style:
                    AppTypography.titleSmall.copyWith(color: AppColors.error)),
          ],
        ),
      ),
    );
  }

  void _onSettingsTapped(BuildContext context) {
    HapticService.lightImpact();
    Navigator.pushNamed(context, '/settings');
  }

  void _showSignOutConfirmation(BuildContext context) {
    HapticService.lightImpact();
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
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}

// --- List Items Helpers (Adapted from original files) ---

class _ArticleListItem extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;

  const _ArticleListItem({required this.article, required this.onTap});

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
            ? CachedNetworkImage(
                imageUrl: article.urlToImage!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _placeholder())
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Center(
      child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 32));

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(article.title ?? 'Untitled',
            style: AppTypography.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        SizedBox(height: AppSpacing.xs),
        Text(article.publishedAt ?? '',
            style:
                AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
      ],
    );
  }
}

class _SavedArticleCard extends StatelessWidget {
  final ArticleEntity article;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SavedArticleCard(
      {required this.article,
      required this.index,
      required this.onTap,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(article.url ?? article.title ?? index.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppSpacing.lg),
        color: AppColors.error.withValues(alpha: 0.2),
        child: Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.lg),
                    bottomLeft: Radius.circular(AppRadius.lg)),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: article.urlToImage != null
                      ? CachedNetworkImage(
                          imageUrl: article.urlToImage!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Icon(Icons.error))
                      : Icon(Icons.image),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(article.title ?? 'Untitled',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleMedium),
                      SizedBox(height: AppSpacing.xs),
                      Text(article.publishedAt ?? '',
                          style: AppTypography.caption),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
