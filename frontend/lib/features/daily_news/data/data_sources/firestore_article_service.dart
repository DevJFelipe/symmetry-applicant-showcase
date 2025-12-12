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
    final doc =
        await _firestore.collection(_articlesCollection).doc(articleId).get();

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
    await _firestore.collection(_articlesCollection).doc(articleId).delete();

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

  /// Updates specific fields of an article.
  ///
  /// Only updates the provided non-null fields.
  Future<void> updateArticleFields({
    required String articleId,
    String? title,
    String? description,
    String? content,
    String? urlToImage,
  }) async {
    final Map<String, dynamic> updates = {};

    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (content != null) updates['content'] = content;
    if (urlToImage != null) updates['urlToImage'] = urlToImage;

    if (updates.isEmpty) return;

    await _firestore
        .collection(_articlesCollection)
        .doc(articleId)
        .update(updates);
  }

  /// Toggles a reaction on an article for a specific user.
  ///
  /// If the user hasn't reacted with this type, adds the reaction.
  /// If the user has already reacted with this type, removes it.
  /// Returns the updated article.
  Future<FirestoreArticleModel> toggleReaction({
    required String articleId,
    required String userId,
    required String reactionType,
  }) async {
    return _firestore
        .runTransaction<FirestoreArticleModel>((transaction) async {
      final docRef = _firestore.collection(_articlesCollection).doc(articleId);
      final doc = await transaction.get(docRef);

      if (!doc.exists) {
        throw FirestoreException(
          code: 'not-found',
          message: 'Article not found',
        );
      }

      final data = doc.data()!;

      // Get current reactions map or create empty one
      final Map<String, int> reactions = Map<String, int>.from(
        data['reactions'] as Map<String, dynamic>? ?? {},
      );

      // Get current userReactions map or create empty one
      final Map<String, List<dynamic>> userReactions =
          Map<String, List<dynamic>>.from(
        data['userReactions'] as Map<String, dynamic>? ?? {},
      );

      // Get the list of users who have this reaction
      final List<String> usersWithReaction = List<String>.from(
        userReactions[reactionType] ?? [],
      );

      final bool hasReacted = usersWithReaction.contains(userId);

      if (hasReacted) {
        // Remove the reaction
        usersWithReaction.remove(userId);
        reactions[reactionType] = (reactions[reactionType] ?? 1) - 1;

        // Remove the reaction type if count is 0
        if (reactions[reactionType] == 0) {
          reactions.remove(reactionType);
        }
      } else {
        // Add the reaction
        usersWithReaction.add(userId);
        reactions[reactionType] = (reactions[reactionType] ?? 0) + 1;
      }

      // Update the userReactions map
      if (usersWithReaction.isEmpty) {
        userReactions.remove(reactionType);
      } else {
        userReactions[reactionType] = usersWithReaction;
      }

      // Update the document
      transaction.update(docRef, {
        'reactions': reactions,
        'userReactions': userReactions,
      });

      // Get the updated document and return
      final updatedDoc = await docRef.get();
      return FirestoreArticleModel.fromFirestore(updatedDoc);
    });
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
