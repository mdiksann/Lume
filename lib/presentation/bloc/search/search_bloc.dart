import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lume/domain/repositories/book_repository.dart';
import 'package:lume/presentation/bloc/search/search_event.dart';
import 'package:lume/presentation/bloc/search/search_state.dart';

/// BLoC for searching books via the Google Books API.
///
/// Implements debounced search (300ms) using a restartable
/// event transformer to avoid excessive API calls while typing.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final BookRepository bookRepository;

  SearchBloc({required this.bookRepository}) : super(SearchInitial()) {
    on<SearchBooks>(
      _onSearchBooks,
      transformer: _debounce(const Duration(milliseconds: 300)),
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

  /// Creates a debounce transformer that restarts the timer
  /// on each new event, ensuring only the last event in a
  /// rapid sequence is processed.
  EventTransformer<T> _debounce<T>(Duration duration) {
    return (events, mapper) {
      return events
          .transform(
            StreamTransformer<T, T>.fromHandlers(
              handleData: (data, sink) {
                sink.add(data);
              },
            ),
          )
          .asyncExpand((event) => Future.delayed(duration)
              .then((_) => event)
              .asStream()
              .asyncExpand(mapper));
    };
  }
}
