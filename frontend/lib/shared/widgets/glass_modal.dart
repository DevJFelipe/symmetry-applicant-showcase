import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_radius.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/core/services/haptic_service.dart';

/// Glassmorphism modal dialog with blur effect
/// Used for "Peek & Pop" interactions and confirmation dialogs
class GlassModal extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final VoidCallback? onDismiss;
  final double blurAmount;

  const GlassModal({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.onDismiss,
    this.blurAmount = 15,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Blurred background
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurAmount,
                  sigmaY: blurAmount,
                ),
                child: Container(
                  color: AppColors.scrim,
                ),
              ),
            ),
            // Content
            Center(
              child: GestureDetector(
                onTap: () {}, // Prevent dismissal when tapping content
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.xxl),
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    gradient: AppColors.glassGradient,
                    borderRadius: AppRadius.modal,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: AppRadius.modal,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        color: AppColors.surface.withValues(alpha: 0.7),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (title != null) ...[
                              Text(
                                title!,
                                style: AppTypography.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                            child,
                            if (actions != null && actions!.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xxl),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: actions!
                                    .map((action) => Padding(
                                          padding: const EdgeInsets.only(
                                            left: AppSpacing.sm,
                                          ),
                                          child: action,
                                        ))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 200.ms).scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 200.ms,
                      curve: Curves.easeOutBack,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show the glass modal as an overlay
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    HapticService.lightImpact();
    return showDialog<T>(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: barrierDismissible,
      builder: (context) => GlassModal(
        title: title,
        actions: actions,
        onDismiss:
            barrierDismissible ? () => Navigator.of(context).pop() : null,
        child: child,
      ),
    );
  }
}

/// Article preview modal for "Peek & Pop" interaction
class ArticlePreviewModal extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final String? author;
  final String? date;
  final VoidCallback onReadMore;
  final VoidCallback? onDismiss;

  const ArticlePreviewModal({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    this.author,
    this.date,
    required this.onReadMore,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GlassModal(
      onDismiss: onDismiss,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview
          if (imageUrl != null)
            ClipRRect(
              borderRadius: AppRadius.borderMd,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppColors.textTertiary,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 200.ms),

          const SizedBox(height: AppSpacing.lg),

          // Title
          Text(
            title,
            style: AppTypography.headlineSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ).animate().fadeIn(delay: 150.ms, duration: 200.ms),

          const SizedBox(height: AppSpacing.sm),

          // Metadata
          if (author != null || date != null)
            Row(
              children: [
                if (author != null) ...[
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    author!,
                    style: AppTypography.caption,
                  ),
                ],
                if (author != null && date != null)
                  const SizedBox(width: AppSpacing.md),
                if (date != null) ...[
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    date!,
                    style: AppTypography.caption,
                  ),
                ],
              ],
            ).animate().fadeIn(delay: 200.ms, duration: 200.ms),

          const SizedBox(height: AppSpacing.md),

          // Description
          Text(
            description,
            style: AppTypography.bodySmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ).animate().fadeIn(delay: 250.ms, duration: 200.ms),

          const SizedBox(height: AppSpacing.xl),

          // Read more button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticService.mediumImpact();
                onReadMore();
              },
              child: const Text('Read Full Article'),
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 200.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  /// Show article preview modal
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String description,
    String? imageUrl,
    String? author,
    String? date,
    required VoidCallback onReadMore,
  }) {
    HapticService.longPress();
    return showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => ArticlePreviewModal(
        title: title,
        description: description,
        imageUrl: imageUrl,
        author: author,
        date: date,
        onReadMore: () {
          Navigator.of(context).pop();
          onReadMore();
        },
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// Confirmation dialog with glass effect
class ConfirmationModal extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isDanger;

  const ConfirmationModal({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    required this.onConfirm,
    required this.onCancel,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassModal(
      title: title,
      onDismiss: onCancel,
      child: Column(
        children: [
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticService.lightImpact();
                    onCancel();
                  },
                  child: Text(cancelLabel),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticService.mediumImpact();
                    onConfirm();
                  },
                  style: isDanger
                      ? ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        )
                      : null,
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDanger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => ConfirmationModal(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDanger: isDanger,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    return result ?? false;
  }
}
