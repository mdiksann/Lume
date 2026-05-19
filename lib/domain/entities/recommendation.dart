import 'package:equatable/equatable.dart';

/// A book recommended by the AI.
class RecommendedBook extends Equatable {
  final String title;
  final String author;
  final String genre;
  final String reason;

  const RecommendedBook({
    required this.title,
    required this.author,
    required this.genre,
    required this.reason,
  });

  factory RecommendedBook.fromJson(Map<String, dynamic> json) {
    return RecommendedBook(
      title: json['title'] as String? ?? 'Unknown Title',
      author: json['author'] as String? ?? 'Unknown Author',
      genre: json['genre'] as String? ?? 'Unknown Genre',
      reason: json['reason'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [title, author, genre, reason];
}

/// The complete structured result of an AI recommendation request.
class RecommendationResult extends Equatable {
  final String profileSummary;
  final List<RecommendedBook> books;

  const RecommendationResult({
    required this.profileSummary,
    required this.books,
  });

  factory RecommendationResult.fromJson(Map<String, dynamic> json) {
    final booksJson = json['books'] as List<dynamic>? ?? [];
    return RecommendationResult(
      profileSummary: json['profileSummary'] as String? ?? '',
      books: booksJson
          .map((e) => RecommendedBook.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [profileSummary, books];
}
