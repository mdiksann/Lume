import 'package:lume/domain/entities/book.dart';
import 'package:lume/domain/repositories/book_repository.dart';

/// Use case: Retrieve books filtered by their reading status.
class GetBooksByStatus {
  final BookRepository repository;

  const GetBooksByStatus(this.repository);

  Future<List<Book>> call(BookStatus status) {
    return repository.getBooksByStatus(status);
  }
}
