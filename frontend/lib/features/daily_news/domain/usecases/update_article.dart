import 'dart:io';

import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/firestore_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/toggle_reaction_params.dart';

/// Use case for updating an existing article.
///
/// Allows modification of title, description, content, and thumbnail.
/// Only non-null fields will be updated in Firestore.
class UpdateArticleUseCase implements UseCase<ArticleEntity, UpdateArticleParams> {
  final FirestoreArticleRepository _repository;

  UpdateArticleUseCase(this._repository);

  @override
  Future<ArticleEntity> call({UpdateArticleParams? params}) async {
    if (params == null) {
      throw ArgumentError('UpdateArticleParams cannot be null');
    }

    if (!params.hasChanges) {
      throw ArgumentError('No changes provided for update');
    }

    // Convert path to File if thumbnail is being updated
    File? thumbnailFile;
    if (params.newThumbnailPath != null) {
      thumbnailFile = File(params.newThumbnailPath!);
      if (!await thumbnailFile.exists()) {
        throw ArgumentError('Thumbnail file does not exist');
      }
    }

    return _repository.updateArticle(
      articleId: params.articleId,
      title: params.title,
      description: params.description,
      content: params.content,
      thumbnailFile: thumbnailFile,
    );
  }
}
