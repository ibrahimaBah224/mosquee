import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/mosque_info.dart';

class MosqueService {
  static final MosqueService _instance = MosqueService._internal();
  factory MosqueService() => _instance;
  MosqueService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'mosque_info';
  static const String _docId = 'main';

  MosqueInfo? _cachedInfo;

  /// Récupère les informations de la mosquée (avec cache)
  Future<MosqueInfo?> getMosqueInfo() async {
    try {
      if (_cachedInfo != null) {
        return _cachedInfo;
      }

      final doc =
          await _firestore.collection(_collectionName).doc(_docId).get();

      if (doc.exists) {
        _cachedInfo = MosqueInfo.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
        return _cachedInfo;
      }

      // Si aucune info n'existe, créer les données par défaut
      final defaultInfo = _createDefaultMosqueInfo();
      await _firestore
          .collection(_collectionName)
          .doc(_docId)
          .set(defaultInfo.toFirestore());
      _cachedInfo = defaultInfo;
      return defaultInfo;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des infos mosquée: $e');
      }
      return _createDefaultMosqueInfo();
    }
  }

  /// Stream temps réel des informations de la mosquée
  Stream<MosqueInfo?> watchMosqueInfo() {
    return _firestore
        .collection(_collectionName)
        .doc(_docId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        final info = MosqueInfo.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
        _cachedInfo = info; // Mettre à jour le cache
        return info;
      }
      return null;
    });
  }

  /// Met à jour les informations de la mosquée
  Future<void> updateMosqueInfo(MosqueInfo info) async {
    try {
      final updatedInfo = info.copyWith(
        updatedAt: DateTime.now(),
        lastUpdatedBy: 'admin', // TODO: Récupérer l'utilisateur connecté
      );

      await _firestore
          .collection(_collectionName)
          .doc(_docId)
          .set(updatedInfo.toFirestore());

      _cachedInfo = updatedInfo; // Mettre à jour le cache

      if (kDebugMode) {
        print('Informations mosquée mises à jour avec succès');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour des infos mosquée: $e');
      }
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

  /// Vide le cache (à utiliser après mise à jour)
  void clearCache() {
    _cachedInfo = null;
  }

  /// Vérifie si les informations existent
  Future<bool> mosqueInfoExists() async {
    try {
      final doc =
          await _firestore.collection(_collectionName).doc(_docId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Crée les informations par défaut pour la mosquée Elhadj Daouda
  MosqueInfo _createDefaultMosqueInfo() {
    return MosqueInfo(
      id: _docId,
      name: 'Mosquée Elhadj Daouda',
      nameArabic: 'مسجد الحاج داوودا',
      slogan: 'Bienvenue dans la maison d\'Allah',
      description:
          'Une mosquée moderne au service de la communauté musulmane de Conakry, offrant des services religieux, éducatifs et sociaux.',

      // Localisation Conakry
      address: 'Quartier de Madina',
      city: 'Conakry',
      country: 'Guinée',
      latitude: 9.5380,
      longitude: -13.6773,
      timezone: 'Africa/Conakry',

      // Contact
      phone: '+224 XX XX XX XX',
      email: 'contact@elhadj-daouda.org',
      website: 'https://elhadj-daouda.org',
      supportEmail: 'support@elhadj-daouda.org',

      // Réseaux sociaux
      facebookUrl: 'https://facebook.com/mosquee-elhadj-daouda',
      instagramUrl: 'https://instagram.com/mosquee_elhadj_daouda',
      youtubeUrl: 'https://youtube.com/c/mosquee-elhadj-daouda',

      // Horaires d'ouverture (24h/24 typique pour une mosquée)
      openingHours: {
        'Lundi': '05:00 - 22:00',
        'Mardi': '05:00 - 22:00',
        'Mercredi': '05:00 - 22:00',
        'Jeudi': '05:00 - 22:00',
        'Vendredi': '05:00 - 23:00', // Plus tard pour la prière du vendredi
        'Samedi': '05:00 - 22:00',
        'Dimanche': '05:00 - 22:00',
      },

      // Responsables
      imamName: 'Imam Abdoulaye Camara',
      imamPhone: '+224 XX XX XX XX',
      imamEmail: 'imam@elhadj-daouda.org',
      presidentName: 'Président Alpha Diallo',
      presidentPhone: '+224 XX XX XX XX',
      presidentEmail: 'president@elhadj-daouda.org',

      // Informations financières (typiques pour la Guinée)
      mobileMoneyNumber: '+224 XX XX XX XX', // Orange/MTN Money
      bankAccount: 'Compte bancaire: XXXX-XXXX-XXXX',

      // Capacité et équipements
      capacity: 500,
      hasParking: true,
      hasWuduArea: true,
      hasWomenSection: true,
      hasChildrenArea: true,
      hasLibrary: true,
      hasClassrooms: true,
      hasKitchen: true,
      isWheelchairAccessible: false,

      // Services
      services: [
        'Prières quotidiennes',
        'Prière du vendredi',
        'Cours de Coran',
        'École coranique',
        'Mariage religieux',
        'Consultation religieuse',
        'Cours d\'arabe',
        'Conférences religieuses',
        'Services funéraires',
        'Aide sociale',
      ],

      // Configuration app
      appVersion: '1.0.0',
      logoUrl: '',
      bannerImageUrl: '',
      primaryColor: '#2E7D32',
      secondaryColor: '#1565C0',

      // Métadonnées
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastUpdatedBy: 'system',
    );
  }

  /// Initialise les données par défaut si elles n'existent pas
  Future<void> initializeDefaultData() async {
    try {
      final exists = await mosqueInfoExists();
      if (!exists) {
        final defaultInfo = _createDefaultMosqueInfo();
        await _firestore
            .collection(_collectionName)
            .doc(_docId)
            .set(defaultInfo.toFirestore());

        if (kDebugMode) {
          print('Données par défaut de la mosquée créées');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'initialisation des données: $e');
      }
    }
  }
}
