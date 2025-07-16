import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import des services
import '../services/firebase_service.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';
import '../services/notification_service.dart';
import '../config/app_config.dart';

// Import des repositories
import '../repositories/user_repository.dart';
import '../repositories/prayer_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/donation_repository.dart';

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

    // Notification Service (initialisé par FirebaseService)
    getIt.registerSingleton<NotificationService>(NotificationService());

    // Cloudinary Service
    if (AppConfig.cloudinaryEnabled) {
      try {
        await CloudinaryService.instance.initialize(
          cloudName: AppConfig.cloudinaryCloudName,
          apiKey: AppConfig.cloudinaryApiKey,
          apiSecret: AppConfig.cloudinaryApiSecret,
        );
        getIt.registerSingleton<CloudinaryService>(CloudinaryService.instance);
      } catch (e) {
        print('Failed to initialize Cloudinary: $e');
        // L'application peut continuer sans Cloudinary
      }
    }

    // Repositories
    getIt.registerLazySingleton<UserRepository>(() => UserRepository());
    getIt.registerLazySingleton<PrayerRepository>(() => PrayerRepository());
    getIt.registerLazySingleton<EventRepository>(() => EventRepository());
    getIt.registerLazySingleton<DonationRepository>(() => DonationRepository());

    // Blocs
    getIt.registerFactory<AuthBloc>(() => AuthBloc());
    getIt.registerFactory<PrayerBloc>(() => PrayerBloc());
    getIt.registerFactory<SettingsBloc>(() => SettingsBloc());
  }
}
