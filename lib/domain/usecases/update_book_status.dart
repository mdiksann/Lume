import 'package:lume/domain/entities/book.dart';
import 'package:lume/domain/repositories/book_repository.dart';

/// Use case: Update a book's reading status.
class UpdateBookStatus {
  final BookRepository repository;

  const UpdateBookStatus(this.repository);

  Future<void> call(String bookId, BookStatus status) {
    return repository.updateBookStatus(bookId, status);
  }
}
