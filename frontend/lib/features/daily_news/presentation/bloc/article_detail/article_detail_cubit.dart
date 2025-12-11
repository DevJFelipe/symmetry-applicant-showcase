import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/reaction_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article_detail/article_detail_state.dart';

export 'article_detail_state.dart';

/// Cubit for managing article detail interactions, including reactions.
///
/// Implements optimistic UI updates for reactions:
/// 1. Immediately updates UI with expected result
/// 2. Makes server request in background
/// 3. Rolls back on failure with error message
///
/// Supports reactions on both:
/// - Firestore articles (have documentId)
/// - External API articles (use URL as identifier)
///
/// Each user can only have ONE active reaction per article.
class ArticleDetailCubit extends Cubit<ArticleDetailState> {
  final ReactionService _reactionService;

  ArticleDetailCubit({
    required ReactionService reactionService,
  })  : _reactionService = reactionService,
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
  ///
  /// Supports single-reaction-per-user:
  /// - If user already has this reaction → removes it
  /// - If user has a different reaction → replaces it
  /// - If user has no reaction → adds it
  Future<void> toggleReaction({
    required String userId,
    required ArticleReaction reactionType,
  }) async {
    final article = currentArticle;
    if (article == null) return;

    // Check if article can receive reactions (needs documentId OR url)
    final hasValidIdentifier = 
        (article.documentId != null && article.documentId!.isNotEmpty) ||
        (article.url != null && article.url!.isNotEmpty);
    
    if (!hasValidIdentifier) {
      emit(ArticleDetailError(
        article: article,
        message: 'This article cannot receive reactions.',
      ));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(ArticleDetailLoaded(article));
      return;
    }

    // Find user's existing reaction (if any)
    final existingReactionType = _findUserReaction(article, userId);
    
    // Create optimistic article state
    final optimisticArticle = _createOptimisticUpdate(
      article: article,
      userId: userId,
      newReactionType: reactionType,
      existingReactionType: existingReactionType,
    );

    // Emit optimistic update immediately
    emit(ArticleDetailUpdating(
      article: optimisticArticle,
      reactionType: reactionType,
    ));

    try {
      // Make server request
      final result = await _reactionService.toggleReaction(
        documentId: article.documentId,
        articleUrl: article.url,
        userId: userId,
        reactionType: reactionType.name,
      );

      // Update article with server response
      final updatedArticle = article.copyWith(
        reactions: result.reactions,
        userReactions: result.userReactions,
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

  /// Finds the user's existing reaction type (if any).
  ArticleReaction? _findUserReaction(ArticleEntity article, String userId) {
    final userReactions = article.userReactions;
    if (userReactions == null) return null;

    for (final entry in userReactions.entries) {
      if (entry.value.contains(userId)) {
        // Find the ArticleReaction enum that matches this key
        try {
          return ArticleReaction.values.firstWhere(
            (r) => r.name == entry.key,
          );
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  /// Creates an optimistic update of the article with the reaction toggled.
  ///
  /// Handles single-reaction-per-user logic:
  /// - Same reaction = remove
  /// - Different reaction = replace (remove old, add new)
  /// - No reaction = add
  ArticleEntity _createOptimisticUpdate({
    required ArticleEntity article,
    required String userId,
    required ArticleReaction newReactionType,
    ArticleReaction? existingReactionType,
  }) {
    // Copy current reactions or create empty map
    final newReactions = Map<String, int>.from(article.reactions ?? {});
    final newUserReactions = Map<String, List<String>>.from(
      article.userReactions?.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ) ??
          {},
    );

    final newKey = newReactionType.name;

    if (existingReactionType?.name == newKey) {
      // Same reaction - remove it (toggle off)
      _removeReaction(newReactions, newUserReactions, userId, newKey);
    } else {
      // Different or no existing reaction
      if (existingReactionType != null) {
        // Remove the old reaction first
        _removeReaction(
          newReactions,
          newUserReactions,
          userId,
          existingReactionType.name,
        );
      }
      // Add the new reaction
      _addReaction(newReactions, newUserReactions, userId, newKey);
    }

    return article.copyWith(
      reactions: newReactions,
      userReactions: newUserReactions,
    );
  }

  void _removeReaction(
    Map<String, int> reactions,
    Map<String, List<String>> userReactions,
    String userId,
    String reactionType,
  ) {
    final currentCount = reactions[reactionType] ?? 0;
    if (currentCount <= 1) {
      reactions.remove(reactionType);
    } else {
      reactions[reactionType] = currentCount - 1;
    }

    final users = userReactions[reactionType];
    if (users != null) {
      users.remove(userId);
      if (users.isEmpty) {
        userReactions.remove(reactionType);
      }
    }
  }

  void _addReaction(
    Map<String, int> reactions,
    Map<String, List<String>> userReactions,
    String userId,
    String reactionType,
  ) {
    reactions[reactionType] = (reactions[reactionType] ?? 0) + 1;

    final users = userReactions[reactionType] ?? [];
    if (!users.contains(userId)) {
      users.add(userId);
    }
    userReactions[reactionType] = users;
  }

  /// Updates the article in state (useful for external updates).
  void updateArticle(ArticleEntity article) {
    emit(ArticleDetailLoaded(article));
  }
}
