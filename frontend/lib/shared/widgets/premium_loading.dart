import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';

/// Premium loading indicator with animated logo
class PremiumLoading extends StatelessWidget {
  final double size;
  final Color? color;
  
  const PremiumLoading({
    super.key,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAnimatedLogo(),
        const SizedBox(height: 24),
        _buildLoadingDots(),
      ],
    );
  }
  
  Widget _buildAnimatedLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(
        Icons.article_outlined,
        color: Colors.white,
        size: size * 0.6,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 800.ms,
        )
        .then()
        .scale(
          begin: const Offset(1.1, 1.1),
          end: const Offset(1, 1),
          duration: 800.ms,
        );
  }
  
  Widget _buildLoadingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color ?? AppColors.primary,
            shape: BoxShape.circle,
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(),
              delay: Duration(milliseconds: index * 200),
            )
            .fadeIn(duration: 300.ms)
            .then()
            .fadeOut(duration: 300.ms);
      }),
    );
  }
}

/// Compact loading spinner for inline use
class PremiumSpinner extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  
  const PremiumSpinner({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
      ),
    );
  }
}

/// Full screen loading overlay with blur effect
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: AppColors.scrim,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PremiumLoading(),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 200.ms),
          ),
      ],
    );
  }
}
