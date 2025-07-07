import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../config/app_config.dart';

class PrayerTimeService {
  static PrayerTimes? _currentPrayerTimes;
  static Coordinates? _coordinates;

  static Future<void> init() async {
    await _getCurrentLocation();
    await _calculatePrayerTimes();
  }

  static Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _coordinates = Coordinates(
          AppConfig.defaultLatitude,
          AppConfig.defaultLongitude,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      _coordinates = Coordinates(position.latitude, position.longitude);
    } catch (e) {
      _coordinates = Coordinates(
        AppConfig.defaultLatitude,
        AppConfig.defaultLongitude,
      );
    }
  }

  static Future<void> _calculatePrayerTimes() async {
    if (_coordinates == null) return;

    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    final date = DateComponents.from(DateTime.now());
    _currentPrayerTimes = PrayerTimes(_coordinates!, date, params);
  }

  static PrayerTimes? get currentPrayerTimes => _currentPrayerTimes;

  static Map<String, DateTime> getPrayerTimesMap() {
    if (_currentPrayerTimes == null) return {};

    return {
      'Fajr': _currentPrayerTimes!.fajr,
      'Sunrise': _currentPrayerTimes!.sunrise,
      'Dhuhr': _currentPrayerTimes!.dhuhr,
      'Asr': _currentPrayerTimes!.asr,
      'Maghrib': _currentPrayerTimes!.maghrib,
      'Isha': _currentPrayerTimes!.isha,
    };
  }

  static String getCurrentPrayer() {
    if (_currentPrayerTimes == null) return 'Unknown';
    return _currentPrayerTimes!.currentPrayer().name;
  }

  static String getNextPrayer() {
    if (_currentPrayerTimes == null) return 'Unknown';
    return _currentPrayerTimes!.nextPrayer().name;
  }

  Future<Map<String, DateTime>> getPrayerTimes(DateTime date) async {
    try {
      // Obtenir la position actuelle
      final position = await _getCurrentPosition();

      // Configurer les paramètres de calcul
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;

      // Créer les coordonnées
      final coordinates = Coordinates(position.latitude, position.longitude);

      // Calculer les horaires
      final prayerTimes =
          PrayerTimes(coordinates, DateComponents.from(date), params);

      // Retourner les horaires dans un Map
      return {
        'Fajr': prayerTimes.fajr,
        'Sunrise': prayerTimes.sunrise,
        'Dhuhr': prayerTimes.dhuhr,
        'Asr': prayerTimes.asr,
        'Maghrib': prayerTimes.maghrib,
        'Isha': prayerTimes.isha,
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des horaires de prière: $e');
    }
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si les services de localisation sont activés
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Les services de localisation sont désactivés');
    }

    // Vérifier les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Les permissions de localisation ont été refusées');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Les permissions de localisation sont définitivement refusées, nous ne pouvons pas demander les permissions');
    }

    // Obtenir la position
    return await Geolocator.getCurrentPosition();
  }

  String formatPrayerTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  String getTimeUntilNextPrayer(DateTime nextPrayerTime) {
    final now = DateTime.now();
    final difference = nextPrayerTime.difference(now);

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return '$hours heure${hours > 1 ? 's' : ''} et $minutes minute${minutes > 1 ? 's' : ''}';
    } else {
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    }
  }

  String findNextPrayer(Map<String, DateTime> prayerTimes) {
    final now = DateTime.now();
    String nextPrayer = '';
    DateTime? nextTime;

    for (var entry in prayerTimes.entries) {
      if (entry.value.isAfter(now)) {
        if (nextTime == null || entry.value.isBefore(nextTime)) {
          nextPrayer = entry.key;
          nextTime = entry.value;
        }
      }
    }

    return nextPrayer;
  }
}
