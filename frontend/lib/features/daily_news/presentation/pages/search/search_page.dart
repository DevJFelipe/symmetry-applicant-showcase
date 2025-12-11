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
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/search/search_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/search/search_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/animated_bento_card.dart';
import 'package:news_app_clean_architecture/shared/widgets/widgets.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchHeader(),
              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) => _buildContent(state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          ),
          Expanded(child: _buildSearchField()),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: _searchFocus.hasFocus ? AppColors.accent : AppColors.border,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        style: AppTypography.bodyMedium,
        textInputAction: TextInputAction.search,
        onSubmitted: _onSearchSubmitted,
        decoration: InputDecoration(
          hintText: 'Search articles...',
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildContent(SearchState state) {
    return switch (state) {
      SearchInitial() => _buildSuggestions(),
      SearchLoading() => _buildLoadingState(),
      SearchSuccess(:final articles, :final query) => 
        articles.isEmpty ? _buildNoResults(query) : _buildSearchResults(articles),
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

  Widget _buildSearchResults(List<ArticleEntity> results) {
    final currentUserId = context.read<AuthCubit>().state.user?.uid;

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.screenPaddingH),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: AnimatedBentoCard(
            article: results[index],
            size: BentoCardSize.medium,
            index: index,
            currentUserId: currentUserId,
            onTap: () => _onArticleTapped(results[index]),
          ),
        );
      },
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

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            _buildSectionHeader('Recent Searches', onClear: _clearRecentSearches),
            SizedBox(height: AppSpacing.sm),
            _buildChipsWrap(_recentSearches, Icons.history_rounded),
            SizedBox(height: AppSpacing.xl),
          ],
          _buildSectionHeader('Suggested Topics'),
          SizedBox(height: AppSpacing.sm),
          _buildChipsWrap(
            ['Technology', 'Science', 'Business', 'Health', 'Sports', 'Entertainment'],
            Icons.tag_rounded,
            startDelay: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onClear}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.titleSmall.copyWith(color: AppColors.textSecondary)),
        if (onClear != null)
          TextButton(
            onPressed: onClear,
            child: Text('Clear', style: AppTypography.labelMedium.copyWith(color: AppColors.accent)),
          ),
      ],
    );
  }

  Widget _buildChipsWrap(List<String> items, IconData icon, {int startDelay = 0}) {
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textMuted),
            SizedBox(width: AppSpacing.xs),
            Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
