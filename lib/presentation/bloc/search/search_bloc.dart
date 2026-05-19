import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart' show restartable;
import 'package:lume/domain/repositories/book_repository.dart';
import 'package:lume/presentation/bloc/search/search_event.dart';
import 'package:lume/presentation/bloc/search/search_state.dart';

/// BLoC for searching books via the Google Books API.
///
/// Implements debounced search (500ms) using a restartable
/// event transformer to avoid excessive API calls while typing.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final BookRepository bookRepository;

  SearchBloc({required this.bookRepository}) : super(SearchInitial()) {
    on<SearchBooks>(
      _onSearchBooks,
      transformer: restartable(),
    );
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchBooks(
    SearchBooks event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    // Debounce: wait 500ms before actually searching
    await Future.delayed(const Duration(milliseconds: 500));

    emit(SearchLoading());
    try {
      final results = await bookRepository.searchBooks(query);
      emit(SearchLoaded(results: results, query: query));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchInitial());
  }
}
