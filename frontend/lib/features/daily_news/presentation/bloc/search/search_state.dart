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

/// Initial state showing all articles (user articles first, then API articles).
final class SearchInitial extends SearchState {
  /// User's own articles.
  final List<ArticleEntity> userArticles;
  
  /// Articles from external API.
  final List<ArticleEntity> apiArticles;
  
  const SearchInitial({
    this.userArticles = const [],
    this.apiArticles = const [],
  });
  
  /// Combined list with user articles first.
  List<ArticleEntity> get allArticles => [...userArticles, ...apiArticles];
  
  /// Whether data is loaded.
  bool get hasData => userArticles.isNotEmpty || apiArticles.isNotEmpty;
  
  @override
  List<Object?> get props => [userArticles, apiArticles];
}

/// State while loading initial data or search.
final class SearchLoading extends SearchState {
  /// The query being searched (null if loading initial data).
  final String? query;
  
  const SearchLoading({this.query});
  
  @override
  List<Object?> get props => [query];
}

/// State when search completes successfully.
final class SearchSuccess extends SearchState {
  /// The search query that produced these results.
  final String query;
  
  /// User articles matching the search.
  final List<ArticleEntity> userArticles;
  
  /// API articles matching the search.
  final List<ArticleEntity> apiArticles;
  
  const SearchSuccess({
    required this.query,
    this.userArticles = const [],
    this.apiArticles = const [],
  });
  
  /// Combined results with user articles first.
  List<ArticleEntity> get articles => [...userArticles, ...apiArticles];
  
  /// Whether results are empty.
  bool get isEmpty => userArticles.isEmpty && apiArticles.isEmpty;
  
  @override
  List<Object?> get props => [query, userArticles, apiArticles];
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
