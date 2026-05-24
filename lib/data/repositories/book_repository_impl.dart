import 'package:lume/data/datasources/local/book_local_datasource.dart';
import 'package:lume/data/datasources/remote/google_books_api.dart';
import 'package:lume/data/models/book_model.dart';
import 'package:lume/domain/entities/book.dart';
import 'package:lume/domain/repositories/book_repository.dart';
import 'package:lume/services/supabase_service.dart';

/// Concrete implementation of [BookRepository].
///
/// Bridges local Hive storage for library management and the
/// Google Books API for remote search operations.
class BookRepositoryImpl implements BookRepository {
  final BookLocalDatasource localDatasource;
  final GoogleBooksApi remoteApi;

  BookRepositoryImpl({
    required this.localDatasource,
    required this.remoteApi,
  });

  @override
  Future<List<Book>> getBooksByStatus(BookStatus status) async {
    final models = localDatasource.getBooksByStatus(status);
    return models.map((m) => m.toEntity()).toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }

  @override
  Future<List<Book>> getAllBooks() async {
    final models = localDatasource.getAllBooks();
    return models.map((m) => m.toEntity()).toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }

  @override
  Future<void> addBook(Book book) async {
    final model = BookModel.fromEntity(book);
    await localDatasource.addBook(model);
    await SupabaseService().syncBook(model);
  }

  @override
  Future<void> updateBookStatus(String bookId, BookStatus status) async {
    await localDatasource.updateBookStatus(bookId, status);
    final model = localDatasource.getBookById(bookId);
    if (model != null) {
      await SupabaseService().syncBook(model);
    }
  }

  @override
  Future<void> removeBook(String bookId) async {
    await localDatasource.removeBook(bookId);
    await SupabaseService().unsyncBook(bookId);
  }

  @override
  Future<List<Book>> searchBooks(String query) async {
    final models = await remoteApi.searchBooks(query);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Book?> getBookById(String bookId) async {
    final model = localDatasource.getBookById(bookId);
    return model?.toEntity();
  }

  @override
  Future<void> syncWithCloud() async {
    final supabase = SupabaseService();
    if (!supabase.isConfigured || !supabase.isAuthenticated) return;

    try {
      final localBooks = localDatasource.getAllBooks();
      final cloudBooks = await supabase.fetchBooksFromCloud();

      final Map<String, BookModel> localMap = {for (var b in localBooks) b.id: b};
      final Map<String, BookModel> cloudMap = {for (var b in cloudBooks) b.id: b};

      // 1. Upload local books that are not in the cloud
      for (final localBook in localBooks) {
        if (!cloudMap.containsKey(localBook.id)) {
          await supabase.syncBook(localBook);
        }
      }

      // 2. Download cloud books that are not local
      for (final cloudBook in cloudBooks) {
        if (!localMap.containsKey(cloudBook.id)) {
          await localDatasource.addBook(cloudBook);
        }
      }
    } catch (e) {
      // Gracefully capture sync exceptions
    }
  }
}
