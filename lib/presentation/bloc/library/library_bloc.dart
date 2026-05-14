import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lume/domain/entities/book.dart';
import 'package:lume/domain/repositories/book_repository.dart';
import 'package:lume/presentation/bloc/library/library_event.dart';
import 'package:lume/presentation/bloc/library/library_state.dart';

/// BLoC for managing the user's book library.
///
/// Handles loading, adding, removing, and updating books across
/// three categories: Reading Now, Finished, and Wishlist.
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final BookRepository bookRepository;

  LibraryBloc({required this.bookRepository}) : super(LibraryInitial()) {
    on<LoadBooks>(_onLoadBooks);
    on<AddBookToLibrary>(_onAddBook);
    on<RemoveBookFromLibrary>(_onRemoveBook);
    on<UpdateStatus>(_onUpdateStatus);
  }

  Future<void> _onLoadBooks(
    LoadBooks event,
    Emitter<LibraryState> emit,
  ) async {
    emit(LibraryLoading());
    try {
      final readingNow =
          await bookRepository.getBooksByStatus(BookStatus.readingNow);
      final finished =
          await bookRepository.getBooksByStatus(BookStatus.finished);
      final wishlist =
          await bookRepository.getBooksByStatus(BookStatus.wishlist);

      emit(LibraryLoaded(
        readingNow: readingNow,
        finished: finished,
        wishlist: wishlist,
      ));
    } catch (e) {
      emit(LibraryError('Failed to load library: ${e.toString()}'));
    }
  }

  Future<void> _onAddBook(
    AddBookToLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await bookRepository.addBook(event.book);
      // Reload the full library to keep all tabs in sync
      add(const LoadBooks());
    } catch (e) {
      emit(LibraryError('Failed to add book: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveBook(
    RemoveBookFromLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await bookRepository.removeBook(event.bookId);
      add(const LoadBooks());
    } catch (e) {
      emit(LibraryError('Failed to remove book: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateStatus event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await bookRepository.updateBookStatus(event.bookId, event.newStatus);
      add(const LoadBooks());
    } catch (e) {
      emit(LibraryError('Failed to update book status: ${e.toString()}'));
    }
  }
}
