import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// Base class for edit article states using sealed class pattern.
sealed class EditArticleState extends Equatable {
  const EditArticleState();

  @override
  List<Object?> get props => [];
}

/// Initial state with the article loaded for editing.
final class EditArticleInitial extends EditArticleState {
  final ArticleEntity article;

  const EditArticleInitial(this.article);

  @override
  List<Object?> get props => [article];
}

/// State when a new image has been selected but not yet saved.
final class EditArticleImagePicked extends EditArticleState {
  final ArticleEntity article;
  final String newImagePath;

  const EditArticleImagePicked({
    required this.article,
    required this.newImagePath,
  });

  @override
  List<Object?> get props => [article, newImagePath];
}

/// State while the article is being updated.
final class EditArticleLoading extends EditArticleState {
  final String message;

  const EditArticleLoading({this.message = 'Saving changes...'});

  @override
  List<Object?> get props => [message];
}

/// State when the article has been successfully updated.
final class EditArticleSuccess extends EditArticleState {
  final ArticleEntity article;

  const EditArticleSuccess(this.article);

  @override
  List<Object?> get props => [article];
}

/// State when article update fails.
final class EditArticleError extends EditArticleState {
  final ArticleEntity article;
  final String message;
  final String? newImagePath;

  const EditArticleError({
    required this.article,
    required this.message,
    this.newImagePath,
  });

  @override
  List<Object?> get props => [article, message, newImagePath];
}
