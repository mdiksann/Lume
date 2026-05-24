import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lume/core/theme/app_theme.dart';
import 'package:lume/domain/entities/book.dart';
import 'package:lume/presentation/bloc/library/library_bloc.dart';
import 'package:lume/presentation/bloc/search/search_bloc.dart';
import 'package:lume/presentation/bloc/recommendation/recommendation_bloc.dart';
import 'package:lume/presentation/screens/splash_screen.dart';
import 'package:lume/presentation/screens/library_screen.dart';
import 'package:lume/presentation/screens/search_screen.dart';
import 'package:lume/presentation/screens/book_detail_screen.dart';
import 'package:lume/presentation/screens/recommendation_screen.dart';
import 'package:lume/presentation/screens/settings_screen.dart';
import 'package:lume/presentation/screens/auth_screen.dart';
import 'package:lume/domain/repositories/book_repository.dart';
import 'package:lume/domain/repositories/ai_repository.dart';

/// Root application widget for Lume.
///
/// Configures the MaterialApp with:
/// - Light and Dark themes
/// - Named route navigation
/// - BLoC providers for state management
class LumeApp extends StatelessWidget {
  final BookRepository bookRepository;
  final AiRepository aiRepository;

  const LumeApp({
    super.key,
    required this.bookRepository,
    required this.aiRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LibraryBloc(bookRepository: bookRepository),
        ),
        BlocProvider(
          create: (_) => SearchBloc(bookRepository: bookRepository),
        ),
        BlocProvider(
          create: (_) => RecommendationBloc(
            aiRepository: aiRepository,
            bookRepository: bookRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Lume',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      case '/library':
        return MaterialPageRoute(
          builder: (_) => const LibraryScreen(),
        );
      case '/search':
        return MaterialPageRoute(
          builder: (_) => const SearchScreen(),
        );
      case '/detail':
        final book = settings.arguments as Book;
        return MaterialPageRoute(
          builder: (_) => BookDetailScreen(book: book),
        );
      case '/recommendations':
        return MaterialPageRoute(
          builder: (_) => const RecommendationScreen(),
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      case '/auth':
        return MaterialPageRoute(
          builder: (_) => AuthScreen(bookRepository: bookRepository),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
    }
  }
}
