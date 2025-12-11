import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import '../../../../domain/entities/article.dart';

/// Base state for remote articles operations
sealed class RemoteArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final AppException? error;

  const RemoteArticlesState({this.articles, this.error});

  @override
  List<Object?> get props => [articles, error];
}

/// Initial loading state
final class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading();
}

/// Successfully loaded articles
final class RemoteArticlesDone extends RemoteArticlesState {
  const RemoteArticlesDone(List<ArticleEntity> articles)
      : super(articles: articles);
}

/// Error state with domain-level exception
final class RemoteArticlesError extends RemoteArticlesState {
  const RemoteArticlesError(AppException error) : super(error: error);
}

/// Empty state when no articles are available
final class RemoteArticlesEmpty extends RemoteArticlesState {
  const RemoteArticlesEmpty();
}

