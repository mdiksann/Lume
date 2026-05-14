import 'package:lume/domain/entities/book.dart';

/// Abstract contract for the AI recommendation repository.
///
/// Implementations will connect to an LLM API (Gemini or OpenAI)
/// to generate personalized reading recommendations based on
/// the user's reading history.
abstract class AiRepository {
  /// Generates AI-powered reading recommendations based on
  /// the user's [finishedBooks] list.
  ///
  /// Returns a formatted string containing a reading taste summary
  /// and personalized book recommendations with explanations.
  Future<String> getRecommendations(List<Book> finishedBooks);
}
