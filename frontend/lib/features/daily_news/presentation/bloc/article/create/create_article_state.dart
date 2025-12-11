import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// Base class for all create article states.
abstract class CreateArticleState extends Equatable {
  const CreateArticleState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the create article form is displayed.
class CreateArticleInitial extends CreateArticleState {
  const CreateArticleInitial();
}

/// State while the article is being created/uploaded.
class CreateArticleLoading extends CreateArticleState {
  /// Progress message to display to the user.
  final String message;

  const CreateArticleLoading({this.message = 'Creating article...'});

  @override
  List<Object?> get props => [message];
}

/// State when the article has been successfully created.
class CreateArticleSuccess extends CreateArticleState {
  /// The created article entity.
  final ArticleEntity article;

  const CreateArticleSuccess(this.article);

  @override
  List<Object?> get props => [article];
}

/// State when article creation fails.
class CreateArticleError extends CreateArticleState {
  /// Error message describing what went wrong.
  final String message;

  const CreateArticleError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when an image has been selected but article not yet submitted.
class CreateArticleImageSelected extends CreateArticleState {
  /// Path to the selected image file.
  final String imagePath;

  const CreateArticleImageSelected(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}
