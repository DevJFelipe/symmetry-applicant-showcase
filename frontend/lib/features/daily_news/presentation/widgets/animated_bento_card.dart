import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/app_radius.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// Enum for different bento card sizes
enum BentoCardSize {
  /// Large card spanning full width - for featured articles
  large,
  /// Medium card - standard size
  medium,
  /// Small card - compact view
  small,
}

/// Premium animated bento card for articles.
///
/// Features:
/// - Animated entrance with stagger
/// - Parallax image effect on scroll
/// - Glassmorphism overlay
/// - Reaction badges
/// - Touch feedback animations
class AnimatedBentoCard extends StatefulWidget {
  final ArticleEntity article;
  final BentoCardSize size;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? currentUserId;

  const AnimatedBentoCard({
    super.key,
    required this.article,
    required this.size,
    this.index = 0,
    this.onTap,
    this.onLongPress,
    this.currentUserId,
  });

  @override
  State<AnimatedBentoCard> createState() => _AnimatedBentoCardState();
}

class _AnimatedBentoCardState extends State<AnimatedBentoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    _scaleController.reverse();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    _scaleController.forward();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final height = _getHeight();
    
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleController.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.size == BentoCardSize.large 
                  ? AppRadius.xl 
                  : AppRadius.lg,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowDark,
                blurRadius: _isPressed ? 8 : 16,
                offset: Offset(0, _isPressed ? 4 : 8),
              ),
              if (widget.article.totalReactions > 10)
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              widget.size == BentoCardSize.large 
                  ? AppRadius.xl 
                  : AppRadius.lg,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image with parallax
                _buildImage(),
                
                // Gradient overlay
                _buildGradientOverlay(),
                
                // Content
                _buildContent(),
                
                // Reaction badges (top right)
                if (widget.article.totalReactions > 0)
                  _buildReactionBadge(),
                
                // Own article badge
                if (widget.currentUserId != null && 
                    widget.article.isOwnedBy(widget.currentUserId!))
                  _buildOwnBadge(),
              ],
            ),
          ),
        ),
      ),
    )
    .animate(delay: Duration(milliseconds: 50 * widget.index))
    .fadeIn(duration: 400.ms, curve: Curves.easeOut)
    .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  double _getHeight() {
    switch (widget.size) {
      case BentoCardSize.large:
        return AppSpacing.bentoLargeHeight;
      case BentoCardSize.medium:
        return AppSpacing.bentoMediumHeight;
      case BentoCardSize.small:
        return AppSpacing.bentoSmallHeight;
    }
  }

  Widget _buildImage() {
    final imageUrl = widget.article.urlToImage;
    
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: AppColors.surfaceLight,
        child: Center(
          child: Icon(
            Icons.article_outlined,
            size: 48,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.surfaceLight,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.surfaceLight,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            AppColors.background.withValues(alpha: 0.3),
            AppColors.background.withValues(alpha: 0.8),
            AppColors.background.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final isLarge = widget.size == BentoCardSize.large;
    
    return Padding(
      padding: EdgeInsets.all(isLarge ? AppSpacing.lg : AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category tag
          _buildCategoryTag(),
          
          SizedBox(height: AppSpacing.sm),
          
          // Title
          Text(
            widget.article.title ?? 'Untitled',
            style: isLarge 
                ? AppTypography.headlineMedium 
                : AppTypography.titleMedium,
            maxLines: isLarge ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          if (widget.size != BentoCardSize.small) ...[
            SizedBox(height: AppSpacing.xs),
            
            // Description (only for large and medium)
            Text(
              widget.article.description ?? '',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: isLarge ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          SizedBox(height: AppSpacing.sm),
          
          // Meta row
          _buildMetaRow(),
        ],
      ),
    );
  }

  Widget _buildCategoryTag() {
    // Use source as category for now
    final category = widget.article.source?.name ?? 'Article';
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        category.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMetaRow() {
    final author = widget.article.author ?? 'Anonymous';
    final date = _formatDate(widget.article.publishedAt);
    
    return Row(
      children: [
        // Author avatar
        CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.accent.withValues(alpha: 0.2),
          child: Text(
            author.isNotEmpty ? author[0].toUpperCase() : 'A',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        SizedBox(width: AppSpacing.xs),
        
        // Author name
        Expanded(
          child: Text(
            author,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Date
        Text(
          date,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildReactionBadge() {
    final reactions = widget.article.reactions;
    final total = widget.article.totalReactions;
    
    // Get the most popular reaction
    String? topReaction;
    int topCount = 0;
    reactions?.forEach((key, value) {
      if (value > topCount) {
        topCount = value;
        topReaction = key;
      }
    });
    
    return Positioned(
      top: AppSpacing.md,
      right: AppSpacing.md,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (topReaction != null)
              Text(
                _getReactionEmoji(topReaction!),
                style: const TextStyle(fontSize: 14),
              ),
            SizedBox(width: AppSpacing.xxs),
            Text(
              _formatCount(total),
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnBadge() {
    return Positioned(
      top: AppSpacing.md,
      left: AppSpacing.md,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_outlined,
              size: 12,
              color: Colors.white,
            ),
            SizedBox(width: AppSpacing.xxs),
            Text(
              'YOUR ARTICLE',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReactionEmoji(String reaction) {
    switch (reaction) {
      case 'like':
        return '👍';
      case 'love':
        return '❤️';
      case 'fire':
        return '🔥';
      case 'mindBlown':
        return '🤯';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      default:
        return '👍';
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (_) {
      return '';
    }
  }
}
