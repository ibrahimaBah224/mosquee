import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import des services
import '../services/firebase_service.dart';
import '../services/firestore_service.dart';

// Import des repositories
import '../repositories/user_repository.dart';
import '../repositories/prayer_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/donation_repository.dart';
import '../repositories/news_repository.dart';
import '../repositories/book_repository.dart';

// Import des blocs
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/prayer/presentation/bloc/prayer_bloc.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';

final GetIt getIt = GetIt.instance;

class DependencyInjection {
  static Future<void> init() async {
    // External dependencies
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);

    // Services
    final firebaseService = FirebaseService();
    await firebaseService.initialize();
    getIt.registerSingleton<FirebaseService>(firebaseService);

    final firestoreService = FirestoreService();
    await firestoreService.initialize();
    getIt.registerSingleton<FirestoreService>(firestoreService);

    // Repositories
    getIt.registerLazySingleton<UserRepository>(() => UserRepository());
    getIt.registerLazySingleton<PrayerRepository>(() => PrayerRepository());
    getIt.registerLazySingleton<EventRepository>(() => EventRepository());
    getIt.registerLazySingleton<DonationRepository>(() => DonationRepository());
    getIt.registerLazySingleton<NewsRepository>(() => NewsRepository());
    getIt.registerLazySingleton<BookRepository>(() => BookRepository());

    // Blocs
    getIt.registerFactory<AuthBloc>(() => AuthBloc());
    getIt.registerFactory<PrayerBloc>(() => PrayerBloc());
    getIt.registerFactory<SettingsBloc>(() => SettingsBloc());
  }
}
