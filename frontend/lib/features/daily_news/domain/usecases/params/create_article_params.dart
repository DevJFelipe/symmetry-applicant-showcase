import 'dart:io';

/// Parameters for creating a new article.
///
/// Contains all the data needed to create an article in Firestore,
/// including the image file for the thumbnail.
class CreateArticleParams {
  /// The article title.
  final String title;

  /// Brief description for the feed.
  final String description;

  /// Full article content.
  final String content;

  /// The image file for the article thumbnail.
  final File thumbnailFile;

  /// Optional external URL for the article.
  final String? url;

  const CreateArticleParams({
    required this.title,
    required this.description,
    required this.content,
    required this.thumbnailFile,
    this.url,
  });
}
