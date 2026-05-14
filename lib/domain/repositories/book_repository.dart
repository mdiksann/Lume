import 'package:lume/domain/entities/book.dart';

/// Abstract contract for the Book repository.
///
/// This defines the operations available for managing books
/// in the user's library. The data layer provides the concrete
/// implementation that bridges local storage and remote APIs.
abstract class BookRepository {
  /// Returns all books matching the given [status].
  Future<List<Book>> getBooksByStatus(BookStatus status);

  /// Returns all books in the library regardless of status.
  Future<List<Book>> getAllBooks();

  /// Adds a [book] to the local library.
  Future<void> addBook(Book book);

  /// Updates the [status] of the book with the given [bookId].
  Future<void> updateBookStatus(String bookId, BookStatus status);

  /// Removes the book with the given [bookId] from the library.
  Future<void> removeBook(String bookId);

  /// Searches for books matching [query] via the external API.
  Future<List<Book>> searchBooks(String query);

  /// Returns a single book by its [bookId], or null if not found.
  Future<Book?> getBookById(String bookId);
}
