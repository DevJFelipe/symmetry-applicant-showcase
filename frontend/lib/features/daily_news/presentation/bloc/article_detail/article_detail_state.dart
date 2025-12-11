import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// Base class for article detail states using sealed class pattern.
sealed class ArticleDetailState extends Equatable {
  const ArticleDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state before article is loaded.
final class ArticleDetailInitial extends ArticleDetailState {
  const ArticleDetailInitial();
}

/// State when article is successfully loaded and ready for interaction.
final class ArticleDetailLoaded extends ArticleDetailState {
  final ArticleEntity article;

  const ArticleDetailLoaded(this.article);

  @override
  List<Object?> get props => [article];
}

/// State during optimistic UI update while toggling a reaction.
/// 
/// Contains the optimistically updated article and the reaction being toggled.
/// Used to show immediate feedback before server confirmation.
final class ArticleDetailUpdating extends ArticleDetailState {
  final ArticleEntity article;
  final ArticleReaction reactionType;

  const ArticleDetailUpdating({
    required this.article,
    required this.reactionType,
  });

  @override
  List<Object?> get props => [article, reactionType];
}

/// State when a reaction toggle fails and needs rollback.
/// 
/// Contains the original article (before optimistic update) and error message.
final class ArticleDetailError extends ArticleDetailState {
  final ArticleEntity article;
  final String message;

  const ArticleDetailError({
    required this.article,
    required this.message,
  });

  @override
  List<Object?> get props => [article, message];
}
