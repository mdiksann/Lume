import 'package:flutter/material.dart';
import 'package:lume/core/constants/app_colors.dart';

/// A beautiful empty state widget displayed when a book list is empty.
///
/// Features an animated fade-in, an icon, and descriptive text
/// to guide the user toward their next action.
class EmptyStateWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? AppColors.darkAccentMuted.withValues(alpha: 0.3)
                        : AppColors.lightAccentMuted.withValues(alpha: 0.5),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 36,
                    color: isDark
                        ? AppColors.darkAccent
                        : AppColors.lightAccent,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subtitle,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (widget.onAction != null && widget.actionLabel != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: widget.onAction,
                    child: Text(widget.actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
