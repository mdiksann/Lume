import 'package:lume/domain/entities/book.dart';
import 'package:lume/domain/repositories/ai_repository.dart';

/// Use case: Generate AI-powered reading recommendations.
class GetRecommendations {
  final AiRepository repository;

  const GetRecommendations(this.repository);

  Future<String> call(List<Book> finishedBooks) {
    return repository.getRecommendations(finishedBooks);
  }
}
