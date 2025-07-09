import 'package:uuid/uuid.dart';
import '../services/firestore_service.dart';
import '../services/mosque_service.dart';
import '../services/imam_service.dart';
import '../services/muezzin_service.dart';
import '../models/prayer_time.dart';

class FirebaseInitializer {
  static final FirestoreService _firestoreService = FirestoreService();

  /// Initialise Firebase avec les services de base uniquement
  /// Les données doivent être ajoutées par les administrateurs
  static Future<void> initializeBasicServices() async {
    try {
      await _initializeMosqueInfo();
      await _initializeImams();
      await _initializeMuezzins();
      await _createDefaultPrayerConfiguration();

      print(
          '✅ Services de base initialisés - Les données doivent être ajoutées via l\'interface admin');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation des services: $e');
    }
  }

  static Future<void> _initializeMosqueInfo() async {
    final mosqueService = MosqueService();
    await mosqueService.initializeDefaultData();
    print('✅ Informations de la mosquée initialisées');
  }

  static Future<void> _initializeImams() async {
    final imamService = ImamService();
    await imamService.initializeSampleImams();
    print('✅ Imams initialisés');
  }

  static Future<void> _initializeMuezzins() async {
    final muezzinService = MuezzinService();
    await muezzinService.initializeSampleMuezzins();
    print('✅ Muezzins initialisés');
  }

  static Future<void> _createDefaultPrayerConfiguration() async {
    final config = PrayerConfiguration(
      id: 'main',
      mosqueName: 'Mosquée Elhadj Daouda',
      latitude: 9.5380, // Conakry
      longitude: -13.6773, // Conakry
      timezone: 'Africa/Conakry',
      calculationMethod: 'MECCA',
      adjustments: {
        'fajr': 0,
        'dhuhr': 0,
        'asr': 0,
        'maghrib': 0,
        'isha': 0,
      },
      automaticCalculation: true,
      updatedAt: DateTime.now(),
    );

    await _firestoreService.updatePrayerConfiguration(config);
    print('✅ Configuration de prière par défaut créée');
  }
}
