import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:lume/app.dart';
import 'package:lume/data/datasources/local/book_local_datasource.dart';
import 'package:lume/data/datasources/remote/google_books_api.dart';
import 'package:lume/data/datasources/remote/ai_api_client.dart';
import 'package:lume/data/models/book_model.dart';
import 'package:lume/data/repositories/book_repository_impl.dart';
import 'package:lume/data/repositories/ai_repository_impl.dart';
import 'package:lume/services/notification_service.dart';
import 'package:lume/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  // Initialize Supabase Cloud Service (fails gracefully to local-only mode if no keys)
  await SupabaseService().init();

  // Lock to portrait orientation for iOS
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(BookModelAdapter());

  // Initialize data sources
  final localDatasource = BookLocalDatasource();
  await localDatasource.init();

  final googleBooksApi = GoogleBooksApi();
  final aiApiClient = AiApiClient();

  // Initialize repositories
  final bookRepository = BookRepositoryImpl(
    localDatasource: localDatasource,
    remoteApi: googleBooksApi,
  );
  final aiRepository = AiRepositoryImpl(apiClient: aiApiClient);

  // Initialize notifications
  await NotificationService().init();

  runApp(LumeApp(
    bookRepository: bookRepository,
    aiRepository: aiRepository,
  ));
}
