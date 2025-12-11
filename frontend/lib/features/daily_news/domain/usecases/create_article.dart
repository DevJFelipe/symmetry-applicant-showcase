import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/firestore_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/create_article_params.dart';

/// Use case for creating a new article in Firestore.
///
/// Handles the business logic for article creation including:
/// - Uploading the thumbnail image to Cloud Storage
/// - Saving the article data to Firestore
class CreateArticleUseCase implements UseCase<ArticleEntity, CreateArticleParams> {
  final FirestoreArticleRepository _repository;
  
  CreateArticleUseCase(this._repository);

  /// Creates a new article.
  ///
  /// Requires [params] containing:
  /// - title, description, content (article data)
  /// - thumbnailFile (image file)
  /// - userId and authorName (from authenticated user)
  /// - optional url (external link)
  ///
  /// Note: userId and authorName must be provided by the caller (Cubit)
  /// since UseCases should not depend on auth state directly.
  @override
  Future<ArticleEntity> call({CreateArticleParams? params}) async {
    if (params == null) {
      throw ArgumentError('CreateArticleParams cannot be null');
    }
    
    // This use case expects the caller to provide userId and authorName
    // The actual implementation will be called from the cubit
    throw UnimplementedError(
      'Use createWithUserData instead for proper user context',
    );
  }

  /// Creates an article with explicit user data.
  ///
  /// This method should be used instead of [call] to provide user context.
  Future<ArticleEntity> createWithUserData({
    required CreateArticleParams params,
    required String userId,
    required String authorName,
  }) async {
    return await _repository.createArticle(
      title: params.title,
      description: params.description,
      content: params.content,
      thumbnailFile: params.thumbnailFile,
      userId: userId,
      authorName: authorName,
      url: params.url,
    );
  }
}
