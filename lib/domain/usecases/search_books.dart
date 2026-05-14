import 'package:lume/domain/entities/book.dart';
import 'package:lume/domain/repositories/book_repository.dart';

/// Use case: Search for books via the external API.
class SearchBooks {
  final BookRepository repository;

  const SearchBooks(this.repository);

  Future<List<Book>> call(String query) {
    return repository.searchBooks(query);
  }
}
