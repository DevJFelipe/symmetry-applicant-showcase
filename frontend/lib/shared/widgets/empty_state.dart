import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// Empty state widget with illustration and action
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? message; // Alias for subtitle
  final String? actionLabel;
  final VoidCallback? onAction;
  
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.message,
    this.actionLabel,
    this.onAction,
  });
  
  String? get _displayMessage => subtitle ?? message;
  
  /// Factory for no articles state
  static Widget noArticles({VoidCallback? onAction}) {
    return EmptyStateWidget(
      icon: Icons.article_outlined,
      title: 'No articles yet',
      message: 'Check back later for the latest news',
      actionLabel: onAction != null ? 'Create Article' : null,
      onAction: onAction,
    );
  }
  
  /// Factory for no saved articles state
  static Widget noSavedArticles({VoidCallback? onBrowse}) {
    return EmptyStateWidget(
      icon: Icons.bookmark_border_rounded,
      title: 'No saved articles',
      message: 'Articles you save will appear here',
      actionLabel: onBrowse != null ? 'Browse Articles' : null,
      onAction: onBrowse,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with gradient background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.primaryDark.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: AppColors.primary,
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            // Title
            Text(
              title,
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.2, end: 0, duration: 300.ms),
            
            if (_displayMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _displayMessage!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 300.ms)
                  .slideY(begin: 0.2, end: 0, duration: 300.ms),
            ],
            
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 300.ms)
                  .slideY(begin: 0.2, end: 0, duration: 300.ms),
            ],
          ],
        ),
      ),
    );
  }
}

/// Preset empty states for common scenarios
class EmptyStates {
  EmptyStates._();
  
  /// No articles found
  static Widget noArticles({VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      icon: Icons.article_outlined,
      title: 'No articles yet',
      subtitle: 'Check back later for the latest news',
      actionLabel: onRefresh != null ? 'Refresh' : null,
      onAction: onRefresh,
    );
  }
  
  /// No saved articles
  static Widget noSavedArticles({VoidCallback? onBrowse}) {
    return EmptyStateWidget(
      icon: Icons.bookmark_border_rounded,
      title: 'No saved articles',
      subtitle: 'Articles you save will appear here',
      actionLabel: onBrowse != null ? 'Browse Articles' : null,
      onAction: onBrowse,
    );
  }
  
  /// No user articles
  static Widget noUserArticles({VoidCallback? onCreate}) {
    return EmptyStateWidget(
      icon: Icons.edit_note_rounded,
      title: 'No articles published',
      subtitle: 'Share your thoughts with the world',
      actionLabel: onCreate != null ? 'Create Article' : null,
      onAction: onCreate,
    );
  }
  
  /// No search results
  static Widget noSearchResults({String? query, VoidCallback? onClear}) {
    return EmptyStateWidget(
      icon: Icons.search_off_rounded,
      title: 'No results found',
      subtitle: query != null 
          ? 'No articles match "$query"' 
          : 'Try a different search term',
      actionLabel: onClear != null ? 'Clear Search' : null,
      onAction: onClear,
    );
  }
  
  /// Network/connection issue
  static Widget noConnection({VoidCallback? onRetry}) {
    return EmptyStateWidget(
      icon: Icons.wifi_off_rounded,
      title: 'No connection',
      subtitle: 'Check your internet and try again',
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }
}
