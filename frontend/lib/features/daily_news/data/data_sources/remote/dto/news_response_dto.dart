import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

/// DTO para deserializar la respuesta de la API de NewsAPI.
///
/// Este objeto solo existe para parsear la estructura de respuesta
/// de la API que contiene status, totalResults y articles.
/// No es un modelo de negocio.
class NewsResponseDto {
  final String status;
  final int totalResults;
  final List<ArticleModel> articles;

  const NewsResponseDto({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsResponseDto.fromJson(Map<String, dynamic> json) {
    return NewsResponseDto(
      status: json['status'] ?? '',
      totalResults: json['totalResults'] ?? 0,
      articles: (json['articles'] as List<dynamic>?)
              ?.map((article) =>
                  ArticleModel.fromJson(article as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
