import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/muezzin.dart';
import 'notification_service.dart';

class MuezzinService {
  static final MuezzinService _instance = MuezzinService._internal();
  factory MuezzinService() => _instance;
  MuezzinService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'muezzins';

  /// Récupère tous les Muezzins actifs
  Future<List<Muezzin>> getAllMuezzins() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      final muezzins = querySnapshot.docs.map((doc) {
        return Muezzin.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Trier localement par statut
      muezzins.sort((a, b) => a.status.index.compareTo(b.status.index));

      return muezzins;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des Muezzins: $e');
      }
      return [];
    }
  }

  /// Récupère un Muezzin par son ID
  Future<Muezzin?> getMuezzinById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();

      if (doc.exists) {
        return Muezzin.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération du Muezzin $id: $e');
      }
      return null;
    }
  }

  /// Stream temps réel de tous les Muezzins
  Stream<List<Muezzin>> watchAllMuezzins() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final muezzins = snapshot.docs.map((doc) {
        return Muezzin.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Trier localement par statut
      muezzins.sort((a, b) => a.status.index.compareTo(b.status.index));

      return muezzins;
    });
  }

  /// Stream d'un Muezzin spécifique
  Stream<Muezzin?> watchMuezzin(String id) {
    return _firestore
        .collection(_collectionName)
        .doc(id)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return Muezzin.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    });
  }

  /// Crée un nouveau Muezzin
  Future<String> createMuezzin(Muezzin muezzin) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(muezzin.toFirestore());

      if (kDebugMode) {
        print('Muezzin ${muezzin.fullName} créé avec l\'ID: ${docRef.id}');
      }

      // 🔔 Envoyer notification push pour nouveau Muezzin
      try {
        await NotificationService().notifyNewStaffMember(
          memberName: muezzin.fullName,
          position: _getStatusDisplayName(muezzin.status),
          staffType: StaffType.muezzin,
        );
      } catch (notifError) {
        if (kDebugMode) {
          print('⚠️ Erreur notification pour nouveau Muezzin: $notifError');
        }
        // Continue même si la notification échoue
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la création du Muezzin: $e');
      }
      throw Exception('Erreur lors de la création: $e');
    }
  }

  /// Obtient le nom d'affichage du statut
  String _getStatusDisplayName(MuezzinStatus status) {
    switch (status) {
      case MuezzinStatus.principal:
        return 'Muezzin Principal';
      case MuezzinStatus.assistant:
        return 'Muezzin Assistant';
      case MuezzinStatus.remplacant:
        return 'Muezzin Remplaçant';
    }
  }

  /// Met à jour un Muezzin existant
  Future<void> updateMuezzin(Muezzin muezzin) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(muezzin.id)
          .update(muezzin.toFirestore());

      if (kDebugMode) {
        print('Muezzin ${muezzin.fullName} mis à jour');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour du Muezzin: $e');
      }
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

  /// Supprime un Muezzin (soft delete - marque comme inactif)
  Future<void> deleteMuezzin(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print('Muezzin $id supprimé (soft delete)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la suppression du Muezzin: $e');
      }
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  /// Suppression définitive (hard delete)
  Future<void> hardDeleteMuezzin(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();

      if (kDebugMode) {
        print('Muezzin $id supprimé définitivement');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la suppression définitive: $e');
      }
      throw Exception('Erreur lors de la suppression définitive: $e');
    }
  }

  /// Récupère les Muezzins par statut
  Future<List<Muezzin>> getMuezzinsByStatus(MuezzinStatus status) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: status.name)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Muezzin.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des Muezzins par statut: $e');
      }
      return [];
    }
  }

  /// Récupère les Muezzins assignés à une prière spécifique
  Future<List<Muezzin>> getMuezzinsByPrayer(PrayerAssignment prayer) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('assignedPrayers', arrayContains: prayer.name)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Muezzin.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des Muezzins par prière: $e');
      }
      return [];
    }
  }

  /// Récupère le Muezzin principal
  Future<Muezzin?> getPrincipalMuezzin() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: MuezzinStatus.principal.name)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Muezzin.fromFirestore(
            querySnapshot.docs.first.data(), querySnapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération du Muezzin principal: $e');
      }
      return null;
    }
  }

  /// Récupère les Muezzins disponibles pour une prière et un jour donnés
  Future<List<Muezzin>> getAvailableMuezzins(String day, String prayer) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      final allMuezzins = querySnapshot.docs.map((doc) {
        return Muezzin.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Filtrer par disponibilité
      final availableMuezzins = allMuezzins.where((muezzin) {
        final dayAvailability = muezzin.weeklyAvailability[day];
        if (dayAvailability == null) return false;
        return dayAvailability[prayer] == true;
      }).toList();

      return availableMuezzins;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des Muezzins disponibles: $e');
      }
      return [];
    }
  }

  /// Recherche de Muezzins par nom
  Future<List<Muezzin>> searchMuezzins(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      final allMuezzins = querySnapshot.docs.map((doc) {
        return Muezzin.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Filtrer localement par nom
      final filteredMuezzins = allMuezzins.where((muezzin) {
        final searchLower = query.toLowerCase();
        return muezzin.firstName.toLowerCase().contains(searchLower) ||
            muezzin.lastName.toLowerCase().contains(searchLower) ||
            muezzin.fullNameArabic.toLowerCase().contains(searchLower);
      }).toList();

      return filteredMuezzins;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la recherche de Muezzins: $e');
      }
      return [];
    }
  }

  /// Récupère les Muezzins qui ont besoin d'évaluation
  Future<List<Muezzin>> getMuezzinsNeedingEvaluation() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      final allMuezzins = querySnapshot.docs.map((doc) {
        return Muezzin.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Filtrer ceux qui ont besoin d'évaluation
      final needingEvaluation =
          allMuezzins.where((muezzin) => muezzin.needsEvaluation).toList();

      return needingEvaluation;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des Muezzins à évaluer: $e');
      }
      return [];
    }
  }

  /// Ajoute un feedback pour un Muezzin
  Future<void> addFeedback(String muezzinId, String feedback) async {
    try {
      final muezzin = await getMuezzinById(muezzinId);
      if (muezzin != null) {
        final updatedFeedback = List<String>.from(muezzin.feedback)
          ..add(feedback);
        final updatedMuezzin = muezzin.copyWith(
          feedback: updatedFeedback,
          updatedAt: DateTime.now(),
        );

        await updateMuezzin(updatedMuezzin);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'ajout du feedback: $e');
      }
      throw Exception('Erreur lors de l\'ajout du feedback: $e');
    }
  }

  /// Met à jour la note de performance
  Future<void> updatePerformanceRating(String muezzinId, double rating) async {
    try {
      await _firestore.collection(_collectionName).doc(muezzinId).update({
        'performanceRating': rating,
        'lastEvaluation': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print('Note de performance mise à jour pour $muezzinId: $rating');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour de la note: $e');
      }
      throw Exception('Erreur lors de la mise à jour de la note: $e');
    }
  }

  /// Statistiques des Muezzins
  Future<Map<String, dynamic>> getMuezzinStats() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      final muezzins = querySnapshot.docs.map((doc) {
        return Muezzin.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Calcul des statistiques
      final stats = <String, dynamic>{
        'totalMuezzins': muezzins.length,
        'byStatus': <String, int>{},
        'byEmploymentType': <String, int>{},
        'averageRating': 0.0,
        'needingEvaluation': 0,
        'volunteers': muezzins.where((m) => m.isVolunteer).length,
        'employees': muezzins.where((m) => !m.isVolunteer).length,
      };

      // Statistiques par statut
      for (final status in MuezzinStatus.values) {
        stats['byStatus'][status.name] =
            muezzins.where((m) => m.status == status).length;
      }

      // Note moyenne
      final ratingsWithValue = muezzins
          .where((m) => m.performanceRating != null)
          .map((m) => m.performanceRating!)
          .toList();
      if (ratingsWithValue.isNotEmpty) {
        stats['averageRating'] =
            ratingsWithValue.reduce((a, b) => a + b) / ratingsWithValue.length;
      }

      // Muezzins ayant besoin d'évaluation
      stats['needingEvaluation'] =
          muezzins.where((m) => m.needsEvaluation).length;

      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du calcul des statistiques: $e');
      }
      return {};
    }
  }

  /// Initialise des données d'exemple
  Future<void> initializeSampleMuezzins() async {
    try {
      // Vérifier si des Muezzins existent déjà
      final existing = await getAllMuezzins();
      if (existing.isNotEmpty) {
        if (kDebugMode) {
          print('Des Muezzins existent déjà, initialisation ignorée');
        }
        return;
      }

      final now = DateTime.now();
      final sampleMuezzins = [
        Muezzin(
          id: '',
          firstName: 'Ousmane',
          lastName: 'Barry',
          fullNameArabic: 'عثمان باري',
          status: MuezzinStatus.principal,
          assignedPrayers: [PrayerAssignment.all],
          phone: '+224 XX XX XX XX',
          email: 'muezzin.principal@elhadj-daouda.org',
          address: 'Quartier Madina, Conakry',
          birthDate: DateTime(1988, 3, 12),
          nationality: 'Guinéenne',
          voiceQuality: 'Excellente, voix claire et mélodieuse',
          recitationStyles: ['Hafs', 'Warsh'],
          training: 'Formation en récitation coranique à Conakry',
          experience: '8 ans d\'expérience comme muezzin',
          weeklyAvailability: {
            'Lundi': {
              'fajr': true,
              'dhuhr': true,
              'asr': true,
              'maghrib': true,
              'isha': true
            },
            'Mardi': {
              'fajr': true,
              'dhuhr': true,
              'asr': true,
              'maghrib': true,
              'isha': true
            },
            'Mercredi': {
              'fajr': true,
              'dhuhr': true,
              'asr': true,
              'maghrib': true,
              'isha': true
            },
            'Jeudi': {
              'fajr': true,
              'dhuhr': true,
              'asr': true,
              'maghrib': true,
              'isha': true
            },
            'Vendredi': {
              'fajr': true,
              'dhuhr': true,
              'asr': true,
              'maghrib': true,
              'isha': true
            },
            'Samedi': {
              'fajr': true,
              'dhuhr': true,
              'asr': true,
              'maghrib': true,
              'isha': true
            },
            'Dimanche': {
              'fajr': true,
              'dhuhr': true,
              'asr': true,
              'maghrib': true,
              'isha': true
            },
          },
          specialOccasions: ['Ramadan', 'Aïd', 'Vendredi'],
          isActive: true,
          isVolunteer: false,
          startDate: DateTime(2016, 6, 1),
          monthlyCompensation: 150000.0, // Francs guinéens
          languages: ['Français', 'Arabe', 'Peul'],
          canReadArabic: true,
          canMemorizeQuran: true,
          quranMemorization: 'Hafiz (mémorisation complète)',
          performanceRating: 4.8,
          feedback: [
            'Excellente voix',
            'Très ponctuel',
            'Récitation magnifique'
          ],
          lastEvaluation: DateTime.now().subtract(const Duration(days: 90)),
          createdAt: now,
          updatedAt: now,
          createdBy: 'system',
        ),
        Muezzin(
          id: '',
          firstName: 'Mamadou',
          lastName: 'Sow',
          fullNameArabic: 'محمدو سو',
          status: MuezzinStatus.assistant,
          assignedPrayers: [
            PrayerAssignment.fajr,
            PrayerAssignment.maghrib,
            PrayerAssignment.isha
          ],
          phone: '+224 XX XX XX XX',
          address: 'Quartier Kaloum, Conakry',
          birthDate: DateTime(1992, 7, 25),
          nationality: 'Guinéenne',
          voiceQuality: 'Bonne, voix grave et apaisante',
          recitationStyles: ['Hafs'],
          training: 'Auto-formation et cours avec l\'Imam',
          weeklyAvailability: {
            'Lundi': {'fajr': true, 'maghrib': true, 'isha': true},
            'Mardi': {'fajr': true, 'maghrib': true, 'isha': true},
            'Mercredi': {'fajr': true, 'maghrib': true, 'isha': true},
            'Jeudi': {'fajr': true, 'maghrib': true, 'isha': true},
            'Vendredi': {'fajr': true, 'maghrib': true, 'isha': true},
            'Samedi': {'fajr': true, 'maghrib': true, 'isha': true},
            'Dimanche': {
              'fajr': false,
              'maghrib': true,
              'isha': true
            }, // Repos dimanche matin
          },
          isActive: true,
          isVolunteer: true,
          startDate: DateTime(2019, 2, 15),
          languages: ['Français', 'Arabe', 'Soussou'],
          canReadArabic: true,
          canMemorizeQuran: false,
          quranMemorization: 'Juz Amma (dernière partie)',
          performanceRating: 4.2,
          feedback: ['Ponctuel', 'Bonne articulation'],
          lastEvaluation: DateTime.now().subtract(const Duration(days: 45)),
          createdAt: now,
          updatedAt: now,
          createdBy: 'system',
        ),
        Muezzin(
          id: '',
          firstName: 'Ibrahim',
          lastName: 'Camara',
          fullNameArabic: 'إبراهيم كامارا',
          status: MuezzinStatus.remplacant,
          assignedPrayers: [PrayerAssignment.dhuhr, PrayerAssignment.asr],
          phone: '+224 XX XX XX XX',
          birthDate: DateTime(1995, 11, 8),
          nationality: 'Guinéenne',
          voiceQuality: 'Voix jeune et claire',
          training: 'Formation en cours',
          weeklyAvailability: {
            'Mercredi': {'dhuhr': true, 'asr': true},
            'Jeudi': {'dhuhr': true, 'asr': true},
            'Vendredi': {'dhuhr': true, 'asr': true},
            'Samedi': {'dhuhr': true, 'asr': true},
            'Dimanche': {'dhuhr': true, 'asr': true},
          },
          isActive: true,
          isVolunteer: true,
          startDate: DateTime(2022, 5, 1),
          languages: ['Français', 'Arabe'],
          canReadArabic: true,
          canMemorizeQuran: false,
          quranMemorization: 'En apprentissage',
          performanceRating: 3.8,
          feedback: ['Motivé', 'En progression'],
          createdAt: now,
          updatedAt: now,
          createdBy: 'system',
        ),
      ];

      for (final muezzin in sampleMuezzins) {
        await createMuezzin(muezzin);
      }

      if (kDebugMode) {
        print('✅ Muezzins d\'exemple créés avec succès');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de l\'initialisation des Muezzins: $e');
      }
    }
  }
}
