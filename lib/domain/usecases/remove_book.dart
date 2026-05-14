import 'package:lume/domain/repositories/book_repository.dart';

/// Use case: Remove a book from the user's library.
class RemoveBook {
  final BookRepository repository;

  const RemoveBook(this.repository);

  Future<void> call(String bookId) {
    return repository.removeBook(bookId);
  }
}
