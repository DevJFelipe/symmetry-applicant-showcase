import 'package:equatable/equatable.dart';

/// Result of a reaction toggle operation.
///
/// Contains the updated reaction state after toggling a user's reaction
/// on an article. Used for optimistic UI updates and server confirmation.
class ReactionResult extends Equatable {
  /// Map of reaction type to count.
  final Map<String, int> reactions;

  /// Map of reaction type to list of user IDs.
  final Map<String, List<String>> userReactions;

  /// The action that was performed.
  final ReactionAction action;

  /// The reaction type that was toggled.
  final String reactionType;

  /// The previous reaction type (if replaced).
  final String? previousReactionType;

  const ReactionResult({
    required this.reactions,
    required this.userReactions,
    required this.action,
    required this.reactionType,
    this.previousReactionType,
  });

  @override
  List<Object?> get props => [
        reactions,
        userReactions,
        action,
        reactionType,
        previousReactionType,
      ];
}

/// Actions that can result from a toggle operation.
enum ReactionAction {
  /// A new reaction was added.
  added,

  /// An existing reaction was removed.
  removed,

  /// An existing reaction was replaced with a different type.
  replaced,
}

/// Reaction data for an article.
///
/// Represents the current reaction state of an article,
/// including counts and user tracking.
class ReactionData extends Equatable {
  /// Map of reaction type to count.
  final Map<String, int> reactions;

  /// Map of reaction type to list of user IDs.
  final Map<String, List<String>> userReactions;

  const ReactionData({
    required this.reactions,
    required this.userReactions,
  });

  /// Creates empty reaction data.
  const ReactionData.empty()
      : reactions = const {},
        userReactions = const {};

  /// Creates ReactionData from a Firestore document map.
  factory ReactionData.fromMap(Map<String, dynamic> data) {
    return ReactionData(
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

  @override
  List<Object?> get props => [reactions, userReactions];
}

/// Exception for reaction operations.
///
/// Thrown when a reaction operation fails, such as when
/// the article is not found or the user is not authenticated.
class ReactionException implements Exception {
  /// Error code for programmatic handling.
  final String code;

  /// Human-readable error message.
  final String message;

  const ReactionException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'ReactionException($code): $message';
}
