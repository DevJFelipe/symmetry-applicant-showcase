import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/firestore_article_model.dart';

/// Data source for Firestore article operations.
///
/// Handles CRUD operations for articles stored in Firebase Cloud Firestore
/// and image uploads to Firebase Cloud Storage.
class FirestoreArticleService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  /// Collection reference for articles.
  static const String _articlesCollection = 'articles';

  /// Storage path for article thumbnails.
  static const String _thumbnailsPath = 'thumbnails';

  FirestoreArticleService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Fetches all articles ordered by publication date (newest first).
  Future<List<FirestoreArticleModel>> getArticles() async {
    final snapshot = await _firestore
        .collection(_articlesCollection)
        .orderBy('publishedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FirestoreArticleModel.fromFirestore(doc))
        .toList();
  }

  /// Fetches articles created by a specific user.
  Future<List<FirestoreArticleModel>> getArticlesByUser(String userId) async {
    final snapshot = await _firestore
        .collection(_articlesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('publishedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FirestoreArticleModel.fromFirestore(doc))
        .toList();
  }

  /// Fetches a single article by its document ID.
  Future<FirestoreArticleModel?> getArticleById(String articleId) async {
    final doc = await _firestore
        .collection(_articlesCollection)
        .doc(articleId)
        .get();

    if (!doc.exists) return null;
    return FirestoreArticleModel.fromFirestore(doc);
  }

  /// Creates a new article in Firestore.
  ///
  /// Returns the created article with its generated document ID.
  Future<FirestoreArticleModel> createArticle(
    FirestoreArticleModel article,
  ) async {
    final docRef = await _firestore
        .collection(_articlesCollection)
        .add(article.toFirestore());

    final createdDoc = await docRef.get();
    return FirestoreArticleModel.fromFirestore(createdDoc);
  }

  /// Updates an existing article in Firestore.
  ///
  /// Throws [FirestoreException] if the article doesn't exist.
  Future<void> updateArticle(
    String articleId,
    FirestoreArticleModel article,
  ) async {
    await _firestore
        .collection(_articlesCollection)
        .doc(articleId)
        .update(article.toFirestore());
  }

  /// Deletes an article from Firestore.
  ///
  /// Also deletes the associated thumbnail from Cloud Storage if it exists.
  Future<void> deleteArticle(String articleId, String? imageUrl) async {
    // Delete the article document
    await _firestore
        .collection(_articlesCollection)
        .doc(articleId)
        .delete();

    // Delete the associated image if it exists in our storage
    if (imageUrl != null && imageUrl.contains('firebase')) {
      try {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      } catch (e) {
        // Log error but don't fail the deletion
        // Image might have been already deleted or URL is external
      }
    }
  }

  /// Uploads an image file to Cloud Storage.
  ///
  /// Returns the download URL for the uploaded image.
  Future<String> uploadThumbnail({
    required File imageFile,
    required String userId,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = imageFile.path.split('.').last;
    final fileName = '${userId}_$timestamp.$extension';
    final ref = _storage.ref().child(_thumbnailsPath).child(fileName);

    // Set metadata for the upload
    final metadata = SettableMetadata(
      contentType: 'image/$extension',
      customMetadata: {
        'uploadedBy': userId,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );

    // Upload the file
    final uploadTask = await ref.putFile(imageFile, metadata);

    // Get and return the download URL
    return await uploadTask.ref.getDownloadURL();
  }

  /// Deletes a thumbnail from Cloud Storage by its URL.
  Future<void> deleteThumbnail(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Image might not exist or URL is external
      rethrow;
    }
  }
}

/// Exception class for Firestore operations.
class FirestoreException implements Exception {
  final String code;
  final String message;

  const FirestoreException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => message;
}
