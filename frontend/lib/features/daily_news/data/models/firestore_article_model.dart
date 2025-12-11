import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// Model class for Firestore articles.
///
/// This model handles conversion between Firestore documents and [ArticleEntity].
/// It includes additional fields required for user-created articles.
class FirestoreArticleModel {
  final String? id;
  final String title;
  final String description;
  final String content;
  final String author;
  final String userId;
  final String urlToImage;
  final String? url;
  final DateTime publishedAt;
  final DateTime createdAt;

  const FirestoreArticleModel({
    this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.author,
    required this.userId,
    required this.urlToImage,
    this.url,
    required this.publishedAt,
    required this.createdAt,
  });

  /// Creates a [FirestoreArticleModel] from a Firestore document snapshot.
  factory FirestoreArticleModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return FirestoreArticleModel(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      content: data['content'] as String,
      author: data['author'] as String,
      userId: data['userId'] as String,
      urlToImage: data['urlToImage'] as String,
      url: data['url'] as String?,
      publishedAt: (data['publishedAt'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Converts this model to a Firestore-compatible map for writing.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'author': author,
      'userId': userId,
      'urlToImage': urlToImage,
      if (url != null) 'url': url,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Converts this model to an [ArticleEntity] for use in the domain layer.
  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id.hashCode, // Generate numeric ID from string ID
      title: title,
      description: description,
      content: content,
      author: author,
      urlToImage: urlToImage,
      url: url,
      publishedAt: publishedAt.toIso8601String(),
    );
  }

  /// Creates a [FirestoreArticleModel] from an [ArticleEntity] and additional data.
  ///
  /// Used when creating new articles from the domain layer.
  factory FirestoreArticleModel.fromEntityWithUserData({
    required ArticleEntity entity,
    required String userId,
    required String author,
    required String urlToImage,
  }) {
    final now = DateTime.now();
    return FirestoreArticleModel(
      title: entity.title ?? '',
      description: entity.description ?? '',
      content: entity.content ?? '',
      author: author,
      userId: userId,
      urlToImage: urlToImage,
      url: entity.url,
      publishedAt: now,
      createdAt: now,
    );
  }
}
