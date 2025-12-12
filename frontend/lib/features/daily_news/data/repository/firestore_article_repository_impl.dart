import 'dart:io';

import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/firestore_article_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/firestore_article_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/firestore_article_repository.dart';

/// Implementation of [FirestoreArticleRepository] using Firebase services.
///
/// This class acts as a bridge between the domain layer and the Firestore
/// data source, converting models to entities.
class FirestoreArticleRepositoryImpl implements FirestoreArticleRepository {
  final FirestoreArticleService _articleService;

  FirestoreArticleRepositoryImpl(this._articleService);

  @override
  Future<List<ArticleEntity>> getArticles() async {
    final models = await _articleService.getArticles();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ArticleEntity>> getArticlesByUser(String userId) async {
    final models = await _articleService.getArticlesByUser(userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ArticleEntity?> getArticleById(String articleId) async {
    final model = await _articleService.getArticleById(articleId);
    return model?.toEntity();
  }

  @override
  Future<ArticleEntity> createArticle({
    required String title,
    required String description,
    required String content,
    required File thumbnailFile,
    required String userId,
    required String authorName,
    String? url,
  }) async {
    // First, upload the thumbnail image
    final imageUrl = await _articleService.uploadThumbnail(
      imageFile: thumbnailFile,
      userId: userId,
    );

    // Create the article model
    final now = DateTime.now();
    final articleModel = FirestoreArticleModel(
      title: title,
      description: description,
      content: content,
      author: authorName,
      userId: userId,
      urlToImage: imageUrl,
      url: url,
      publishedAt: now,
      createdAt: now,
      reactions: const {},
      userReactions: const {},
    );

    // Save to Firestore and return the entity
    final createdArticle = await _articleService.createArticle(articleModel);
    return createdArticle.toEntity();
  }

  @override
  Future<ArticleEntity> updateArticle({
    required String articleId,
    String? title,
    String? description,
    String? content,
    File? thumbnailFile,
  }) async {
    // Get existing article
    final existingArticle = await _articleService.getArticleById(articleId);
    if (existingArticle == null) {
      throw Exception('Article not found');
    }

    String? newImageUrl;
    if (thumbnailFile != null) {
      // Upload new thumbnail
      newImageUrl = await _articleService.uploadThumbnail(
        imageFile: thumbnailFile,
        userId: existingArticle.userId,
      );
      // Optionally delete old image
      if (existingArticle.urlToImage.isNotEmpty) {
        try {
          await _articleService.deleteThumbnail(existingArticle.urlToImage);
        } catch (_) {
          // Ignore deletion errors
        }
      }
    }

    // Update the article fields
    await _articleService.updateArticleFields(
      articleId: articleId,
      title: title,
      description: description,
      content: content,
      urlToImage: newImageUrl,
    );

    // Fetch and return the updated article
    final updated = await _articleService.getArticleById(articleId);
    return updated!.toEntity();
  }

  @override
  Future<void> deleteArticle(String articleId) async {
    // Get the article to retrieve the image URL
    final article = await _articleService.getArticleById(articleId);
    
    // Delete the article and its image
    await _articleService.deleteArticle(
      articleId,
      article?.urlToImage,
    );
  }

  @override
  Future<ArticleEntity> toggleReaction({
    required String articleId,
    required String userId,
    required String reactionType,
    required bool add,
  }) async {
    // Note: The 'add' parameter is handled internally by the service
    // which toggles (adds if not present, removes if present)
    final updatedModel = await _articleService.toggleReaction(
      articleId: articleId,
      userId: userId,
      reactionType: reactionType,
    );
    return updatedModel.toEntity();
  }
}

