import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/search_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/toggle_reaction_params.dart';
import 'search_state.dart';

/// Cubit for managing article search functionality.
/// 
/// Handles search operations following Clean Architecture principles:
/// - Only interacts with domain layer (UseCases)
/// - Implements debouncing to prevent excessive API calls
/// - Manages search state transitions
class SearchCubit extends Cubit<SearchState> {
  final SearchArticlesUseCase _searchArticlesUseCase;
  
  /// Debounce timer for search input.
  Timer? _debounceTimer;
  
  /// Debounce duration in milliseconds.
  static const _debounceDuration = Duration(milliseconds: 300);

  SearchCubit({
    required SearchArticlesUseCase searchArticlesUseCase,
  })  : _searchArticlesUseCase = searchArticlesUseCase,
        super(const SearchInitial());

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
      emit(const SearchInitial());
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
      emit(const SearchInitial());
      return;
    }
    
    await _performSearch(trimmedQuery);
  }

  /// Internal method to execute the search.
  Future<void> _performSearch(String query) async {
    try {
      emit(SearchLoading(query: query));
      
      final articles = await _searchArticlesUseCase(
        params: SearchArticlesParams(query: query),
      );
      
      emit(SearchSuccess(query: query, articles: articles));
    } catch (e) {
      emit(SearchError(
        message: e.toString(),
        query: query,
      ));
    }
  }

  /// Clears the current search and resets to initial state.
  void clearSearch() {
    _debounceTimer?.cancel();
    emit(const SearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
