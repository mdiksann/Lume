import 'package:equatable/equatable.dart';
import 'package:lume/domain/entities/book.dart';

/// Events for the [LibraryBloc].
abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

/// Load all books in the library, optionally filtered by [status].
class LoadBooks extends LibraryEvent {
  final BookStatus? status;

  const LoadBooks({this.status});

  @override
  List<Object?> get props => [status];
}

/// Add a book to the library with the specified status.
class AddBookToLibrary extends LibraryEvent {
  final Book book;

  const AddBookToLibrary(this.book);

  @override
  List<Object?> get props => [book];
}

/// Remove a book from the library by ID.
class RemoveBookFromLibrary extends LibraryEvent {
  final String bookId;

  const RemoveBookFromLibrary(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// Update the reading status of a book.
class UpdateStatus extends LibraryEvent {
  final String bookId;
  final BookStatus newStatus;

  const UpdateStatus({required this.bookId, required this.newStatus});

  @override
  List<Object?> get props => [bookId, newStatus];
}
