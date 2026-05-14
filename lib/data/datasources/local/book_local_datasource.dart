import 'package:hive_ce/hive.dart';
import 'package:lume/data/models/book_model.dart';
import 'package:lume/domain/entities/book.dart';

/// Local data source for book persistence using Hive.
///
/// Manages a single Hive box named 'books' for all CRUD operations.
/// Books are stored with their [id] as the key for O(1) lookups.
class BookLocalDatasource {
  static const String _boxName = 'books';
  late Box<BookModel> _box;

  /// Initializes the Hive box. Must be called before any operations.
  Future<void> init() async {
    _box = await Hive.openBox<BookModel>(_boxName);
  }

  /// Returns all books currently stored locally.
  List<BookModel> getAllBooks() {
    return _box.values.toList();
  }

  /// Returns books filtered by the given [status].
  List<BookModel> getBooksByStatus(BookStatus status) {
    return _box.values
        .where((book) => book.statusIndex == status.index)
        .toList();
  }

  /// Returns a single book by [id], or null if not found.
  BookModel? getBookById(String id) {
    return _box.get(id);
  }

  /// Adds or updates a [book] in local storage.
  Future<void> addBook(BookModel book) async {
    await _box.put(book.id, book);
  }

  /// Updates the reading status of the book with the given [bookId].
  Future<void> updateBookStatus(String bookId, BookStatus status) async {
    final book = _box.get(bookId);
    if (book != null) {
      final updated = BookModel(
        id: book.id,
        title: book.title,
        authors: book.authors,
        description: book.description,
        genres: book.genres,
        coverUrl: book.coverUrl,
        publishedDate: book.publishedDate,
        statusIndex: status.index,
        dateAdded: book.dateAdded,
        rating: book.rating,
        pageCount: book.pageCount,
      );
      await _box.put(bookId, updated);
    }
  }

  /// Removes the book with the given [bookId] from local storage.
  Future<void> removeBook(String bookId) async {
    await _box.delete(bookId);
  }

  /// Returns the total number of books stored locally.
  int get count => _box.length;
}
