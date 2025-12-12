import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
import 'package:news_app_clean_architecture/config/theme/theme_cubit.dart';
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
    // Load saved articles
    context.read<LocalArticleBloc>().add(const GetSavedArticles());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, AppThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == AppThemeMode.dark;
        final theme = Theme.of(context);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value:
              isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                BlocBuilder<ThemeCubit, AppThemeMode>(
                  builder: (context, themeMode) {
                    final isDark = themeMode == AppThemeMode.dark;
                    return IconButton(
                      onPressed: () {
                        HapticService.lightImpact();
                        context.read<ThemeCubit>().toggleTheme();
                      },
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return RotationTransition(
                            turns:
                                Tween(begin: 0.5, end: 1.0).animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          isDark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          key: ValueKey(isDark),
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      tooltip: isDark
                          ? 'Switch to Light Mode'
                          : 'Switch to Dark Mode',
                    );
                  },
                ),
                IconButton(
                  onPressed: () => _onSettingsTapped(context),
                  icon: Icon(
                    Icons.settings_outlined,
                    color: theme.colorScheme.onSurface,
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
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final displayName = user?.displayName ?? 'Journalist';
        final email = user?.email ?? '';
        final photoURL = user?.photoURL;
        final initial =
            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'J';

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
          child: Column(
            children: [
              _buildAvatarSection(initial, displayName, email, photoURL)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              SizedBox(height: AppSpacing.xxl),
              _buildStatsRow(context)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms),
              SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabContent() {
    final theme = Theme.of(context);

    if (_selectedTab == 0) {
      return BlocBuilder<MyArticlesCubit, MyArticlesState>(
        builder: (context, state) {
          if (state is MyArticlesLoading) {
            return const Center(child: PremiumLoading());
          }
          if (state is MyArticlesError) {
            return Center(
                child: Text(state.message,
                    style: TextStyle(color: theme.colorScheme.error)));
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
              itemCount: articles.length +
                  2, // +1 for sign out button, +1 for extra padding
              separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                if (index == articles.length) {
                  return _buildSignOutButton(context);
                }
                if (index == articles.length + 1) {
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
              itemCount: articles.length +
                  2, // +1 for sign out button, +1 for extra padding
              separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                if (index == articles.length) {
                  return _buildSignOutButton(context);
                }
                if (index == articles.length + 1) {
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
    final theme = Theme.of(context);
    final textMuted = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: textMuted),
                SizedBox(height: AppSpacing.md),
                Text(message,
                    style: AppTypography.bodyLarge.copyWith(color: textMuted)),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(AppSpacing.screenPaddingH),
          child: _buildSignOutButton(context),
        ),
        SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Widget _buildAvatarSection(
      String initial, String name, String email, String? photoURL) {
    final theme = Theme.of(context);
    final textSecondary = theme.colorScheme.onSurfaceVariant;

    return Column(
      children: [
        _buildProfileAvatar(initial, photoURL),
        SizedBox(height: AppSpacing.md),
        Text(name,
            style: AppTypography.headlineMedium
                .copyWith(color: theme.colorScheme.onSurface)),
        SizedBox(height: AppSpacing.xxs),
        Text(email,
            style: AppTypography.bodyMedium.copyWith(color: textSecondary)),
        SizedBox(height: AppSpacing.sm),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded,
                  size: 14, color: theme.colorScheme.primary),
              SizedBox(width: AppSpacing.xxs),
              Text(
                'JOURNALIST',
                style: AppTypography.labelSmall.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(String initial, String? photoURL) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isUpdating = state is ProfilePhotoUpdating;

        return GestureDetector(
          onTap: isUpdating ? null : () => _showPhotoSourceDialog(context),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Use primary color for gradient-like effect or simple color
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.canvasColor,
                  child: isUpdating
                      ? SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : _buildAvatarContent(initial, photoURL),
                ),
              ),
              // Camera icon overlay
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: theme.scaffoldBackgroundColor, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 16,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarContent(String initial, String? photoURL) {
    if (photoURL != null && photoURL.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoURL,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildInitialAvatar(initial),
          errorWidget: (_, __, ___) => _buildInitialAvatar(initial),
        ),
      );
    }
    return _buildInitialAvatar(initial);
  }

  Widget _buildInitialAvatar(String initial) {
    return Text(
      initial,
      style: AppTypography.displaySmall.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _showPhotoSourceDialog(BuildContext context) {
    HapticService.lightImpact();
    final authCubit = context.read<AuthCubit>();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.canvasColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (dialogContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Change Profile Photo',
                  style: AppTypography.titleMedium
                      .copyWith(color: theme.colorScheme.onSurface),
                ),
                SizedBox(height: AppSpacing.md),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.photo_library_outlined,
                        color: theme.colorScheme.primary),
                  ),
                  title: Text('Choose from Gallery',
                      style: AppTypography.bodyLarge
                          .copyWith(color: theme.colorScheme.onSurface)),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    authCubit.pickProfilePhotoFromGallery();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt_outlined,
                        color: theme.colorScheme.primary),
                  ),
                  title: Text('Take a Photo',
                      style: AppTypography.bodyLarge
                          .copyWith(color: theme.colorScheme.onSurface)),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    authCubit.pickProfilePhotoFromCamera();
                  },
                ),
                SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm), // compact padding
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.dividerColor, width: 1),
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
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.5);

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
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
    return Container(
        width: 1, height: 40, color: Theme.of(context).dividerColor);
  }

  Widget _buildSignOutButton(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showSignOutConfirmation(context),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
              color: theme.colorScheme.error.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded,
                color: theme.colorScheme.error, size: 20),
            SizedBox(width: AppSpacing.sm),
            Text('Sign Out',
                style: AppTypography.titleSmall
                    .copyWith(color: theme.colorScheme.error)),
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: theme.dividerColor, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(theme),
            SizedBox(width: AppSpacing.md),
            Expanded(child: _buildContent(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: 80,
        height: 80,
        color: theme.colorScheme.surfaceContainerHighest,
        child: article.urlToImage?.isNotEmpty == true
            ? CachedNetworkImage(
                imageUrl: article.urlToImage!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _placeholder(theme))
            : _placeholder(theme),
      ),
    );
  }

  Widget _placeholder(ThemeData theme) => Center(
      child: Icon(Icons.image_outlined,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 32));

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(article.title ?? 'Untitled',
            style: AppTypography.titleSmall
                .copyWith(color: theme.colorScheme.onSurface),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        SizedBox(height: AppSpacing.xs),
        Text(article.publishedAt ?? '',
            style: AppTypography.bodySmall
                .copyWith(color: theme.colorScheme.onSurfaceVariant)),
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
    final theme = Theme.of(context);
    return Dismissible(
      key: Key(article.url ?? article.title ?? index.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppSpacing.lg),
        color: theme.colorScheme.error.withValues(alpha: 0.2),
        child: Icon(Icons.delete_outline, color: theme.colorScheme.error),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: theme.dividerColor, width: 1),
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
                          errorWidget: (_, __, ___) =>
                              Icon(Icons.error, color: theme.colorScheme.error))
                      : Icon(Icons.image, color: theme.iconTheme.color),
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
                          style: AppTypography.titleMedium
                              .copyWith(color: theme.colorScheme.onSurface)),
                      SizedBox(height: AppSpacing.xs),
                      Text(article.publishedAt ?? '',
                          style: AppTypography.caption.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
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
