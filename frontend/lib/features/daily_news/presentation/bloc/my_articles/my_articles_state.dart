import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// States for the user's articles (My Articles) feature.
/// 
/// Follows the sealed class pattern for exhaustive state handling.
sealed class MyArticlesState extends Equatable {
  const MyArticlesState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state before articles are loaded.
final class MyArticlesInitial extends MyArticlesState {
  const MyArticlesInitial();
}

/// State while articles are being loaded.
final class MyArticlesLoading extends MyArticlesState {
  const MyArticlesLoading();
}

/// State when articles are loaded successfully.
final class MyArticlesLoaded extends MyArticlesState {
  /// The user's articles.
  final List<ArticleEntity> articles;
  
  const MyArticlesLoaded({required this.articles});
  
  /// Whether the user has no articles.
  bool get isEmpty => articles.isEmpty;
  
  /// Total number of articles.
  int get count => articles.length;
  
  /// Total reactions across all articles.
  int get totalReactions => articles.fold(
    0,
    (sum, article) => sum + article.totalReactions,
  );
  
  @override
  List<Object?> get props => [articles];
}

/// State when article loading fails.
final class MyArticlesError extends MyArticlesState {
  /// Error message describing what went wrong.
  final String message;
  
  const MyArticlesError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

/// State when an article is being deleted.
final class MyArticleDeleting extends MyArticlesState {
  /// The ID of the article being deleted.
  final String articleId;
  
  /// Current articles (to preserve UI state).
  final List<ArticleEntity> articles;
  
  const MyArticleDeleting({
    required this.articleId,
    required this.articles,
  });
  
  @override
  List<Object?> get props => [articleId, articles];
}

/// State after an article is deleted successfully.
final class MyArticleDeleted extends MyArticlesState {
  /// Updated list of articles after deletion.
  final List<ArticleEntity> articles;
  
  /// Message to display to user.
  final String message;
  
  const MyArticleDeleted({
    required this.articles,
    this.message = 'Article deleted successfully',
  });
  
  @override
  List<Object?> get props => [articles, message];
}
