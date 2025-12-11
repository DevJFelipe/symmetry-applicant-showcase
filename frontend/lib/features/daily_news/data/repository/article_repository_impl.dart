import 'dart:io';

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/news_api_service.dart';
import '../../../../core/constants/constants.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;

  ArticleRepositoryImpl(this._newsApiService, this._appDatabase);

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    try {
      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final entities = httpResponse.data.articles
            .map((model) => model.toEntity())
            .toList();
        return DataSuccess(entities);
      } else {
        return DataFailed(NetworkException.fromStatusCode(
          httpResponse.response.statusCode ?? 500,
          message: httpResponse.response.statusMessage,
        ));
      }
    } on DioException catch (e) {
      return DataFailed(_mapDioException(e));
    } catch (e) {
      return DataFailed(UnknownException(originalError: e));
    }
  }
  
  /// Maps DioException to domain AppException
  AppException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException.timeout();
      case DioExceptionType.connectionError:
        return NetworkException.noConnection();
      case DioExceptionType.badResponse:
        return NetworkException.fromStatusCode(
          e.response?.statusCode ?? 500,
          message: e.message,
        );
      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'Request was cancelled',
          code: 'CANCELLED',
        );
      default:
        return NetworkException(
          message: e.message ?? 'Network error',
          originalError: e,
        );
    }
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    final models = await _appDatabase.articleDAO.getArticles();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _appDatabase.articleDAO
        .deleteArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _appDatabase.articleDAO
        .insertArticle(ArticleModel.fromEntity(article));
  }
}
