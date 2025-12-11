import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_external_reactions.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

/// BLoC for managing remote articles state
class RemoteArticlesBloc extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticleUseCase _getArticleUseCase;
  final GetExternalReactionsUseCase _getExternalReactionsUseCase;

  RemoteArticlesBloc(
    this._getArticleUseCase,
    this._getExternalReactionsUseCase,
  ) : super(const RemoteArticlesLoading()) {
    on<GetArticles>(_onGetArticles);
  }

  Future<void> _onGetArticles(
    GetArticles event,
    Emitter<RemoteArticlesState> emit,
  ) async {
    emit(const RemoteArticlesLoading());
    
    final dataState = await _getArticleUseCase();

    switch (dataState) {
      case DataSuccess(:final data) when data != null && data.isNotEmpty:
        // Fetch reactions for external articles
        final articleUrls = data
            .where((a) => a.url != null && a.url!.isNotEmpty)
            .map((a) => a.url!)
            .toList();
        
        try {
          final reactionsMap = await _getExternalReactionsUseCase(
            params: GetExternalReactionsParams(articleUrls: articleUrls),
          );
          
          // Merge reactions with articles
          final articlesWithReactions = data.map((article) {
            if (article.url != null && reactionsMap.containsKey(article.url)) {
              final reactionData = reactionsMap[article.url]!;
              return article.copyWith(
                reactions: reactionData.reactions,
                userReactions: reactionData.userReactions,
              );
            }
            return article;
          }).toList();
          
          emit(RemoteArticlesDone(articlesWithReactions));
        } catch (_) {
          // If fetching reactions fails, still show articles without reactions
          emit(RemoteArticlesDone(data));
        }
        
      case DataSuccess():
        emit(const RemoteArticlesEmpty());
      case DataFailed(:final error):
        emit(RemoteArticlesError(error ?? const UnknownException()));
    }
  }
}
