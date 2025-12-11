import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// States for the search feature.
/// 
/// Follows the sealed class pattern for exhaustive state handling.
sealed class SearchState extends Equatable {
  const SearchState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state before any search is performed.
final class SearchInitial extends SearchState {
  const SearchInitial();
}

/// State while search is in progress.
final class SearchLoading extends SearchState {
  /// The query being searched.
  final String query;
  
  const SearchLoading({required this.query});
  
  @override
  List<Object?> get props => [query];
}

/// State when search completes successfully.
final class SearchSuccess extends SearchState {
  /// The search query that produced these results.
  final String query;
  
  /// The list of articles matching the search.
  final List<ArticleEntity> articles;
  
  const SearchSuccess({
    required this.query,
    required this.articles,
  });
  
  /// Whether results are empty.
  bool get isEmpty => articles.isEmpty;
  
  @override
  List<Object?> get props => [query, articles];
}

/// State when search fails.
final class SearchError extends SearchState {
  /// Error message describing what went wrong.
  final String message;
  
  /// The query that failed.
  final String? query;
  
  const SearchError({
    required this.message,
    this.query,
  });
  
  @override
  List<Object?> get props => [message, query];
}
