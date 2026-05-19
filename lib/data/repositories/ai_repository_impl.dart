import 'package:lume/data/datasources/remote/ai_api_client.dart';
import 'package:lume/domain/entities/book.dart';
import 'package:lume/domain/entities/recommendation.dart';
import 'package:lume/domain/repositories/ai_repository.dart';

/// Concrete implementation of [AiRepository].
///
/// Delegates to [AiApiClient] to communicate with the configured
/// LLM provider (Gemini by default).
class AiRepositoryImpl implements AiRepository {
  final AiApiClient apiClient;

  AiRepositoryImpl({required this.apiClient});

  @override
  Future<RecommendationResult> getRecommendations(List<Book> finishedBooks) {
    return apiClient.getRecommendations(finishedBooks);
  }
}
