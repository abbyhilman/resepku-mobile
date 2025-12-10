import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Global shimmer colors - more grey tones
class ShimmerColors {
  static const Color baseColor = Color(0xFFE0E0E0);
  static const Color highlightColor = Color(0xFFF5F5F5);
}

/// Base shimmer wrapper widget
class ShimmerWrapper extends StatelessWidget {
  final Widget child;

  const ShimmerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ShimmerColors.baseColor,
      highlightColor: ShimmerColors.highlightColor,
      child: child,
    );
  }
}

/// Shimmer container for placeholder items
class ShimmerBox extends StatelessWidget {
  final double? height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    this.height,
    this.width,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer loading for recipe card (used in lists)
class ShimmerRecipeCard extends StatelessWidget {
  const ShimmerRecipeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 120,
        decoration: BoxDecoration(
          color: ShimmerColors.baseColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Image placeholder
            Container(
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 16),
            // Content placeholder
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title placeholder
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle placeholder
                    Container(
                      height: 12,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const Spacer(),
                    // Rating placeholder
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading list for recipe cards
class ShimmerRecipeList extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? padding;

  const ShimmerRecipeList({super.key, this.itemCount = 4, this.padding});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerRecipeCard(),
    );
  }
}

/// Shimmer loading for recipe detail screen
class ShimmerRecipeDetail extends StatelessWidget {
  const ShimmerRecipeDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(height: 280, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  const ShimmerBox(height: 28, width: double.infinity),
                  const SizedBox(height: 12),
                  // Info chips placeholder
                  Row(
                    children: const [
                      ShimmerBox(height: 36, width: 100, borderRadius: 10),
                      SizedBox(width: 12),
                      ShimmerBox(height: 36, width: 60, borderRadius: 10),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Description placeholder
                  const ShimmerBox(
                    height: 16,
                    width: double.infinity,
                    borderRadius: 6,
                  ),
                  const SizedBox(height: 8),
                  const ShimmerBox(height: 16, width: 250, borderRadius: 6),
                  const SizedBox(height: 24),
                  // Section title placeholder
                  Row(
                    children: const [
                      ShimmerBox(height: 36, width: 36, borderRadius: 10),
                      SizedBox(width: 12),
                      ShimmerBox(height: 20, width: 120, borderRadius: 6),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Ingredient placeholders
                  ...List.generate(
                    4,
                    (index) => const ShimmerBox(
                      height: 48,
                      width: double.infinity,
                      borderRadius: 12,
                      margin: EdgeInsets.only(bottom: 8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Steps section title placeholder
                  Row(
                    children: const [
                      ShimmerBox(height: 36, width: 36, borderRadius: 10),
                      SizedBox(width: 12),
                      ShimmerBox(height: 20, width: 140, borderRadius: 6),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Step placeholders
                  ...List.generate(
                    3,
                    (index) => const ShimmerBox(
                      height: 80,
                      width: double.infinity,
                      borderRadius: 16,
                      margin: EdgeInsets.only(bottom: 12),
                    ),
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
