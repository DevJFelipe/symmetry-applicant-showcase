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
  final Map<String, int>? reactions;
  final Map<String, List<String>>? userReactions;

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
    this.reactions,
    this.userReactions,
  });

  /// Creates a [FirestoreArticleModel] from a Firestore document snapshot.
  factory FirestoreArticleModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    
    // Parse reactions map
    Map<String, int>? reactions;
    if (data['reactions'] != null) {
      reactions = Map<String, int>.from(
        (data['reactions'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toInt()),
        ),
      );
    }
    
    // Parse userReactions map
    Map<String, List<String>>? userReactions;
    if (data['userReactions'] != null) {
      userReactions = Map<String, List<String>>.from(
        (data['userReactions'] as Map).map(
          (key, value) => MapEntry(
            key.toString(),
            List<String>.from(value as List),
          ),
        ),
      );
    }
    
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
      reactions: reactions,
      userReactions: userReactions,
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
      if (reactions != null) 'reactions': reactions,
      if (userReactions != null) 'userReactions': userReactions,
    };
  }

  /// Converts this model to an [ArticleEntity] for use in the domain layer.
  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id.hashCode, // Generate numeric ID from string ID
      documentId: id,
      title: title,
      description: description,
      content: content,
      author: author,
      userId: userId,
      urlToImage: urlToImage,
      url: url,
      publishedAt: publishedAt.toIso8601String(),
      createdAt: createdAt.toIso8601String(),
      reactions: reactions,
      userReactions: userReactions,
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
      reactions: const {},
      userReactions: const {},
    );
  }
  
  /// Creates a [FirestoreArticleModel] from an existing entity for updates.
  factory FirestoreArticleModel.fromEntity(ArticleEntity entity) {
    return FirestoreArticleModel(
      id: entity.documentId,
      title: entity.title ?? '',
      description: entity.description ?? '',
      content: entity.content ?? '',
      author: entity.author ?? '',
      userId: entity.userId ?? '',
      urlToImage: entity.urlToImage ?? '',
      url: entity.url,
      publishedAt: entity.publishedAt != null 
          ? DateTime.parse(entity.publishedAt!)
          : DateTime.now(),
      createdAt: entity.createdAt != null 
          ? DateTime.parse(entity.createdAt!)
          : DateTime.now(),
      reactions: entity.reactions,
      userReactions: entity.userReactions,
    );
  }
  
  /// Creates a copy with updated fields
  FirestoreArticleModel copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? author,
    String? userId,
    String? urlToImage,
    String? url,
    DateTime? publishedAt,
    DateTime? createdAt,
    Map<String, int>? reactions,
    Map<String, List<String>>? userReactions,
  }) {
    return FirestoreArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      author: author ?? this.author,
      userId: userId ?? this.userId,
      urlToImage: urlToImage ?? this.urlToImage,
      url: url ?? this.url,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      reactions: reactions ?? this.reactions,
      userReactions: userReactions ?? this.userReactions,
    );
  }
}
