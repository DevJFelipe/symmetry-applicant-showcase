import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/firestore_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/toggle_reaction_params.dart';

/// Use case for fetching articles created by a specific user.
///
/// Returns a list of articles authored by the user with the given ID,
/// ordered by creation date (newest first).
class GetUserArticlesUseCase
    implements UseCase<List<ArticleEntity>, GetUserArticlesParams> {
  final FirestoreArticleRepository _repository;

  GetUserArticlesUseCase(this._repository);

  @override
  Future<List<ArticleEntity>> call({GetUserArticlesParams? params}) async {
    if (params == null) {
      throw ArgumentError('GetUserArticlesParams cannot be null');
    }
    
    return _repository.getArticlesByUser(params.userId);
  }
}
