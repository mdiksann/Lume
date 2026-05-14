import 'package:equatable/equatable.dart';

/// Events for the [SearchBloc].
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger a book search with the given [query].
class SearchBooks extends SearchEvent {
  final String query;

  const SearchBooks(this.query);

  @override
  List<Object?> get props => [query];
}

/// Clear the current search results.
class ClearSearch extends SearchEvent {}
