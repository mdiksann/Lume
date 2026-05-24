import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lume/data/models/book_model.dart';
import 'package:lume/domain/entities/book.dart';

/// Service class to manage all Supabase Cloud Sync interactions.
///
/// Handles initialization, authentication, and database synchronization.
/// Gracefully falls back to local-only behavior if credentials are missing
/// or if there is no internet connection.
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isConfigured = false;

  /// Returns true if Supabase is properly configured in the .env file.
  bool get isConfigured => _isConfigured;

  /// Returns the current authenticated Supabase user, if any.
  User? get currentUser {
    if (!_isConfigured) return null;
    return Supabase.instance.client.auth.currentUser;
  }

  /// Returns true if a user is currently signed in.
  bool get isAuthenticated => currentUser != null;

  /// Stream of authentication state changes.
  Stream<AuthState> get authStateChanges {
    if (!_isConfigured) return const Stream.empty();
    return Supabase.instance.client.auth.onAuthStateChange;
  }

  /// Initializes the Supabase client using environment variables.
  /// Does not crash if keys are missing; instead sets [isConfigured] to false.
  Future<void> init() async {
    try {
      final url = dotenv.maybeGet('SUPABASE_URL');
      final anonKey = dotenv.maybeGet('SUPABASE_ANON_KEY');

      if (url == null || url.isEmpty || url.contains('your_supabase') ||
          anonKey == null || anonKey.isEmpty || anonKey.contains('your_supabase')) {
        debugPrint('⚠️ Supabase credentials not found or placeholder used in .env. Running in Local Mode.');
        _isConfigured = false;
        return;
      }

      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        debug: kDebugMode,
      );

      _isConfigured = true;
      debugPrint('🟢 Supabase initialized successfully. Cloud Sync enabled!');
    } catch (e) {
      debugPrint('❌ Error initializing Supabase: $e. Running in Local Mode.');
      _isConfigured = false;
    }
  }

  /// Signs up a new user with [email] and [password].
  Future<AuthResponse> signUp(String email, String password) async {
    if (!_isConfigured) throw Exception('Supabase is not configured.');
    return await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Signs in an existing user with [email] and [password].
  Future<AuthResponse> signIn(String email, String password) async {
    if (!_isConfigured) throw Exception('Supabase is not configured.');
    return await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    if (!_isConfigured) return;
    await Supabase.instance.client.auth.signOut();
  }

  /// Synchronizes a single [book] to the Supabase database.
  Future<void> syncBook(BookModel book) async {
    if (!_isConfigured || !isAuthenticated) return;

    final userId = currentUser!.id;
    try {
      await Supabase.instance.client.from('books').upsert({
        'id': book.id,
        'user_id': userId,
        'title': book.title,
        'authors': book.authors,
        'description': book.description,
        'genres': book.genres,
        'cover_url': book.coverUrl,
        'published_date': book.publishedDate,
        'status_index': book.statusIndex,
        'date_added': book.dateAdded.toIso8601String(),
        'rating': book.rating,
        'page_count': book.pageCount,
        'updated_at': DateTime.now().toIso8601String(),
      });
      debugPrint('☁️ Synced book to cloud: ${book.title}');
    } catch (e) {
      debugPrint('⚠️ Failed to sync book to cloud: $e');
      // Gracefully ignore network errors for offline-first resilience
    }
  }

  /// Deletes a book from the Supabase database by [bookId].
  Future<void> unsyncBook(String bookId) async {
    if (!_isConfigured || !isAuthenticated) return;

    try {
      await Supabase.instance.client
          .from('books')
          .delete()
          .match({'id': bookId, 'user_id': currentUser!.id});
      debugPrint('☁️ Removed book from cloud: $bookId');
    } catch (e) {
      debugPrint('⚠️ Failed to remove book from cloud: $e');
    }
  }

  /// Fetches all books stored in the cloud for the current user.
  Future<List<BookModel>> fetchBooksFromCloud() async {
    if (!_isConfigured || !isAuthenticated) return [];

    try {
      final response = await Supabase.instance.client
          .from('books')
          .select()
          .eq('user_id', currentUser!.id);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => _parseBookModel(json)).toList();
    } catch (e) {
      debugPrint('⚠️ Failed to fetch books from cloud: $e');
      return [];
    }
  }

  /// Private helper to parse json database rows to a [BookModel] instance.
  BookModel _parseBookModel(Map<String, dynamic> json) {
    // Parse authors (can be stored as List or json or legacy array)
    List<String> parsedAuthors = [];
    if (json['authors'] != null) {
      if (json['authors'] is List) {
        parsedAuthors = List<String>.from(json['authors'].map((a) => a.toString()));
      }
    }

    // Parse genres
    List<String> parsedGenres = [];
    if (json['genres'] != null) {
      if (json['genres'] is List) {
        parsedGenres = List<String>.from(json['genres'].map((g) => g.toString()));
      }
    }

    return BookModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Unknown Title',
      authors: parsedAuthors.isNotEmpty ? parsedAuthors : ['Unknown Author'],
      description: json['description'] as String?,
      genres: parsedGenres,
      coverUrl: json['cover_url'] as String?,
      publishedDate: json['published_date'] as String?,
      statusIndex: json['status_index'] as int? ?? BookStatus.wishlist.index,
      dateAdded: json['date_added'] != null
          ? DateTime.tryParse(json['date_added'] as String) ?? DateTime.now()
          : DateTime.now(),
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      pageCount: json['page_count'] as int?,
    );
  }
}
