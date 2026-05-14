import 'package:equatable/equatable.dart';
import 'package:lume/domain/entities/book.dart';

/// States for the [LibraryBloc].
abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any books are loaded.
class LibraryInitial extends LibraryState {}

/// Books are currently being loaded.
class LibraryLoading extends LibraryState {}

/// Books have been successfully loaded.
///
/// Contains three categorized lists for direct access
/// by each tab in the Library Dashboard.
class LibraryLoaded extends LibraryState {
  final List<Book> readingNow;
  final List<Book> finished;
  final List<Book> wishlist;

  const LibraryLoaded({
    required this.readingNow,
    required this.finished,
    required this.wishlist,
  });

  /// Total number of books across all categories.
  int get totalBooks => readingNow.length + finished.length + wishlist.length;

  @override
  List<Object?> get props => [readingNow, finished, wishlist];
}

/// An error occurred while loading or modifying the library.
class LibraryError extends LibraryState {
  final String message;

  const LibraryError(this.message);

  @override
  List<Object?> get props => [message];
}
