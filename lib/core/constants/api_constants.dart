import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API configuration constants.
///
/// API keys are loaded from the `.env` file at app startup.
/// Copy `.env.example` to `.env` and fill in your keys:
/// ```
/// GEMINI_API_KEY=your_key_here
/// GOOGLE_BOOKS_API_KEY=your_key_here
/// ```
class ApiConstants {
  ApiConstants._();

  /// Google Books API base URL.
  static const String googleBooksBaseUrl =
      'https://www.googleapis.com/books/v1/volumes';

  /// Google Gemini API base URL.
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite-preview';

  /// Gemini API key — loaded from `.env` file.
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// Google Books API key — loaded from `.env` file (optional).
  static String get googleBooksApiKey =>
      dotenv.env['GOOGLE_BOOKS_API_KEY'] ?? '';
}
