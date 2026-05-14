import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lume/core/constants/app_colors.dart';
import 'package:lume/domain/entities/book.dart';

/// A premium card widget for displaying a book in list views.
///
/// Shows cover art, title, author, genre chips, and an optional
/// status indicator. Supports tap and long-press interactions.
class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showStatus;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onLongPress,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cover Art ──
              _buildCoverArt(context),
              const SizedBox(width: 16),
              // ── Book Info ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.authorsFormatted,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (book.genres.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildGenreChips(context),
                    ],
                    if (showStatus) ...[
                      const SizedBox(height: 8),
                      _buildStatusBadge(context),
                    ],
                    if (book.pageCount != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${book.pageCount} pages',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverArt(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Hero(
      tag: 'book-cover-${book.id}',
      child: Container(
        width: 72,
        height: 108,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isDark ? AppColors.darkAccentMuted : AppColors.lightAccentMuted,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: book.coverUrl != null
            ? CachedNetworkImage(
                imageUrl: book.coverUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _buildCoverPlaceholder(context),
                errorWidget: (_, __, ___) => _buildCoverPlaceholder(context),
              )
            : _buildCoverPlaceholder(context),
      ),
    );
  }

  Widget _buildCoverPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.darkAccentMuted : AppColors.lightAccentMuted,
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 28,
          color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
        ),
      ),
    );
  }

  Widget _buildGenreChips(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: book.genres.take(2).map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkAccentMuted
                : AppColors.lightAccentMuted.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            genre,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String label;
    Color color;

    switch (book.status) {
      case BookStatus.readingNow:
        label = 'Reading';
        color = AppColors.lightAccent;
        break;
      case BookStatus.finished:
        label = 'Finished';
        color = AppColors.success;
        break;
      case BookStatus.wishlist:
        label = 'Wishlist';
        color = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
