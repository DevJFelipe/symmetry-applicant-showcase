import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/app_radius.dart';
import 'package:news_app_clean_architecture/core/services/haptic_service.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/search/search_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/search/search_state.dart';
import 'package:news_app_clean_architecture/shared/widgets/widgets.dart';
import 'package:news_app_clean_architecture/config/theme/theme_cubit.dart';

/// Search page for finding articles.
///
/// Uses [SearchCubit] for state management following Clean Architecture.
/// Features debounced search, recent searches, and animated results.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  /// Locally stored recent searches (could be persisted with SharedPreferences).
  List<String> _recentSearches = ['Flutter', 'Technology', 'Science'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Load initial articles when page opens
    final userId = context.read<AuthCubit>().state.user?.uid;
    context.read<SearchCubit>().loadInitialArticles(userId: userId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    context.read<SearchCubit>().search(query);
  }

  void _onSearchSubmitted(String query) {
    if (query.isEmpty) return;

    HapticService.lightImpact();
    _addToRecentSearches(query);
    context.read<SearchCubit>().searchImmediate(query);
    _searchFocus.unfocus();
  }

  void _addToRecentSearches(String query) {
    if (_recentSearches.contains(query)) return;
    setState(() {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    });
  }

  void _onRecentSearchTapped(String search) {
    HapticService.lightImpact();
    _searchController.text = search;
    _onSearchSubmitted(search);
  }

  void _clearRecentSearches() {
    HapticService.lightImpact();
    setState(() => _recentSearches = []);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SearchCubit>().clearSearch();
    _searchFocus.requestFocus();
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
            body: SafeArea(
              child: Column(
                children: [
                  _buildSearchHeader(context),
                  Expanded(
                    child: BlocBuilder<SearchCubit, SearchState>(
                      builder: (context, state) =>
                          _buildContent(context, state),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: theme.colorScheme.onSurface, size: 20),
          ),
          Expanded(child: _buildSearchField(context)),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: _searchFocus.hasFocus
              ? theme.colorScheme.primary
              : theme.dividerColor,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        style: AppTypography.bodyMedium
            .copyWith(color: theme.colorScheme.onSurface),
        textInputAction: TextInputAction.search,
        onSubmitted: _onSearchSubmitted,
        decoration: InputDecoration(
          hintText: 'Search articles...',
          hintStyle: AppTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          prefixIcon: Icon(Icons.search_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: Icon(Icons.close_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 18),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SearchState state) {
    return switch (state) {
      SearchInitial(:final userArticles, :final apiArticles) =>
        userArticles.isEmpty && apiArticles.isEmpty
            ? _buildSuggestions(context)
            : _buildArticleList(userArticles, apiArticles),
      SearchLoading() => _buildLoadingState(),
      SearchSuccess(:final userArticles, :final apiArticles, :final query) =>
        userArticles.isEmpty && apiArticles.isEmpty
            ? _buildNoResults(query)
            : _buildArticleList(userArticles, apiArticles, isSearch: true),
      SearchError(:final message) => _buildErrorState(message),
    };
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.screenPaddingH),
      child: ShimmerBentoGrid(itemCount: 3),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: ErrorStateWidget(
        title: 'Search Failed',
        message: message,
        onRetry: () => _onSearchSubmitted(_searchController.text),
      ),
    );
  }

  Widget _buildArticleList(
    List<ArticleEntity> userArticles,
    List<ArticleEntity> apiArticles, {
    bool isSearch = false,
  }) {
    final currentUserId = context.read<AuthCubit>().state.user?.uid;

    return ListView(
      padding: EdgeInsets.all(AppSpacing.screenPaddingH),
      children: [
        // User articles section
        if (userArticles.isNotEmpty) ...[
          _buildSectionHeader(
              context, isSearch ? 'Your Articles' : 'My Articles'),
          SizedBox(height: AppSpacing.sm),
          ...userArticles.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: _SearchArticleItem(
                article: entry.value,
                index: entry.key,
                currentUserId: currentUserId,
                onTap: () => _onArticleTapped(entry.value),
              ),
            );
          }),
          SizedBox(height: AppSpacing.lg),
        ],
        // API articles section
        if (apiArticles.isNotEmpty) ...[
          _buildSectionHeader(
              context, isSearch ? 'News Articles' : 'Latest News'),
          SizedBox(height: AppSpacing.sm),
          ...apiArticles.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: _SearchArticleItem(
                article: entry.value,
                index: entry.key + userArticles.length,
                currentUserId: currentUserId,
                onTap: () => _onArticleTapped(entry.value),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildNoResults(String query) {
    return Center(
      child: EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: 'No Results',
        message: 'No articles found for "$query".\nTry different keywords.',
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSuggestions(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            _buildSectionHeader(context, 'Recent Searches',
                onClear: _clearRecentSearches),
            SizedBox(height: AppSpacing.sm),
            _buildChipsWrap(context, _recentSearches, Icons.history_rounded),
            SizedBox(height: AppSpacing.xl),
          ],
          _buildSectionHeader(context, 'Suggested Topics'),
          SizedBox(height: AppSpacing.sm),
          _buildChipsWrap(
            context,
            [
              'Technology',
              'Science',
              'Business',
              'Health',
              'Sports',
              'Entertainment'
            ],
            Icons.tag_rounded,
            startDelay: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title,
      {VoidCallback? onClear}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: AppTypography.titleSmall
                .copyWith(color: theme.colorScheme.onSurfaceVariant)),
        if (onClear != null)
          TextButton(
            onPressed: onClear,
            child: Text('Clear',
                style: AppTypography.labelMedium
                    .copyWith(color: theme.colorScheme.primary)),
          ),
      ],
    );
  }

  Widget _buildChipsWrap(
      BuildContext context, List<String> items, IconData icon,
      {int startDelay = 0}) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: items.asMap().entries.map((entry) {
        return _SearchChip(
          label: entry.value,
          icon: icon,
          onTap: () => _onRecentSearchTapped(entry.value),
        ).animate().fadeIn(
              duration: 300.ms,
              delay: Duration(milliseconds: startDelay + entry.key * 50),
            );
      }).toList(),
    );
  }

  void _onArticleTapped(ArticleEntity article) {
    HapticService.lightImpact();
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }
}

/// Chip widget for search suggestions and recent searches.
class _SearchChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SearchChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: theme.dividerColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            SizedBox(width: AppSpacing.xs),
            Text(label,
                style: AppTypography.bodyMedium
                    .copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

/// Simple article list item for search results.
class _SearchArticleItem extends StatelessWidget {
  final ArticleEntity article;
  final int index;
  final String? currentUserId;
  final VoidCallback onTap;

  const _SearchArticleItem({
    required this.article,
    required this.index,
    required this.onTap,
    this.currentUserId,
  });

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
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: article.urlToImage != null
                  ? Image.network(
                      article.urlToImage!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                    )
                  : _buildPlaceholder(context),
            ),
            SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source/Author badge
                  if (article.source?.name != null || article.author != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs / 2,
                      ),
                      decoration: BoxDecoration(
                        color: article.documentId != null
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        article.documentId != null
                            ? (article.author ?? 'You')
                            : (article.source?.name ?? ''),
                        style: AppTypography.labelSmall.copyWith(
                          color: article.documentId != null
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  SizedBox(height: AppSpacing.xs),
                  // Title
                  Text(
                    article.title ?? 'Untitled',
                    style: AppTypography.titleSmall
                        .copyWith(color: theme.colorScheme.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  // Description
                  if (article.description != null)
                    Text(
                      article.description!,
                      style: AppTypography.bodySmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
          duration: 300.ms,
          delay: Duration(milliseconds: index * 50),
        );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 80,
      height: 80,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(Icons.article_outlined,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5), size: 32),
    );
  }
}
