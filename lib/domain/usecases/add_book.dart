import 'package:lume/domain/entities/book.dart';
import 'package:lume/domain/repositories/book_repository.dart';

/// Use case: Add a book to the user's library.
class AddBook {
  final BookRepository repository;

  const AddBook(this.repository);

  Future<void> call(Book book) {
    return repository.addBook(book);
  }
}
