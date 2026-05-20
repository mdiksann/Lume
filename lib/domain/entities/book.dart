import 'package:equatable/equatable.dart';

/// Reading status for a book in the user's library.
enum BookStatus {
  readingNow,
  finished,
  wishlist,
  toBeRead,
}

/// Pure domain entity representing a Book.
///
/// This entity has no framework dependencies and serves as the
/// single source of truth for book data across all layers.
class Book extends Equatable {
  final String id;
  final String title;
  final List<String> authors;
  final String? description;
  final List<String> genres;
  final String? coverUrl;
  final String? publishedDate;
  final BookStatus status;
  final DateTime dateAdded;
  final double? rating;
  final int? pageCount;

  const Book({
    required this.id,
    required this.title,
    required this.authors,
    this.description,
    this.genres = const [],
    this.coverUrl,
    this.publishedDate,
    required this.status,
    required this.dateAdded,
    this.rating,
    this.pageCount,
  });

  /// Creates a copy of this Book with the given fields replaced.
  Book copyWith({
    String? id,
    String? title,
    List<String>? authors,
    String? description,
    List<String>? genres,
    String? coverUrl,
    String? publishedDate,
    BookStatus? status,
    DateTime? dateAdded,
    double? rating,
    int? pageCount,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      coverUrl: coverUrl ?? this.coverUrl,
      publishedDate: publishedDate ?? this.publishedDate,
      status: status ?? this.status,
      dateAdded: dateAdded ?? this.dateAdded,
      rating: rating ?? this.rating,
      pageCount: pageCount ?? this.pageCount,
    );
  }

  /// Returns the authors as a comma-separated string.
  String get authorsFormatted => authors.join(', ');

  /// Returns the genres as a comma-separated string.
  String get genresFormatted => genres.join(', ');

  @override
  List<Object?> get props => [
        id,
        title,
        authors,
        description,
        genres,
        coverUrl,
        publishedDate,
        status,
        dateAdded,
        rating,
        pageCount,
      ];
}
