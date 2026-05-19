import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lume/core/constants/api_constants.dart';
import 'package:lume/domain/entities/book.dart';
import 'package:lume/domain/entities/recommendation.dart';

/// Remote data source for communicating with an LLM API
/// (Google Gemini or OpenAI) to generate reading recommendations.
///
/// Uses a strategy pattern: the endpoint and headers are configured
/// via [ApiConstants] to support switching between AI providers.
class AiApiClient {
  final http.Client _client;

  AiApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Generates reading recommendations based on the user's [finishedBooks].
  ///
  /// Sends book metadata (titles, authors, genres) as a structured prompt
  /// to the configured LLM endpoint and returns a [RecommendationResult].
  Future<RecommendationResult> getRecommendations(List<Book> finishedBooks) async {
    if (finishedBooks.isEmpty) {
      return const RecommendationResult(
        profileSummary: 'Start reading and finishing books to get personalized AI recommendations! Your reading history helps us understand your tastes.',
        books: [],
      );
    }

    final prompt = _buildPrompt(finishedBooks);

    try {
      final response = await _callGeminiApi(prompt);
      return response;
    } on Exception catch (e) {
      throw Exception('Failed to get recommendations: $e');
    }
  }

  /// Builds a structured prompt from the user's finished books.
  String _buildPrompt(List<Book> books) {
    final bookList = books.map((b) {
      final genres =
          b.genres.isNotEmpty ? b.genres.join(', ') : 'Unknown Genre';
      final authors = b.authorsFormatted;
      return '- "${b.title}" by $authors (Genre: $genres)';
    }).join('\n');

    return '''
You are a literary expert and book recommendation assistant. 
Analyze the following list of books that a reader has finished, 
then provide:

1. A brief "Reading Profile" summary (2-3 sentences) describing their reading tastes and patterns.
2. Exactly 5 personalized book recommendations with:
   - title
   - author
   - genre
   - A brief explanation of WHY this book fits their taste (reason)

Books the reader has finished:
$bookList

IMPORTANT: You must respond ONLY with a valid JSON object matching this schema, without any markdown formatting or code blocks:
{
  "profileSummary": "A brief summary...",
  "books": [
    {
      "title": "Book Title",
      "author": "Author Name",
      "genre": "Genre",
      "reason": "Why it fits their taste..."
    }
  ]
}
''';
  }

  /// Calls the Google Gemini API with the given [prompt].
  Future<RecommendationResult> _callGeminiApi(String prompt) async {
    final apiKey = ApiConstants.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception(
        'Gemini API key not configured. '
        'Pass it via --dart-define=GEMINI_API_KEY=your_key',
      );
    }

    final uri = Uri.parse(
      '${ApiConstants.geminiBaseUrl}'
      ':generateContent?key=$apiKey',
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 1024,
        'responseMimeType': 'application/json',
      },
    });

    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;

      if (candidates != null && candidates.isNotEmpty) {
        final content =
            candidates[0]['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;
        if (parts != null && parts.isNotEmpty) {
          final textResponse = parts[0]['text'] as String?;
          if (textResponse != null) {
            try {
              final jsonResponse = jsonDecode(textResponse);
              return RecommendationResult.fromJson(jsonResponse);
            } catch (e) {
              throw Exception('Failed to parse AI response as JSON: $e');
            }
          }
        }
      }
      throw Exception('No recommendations generated. Please try again.');
    } else if (response.statusCode == 429) {
      throw Exception(
          'AI rate limit exceeded. Please wait a moment and try again.');
    } else {
      throw Exception('AI API error: HTTP ${response.statusCode}');
    }
  }

  /// Disposes the HTTP client.
  void dispose() {
    _client.close();
  }
}
