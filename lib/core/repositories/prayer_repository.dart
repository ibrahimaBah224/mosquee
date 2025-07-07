import '../models/prayer_time.dart';
import '../services/firestore_service.dart';
import '../di/dependency_injection.dart';

class PrayerRepository {
  final FirestoreService _firestoreService = getIt<FirestoreService>();

  Future<void> updatePrayerTimes(List<PrayerTime> prayerTimes) async {
    await _firestoreService.updatePrayerTimes(prayerTimes);
  }

  Future<List<PrayerTime>> getPrayerTimesForDate(DateTime date) async {
    return await _firestoreService.getPrayerTimesForDate(date);
  }

  Stream<List<PrayerTime>> watchPrayerTimesForDate(DateTime date) {
    return _firestoreService.watchPrayerTimesForDate(date);
  }

  Future<void> updateConfiguration(PrayerConfiguration config) async {
    await _firestoreService.updatePrayerConfiguration(config);
  }

  Future<PrayerConfiguration?> getConfiguration() async {
    return await _firestoreService.getPrayerConfiguration();
  }

  Future<void> adjustPrayerTime(String prayerId, int adjustmentMinutes) async {
    // Logique pour ajuster une prière spécifique
    final currentTimes = await getPrayerTimesForDate(DateTime.now());
    final prayerToUpdate = currentTimes.firstWhere((p) => p.id == prayerId);

    final updatedPrayer = prayerToUpdate.copyWith(
      adjustmentMinutes: adjustmentMinutes,
      updatedAt: DateTime.now(),
    );

    await updatePrayerTimes([updatedPrayer]);
  }

  Future<PrayerTime?> getNextPrayer() async {
    final today = DateTime.now();
    final prayerTimes = await getPrayerTimesForDate(today);

    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Trouver la prochaine prière du jour
    for (final prayer in prayerTimes) {
      if (prayer.isEnabled && prayer.adjustedTime.compareTo(currentTime) > 0) {
        return prayer;
      }
    }

    // Si aucune prière aujourd'hui, prendre la première de demain
    final tomorrow = today.add(const Duration(days: 1));
    final tomorrowPrayers = await getPrayerTimesForDate(tomorrow);
    return tomorrowPrayers.isNotEmpty ? tomorrowPrayers.first : null;
  }
}
