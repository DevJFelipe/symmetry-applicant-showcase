import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_user_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/toggle_reaction_params.dart';
import 'my_articles_state.dart';

/// Cubit for managing user's own articles.
/// 
/// Handles CRUD operations for user-created articles following
/// Clean Architecture principles:
/// - Only interacts with domain layer (UseCases)
/// - Manages state transitions for loading, success, and error states
/// - Provides optimistic UI updates for deletions
class MyArticlesCubit extends Cubit<MyArticlesState> {
  final GetUserArticlesUseCase _getUserArticlesUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;
  
  /// Current user ID for fetching articles.
  String? _currentUserId;

  MyArticlesCubit({
    required GetUserArticlesUseCase getUserArticlesUseCase,
    required DeleteArticleUseCase deleteArticleUseCase,
  })  : _getUserArticlesUseCase = getUserArticlesUseCase,
        _deleteArticleUseCase = deleteArticleUseCase,
        super(const MyArticlesInitial());

  /// Loads articles for the specified user.
  /// 
  /// [userId] The ID of the user whose articles to fetch.
  Future<void> loadArticles(String userId) async {
    _currentUserId = userId;
    
    emit(const MyArticlesLoading());
    
    try {
      final articles = await _getUserArticlesUseCase(
        params: GetUserArticlesParams(userId: userId),
      );
      
      emit(MyArticlesLoaded(articles: articles));
    } catch (e) {
      emit(MyArticlesError(message: e.toString()));
    }
  }

  /// Refreshes the current user's articles.
  /// 
  /// Requires [loadArticles] to have been called at least once.
  Future<void> refresh() async {
    if (_currentUserId == null) return;
    await loadArticles(_currentUserId!);
  }

  /// Deletes an article by ID.
  /// 
  /// [articleId] The Firestore document ID of the article to delete.
  /// 
  /// Performs optimistic UI update - removes article from list
  /// immediately and restores on failure.
  Future<void> deleteArticle(String articleId) async {
    final currentState = state;
    
    // Only proceed if we have a loaded state
    if (currentState is! MyArticlesLoaded) return;
    
    final originalArticles = currentState.articles;
    
    // Emit deleting state with optimistic removal
    // Use documentId for comparison (Firestore ID)
    emit(MyArticleDeleting(
      articleId: articleId,
      articles: originalArticles.where((a) => a.documentId != articleId).toList(),
    ));
    
    try {
      await _deleteArticleUseCase(
        params: DeleteArticleParams(articleId: articleId),
      );
      
      // Success - emit deleted state with updated list
      final updatedArticles = originalArticles
          .where((a) => a.documentId != articleId)
          .toList();
      
      emit(MyArticleDeleted(articles: updatedArticles));
      
      // Transition back to loaded state after brief delay for snackbar
      await Future.delayed(const Duration(milliseconds: 100));
      emit(MyArticlesLoaded(articles: updatedArticles));
      
    } catch (e) {
      // Restore original list on error
      emit(MyArticlesError(message: 'Failed to delete article: $e'));
      
      // Restore the original state
      await Future.delayed(const Duration(seconds: 2));
      emit(MyArticlesLoaded(articles: originalArticles));
    }
  }

  /// Gets current articles if in loaded state.
  List<dynamic> get currentArticles {
    final currentState = state;
    if (currentState is MyArticlesLoaded) {
      return currentState.articles;
    }
    if (currentState is MyArticleDeleting) {
      return currentState.articles;
    }
    if (currentState is MyArticleDeleted) {
      return currentState.articles;
    }
    return [];
  }
}
