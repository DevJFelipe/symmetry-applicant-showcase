import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// Parameters for the [ToggleReactionUseCase].
class ToggleReactionParams {
  /// The ID of the article to react to.
  final String articleId;
  
  /// The ID of the user performing the reaction.
  final String userId;
  
  /// The type of reaction to toggle.
  final ArticleReaction reactionType;
  
  /// Whether to add (true) or remove (false) the reaction.
  /// Note: The backend handles this as a toggle, but we include
  /// this for explicit intent documentation.
  final bool add;

  const ToggleReactionParams({
    required this.articleId,
    required this.userId,
    required this.reactionType,
    this.add = true,
  });
}

/// Parameters for searching articles.
class SearchArticlesParams {
  /// The search query string.
  final String query;

  const SearchArticlesParams({required this.query});
}

/// Parameters for updating an article.
class UpdateArticleParams {
  /// The ID of the article to update.
  final String articleId;
  
  /// New title (optional).
  final String? title;
  
  /// New description (optional).
  final String? description;
  
  /// New content (optional).
  final String? content;
  
  /// New thumbnail image path (optional, replaces existing).
  final String? newThumbnailPath;

  const UpdateArticleParams({
    required this.articleId,
    this.title,
    this.description,
    this.content,
    this.newThumbnailPath,
  });
  
  /// Returns true if any field has been modified.
  bool get hasChanges => 
      title != null || 
      description != null || 
      content != null || 
      newThumbnailPath != null;
}

/// Parameters for getting user articles.
class GetUserArticlesParams {
  /// The ID of the user whose articles to fetch.
  final String userId;

  const GetUserArticlesParams({required this.userId});
}

/// Parameters for deleting an article.
class DeleteArticleParams {
  /// The ID of the article to delete.
  final String articleId;

  const DeleteArticleParams({required this.articleId});
}
