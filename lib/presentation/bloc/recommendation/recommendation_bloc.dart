import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lume/domain/entities/book.dart';
import 'package:lume/domain/repositories/ai_repository.dart';
import 'package:lume/domain/repositories/book_repository.dart';
import 'package:lume/presentation/bloc/recommendation/recommendation_event.dart';
import 'package:lume/presentation/bloc/recommendation/recommendation_state.dart';

/// BLoC for generating AI-powered reading recommendations.
///
/// Fetches the user's finished books, sends them to the AI service,
/// and emits the generated recommendations.
class RecommendationBloc
    extends Bloc<RecommendationEvent, RecommendationState> {
  final AiRepository aiRepository;
  final BookRepository bookRepository;

  RecommendationBloc({
    required this.aiRepository,
    required this.bookRepository,
  }) : super(RecommendationInitial()) {
    on<FetchRecommendations>(_onFetchRecommendations);
  }

  Future<void> _onFetchRecommendations(
    FetchRecommendations event,
    Emitter<RecommendationState> emit,
  ) async {
    emit(RecommendationLoading());
    try {
      final finishedBooks =
          await bookRepository.getBooksByStatus(BookStatus.finished);
      final recommendations =
          await aiRepository.getRecommendations(finishedBooks);
      
      // Fetch covers for the recommended books
      final booksWithCovers = await Future.wait(
        recommendations.books.map((recBook) async {
          try {
            final query = '${recBook.title} ${recBook.author}';
            final searchResults = await bookRepository.searchBooks(query);
            if (searchResults.isNotEmpty && searchResults.first.coverUrl != null) {
              return recBook.copyWith(coverUrl: searchResults.first.coverUrl);
            }
          } catch (e) {
            // Ignore search errors, just return without cover
          }
          return recBook;
        }),
      );

      final finalResult = recommendations.copyWith(books: booksWithCovers);
      emit(RecommendationLoaded(finalResult));
    } catch (e) {
      emit(RecommendationError(e.toString()));
    }
  }
}
