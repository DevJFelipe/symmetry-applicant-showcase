import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

/// Service for managing article reactions in Firestore.
///
/// Supports reactions on both:
/// - User-created articles (stored in 'articles' collection)
/// - External API articles (stored in 'article_reactions' collection)
///
/// Each user can only have ONE active reaction per article.
/// Changing reaction type removes the previous one.
class ReactionService {
  final FirebaseFirestore _firestore;

  /// Collection for user-created articles.
  static const String _articlesCollection = 'articles';

  /// Collection for external article reactions.
  static const String _reactionsCollection = 'article_reactions';

  ReactionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Generates a unique ID for an external article based on its URL.
  ///
  /// Uses MD5 hash of the URL to create a consistent, valid document ID.
  String _generateArticleId(String url) {
    final bytes = utf8.encode(url);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Toggles a reaction on an article.
  ///
  /// - If the user has no reaction, adds the reaction.
  /// - If the user has the SAME reaction type, removes it.
  /// - If the user has a DIFFERENT reaction type, replaces it.
  ///
  /// Returns the updated reactions data.
  Future<ServiceReactionResult> toggleReaction({
    required String? documentId,
    required String? articleUrl,
    required String userId,
    required String reactionType,
  }) async {
    // Determine if this is a Firestore article or external
    if (documentId != null && documentId.isNotEmpty) {
      return _toggleFirestoreArticleReaction(
        documentId: documentId,
        userId: userId,
        reactionType: reactionType,
      );
    } else if (articleUrl != null && articleUrl.isNotEmpty) {
      return _toggleExternalArticleReaction(
        articleUrl: articleUrl,
        userId: userId,
        reactionType: reactionType,
      );
    } else {
      throw ArgumentError('Either documentId or articleUrl must be provided');
    }
  }

  /// Toggles reaction on a user-created Firestore article.
  Future<ServiceReactionResult> _toggleFirestoreArticleReaction({
    required String documentId,
    required String userId,
    required String reactionType,
  }) async {
    return _firestore.runTransaction<ServiceReactionResult>((transaction) async {
      final docRef = _firestore.collection(_articlesCollection).doc(documentId);
      final doc = await transaction.get(docRef);

      if (!doc.exists) {
        throw ServiceReactionException(
          code: 'not-found',
          message: 'Article not found',
        );
      }

      final data = doc.data()!;
      final result = _calculateReactionUpdate(
        currentReactions: data['reactions'] as Map<String, dynamic>?,
        currentUserReactions: data['userReactions'] as Map<String, dynamic>?,
        userId: userId,
        newReactionType: reactionType,
      );

      transaction.update(docRef, {
        'reactions': result.reactions,
        'userReactions': result.userReactions,
      });

      return result;
    });
  }

  /// Toggles reaction on an external API article.
  ///
  /// Creates a document in 'article_reactions' collection if it doesn't exist.
  Future<ServiceReactionResult> _toggleExternalArticleReaction({
    required String articleUrl,
    required String userId,
    required String reactionType,
  }) async {
    final articleId = _generateArticleId(articleUrl);

    return _firestore.runTransaction<ServiceReactionResult>((transaction) async {
      final docRef = _firestore.collection(_reactionsCollection).doc(articleId);
      final doc = await transaction.get(docRef);

      Map<String, dynamic>? currentReactions;
      Map<String, dynamic>? currentUserReactions;

      if (doc.exists) {
        final data = doc.data()!;
        currentReactions = data['reactions'] as Map<String, dynamic>?;
        currentUserReactions = data['userReactions'] as Map<String, dynamic>?;
      }

      final result = _calculateReactionUpdate(
        currentReactions: currentReactions,
        currentUserReactions: currentUserReactions,
        userId: userId,
        newReactionType: reactionType,
      );

      if (doc.exists) {
        transaction.update(docRef, {
          'reactions': result.reactions,
          'userReactions': result.userReactions,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        transaction.set(docRef, {
          'articleUrl': articleUrl,
          'reactions': result.reactions,
          'userReactions': result.userReactions,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return result;
    });
  }

  /// Calculates the new reaction state after toggling.
  ///
  /// Implements single-reaction-per-user logic:
  /// - Same reaction type = remove
  /// - Different reaction type = replace (remove old, add new)
  /// - No existing reaction = add
  ServiceReactionResult _calculateReactionUpdate({
    required Map<String, dynamic>? currentReactions,
    required Map<String, dynamic>? currentUserReactions,
    required String userId,
    required String newReactionType,
  }) {
    // Initialize maps
    final reactions = Map<String, int>.from(
      currentReactions?.map((k, v) => MapEntry(k, (v as num).toInt())) ?? {},
    );
    final userReactions = Map<String, List<String>>.from(
      currentUserReactions?.map(
            (k, v) => MapEntry(k, List<String>.from(v as List)),
          ) ??
          {},
    );

    // Find user's current reaction (if any)
    String? existingReactionType;
    for (final entry in userReactions.entries) {
      if (entry.value.contains(userId)) {
        existingReactionType = entry.key;
        break;
      }
    }

    // Determine action
    if (existingReactionType == newReactionType) {
      // Same reaction - remove it (toggle off)
      _removeReaction(reactions, userReactions, userId, existingReactionType!);
      return ServiceReactionResult(
        reactions: reactions,
        userReactions: userReactions,
        action: ServiceReactionAction.removed,
        reactionType: existingReactionType,
      );
    } else if (existingReactionType != null) {
      // Different reaction - replace it
      _removeReaction(reactions, userReactions, userId, existingReactionType);
      _addReaction(reactions, userReactions, userId, newReactionType);
      return ServiceReactionResult(
        reactions: reactions,
        userReactions: userReactions,
        action: ServiceReactionAction.replaced,
        reactionType: newReactionType,
        previousReactionType: existingReactionType,
      );
    } else {
      // No existing reaction - add new one
      _addReaction(reactions, userReactions, userId, newReactionType);
      return ServiceReactionResult(
        reactions: reactions,
        userReactions: userReactions,
        action: ServiceReactionAction.added,
        reactionType: newReactionType,
      );
    }
  }

  void _removeReaction(
    Map<String, int> reactions,
    Map<String, List<String>> userReactions,
    String userId,
    String reactionType,
  ) {
    // Update count
    final currentCount = reactions[reactionType] ?? 0;
    if (currentCount <= 1) {
      reactions.remove(reactionType);
    } else {
      reactions[reactionType] = currentCount - 1;
    }

    // Remove user from list
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
    // Update count
    reactions[reactionType] = (reactions[reactionType] ?? 0) + 1;

    // Add user to list
    final users = userReactions[reactionType] ?? [];
    if (!users.contains(userId)) {
      users.add(userId);
    }
    userReactions[reactionType] = users;
  }

  /// Gets reactions for an external article by URL.
  Future<ServiceReactionData?> getExternalArticleReactions(String articleUrl) async {
    final articleId = _generateArticleId(articleUrl);
    final doc =
        await _firestore.collection(_reactionsCollection).doc(articleId).get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    return ServiceReactionData.fromMap(data);
  }

  /// Gets reactions for multiple external articles by URLs.
  ///
  /// Returns a map of URL -> ServiceReactionData for efficient batch fetching.
  Future<Map<String, ServiceReactionData>> getExternalArticlesReactions(
    List<String> articleUrls,
  ) async {
    if (articleUrls.isEmpty) return {};

    final articleIds = articleUrls.map(_generateArticleId).toList();
    final results = <String, ServiceReactionData>{};

    // Firestore 'in' queries are limited to 30 items
    const batchSize = 30;
    for (var i = 0; i < articleIds.length; i += batchSize) {
      final batchIds = articleIds.sublist(
        i,
        (i + batchSize).clamp(0, articleIds.length),
      );

      final snapshot = await _firestore
          .collection(_reactionsCollection)
          .where(FieldPath.documentId, whereIn: batchIds)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final url = data['articleUrl'] as String?;
        if (url != null) {
          results[url] = ServiceReactionData.fromMap(data);
        }
      }
    }

    return results;
  }
}

/// Result of a reaction toggle operation (service-level).
///
/// Used internally by [ReactionService]. The repository layer
/// converts this to domain entities.
class ServiceReactionResult {
  final Map<String, int> reactions;
  final Map<String, List<String>> userReactions;
  final ServiceReactionAction action;
  final String reactionType;
  final String? previousReactionType;

  const ServiceReactionResult({
    required this.reactions,
    required this.userReactions,
    required this.action,
    required this.reactionType,
    this.previousReactionType,
  });
}

/// Actions that can result from a toggle operation (service-level).
enum ServiceReactionAction { added, removed, replaced }

/// Reaction data for an article (service-level).
///
/// Used internally by [ReactionService]. The repository layer
/// converts this to domain entities.
class ServiceReactionData {
  final Map<String, int> reactions;
  final Map<String, List<String>> userReactions;

  const ServiceReactionData({
    required this.reactions,
    required this.userReactions,
  });

  factory ServiceReactionData.fromMap(Map<String, dynamic> data) {
    return ServiceReactionData(
      reactions: Map<String, int>.from(
        (data['reactions'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, (v as num).toInt()),
            ) ??
            {},
      ),
      userReactions: Map<String, List<String>>.from(
        (data['userReactions'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, List<String>.from(v as List)),
            ) ??
            {},
      ),
    );
  }
}

/// Exception for reaction operations (service-level).
class ServiceReactionException implements Exception {
  final String code;
  final String message;

  const ServiceReactionException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => message;
}
