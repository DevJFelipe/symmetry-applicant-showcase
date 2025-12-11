import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_radius.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// Error state widget with retry action
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final String? retryLabel;
  final VoidCallback? onRetry;
  
  const ErrorStateWidget({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.retryLabel,
    this.onRetry,
  });
  
  /// Factory for network error
  static Widget network({VoidCallback? onRetry}) {
    return ErrorStateWidget(
      title: 'Connection Error',
      message: 'Unable to connect to the server. Please check your internet connection.',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
    );
  }
  
  /// Factory for server error
  static Widget server({VoidCallback? onRetry}) {
    return ErrorStateWidget(
      title: 'Server Error',
      message: 'Something went wrong on our end. Please try again later.',
      icon: Icons.cloud_off_rounded,
      onRetry: onRetry,
    );
  }
  
  /// Factory for generic error
  static Widget generic({String? message, VoidCallback? onRetry}) {
    return ErrorStateWidget(
      title: 'Oops!',
      message: message ?? 'Something went wrong. Please try again.',
      onRetry: onRetry,
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
            // Error icon with pulsing animation
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.errorSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.05, 1.05),
                  duration: 1000.ms,
                ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            // Title
            Text(
              title,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms),
            
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 300.ms),
            ],
            
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              _RetryButton(
                label: retryLabel ?? 'Try Again',
                onPressed: onRetry!,
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

/// Styled retry button with icon
class _RetryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  
  const _RetryButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.refresh_rounded),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.lg,
        ),
      ),
    );
  }
}

/// Compact error message for inline display
class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  
  const ErrorMessage({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.errorLight,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDismiss,
              color: AppColors.errorLight,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: -0.2, end: 0, duration: 200.ms);
  }
}

/// Preset error states for common scenarios
class ErrorStates {
  ErrorStates._();
  
  /// Network error
  static Widget network({VoidCallback? onRetry}) {
    return ErrorStateWidget(
      title: 'Connection Error',
      message: 'Unable to connect to the server. Please check your internet connection.',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
    );
  }
  
  /// Server error
  static Widget server({VoidCallback? onRetry}) {
    return ErrorStateWidget(
      title: 'Server Error',
      message: 'Something went wrong on our end. Please try again later.',
      icon: Icons.cloud_off_rounded,
      onRetry: onRetry,
    );
  }
  
  /// Generic error
  static Widget generic({String? message, VoidCallback? onRetry}) {
    return ErrorStateWidget(
      title: 'Oops!',
      message: message ?? 'Something went wrong. Please try again.',
      onRetry: onRetry,
    );
  }
  
  /// Permission denied
  static Widget permissionDenied({VoidCallback? onRetry}) {
    return ErrorStateWidget(
      title: 'Access Denied',
      message: 'You don\'t have permission to perform this action.',
      icon: Icons.lock_outline_rounded,
      onRetry: onRetry,
    );
  }
  
  /// Not found
  static Widget notFound({VoidCallback? onGoBack}) {
    return ErrorStateWidget(
      title: 'Not Found',
      message: 'The content you\'re looking for doesn\'t exist or has been removed.',
      icon: Icons.search_off_rounded,
      retryLabel: 'Go Back',
      onRetry: onGoBack,
    );
  }
}
