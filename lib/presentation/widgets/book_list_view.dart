import 'package:flutter/material.dart';
import 'package:lume/domain/entities/book.dart';
import 'package:lume/presentation/widgets/book_card.dart';
import 'package:lume/presentation/widgets/empty_state_widget.dart';

/// A scrollable list view of [BookCard] widgets.
///
/// Displays an [EmptyStateWidget] when the list is empty.
class BookListView extends StatelessWidget {
  final List<Book> books;
  final void Function(Book book)? onBookTap;
  final void Function(Book book)? onBookLongPress;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final VoidCallback? onEmptyAction;
  final String? emptyActionLabel;
  final bool showStatus;

  const BookListView({
    super.key,
    required this.books,
    this.onBookTap,
    this.onBookLongPress,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.onEmptyAction,
    this.emptyActionLabel,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return EmptyStateWidget(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
        onAction: onEmptyAction,
        actionLabel: emptyActionLabel,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCard(
          book: book,
          showStatus: showStatus,
          onTap: onBookTap != null ? () => onBookTap!(book) : null,
          onLongPress:
              onBookLongPress != null ? () => onBookLongPress!(book) : null,
        );
      },
    );
  }
}
