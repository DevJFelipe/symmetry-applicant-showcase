import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/firestore_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/toggle_reaction_params.dart';

/// Use case for searching articles by query.
///
/// Searches article titles, descriptions, and author names
/// for the given query string.
class SearchArticlesUseCase
    implements UseCase<List<ArticleEntity>, SearchArticlesParams> {
  final FirestoreArticleRepository _repository;

  SearchArticlesUseCase(this._repository);

  @override
  Future<List<ArticleEntity>> call({SearchArticlesParams? params}) async {
    if (params == null) {
      throw ArgumentError('SearchArticlesParams cannot be null');
    }
    
    return _repository.searchArticles(params.query);
  }
}
