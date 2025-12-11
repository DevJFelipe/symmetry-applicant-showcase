import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/firestore_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/toggle_reaction_params.dart';

/// Use case for deleting an article.
///
/// Deletes an article and its associated thumbnail image from storage.
/// Should only be callable by the article's owner.
class DeleteArticleUseCase implements UseCase<void, DeleteArticleParams> {
  final FirestoreArticleRepository _repository;

  DeleteArticleUseCase(this._repository);

  @override
  Future<void> call({DeleteArticleParams? params}) async {
    if (params == null) {
      throw ArgumentError('DeleteArticleParams cannot be null');
    }
    
    return _repository.deleteArticle(params.articleId);
  }
}
