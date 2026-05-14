import 'package:flutter/material.dart';
import 'package:lume/core/constants/app_colors.dart';

/// A shimmer loading skeleton for book cards.
///
/// Displays while book data is being fetched, providing
/// a polished loading experience instead of a spinner.
class ShimmerLoading extends StatefulWidget {
  final int itemCount;

  const ShimmerLoading({super.key, this.itemCount = 5});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) => _buildShimmerCard(context),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? AppColors.darkSurface : AppColors.lightDivider;
    final highlightColor = isDark
        ? AppColors.darkDivider.withValues(alpha: 0.5)
        : AppColors.lightSurface;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: Border.all(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover placeholder
              _shimmerBox(72, 108, baseColor, highlightColor, 10),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(double.infinity, 18, baseColor, highlightColor, 4),
                    const SizedBox(height: 8),
                    _shimmerBox(140, 14, baseColor, highlightColor, 4),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _shimmerBox(60, 20, baseColor, highlightColor, 6),
                        const SizedBox(width: 6),
                        _shimmerBox(50, 20, baseColor, highlightColor, 6),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _shimmerBox(80, 12, baseColor, highlightColor, 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox(
    double width,
    double height,
    Color baseColor,
    Color highlightColor,
    double radius,
  ) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
