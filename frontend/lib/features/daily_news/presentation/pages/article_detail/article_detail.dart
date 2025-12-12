import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/app_radius.dart';
import 'package:news_app_clean_architecture/core/services/haptic_service.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article_detail/article_detail_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/reaction_bar.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/config/theme/theme_cubit.dart';

/// Premium Article Detail page with immersive design.
///
/// Features:
/// - Hero image with parallax effect
/// - Glassmorphism header overlay
/// - Animated content reveal
/// - Floating reaction bar
/// - Save article functionality
/// - Share functionality
class PremiumArticleDetail extends StatefulWidget {
  final ArticleEntity article;

  const PremiumArticleDetail({
    super.key,
    required this.article,
  });

  @override
  State<PremiumArticleDetail> createState() => _PremiumArticleDetailState();
}

class _PremiumArticleDetailState extends State<PremiumArticleDetail> {
  final ScrollController _scrollController = ScrollController();
  double _imageOpacity = 1.0;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;

    // Calculate image opacity based on scroll
    final newOpacity = 1.0 - (offset / 200).clamp(0.0, 0.5);

    // Show title in app bar after scrolling past image
    final shouldShowTitle = offset > 250;

    if (newOpacity != _imageOpacity || shouldShowTitle != _showTitle) {
      setState(() {
        _imageOpacity = newOpacity;
        _showTitle = shouldShowTitle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>(),
      child: BlocBuilder<ThemeCubit, AppThemeMode>(
        builder: (context, themeMode) {
          final isDark = themeMode == AppThemeMode.dark;
          final theme = Theme.of(context);

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value:
                isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            child: Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: Stack(
                children: [
                  // Main content
                  CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Hero image with app bar
                      _buildSliverAppBar(context),

                      // Article content
                      _buildContent(context),

                      // Bottom spacing for reaction bar
                      SliverPadding(
                        padding: EdgeInsets.only(bottom: 100),
                      ),
                    ],
                  ),

                  // Floating reaction bar
                  _buildFloatingReactionBar(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final imageUrl = widget.article.urlToImage;
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      stretch: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      leading: _buildBackButton(context),
      actions: [
        _buildSaveButton(context),
        _buildShareButton(context),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        title: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _showTitle ? 1.0 : 0.0,
          child: Text(
            widget.article.title ?? '',
            style: AppTypography.titleSmall.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            if (imageUrl != null && imageUrl.isNotEmpty)
              Opacity(
                opacity: _imageOpacity,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              )
            else
              Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.article_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                    theme.scaffoldBackgroundColor,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        HapticService.lightImpact();
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.all(AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: theme.colorScheme.onSurface,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final theme = Theme.of(context);
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => _onSaveArticle(context),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
          padding: EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.dividerColor,
              width: 1,
            ),
          ),
          child: Icon(
            Icons.bookmark_border_rounded,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: _onShareArticle,
      child: Container(
        margin: EdgeInsets.only(
          right: AppSpacing.sm,
          top: AppSpacing.sm,
          bottom: AppSpacing.sm,
        ),
        padding: EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.share_rounded,
          color: theme.colorScheme.onSurface,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category tag
            _buildCategoryTag(context)
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms),

            SizedBox(height: AppSpacing.md),

            // Title
            Text(
              widget.article.title ?? 'Untitled Article',
              style: AppTypography.headlineLarge
                  .copyWith(color: theme.colorScheme.onSurface),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0),

            SizedBox(height: AppSpacing.lg),

            // Author and date row
            _buildAuthorRow(context)
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms),

            SizedBox(height: AppSpacing.xl),

            // Divider
            Container(
              height: 1,
              color: theme.dividerColor,
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

            SizedBox(height: AppSpacing.xl),

            // Description
            if (widget.article.description != null &&
                widget.article.description!.isNotEmpty)
              Text(
                widget.article.description!,
                style: AppTypography.bodyLarge.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

            SizedBox(height: AppSpacing.lg),

            // Content
            Text(
              _cleanContent(widget.article.content),
              style: AppTypography.articleBody
                  .copyWith(color: theme.colorScheme.onSurface),
            ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

            SizedBox(height: AppSpacing.xxl),

            // Source link
            if (widget.article.url != null)
              _buildSourceLink(context)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 700.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTag(BuildContext context) {
    final source = widget.article.source?.name ?? 'Article';
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        source.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAuthorRow(BuildContext context) {
    final author = widget.article.author ?? 'Anonymous';
    final date = _formatDate(widget.article.publishedAt);
    final isOwn = _isOwnArticle();
    final theme = Theme.of(context);

    return Row(
      children: [
        // Author avatar
        CircleAvatar(
          radius: 20,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          child: Text(
            author.isNotEmpty ? author[0].toUpperCase() : 'A',
            style: AppTypography.titleMedium.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        SizedBox(width: AppSpacing.sm),

        // Author info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    author,
                    style: AppTypography.titleSmall
                        .copyWith(color: theme.colorScheme.onSurface),
                  ),
                  if (isOwn) ...[
                    SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.tertiary,
                        ]),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        'YOU',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                date,
                style: AppTypography.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),

        // Reading time estimate
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              SizedBox(width: AppSpacing.xxs),
              Text(
                _estimateReadingTime(),
                style: AppTypography.labelSmall.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourceLink(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: _onOpenSource,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.link_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View Original Article',
                    style: AppTypography.titleSmall.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    widget.article.url ?? '',
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.colorScheme.primary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingReactionBar(BuildContext context) {
    final currentUserId = context.read<AuthCubit>().state.user?.uid;
    final theme = Theme.of(context);

    return Positioned(
      left: AppSpacing.screenPaddingH,
      right: AppSpacing.screenPaddingH,
      bottom: AppSpacing.xl,
      child: BlocConsumer<ArticleDetailCubit, ArticleDetailState>(
        listener: (context, state) {
          if (state is ArticleDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          // Get article from cubit state for optimistic updates
          final article = switch (state) {
            ArticleDetailLoaded(:final article) => article,
            ArticleDetailUpdating(:final article) => article,
            ArticleDetailError(:final article) => article,
            ArticleDetailInitial() => widget.article,
          };

          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                      alpha:
                          0.2), // Keep shadow dark even in light mode for lift
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ReactionBar(
              reactions: article.reactions ?? const {},
              userReactions: article.userReactions ?? const {},
              currentUserId: currentUserId,
              onReactionToggled: (reaction, isActive) {
                if (currentUserId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please sign in to react'),
                      backgroundColor: theme.colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                context.read<ArticleDetailCubit>().toggleReaction(
                      userId: currentUserId,
                      reactionType: reaction,
                    );
              },
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 800.ms)
              .slideY(begin: 0.5, end: 0);
        },
      ),
    );
  }

  // Helper methods

  /// Cleans the article content by removing the "[+XXXX chars]" suffix
  /// that comes from external news APIs.
  String _cleanContent(String? content) {
    if (content == null || content.isEmpty) return 'No content available.';

    // Remove patterns like "[+1234 chars]" or "... [+1234 chars]"
    final cleanedContent =
        content.replaceAll(RegExp(r'\s*\[\+\d+\s*chars\]'), '');
    return cleanedContent.trim();
  }

  bool _isOwnArticle() {
    final currentUserId = context.read<AuthCubit>().state.user?.uid;
    if (currentUserId == null) return false;
    return widget.article.isOwnedBy(currentUserId);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';

    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _estimateReadingTime() {
    final content = widget.article.content ?? '';
    final description = widget.article.description ?? '';
    final totalWords = (content + description).split(' ').length;
    final minutes = (totalWords / 200).ceil();
    return '$minutes min read';
  }

  void _onSaveArticle(BuildContext context) {
    HapticService.success();
    BlocProvider.of<LocalArticleBloc>(context).add(SaveArticle(widget.article));
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.bookmark_added_rounded,
              color: Colors.green,
              size: 20,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Article saved',
              style: AppTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onInverseSurface,
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        margin: EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  Future<void> _onShareArticle() async {
    HapticService.lightImpact();
    final theme = Theme.of(context);

    final title = widget.article.title ?? 'Check out this article';
    final url = widget.article.url ?? '';
    final description = widget.article.description ?? '';

    final shareText = url.isNotEmpty
        ? '$title\n\n$description\n\n$url'
        : '$title\n\n$description';

    try {
      await Share.share(
        shareText,
        subject: title,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not share article'),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _onOpenSource() async {
    HapticService.lightImpact();
    final theme = Theme.of(context);

    final urlString = widget.article.url;
    if (urlString == null || urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No source URL available'),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final uri = Uri.tryParse(urlString);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid URL'),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      // Launch directly without checking canLaunchUrl first
      // canLaunchUrl can return false on some Android versions even when launch works
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open URL'),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening URL'),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
