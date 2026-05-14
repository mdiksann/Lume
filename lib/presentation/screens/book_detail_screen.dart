import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lume/core/constants/app_colors.dart';
import 'package:lume/domain/entities/book.dart';
import 'package:lume/presentation/bloc/library/library_bloc.dart';
import 'package:lume/presentation/bloc/library/library_event.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkSurface : AppColors.lightSurface).withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_ios_rounded, size: 18, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [
                          isDark ? AppColors.darkAccentMuted : AppColors.lightAccentMuted,
                          isDark ? AppColors.darkBackground : AppColors.lightBackground,
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Hero(
                      tag: 'book-cover-${book.id}',
                      child: Container(
                        width: 140, height: 210,
                        margin: const EdgeInsets.only(top: 40),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: book.coverUrl != null
                            ? CachedNetworkImage(imageUrl: book.coverUrl!, fit: BoxFit.cover)
                            : Container(
                                color: isDark ? AppColors.darkAccentMuted : AppColors.lightAccentMuted,
                                child: Center(child: Icon(Icons.menu_book_rounded, size: 48, color: isDark ? AppColors.darkAccent : AppColors.lightAccent)),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(book.title, style: theme.textTheme.headlineLarge, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Center(child: Text(book.authorsFormatted, style: theme.textTheme.bodyLarge?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))),
                const SizedBox(height: 16),
                // Metadata row
                Center(child: Wrap(spacing: 24, runSpacing: 8, alignment: WrapAlignment.center, children: [
                  if (book.publishedDate != null) _metaChip(context, Icons.calendar_today_rounded, book.publishedDate!),
                  if (book.pageCount != null) _metaChip(context, Icons.auto_stories_rounded, '${book.pageCount} pages'),
                  if (book.rating != null) _metaChip(context, Icons.star_rounded, book.rating!.toStringAsFixed(1)),
                ])),
                if (book.genres.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Wrap(spacing: 8, runSpacing: 6, children: book.genres.map((g) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkAccentMuted : AppColors.lightAccentMuted.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(g, style: theme.textTheme.labelMedium),
                  )).toList()),
                ],
                const SizedBox(height: 24),
                // Action buttons
                Row(children: [
                  Expanded(child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Add to Library'),
                    onPressed: () => _showAddSheet(context),
                  )),
                ]),
                if (book.description != null) ...[
                  const SizedBox(height: 32),
                  Text('About', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Text(book.description!, style: theme.textTheme.bodyLarge?.copyWith(height: 1.8)),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(BuildContext context, IconData icon, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 16, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      const SizedBox(width: 4),
      Text(text, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }

  void _showAddSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? AppColors.darkDivider : AppColors.lightDivider, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('Add to...', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _addTile(context, BookStatus.readingNow, Icons.menu_book_rounded, 'Reading Now'),
          _addTile(context, BookStatus.wishlist, Icons.bookmark_border_rounded, 'Wishlist'),
          _addTile(context, BookStatus.finished, Icons.done_all_rounded, 'Finished'),
        ]),
      )),
    );
  }

  Widget _addTile(BuildContext context, BookStatus status, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon), title: Text(label),
      onTap: () {
        final b = book.copyWith(status: status, dateAdded: DateTime.now());
        context.read<LibraryBloc>().add(AddBookToLibrary(b));
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Added to $label'), behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      },
    );
  }
}
