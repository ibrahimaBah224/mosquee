import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/imam.dart';

class ImamService {
  static final ImamService _instance = ImamService._internal();
  factory ImamService() => _instance;
  ImamService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'imams';

  /// Récupère tous les Imams actifs triés par ordre hiérarchique
  Future<List<Imam>> getAllImams() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      final imams = querySnapshot.docs.map((doc) {
        return Imam.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Trier localement par ordre hiérarchique
      imams.sort((a, b) => a.orderInHierarchy.compareTo(b.orderInHierarchy));

      return imams;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des Imams: $e');
      }
      return [];
    }
  }

  /// Récupère un Imam par son ID
  Future<Imam?> getImamById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();

      if (doc.exists) {
        return Imam.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération de l\'Imam $id: $e');
      }
      return null;
    }
  }

  /// Stream temps réel de tous les Imams
  Stream<List<Imam>> watchAllImams() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final imams = snapshot.docs.map((doc) {
        return Imam.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Trier localement par ordre hiérarchique
      imams.sort((a, b) => a.orderInHierarchy.compareTo(b.orderInHierarchy));

      return imams;
    });
  }

  /// Stream d'un Imam spécifique
  Stream<Imam?> watchImam(String id) {
    return _firestore
        .collection(_collectionName)
        .doc(id)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return Imam.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    });
  }

  /// Crée un nouvel Imam
  Future<String> createImam(Imam imam) async {
    try {
      final docRef =
          await _firestore.collection(_collectionName).add(imam.toFirestore());

      if (kDebugMode) {
        print('Imam ${imam.fullName} créé avec l\'ID: ${docRef.id}');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la création de l\'Imam: $e');
      }
      throw Exception('Erreur lors de la création: $e');
    }
  }

  /// Met à jour un Imam existant
  Future<void> updateImam(Imam imam) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(imam.id)
          .update(imam.toFirestore());

      if (kDebugMode) {
        print('Imam ${imam.fullName} mis à jour');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour de l\'Imam: $e');
      }
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

  /// Supprime un Imam (soft delete - marque comme inactif)
  Future<void> deleteImam(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print('Imam $id supprimé (soft delete)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la suppression de l\'Imam: $e');
      }
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  /// Suppression définitive (hard delete)
  Future<void> hardDeleteImam(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();

      if (kDebugMode) {
        print('Imam $id supprimé définitivement');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la suppression définitive: $e');
      }
      throw Exception('Erreur lors de la suppression définitive: $e');
    }
  }

  /// Récupère les Imams par rang
  Future<List<Imam>> getImamsByRank(ImamRank rank) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('rank', isEqualTo: rank.name)
          .where('isActive', isEqualTo: true)
          .get();

      final imams = querySnapshot.docs.map((doc) {
        return Imam.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Trier localement par ordre hiérarchique
      imams.sort((a, b) => a.orderInHierarchy.compareTo(b.orderInHierarchy));

      return imams;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des Imams par rang: $e');
      }
      return [];
    }
  }

  /// Récupère les Imams par spécialité
  Future<List<Imam>> getImamsBySpecialty(ImamSpecialty specialty) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('specialties', arrayContains: specialty.name)
          .where('isActive', isEqualTo: true)
          .get();

      final imams = querySnapshot.docs.map((doc) {
        return Imam.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Trier localement par ordre hiérarchique
      imams.sort((a, b) => a.orderInHierarchy.compareTo(b.orderInHierarchy));

      return imams;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des Imams par spécialité: $e');
      }
      return [];
    }
  }

  /// Récupère l'Imam principal
  Future<Imam?> getPrincipalImam() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('rank', isEqualTo: ImamRank.principal.name)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Imam.fromFirestore(
            querySnapshot.docs.first.data(), querySnapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération de l\'Imam principal: $e');
      }
      return null;
    }
  }

  /// Met à jour l'ordre hiérarchique
  Future<void> updateHierarchyOrder(List<String> imamIds) async {
    try {
      final batch = _firestore.batch();

      for (int i = 0; i < imamIds.length; i++) {
        final docRef = _firestore.collection(_collectionName).doc(imamIds[i]);
        batch.update(docRef, {
          'orderInHierarchy': i + 1,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      await batch.commit();

      if (kDebugMode) {
        print('Ordre hiérarchique mis à jour');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour de l\'ordre: $e');
      }
      throw Exception('Erreur lors de la mise à jour de l\'ordre: $e');
    }
  }

  /// Recherche d'Imams par nom
  Future<List<Imam>> searchImams(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      final allImams = querySnapshot.docs.map((doc) {
        return Imam.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Filtrer localement par nom (Firebase ne supporte pas les recherches textuelles complexes)
      final filteredImams = allImams.where((imam) {
        final searchLower = query.toLowerCase();
        return imam.firstName.toLowerCase().contains(searchLower) ||
            imam.lastName.toLowerCase().contains(searchLower) ||
            imam.fullNameArabic.toLowerCase().contains(searchLower);
      }).toList();

      // Trier par ordre hiérarchique
      filteredImams
          .sort((a, b) => a.orderInHierarchy.compareTo(b.orderInHierarchy));

      return filteredImams;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la recherche d\'Imams: $e');
      }
      return [];
    }
  }

  /// Statistiques des Imams
  Future<Map<String, dynamic>> getImamStats() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      final imams = querySnapshot.docs.map((doc) {
        return Imam.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Calcul des statistiques
      final stats = <String, dynamic>{
        'totalImams': imams.length,
        'byRank': <String, int>{},
        'bySpecialty': <String, int>{},
        'averageAge': 0.0,
        'totalServiceYears': 0,
        'activeImams': imams.where((i) => i.isActive).length,
      };

      // Statistiques par rang
      for (final rank in ImamRank.values) {
        stats['byRank'][rank.name] = imams.where((i) => i.rank == rank).length;
      }

      // Statistiques par spécialité
      for (final specialty in ImamSpecialty.values) {
        stats['bySpecialty'][specialty.name] =
            imams.where((i) => i.specialties.contains(specialty)).length;
      }

      // Âge moyen
      final agesWithValue =
          imams.where((i) => i.age != null).map((i) => i.age!).toList();
      if (agesWithValue.isNotEmpty) {
        stats['averageAge'] =
            agesWithValue.reduce((a, b) => a + b) / agesWithValue.length;
      }

      // Années de service totales
      final serviceYears = imams
          .where((i) => i.serviceYears != null)
          .map((i) => i.serviceYears!.inDays ~/ 365)
          .toList();
      if (serviceYears.isNotEmpty) {
        stats['totalServiceYears'] = serviceYears.reduce((a, b) => a + b);
      }

      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du calcul des statistiques: $e');
      }
      return {};
    }
  }

  /// Initialise des données d'exemple
  Future<void> initializeSampleImams() async {
    try {
      // Vérifier si des Imams existent déjà
      final existing = await getAllImams();
      if (existing.isNotEmpty) {
        if (kDebugMode) {
          print('Des Imams existent déjà, initialisation ignorée');
        }
        return;
      }

      final now = DateTime.now();
      final sampleImams = [
        Imam(
          id: '',
          firstName: 'Abdoulaye',
          lastName: 'Camara',
          fullNameArabic: 'عبد الله كامارا',
          rank: ImamRank.principal,
          orderInHierarchy: 1,
          specialties: [
            ImamSpecialty.khutba,
            ImamSpecialty.marriage,
            ImamSpecialty.general
          ],
          phone: '+224 XX XX XX XX',
          email: 'imam.principal@elhadj-daouda.org',
          address: 'Quartier Madina, Conakry',
          birthDate: DateTime(1975, 5, 15),
          nationality: 'Guinéenne',
          education: 'Université Al-Azhar, Le Caire',
          certifications: 'Ijaza en Fiqh et Hadith',
          languages: ['Français', 'Arabe', 'Peul', 'Malinké'],
          biography:
              'Imam principal de la mosquée depuis 2010, formé à Al-Azhar.',
          weeklySchedule: {
            'Vendredi': ['12:00-14:00'], // Khutba
            'Dimanche': ['09:00-11:00'], // Cours
          },
          isActive: true,
          startDate: DateTime(2010, 3, 1),
          createdAt: now,
          updatedAt: now,
          createdBy: 'system',
        ),
        Imam(
          id: '',
          firstName: 'Mohamed',
          lastName: 'Diallo',
          fullNameArabic: 'محمد ديالو',
          rank: ImamRank.adjoint,
          orderInHierarchy: 2,
          specialties: [ImamSpecialty.courses, ImamSpecialty.tarawih],
          phone: '+224 XX XX XX XX',
          email: 'imam.adjoint@elhadj-daouda.org',
          address: 'Quartier Kaloum, Conakry',
          birthDate: DateTime(1980, 8, 22),
          nationality: 'Guinéenne',
          education: 'Institut Islamique de Conakry',
          languages: ['Français', 'Arabe', 'Soussou'],
          biography:
              'Spécialisé dans l\'enseignement coranique et les cours pour jeunes.',
          weeklySchedule: {
            'Samedi': ['14:00-16:00'], // Cours enfants
            'Dimanche': ['14:00-16:00'], // Cours adultes
          },
          isActive: true,
          startDate: DateTime(2015, 9, 1),
          createdAt: now,
          updatedAt: now,
          createdBy: 'system',
        ),
        Imam(
          id: '',
          firstName: 'Ibrahim',
          lastName: 'Touré',
          fullNameArabic: 'إبراهيم توري',
          rank: ImamRank.assistant,
          orderInHierarchy: 3,
          specialties: [ImamSpecialty.funeral, ImamSpecialty.general],
          phone: '+224 XX XX XX XX',
          email: 'imam.assistant@elhadj-daouda.org',
          birthDate: DateTime(1985, 12, 10),
          nationality: 'Guinéenne',
          education: 'Formation locale en sciences islamiques',
          languages: ['Français', 'Arabe'],
          biography:
              'Assistant pour les services quotidiens et les cérémonies.',
          isActive: true,
          startDate: DateTime(2018, 1, 15),
          createdAt: now,
          updatedAt: now,
          createdBy: 'system',
        ),
      ];

      for (final imam in sampleImams) {
        await createImam(imam);
      }

      if (kDebugMode) {
        print('✅ Imams d\'exemple créés avec succès');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de l\'initialisation des Imams: $e');
      }
    }
  }
}
