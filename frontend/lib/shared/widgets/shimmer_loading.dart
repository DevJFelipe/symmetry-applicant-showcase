import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_radius.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';

/// Shimmer effect wrapper for loading states
class ShimmerWidget extends StatelessWidget {
  final Widget child;
  
  const ShimmerWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: child,
    );
  }
}

/// Shimmer placeholder box
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  
  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: borderRadius ?? AppRadius.borderSm,
      ),
    );
  }
}

/// Shimmer skeleton for Bento card - Large (Featured)
class ShimmerBentoCardLarge extends StatelessWidget {
  const ShimmerBentoCardLarge({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        height: AppSpacing.bentoLargeHeight,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: AppRadius.bentoCard,
        ),
        child: Stack(
          children: [
            // Image placeholder
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: AppRadius.bentoCard,
                ),
              ),
            ),
            // Content overlay
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag
                  ShimmerBox(
                    width: 60,
                    height: 20,
                    borderRadius: AppRadius.chip,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Title
                  const ShimmerBox(
                    height: 24,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ShimmerBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 24,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Metadata row
                  Row(
                    children: [
                      const ShimmerBox(
                        width: 24,
                        height: 24,
                        borderRadius: AppRadius.avatar,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ShimmerBox(
                        width: 80,
                        height: 14,
                        borderRadius: AppRadius.borderXs,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      ShimmerBox(
                        width: 60,
                        height: 14,
                        borderRadius: AppRadius.borderXs,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for Bento card - Small
class ShimmerBentoCardSmall extends StatelessWidget {
  const ShimmerBentoCardSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        height: AppSpacing.bentoSmallHeight,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: AppRadius.bentoCard,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: AppRadius.bentoCard,
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ShimmerBox(
                    height: 16,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ShimmerBox(
                    width: 80,
                    height: 12,
                    borderRadius: AppRadius.borderXs,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for the entire Bento Grid feed
class ShimmerBentoGrid extends StatelessWidget {
  final int itemCount;
  
  const ShimmerBentoGrid({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        if (index % 3 == 0) {
          // Large card
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.bentoGap),
            child: const ShimmerBentoCardLarge(),
          );
        } else if (index % 3 == 1) {
          // Row of two small cards
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.bentoGap),
            child: Row(
              children: [
                const Expanded(child: ShimmerBentoCardSmall()),
                const SizedBox(width: AppSpacing.bentoGap),
                const Expanded(child: ShimmerBentoCardSmall()),
              ],
            ),
          );
        } else {
          // Medium card
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.bentoGap),
            child: const ShimmerBentoCardLarge(),
          );
        }
      }),
    );
  }
}

/// Shimmer skeleton for article detail page
class ShimmerArticleDetail extends StatelessWidget {
  const ShimmerArticleDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            ShimmerBox(
              width: double.infinity,
              height: 300,
              borderRadius: BorderRadius.zero,
            ),
            Padding(
              padding: AppSpacing.page,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  ShimmerBox(
                    width: 80,
                    height: 24,
                    borderRadius: AppRadius.chip,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Title
                  const ShimmerBox(height: 32),
                  const SizedBox(height: AppSpacing.sm),
                  ShimmerBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 32,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Author info
                  Row(
                    children: [
                      const ShimmerBox(
                        width: 48,
                        height: 48,
                        borderRadius: AppRadius.avatar,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(
                            width: 120,
                            height: 16,
                            borderRadius: AppRadius.borderXs,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          ShimmerBox(
                            width: 80,
                            height: 12,
                            borderRadius: AppRadius.borderXs,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  // Content paragraphs
                  ...List.generate(5, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ShimmerBox(
                      height: 16,
                      borderRadius: AppRadius.borderXs,
                    ),
                  )),
                  ShimmerBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 16,
                    borderRadius: AppRadius.borderXs,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for list item (horizontal card)
class ShimmerListItem extends StatelessWidget {
  const ShimmerListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            ShimmerBox(
              width: 100,
              height: 80,
              borderRadius: AppRadius.borderMd,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(
                    height: 16,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ShimmerBox(
                    width: 150,
                    height: 14,
                    borderRadius: AppRadius.borderXs,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ShimmerBox(
                    width: 80,
                    height: 12,
                    borderRadius: AppRadius.borderXs,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
