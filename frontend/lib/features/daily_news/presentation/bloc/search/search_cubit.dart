import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_user_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/toggle_reaction_params.dart';
import 'search_state.dart';

/// Cubit for managing article search functionality.
///
/// Handles search operations following Clean Architecture principles:
/// - Only interacts with domain layer (UseCases)
/// - Implements debouncing to prevent excessive API calls
/// - Manages search state transitions
/// - Loads all articles on init and filters locally
class SearchCubit extends Cubit<SearchState> {
  final GetUserArticlesUseCase _getUserArticlesUseCase;
  final GetArticleUseCase _getArticleUseCase;

  /// Cached user articles for local filtering.
  List<ArticleEntity> _cachedUserArticles = [];
  
  /// Cached API articles for local filtering.
  List<ArticleEntity> _cachedApiArticles = [];

  /// Debounce timer for search input.
  Timer? _debounceTimer;

  /// Debounce duration in milliseconds.
  static const _debounceDuration = Duration(milliseconds: 300);

  SearchCubit({
    required GetUserArticlesUseCase getUserArticlesUseCase,
    required GetArticleUseCase getArticleUseCase,
  })  : _getUserArticlesUseCase = getUserArticlesUseCase,
        _getArticleUseCase = getArticleUseCase,
        super(const SearchInitial());

  /// Loads initial articles from both sources.
  /// 
  /// [userId] The current user's ID for fetching their articles.
  /// 
  /// This should be called when the search page is first opened
  /// to show a feed of articles before any search is performed.
  Future<void> loadInitialArticles({String? userId}) async {
    try {
      emit(const SearchLoading());
      
      // Load API articles (always)
      final apiResult = await _getArticleUseCase();
      if (apiResult.isSuccess && apiResult.data != null) {
        _cachedApiArticles = apiResult.data!;
      } else {
        _cachedApiArticles = [];
      }
      
      // Load user articles (if authenticated)
      if (userId != null) {
        _cachedUserArticles = await _getUserArticlesUseCase(
          params: GetUserArticlesParams(userId: userId),
        );
      } else {
        _cachedUserArticles = [];
      }
      
      emit(SearchInitial(
        userArticles: _cachedUserArticles,
        apiArticles: _cachedApiArticles,
      ));
    } catch (e) {
      emit(SearchError(message: 'Failed to load articles: ${e.toString()}'));
    }
  }

  /// Performs a search with debouncing.
  ///
  /// [query] The search term to look for.
  ///
  /// This method debounces the search to avoid making
  /// too many API calls while the user is typing.
  void search(String query) {
    // Cancel any pending search
    _debounceTimer?.cancel();

    final trimmedQuery = query.trim();

    // Reset to initial if query is empty
    if (trimmedQuery.isEmpty) {
      emit(SearchInitial(
        userArticles: _cachedUserArticles,
        apiArticles: _cachedApiArticles,
      ));
      return;
    }

    // Emit loading state immediately for UX feedback
    emit(SearchLoading(query: trimmedQuery));

    // Debounce the actual search
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch(trimmedQuery);
    });
  }

  /// Performs an immediate search without debouncing.
  ///
  /// Use this when the user explicitly submits a search
  /// (e.g., pressing enter or tapping search button).
  Future<void> searchImmediate(String query) async {
    _debounceTimer?.cancel();

    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      emit(SearchInitial(
        userArticles: _cachedUserArticles,
        apiArticles: _cachedApiArticles,
      ));
      return;
    }

    await _performSearch(trimmedQuery);
  }

  /// Internal method to execute the search.
  /// 
  /// Filters cached articles locally for fast results.
  Future<void> _performSearch(String query) async {
    try {
      emit(SearchLoading(query: query));

      final lowerQuery = query.toLowerCase();
      
      // Filter user articles locally
      final filteredUserArticles = _cachedUserArticles.where((article) {
        return _articleMatchesQuery(article, lowerQuery);
      }).toList();
      
      // Filter API articles locally
      final filteredApiArticles = _cachedApiArticles.where((article) {
        return _articleMatchesQuery(article, lowerQuery);
      }).toList();

      emit(SearchSuccess(
        query: query,
        userArticles: filteredUserArticles,
        apiArticles: filteredApiArticles,
      ));
    } catch (e) {
      emit(SearchError(
        message: e.toString(),
        query: query,
      ));
    }
  }
  
  /// Checks if an article matches the search query.
  bool _articleMatchesQuery(ArticleEntity article, String lowerQuery) {
    final title = article.title?.toLowerCase() ?? '';
    final description = article.description?.toLowerCase() ?? '';
    final author = article.author?.toLowerCase() ?? '';
    final source = article.source?.name?.toLowerCase() ?? '';
    
    return title.contains(lowerQuery) ||
        description.contains(lowerQuery) ||
        author.contains(lowerQuery) ||
        source.contains(lowerQuery);
  }

  /// Clears the current search and resets to initial state with cached articles.
  void clearSearch() {
    _debounceTimer?.cancel();
    emit(SearchInitial(
      userArticles: _cachedUserArticles,
      apiArticles: _cachedApiArticles,
    ));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
