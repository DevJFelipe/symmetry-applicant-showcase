import 'package:equatable/equatable.dart';

/// Article entity representing a news article in the domain layer.
/// 
/// Contains all the core article data needed by the application,
/// independent of any data source implementation.
class ArticleEntity extends Equatable {
  /// Local database ID (for saved articles)
  final int? id;
  
  /// Firestore document ID
  final String? documentId;
  
  /// Author's display name
  final String? author;
  
  /// Firebase Auth UID of the article creator
  final String? userId;
  
  /// Article headline
  final String? title;
  
  /// Brief summary for feed display
  final String? description;
  
  /// External article URL (optional)
  final String? url;
  
  /// Cloud Storage download URL for thumbnail
  final String? urlToImage;
  
  /// Publication date and time
  final String? publishedAt;
  
  /// Document creation timestamp (ISO 8601 string)
  final String? createdAt;
  
  /// Full article body
  final String? content;
  
  /// Article source (for API articles)
  final SourceEntity? source;
  
  /// User reactions map: { 'fire': 5, 'love': 3, ... }
  final Map<String, int>? reactions;
  
  /// List of user IDs who reacted (to track if current user reacted)
  final Map<String, List<String>>? userReactions;

  const ArticleEntity({
    this.id,
    this.documentId,
    this.author,
    this.userId,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.createdAt,
    this.content,
    this.source,
    this.reactions,
    this.userReactions,
  });
  
  /// Creates a copy of this entity with the given fields replaced
  ArticleEntity copyWith({
    int? id,
    String? documentId,
    String? author,
    String? userId,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    String? publishedAt,
    String? createdAt,
    String? content,
    SourceEntity? source,
    Map<String, int>? reactions,
    Map<String, List<String>>? userReactions,
  }) {
    return ArticleEntity(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      author: author ?? this.author,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      urlToImage: urlToImage ?? this.urlToImage,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
      source: source ?? this.source,
      reactions: reactions ?? this.reactions,
      userReactions: userReactions ?? this.userReactions,
    );
  }
  
  /// Get total reaction count
  int get totalReactions {
    if (reactions == null) return 0;
    return reactions!.values.fold(0, (sum, count) => sum + count);
  }
  
  /// Check if a specific user has reacted with a specific type
  bool hasUserReacted(String currentUserId, String reactionType) {
    if (userReactions == null) return false;
    final users = userReactions![reactionType];
    return users?.contains(currentUserId) ?? false;
  }
  
  /// Check if article belongs to a specific user
  bool isOwnedBy(String currentUserId) => userId == currentUserId;

  @override
  List<Object?> get props => [
    id,
    documentId,
    author,
    userId,
    title,
    description,
    url,
    urlToImage,
    publishedAt,
    createdAt,
    content,
    source,
    reactions,
    userReactions,
  ];
}

/// Source entity for article origin
class SourceEntity extends Equatable {
  final String? id;
  final String? name;
  
  const SourceEntity({this.id, this.name});
  
  @override
  List<Object?> get props => [id, name];
}

/// Available reaction types for articles
enum ArticleReaction {
  fire('🔥', 'fire'),
  love('❤️', 'love'),
  thinking('🤔', 'thinking'),
  sad('😢', 'sad'),
  clap('👏', 'clap');
  
  final String emoji;
  final String key;
  
  const ArticleReaction(this.emoji, this.key);
}
