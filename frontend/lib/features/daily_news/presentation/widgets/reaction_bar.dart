import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/app_radius.dart';
import 'package:news_app_clean_architecture/core/services/haptic_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// A horizontal bar showing reaction buttons with counts.
///
/// Features:
/// - Animated reaction buttons
/// - Shows user's active reactions
/// - Haptic feedback on interaction
/// - Expandable/collapsible mode
class ReactionBar extends StatefulWidget {
  /// Current reaction counts by type.
  final Map<String, int> reactions;
  
  /// Map of reaction types to list of user IDs who reacted.
  final Map<String, List<String>> userReactions;
  
  /// Current user's ID to highlight their reactions.
  final String? currentUserId;
  
  /// Callback when a reaction is toggled.
  final Function(ArticleReaction reaction, bool isActive)? onReactionToggled;
  
  /// Whether to show the bar in compact mode.
  final bool compact;

  const ReactionBar({
    super.key,
    required this.reactions,
    required this.userReactions,
    this.currentUserId,
    this.onReactionToggled,
    this.compact = false,
  });

  @override
  State<ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends State<ReactionBar> {
  final Set<ArticleReaction> _animatingReactions = {};

  /// Finds the user's current active reaction (if any).
  /// Each user can only have ONE active reaction.
  ArticleReaction? _getUserActiveReaction() {
    if (widget.currentUserId == null) return null;
    
    for (final reaction in ArticleReaction.values) {
      final users = widget.userReactions[reaction.name] ?? [];
      if (users.contains(widget.currentUserId)) {
        return reaction;
      }
    }
    return null;
  }

  bool _hasUserReacted(ArticleReaction reaction) {
    if (widget.currentUserId == null) return false;
    final users = widget.userReactions[reaction.name] ?? [];
    return users.contains(widget.currentUserId);
  }

  int _getCount(ArticleReaction reaction) {
    return widget.reactions[reaction.name] ?? 0;
  }

  void _onReactionTap(ArticleReaction reaction) {
    final isActive = _hasUserReacted(reaction);
    
    // Trigger animation
    setState(() {
      _animatingReactions.add(reaction);
    });
    
    // Haptic feedback
    HapticService.reaction();
    
    // Callback - the cubit handles single-reaction logic
    widget.onReactionToggled?.call(reaction, !isActive);
    
    // Remove animation state after delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _animatingReactions.remove(reaction);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactBar();
    }
    return _buildFullBar();
  }

  Widget _buildFullBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ArticleReaction.values.map((reaction) {
          return _buildReactionButton(reaction);
        }).toList(),
      ),
    );
  }

  Widget _buildCompactBar() {
    // Only show reactions that have counts > 0 or user's active reactions
    final activeReactions = ArticleReaction.values.where((r) {
      return _getCount(r) > 0 || _hasUserReacted(r);
    }).toList();

    if (activeReactions.isEmpty) {
      // Show just the most common reactions for adding
      return Row(
        children: [
          _buildCompactButton(ArticleReaction.fire),
          SizedBox(width: AppSpacing.xs),
          _buildCompactButton(ArticleReaction.love),
          SizedBox(width: AppSpacing.xs),
          _buildCompactButton(ArticleReaction.clap),
        ],
      );
    }

    return Row(
      children: activeReactions.take(4).map((reaction) {
        return Padding(
          padding: EdgeInsets.only(right: AppSpacing.xs),
          child: _buildCompactButton(reaction),
        );
      }).toList(),
    );
  }

  Widget _buildReactionButton(ArticleReaction reaction) {
    final isActive = _hasUserReacted(reaction);
    final count = _getCount(reaction);
    final isAnimating = _animatingReactions.contains(reaction);

    return GestureDetector(
      onTap: () => _onReactionTap(reaction),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isActive 
              ? _getReactionColor(reaction).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: isActive 
              ? Border.all(
                  color: _getReactionColor(reaction).withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji with animation
            _buildAnimatedEmoji(reaction, isAnimating),
            
            SizedBox(height: AppSpacing.xxs),
            
            // Count
            Text(
              count > 0 ? _formatCount(count) : '0',
              style: AppTypography.labelSmall.copyWith(
                color: isActive 
                    ? _getReactionColor(reaction)
                    : AppColors.textMuted,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactButton(ArticleReaction reaction) {
    final isActive = _hasUserReacted(reaction);
    final count = _getCount(reaction);
    final isAnimating = _animatingReactions.contains(reaction);

    return GestureDetector(
      onTap: () => _onReactionTap(reaction),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: isActive 
              ? _getReactionColor(reaction).withValues(alpha: 0.15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isActive 
                ? _getReactionColor(reaction).withValues(alpha: 0.3)
                : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnimatedEmoji(reaction, isAnimating, size: 16),
            if (count > 0) ...[
              SizedBox(width: AppSpacing.xxs),
              Text(
                _formatCount(count),
                style: AppTypography.labelSmall.copyWith(
                  color: isActive 
                      ? _getReactionColor(reaction)
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedEmoji(
    ArticleReaction reaction, 
    bool isAnimating, {
    double size = 24,
  }) {
    Widget emoji = Text(
      _getEmoji(reaction),
      style: TextStyle(fontSize: size),
    );

    if (isAnimating) {
      return emoji
          .animate()
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.5, 1.5),
            duration: 150.ms,
          )
          .then()
          .scale(
            begin: const Offset(1.5, 1.5),
            end: const Offset(1, 1),
            duration: 150.ms,
          );
    }

    return emoji;
  }

  String _getEmoji(ArticleReaction reaction) {
    return reaction.emoji;
  }

  Color _getReactionColor(ArticleReaction reaction) {
    switch (reaction) {
      case ArticleReaction.fire:
        return AppColors.reactionFire;
      case ArticleReaction.love:
        return AppColors.reactionLove;
      case ArticleReaction.thinking:
        return AppColors.reactionThinking;
      case ArticleReaction.sad:
        return AppColors.reactionSad;
      case ArticleReaction.clap:
        return AppColors.reactionClap;
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

/// A floating reaction picker that pops up on long press.
///
/// Shows all reactions in a horizontal pill for quick selection.
class ReactionPicker extends StatelessWidget {
  final Function(ArticleReaction)? onReactionSelected;

  const ReactionPicker({
    super.key,
    this.onReactionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ArticleReaction.values.asMap().entries.map((entry) {
          final index = entry.key;
          final reaction = entry.value;
          
          return _ReactionPickerItem(
            reaction: reaction,
            index: index,
            onTap: () {
              HapticService.reaction();
              onReactionSelected?.call(reaction);
            },
          );
        }).toList(),
      ),
    )
    .animate()
    .fadeIn(duration: 200.ms)
    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 200.ms);
  }
}

class _ReactionPickerItem extends StatefulWidget {
  final ArticleReaction reaction;
  final int index;
  final VoidCallback? onTap;

  const _ReactionPickerItem({
    required this.reaction,
    required this.index,
    this.onTap,
  });

  @override
  State<_ReactionPickerItem> createState() => _ReactionPickerItemState();
}

class _ReactionPickerItemState extends State<_ReactionPickerItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) {
        setState(() => _isHovered = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isHovered ? 1.3 : 1.0),
        transformAlignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Text(
          _getEmoji(widget.reaction),
          style: const TextStyle(fontSize: 28),
        ),
      ),
    )
    .animate(delay: Duration(milliseconds: widget.index * 50))
    .fadeIn(duration: 150.ms)
    .slideY(begin: 0.5, end: 0, duration: 200.ms);
  }

  String _getEmoji(ArticleReaction reaction) {
    return reaction.emoji;
  }
}
