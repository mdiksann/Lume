import 'package:equatable/equatable.dart';
import 'package:lume/domain/entities/book.dart';

/// States for the [SearchBloc].
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no search has been performed.
class SearchInitial extends SearchState {}

/// A search is currently in progress.
class SearchLoading extends SearchState {}

/// Search completed with results.
class SearchLoaded extends SearchState {
  final List<Book> results;
  final String query;

  const SearchLoaded({required this.results, required this.query});

  @override
  List<Object?> get props => [results, query];
}

/// An error occurred during search.
class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
