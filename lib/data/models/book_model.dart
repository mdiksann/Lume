import 'package:hive_ce/hive.dart';
import 'package:lume/domain/entities/book.dart';

part 'book_model.g.dart';

/// Hive-annotated data model for persisting books locally.
///
/// This model handles serialization/deserialization for both
/// Hive local storage and Google Books API JSON responses.
@HiveType(typeId: 0)
class BookModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<String> authors;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final List<String> genres;

  @HiveField(5)
  final String? coverUrl;

  @HiveField(6)
  final String? publishedDate;

  @HiveField(7)
  final int statusIndex;

  @HiveField(8)
  final DateTime dateAdded;

  @HiveField(9)
  final double? rating;

  @HiveField(10)
  final int? pageCount;

  BookModel({
    required this.id,
    required this.title,
    required this.authors,
    this.description,
    this.genres = const [],
    this.coverUrl,
    this.publishedDate,
    required this.statusIndex,
    required this.dateAdded,
    this.rating,
    this.pageCount,
  });

  /// Converts this data model to a domain entity.
  Book toEntity() {
    return Book(
      id: id,
      title: title,
      authors: List<String>.from(authors),
      description: description,
      genres: List<String>.from(genres),
      coverUrl: coverUrl,
      publishedDate: publishedDate,
      status: BookStatus.values[statusIndex],
      dateAdded: dateAdded,
      rating: rating,
      pageCount: pageCount,
    );
  }

  /// Creates a data model from a domain entity.
  factory BookModel.fromEntity(Book book) {
    return BookModel(
      id: book.id,
      title: book.title,
      authors: List<String>.from(book.authors),
      description: book.description,
      genres: List<String>.from(book.genres),
      coverUrl: book.coverUrl,
      publishedDate: book.publishedDate,
      statusIndex: book.status.index,
      dateAdded: book.dateAdded,
      rating: book.rating,
      pageCount: book.pageCount,
    );
  }

  /// Creates a data model from a Google Books API JSON response item.
  factory BookModel.fromGoogleBooksJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>? ?? {};
    final imageLinks =
        volumeInfo['imageLinks'] as Map<String, dynamic>? ?? {};

    // Prefer the highest quality thumbnail available
    String? coverUrl = imageLinks['thumbnail'] as String? ??
        imageLinks['smallThumbnail'] as String?;

    // Google Books returns HTTP URLs; upgrade to HTTPS
    if (coverUrl != null) {
      if (coverUrl.startsWith('http://')) {
        coverUrl = coverUrl.replaceFirst('http://', 'https://');
      }
      // Remove edge=curl which adds an ugly curled corner to the book cover
      coverUrl = coverUrl.replaceAll('&edge=curl', '');
      
      // Use a CORS proxy to bypass Flutter Web CanvasKit EncodingError issues
      coverUrl = 'https://images.weserv.nl/?url=${Uri.encodeComponent(coverUrl)}';
    }

    return BookModel(
      id: json['id'] as String? ?? '',
      title: volumeInfo['title'] as String? ?? 'Unknown Title',
      authors: (volumeInfo['authors'] as List<dynamic>?)
              ?.map((a) => a.toString())
              .toList() ??
          ['Unknown Author'],
      description: volumeInfo['description'] as String?,
      genres: (volumeInfo['categories'] as List<dynamic>?)
              ?.map((c) => c.toString())
              .toList() ??
          [],
      coverUrl: coverUrl,
      publishedDate: volumeInfo['publishedDate'] as String?,
      statusIndex: BookStatus.wishlist.index, // Default when adding from search
      dateAdded: DateTime.now(),
      rating: (volumeInfo['averageRating'] as num?)?.toDouble(),
      pageCount: volumeInfo['pageCount'] as int?,
    );
  }
}
