import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/toggle_reaction.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/toggle_reaction_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article_detail/article_detail_state.dart';

export 'article_detail_state.dart';

/// Cubit for managing article detail interactions, including reactions.
///
/// Implements optimistic UI updates for reactions:
/// 1. Immediately updates UI with expected result
/// 2. Makes server request in background
/// 3. Rolls back on failure with error message
class ArticleDetailCubit extends Cubit<ArticleDetailState> {
  final ToggleReactionUseCase _toggleReactionUseCase;

  ArticleDetailCubit({
    required ToggleReactionUseCase toggleReactionUseCase,
  })  : _toggleReactionUseCase = toggleReactionUseCase,
        super(const ArticleDetailInitial());

  /// Loads an article into the cubit state.
  void loadArticle(ArticleEntity article) {
    emit(ArticleDetailLoaded(article));
  }

  /// Current article from state, null if not loaded.
  ArticleEntity? get currentArticle {
    final state = this.state;
    return switch (state) {
      ArticleDetailLoaded(:final article) => article,
      ArticleDetailUpdating(:final article) => article,
      ArticleDetailError(:final article) => article,
      ArticleDetailInitial() => null,
    };
  }

  /// Toggles a reaction on the current article with optimistic UI update.
  ///
  /// [userId] - The authenticated user's ID
  /// [reactionType] - The type of reaction to toggle
  Future<void> toggleReaction({
    required String userId,
    required ArticleReaction reactionType,
  }) async {
    final article = currentArticle;
    if (article == null || article.documentId == null) return;

    // Determine if user already has this reaction
    final hasReaction = article.hasUserReacted(userId, reactionType.name);
    
    // Create optimistic article state
    final optimisticArticle = _createOptimisticUpdate(
      article: article,
      userId: userId,
      reactionType: reactionType,
      isAdding: !hasReaction,
    );

    // Emit optimistic update immediately
    emit(ArticleDetailUpdating(
      article: optimisticArticle,
      reactionType: reactionType,
    ));

    try {
      // Make server request
      final updatedArticle = await _toggleReactionUseCase.call(
        params: ToggleReactionParams(
          articleId: article.documentId!,
          userId: userId,
          reactionType: reactionType,
          add: !hasReaction,
        ),
      );

      // Confirm with server response
      emit(ArticleDetailLoaded(updatedArticle));
    } catch (e) {
      // Rollback to original state on failure
      emit(ArticleDetailError(
        article: article,
        message: 'Failed to update reaction. Please try again.',
      ));

      // After showing error, restore to loaded state with original article
      await Future.delayed(const Duration(milliseconds: 100));
      emit(ArticleDetailLoaded(article));
    }
  }

  /// Creates an optimistic update of the article with the reaction toggled.
  ArticleEntity _createOptimisticUpdate({
    required ArticleEntity article,
    required String userId,
    required ArticleReaction reactionType,
    required bool isAdding,
  }) {
    // Copy current reactions or create empty map
    final newReactions = Map<String, int>.from(article.reactions ?? {});
    final newUserReactions = Map<String, List<String>>.from(
      article.userReactions?.map((key, value) => MapEntry(key, List<String>.from(value))) ?? {},
    );

    final reactionKey = reactionType.name;
    final currentCount = newReactions[reactionKey] ?? 0;
    final currentUsers = List<String>.from(newUserReactions[reactionKey] ?? []);

    if (isAdding) {
      // Add reaction
      newReactions[reactionKey] = currentCount + 1;
      if (!currentUsers.contains(userId)) {
        currentUsers.add(userId);
      }
    } else {
      // Remove reaction
      newReactions[reactionKey] = (currentCount - 1).clamp(0, currentCount);
      currentUsers.remove(userId);
    }

    newUserReactions[reactionKey] = currentUsers;

    return article.copyWith(
      reactions: newReactions,
      userReactions: newUserReactions,
    );
  }

  /// Updates the article in state (useful for external updates).
  void updateArticle(ArticleEntity article) {
    emit(ArticleDetailLoaded(article));
  }
}
