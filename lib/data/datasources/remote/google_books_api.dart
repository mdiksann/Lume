import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lume/data/models/book_model.dart';
import 'package:lume/core/constants/api_constants.dart';

/// Remote data source for querying the Google Books API.
///
/// Handles HTTP requests and JSON parsing for book search results.
class GoogleBooksApi {
  final http.Client _client;

  GoogleBooksApi({http.Client? client}) : _client = client ?? http.Client();

  /// Searches for books matching the given [query].
  ///
  /// Returns a list of [BookModel] parsed from the API response.
  /// Limits results to [maxResults] (default 20).
  Future<List<BookModel>> searchBooks(
    String query, {
    int maxResults = 20,
  }) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(
      '${ApiConstants.googleBooksBaseUrl}'
      '?q=${Uri.encodeComponent(query)}'
      '&maxResults=$maxResults'
      '&printType=books'
      '&orderBy=relevance',
    );

    try {
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>?;

        if (items == null || items.isEmpty) return [];

        return items
            .map((item) =>
                BookModel.fromGoogleBooksJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception(
            'Failed to search books: HTTP ${response.statusCode}');
      }
    } on Exception {
      rethrow;
    }
  }

  /// Fetches detailed information for a single book by its [volumeId].
  Future<BookModel?> getBookDetails(String volumeId) async {
    final uri = Uri.parse(
      '${ApiConstants.googleBooksBaseUrl}/$volumeId',
    );

    try {
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return BookModel.fromGoogleBooksJson(data);
      }
      return null;
    } on Exception {
      return null;
    }
  }

  /// Disposes the HTTP client.
  void dispose() {
    _client.close();
  }
}
