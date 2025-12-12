import 'package:news_app_clean_architecture/features/daily_news/domain/entities/reaction.dart';

/// Repository contract for article reaction operations.
///
/// Abstracts reaction storage implementation from business logic.
/// Supports both Firestore articles and external API articles.
///
/// This interface lives in the domain layer and has NO dependencies
/// on data layer implementations or external packages.
abstract class ReactionRepository {
  /// Toggles a reaction on an article.
  ///
  /// Works for both Firestore articles (using documentId) and
  /// external API articles (using articleUrl).
  ///
  /// Behavior:
  /// - Same reaction type = removes it (toggle off)
  /// - Different reaction type = replaces previous
  /// - No existing reaction = adds it
  ///
  /// Parameters:
  /// - [documentId] - Firestore document ID (for user-created articles)
  /// - [articleUrl] - Article URL (for external API articles)
  /// - [userId] - The authenticated user's ID
  /// - [reactionType] - The type of reaction to toggle
  ///
  /// Returns [ReactionResult] with updated counts and action taken.
  ///
  /// Throws [ReactionException] if the operation fails.
  Future<ReactionResult> toggleReaction({
    required String? documentId,
    required String? articleUrl,
    required String userId,
    required String reactionType,
  });

  /// Gets reactions for a single external article by URL.
  ///
  /// Returns null if no reactions exist for this article.
  Future<ReactionData?> getExternalArticleReactions(String articleUrl);

  /// Gets reactions for multiple external articles by URLs.
  ///
  /// Returns a map of URL -> ReactionData for efficient batch fetching.
  /// URLs without reactions are omitted from the result.
  Future<Map<String, ReactionData>> getExternalArticlesReactions(
    List<String> articleUrls,
  );
}
