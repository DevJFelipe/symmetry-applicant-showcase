import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/reaction_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/reaction.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/reaction_repository.dart';

/// Implementation of [ReactionRepository] using Firebase Firestore.
///
/// Delegates actual Firestore operations to [ReactionService] and
/// converts between service-level types and domain entities.
class ReactionRepositoryImpl implements ReactionRepository {
  final ReactionService _reactionService;

  ReactionRepositoryImpl(this._reactionService);

  @override
  Future<ReactionResult> toggleReaction({
    required String? documentId,
    required String? articleUrl,
    required String userId,
    required String reactionType,
  }) async {
    try {
      final result = await _reactionService.toggleReaction(
        documentId: documentId,
        articleUrl: articleUrl,
        userId: userId,
        reactionType: reactionType,
      );

      return ReactionResult(
        reactions: result.reactions,
        userReactions: result.userReactions,
        action: _mapAction(result.action),
        reactionType: result.reactionType,
        previousReactionType: result.previousReactionType,
      );
    } on ServiceReactionException catch (e) {
      throw ReactionException(code: e.code, message: e.message);
    }
  }

  @override
  Future<ReactionData?> getExternalArticleReactions(String articleUrl) async {
    final data = await _reactionService.getExternalArticleReactions(articleUrl);
    if (data == null) return null;

    return ReactionData(
      reactions: data.reactions,
      userReactions: data.userReactions,
    );
  }

  @override
  Future<Map<String, ReactionData>> getExternalArticlesReactions(
    List<String> articleUrls,
  ) async {
    final results =
        await _reactionService.getExternalArticlesReactions(articleUrls);

    return results.map(
      (url, data) => MapEntry(
        url,
        ReactionData(
          reactions: data.reactions,
          userReactions: data.userReactions,
        ),
      ),
    );
  }

  /// Maps service action to domain action.
  ReactionAction _mapAction(ServiceReactionAction action) {
    return switch (action) {
      ServiceReactionAction.added => ReactionAction.added,
      ServiceReactionAction.removed => ReactionAction.removed,
      ServiceReactionAction.replaced => ReactionAction.replaced,
    };
  }
}
