import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/reaction.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/reaction_repository.dart';

/// Parameters for toggling a reaction on an article.
class ToggleArticleReactionParams {
  /// Firestore document ID (for user-created articles).
  final String? documentId;

  /// Article URL (for external API articles).
  final String? articleUrl;

  /// The authenticated user's ID.
  final String userId;

  /// The type of reaction to toggle.
  final String reactionType;

  const ToggleArticleReactionParams({
    this.documentId,
    this.articleUrl,
    required this.userId,
    required this.reactionType,
  });
}

/// Use case for toggling a reaction on an article.
///
/// Supports both user-created Firestore articles (via documentId)
/// and external API articles (via articleUrl).
///
/// Implements single-reaction-per-user logic:
/// - If user has this reaction → removes it (toggle off)
/// - If user has different reaction → replaces it
/// - If user has no reaction → adds it
class ToggleArticleReactionUseCase
    implements UseCase<ReactionResult, ToggleArticleReactionParams> {
  final ReactionRepository _reactionRepository;

  ToggleArticleReactionUseCase(this._reactionRepository);

  @override
  Future<ReactionResult> call({ToggleArticleReactionParams? params}) async {
    if (params == null) {
      throw ArgumentError('ToggleArticleReactionParams is required');
    }

    return _reactionRepository.toggleReaction(
      documentId: params.documentId,
      articleUrl: params.articleUrl,
      userId: params.userId,
      reactionType: params.reactionType,
    );
  }
}
