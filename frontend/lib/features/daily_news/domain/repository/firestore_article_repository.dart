import 'dart:io';

import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// Repository contract for Firestore article operations.
///
/// Defines the interface for creating, reading, updating, and deleting
/// articles stored in Firebase Cloud Firestore.
abstract class FirestoreArticleRepository {
  /// Fetches all articles from Firestore ordered by publication date.
  Future<List<ArticleEntity>> getArticles();

  /// Fetches articles created by a specific user.
  Future<List<ArticleEntity>> getArticlesByUser(String userId);

  /// Fetches a single article by its document ID.
  Future<ArticleEntity?> getArticleById(String articleId);

  /// Creates a new article with an uploaded thumbnail.
  ///
  /// [title] - Article headline
  /// [description] - Brief summary for the feed
  /// [content] - Full article body
  /// [thumbnailFile] - Image file for the article thumbnail
  /// [userId] - Firebase Auth UID of the creator
  /// [authorName] - Display name of the author
  /// [url] - Optional external article URL
  ///
  /// Returns the created [ArticleEntity].
  Future<ArticleEntity> createArticle({
    required String title,
    required String description,
    required String content,
    required File thumbnailFile,
    required String userId,
    required String authorName,
    String? url,
  });

  /// Updates an existing article.
  ///
  /// [articleId] - Document ID of the article to update
  /// [title] - Updated headline (optional)
  /// [description] - Updated summary (optional)
  /// [content] - Updated body (optional)
  /// [thumbnailFile] - New thumbnail image (optional, replaces existing)
  ///
  /// Returns the updated [ArticleEntity].
  Future<ArticleEntity> updateArticle({
    required String articleId,
    String? title,
    String? description,
    String? content,
    File? thumbnailFile,
  });

  /// Deletes an article from Firestore.
  ///
  /// Also removes the associated thumbnail from Cloud Storage.
  Future<void> deleteArticle(String articleId);
  
  /// Adds or removes a reaction to an article.
  ///
  /// [articleId] - Document ID of the article
  /// [userId] - User adding/removing the reaction
  /// [reactionType] - Type of reaction (fire, love, etc.)
  /// [add] - true to add, false to remove
  ///
  /// Returns the updated [ArticleEntity].
  Future<ArticleEntity> toggleReaction({
    required String articleId,
    required String userId,
    required String reactionType,
    required bool add,
  });
}

