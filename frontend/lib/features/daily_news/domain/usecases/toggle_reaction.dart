import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/firestore_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/toggle_reaction_params.dart';

/// Use case for toggling a reaction on an article.
///
/// Allows users to add or remove reactions (like, love, fire, etc.)
/// from articles. The toggle behavior means if a user has already
/// reacted with a type, calling this will remove it, otherwise add it.
class ToggleReactionUseCase
    implements UseCase<ArticleEntity, ToggleReactionParams> {
  final FirestoreArticleRepository _repository;

  ToggleReactionUseCase(this._repository);

  @override
  Future<ArticleEntity> call({ToggleReactionParams? params}) async {
    if (params == null) {
      throw ArgumentError('ToggleReactionParams cannot be null');
    }
    
    return _repository.toggleReaction(
      articleId: params.articleId,
      userId: params.userId,
      reactionType: params.reactionType.name,
      add: params.add,
    );
  }
}
