import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/reaction_service.dart';

/// Parameters for fetching reactions for external articles.
class GetExternalReactionsParams {
  /// List of article URLs to fetch reactions for.
  final List<String> articleUrls;

  const GetExternalReactionsParams({required this.articleUrls});
}

/// Use case for fetching reactions of external API articles.
///
/// Returns a map of article URL to reaction data.
class GetExternalReactionsUseCase
    implements UseCase<Map<String, ReactionData>, GetExternalReactionsParams> {
  final ReactionService _reactionService;

  GetExternalReactionsUseCase(this._reactionService);

  @override
  Future<Map<String, ReactionData>> call({GetExternalReactionsParams? params}) async {
    if (params == null || params.articleUrls.isEmpty) {
      return {};
    }
    
    return _reactionService.getExternalArticlesReactions(params.articleUrls);
  }
}
