import '../models/donation.dart';
import '../services/firestore_service.dart';
import '../di/dependency_injection.dart';

class DonationRepository {
  final FirestoreService _firestoreService = getIt<FirestoreService>();

  Future<String> createDonation(Donation donation) async {
    return await _firestoreService.createDonation(donation);
  }

  Future<void> updateDonation(Donation donation) async {
    await _firestoreService.updateDonation(donation);
  }

  Future<List<Donation>> getUserDonations(String userId) async {
    return await _firestoreService.getUserDonations(userId);
  }

  Stream<List<DonationCampaign>> watchActiveCampaigns() {
    return _firestoreService.watchActiveCampaigns();
  }

  Future<void> completeDonation(String donationId, String transactionId) async {
    // Logique pour marquer un don comme complété
    // Cette méthode nécessiterait de récupérer le don d'abord
  }

  Future<Map<String, double>> getDonationStatsByType() async {
    // Récupérer les statistiques de dons par type
    // Cette fonctionnalité nécessiterait une requête agrégée
    return {
      'zakat': 0.0,
      'sadaqah': 0.0,
      'masjid': 0.0,
      'education': 0.0,
      'charity': 0.0,
      'emergency': 0.0,
    };
  }

  Future<double> getTotalDonationsThisMonth() async {
    // Calculer le total des dons du mois en cours
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    // Cette fonctionnalité nécessiterait une requête avec filtre de date
    return 0.0;
  }

  Future<List<Donation>> getRecentDonations({int limit = 10}) async {
    // Récupérer les dons récents
    // Cette méthode nécessiterait d'être ajoutée au FirestoreService
    return [];
  }
}
