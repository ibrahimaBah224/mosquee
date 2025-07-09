import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../models/prayer_time.dart';
import '../models/event.dart';
import '../models/donation.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _prayerTimesCollection =>
      _firestore.collection('prayer_times');
  CollectionReference get _prayerConfigCollection =>
      _firestore.collection('prayer_config');
  CollectionReference get _eventsCollection => _firestore.collection('events');
  CollectionReference get _donationsCollection =>
      _firestore.collection('donations');
  CollectionReference get _donationCampaignsCollection =>
      _firestore.collection('donation_campaigns');

  /// Initialize Firestore with settings
  Future<void> initialize() async {
    try {
      // Configuration Web spécifique avec timeout augmenté
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Activer le réseau explicitement
      await _firestore.enableNetwork();

      if (kDebugMode) {
        print('Firestore Service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firestore Service: $e');
        print('Continuing with default settings...');
      }
      // Continue même en cas d'erreur d'initialisation
    }
  }

  /// Méthode utilitaire pour retry automatique
  Future<T> _retryOperation<T>(Future<T> Function() operation,
      {int maxRetries = 3}) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        debugPrint('Tentative ${attempt + 1}/$maxRetries échouée: $e');

        if (attempt == maxRetries - 1) {
          // Dernière tentative échouée
          throw e;
        }

        // Attendre avant la prochaine tentative (backoff exponentiel)
        await Future.delayed(Duration(seconds: (attempt + 1) * 2));

        // Réactiver le réseau si nécessaire
        try {
          await _firestore.enableNetwork();
        } catch (networkError) {
          debugPrint('Erreur lors de la réactivation réseau: $networkError');
        }
      }
    }
    throw Exception('Toutes les tentatives ont échoué');
  }

  // =============== USER PROFILES ===============

  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await _usersCollection.doc(profile.id).set(profile.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la création du profil: $e');
    }
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _usersCollection.doc(profile.id).update(profile.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  Stream<UserProfile?> watchUserProfile(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  // =============== PRAYER TIMES ===============

  Future<void> updatePrayerTimes(List<PrayerTime> prayerTimes) async {
    final batch = _firestore.batch();

    for (final prayer in prayerTimes) {
      final ref = _prayerTimesCollection.doc(prayer.id);
      batch.set(ref, prayer.toFirestore());
    }

    await batch.commit();
  }

  Future<List<PrayerTime>> getPrayerTimesForDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final query = await _prayerTimesCollection
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThan: endOfDay.toIso8601String())
          .get();

      final prayerTimes = query.docs
          .map((doc) => PrayerTime.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Trier côté client
      prayerTimes.sort((a, b) => a.date.compareTo(b.date));
      return prayerTimes;
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération des heures de prière: $e');
    }
  }

  Stream<List<PrayerTime>> watchPrayerTimesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _prayerTimesCollection
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThan: endOfDay.toIso8601String())
        .snapshots()
        .map((snapshot) {
      final prayerTimes = snapshot.docs
          .map((doc) => PrayerTime.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Trier côté client
      prayerTimes.sort((a, b) => a.date.compareTo(b.date));
      return prayerTimes;
    });
  }

  Future<void> updatePrayerConfiguration(PrayerConfiguration config) async {
    try {
      await _prayerConfigCollection.doc('main').set(config.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la configuration: $e');
    }
  }

  Future<PrayerConfiguration?> getPrayerConfiguration() async {
    try {
      final doc = await _prayerConfigCollection.doc('main').get();
      if (doc.exists) {
        return PrayerConfiguration.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la configuration: $e');
    }
  }

  // =============== EVENTS ===============

  Future<String> createEvent(Event event) async {
    try {
      final docRef = await _eventsCollection.add(event.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'événement: $e');
    }
  }

  Future<void> updateEvent(Event event) async {
    try {
      await _eventsCollection.doc(event.id).update(event.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'événement: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventsCollection.doc(eventId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'événement: $e');
    }
  }

  Future<Event?> getEvent(String eventId) async {
    try {
      final doc = await _eventsCollection.doc(eventId).get();
      if (doc.exists) {
        return Event.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'événement: $e');
    }
  }

  Stream<List<Event>> watchPublishedEvents() {
    debugPrint('🔍 Starting watchPublishedEvents query...');

    // Stratégie avec gestion d'erreur améliorée
    return _eventsCollection
        .snapshots()
        .timeout(const Duration(seconds: 10))
        .handleError((error) {
      debugPrint('⚠️ Stream error: $error');
      // En cas d'erreur, essayer le cache
      return _eventsCollection
          .get(const GetOptions(source: Source.cache))
          .then((snapshot) => Stream.value(snapshot));
    }).map((snapshot) {
      debugPrint(
          '🔍 All Events query result: ${snapshot.docs.length} documents');

      final events = <Event>[];
      for (var doc in snapshot.docs) {
        try {
          debugPrint('📄 Event document ID: ${doc.id}');
          final data = doc.data() as Map<String, dynamic>;
          debugPrint('📄 Event data: $data');
          debugPrint('📄 Event status: ${data['status']}');

          final event = Event.fromFirestore(data, doc.id);

          // Filtrer seulement les événements publiés
          if (event.status == EventStatus.published) {
            events.add(event);
            debugPrint('✅ Published event added: ${event.title}');
          } else {
            debugPrint(
                '⏭️ Skipped non-published event: ${event.title} (status: ${event.status})');
          }
        } catch (e) {
          debugPrint('❌ Error parsing event ${doc.id}: $e');
          debugPrint('📄 Problematic data: ${doc.data()}');
        }
      }

      // Trier côté client pour éviter les index composites
      events.sort((a, b) => b.startDate.compareTo(a.startDate));
      debugPrint('📊 Final events count: ${events.length}');

      // Debug: afficher tous les titres
      for (var event in events) {
        debugPrint('📋 Event: ${event.title} - ${event.startDate}');
      }

      return events;
    });
  }

  /// Méthode de debug pour récupérer tous les événements
  Stream<List<Event>> watchAllEvents() {
    debugPrint('🔍 Starting watchAllEvents query (DEBUG)...');
    return _eventsCollection.snapshots().map((snapshot) {
      debugPrint(
          '🔍 All Events (DEBUG) query result: ${snapshot.docs.length} documents');

      final events = <Event>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final event = Event.fromFirestore(data, doc.id);
          events.add(event);
          debugPrint(
              '✅ Event (DEBUG): ${event.title} - Status: ${event.status}');
        } catch (e) {
          debugPrint('❌ Error parsing event ${doc.id}: $e');
        }
      }

      events.sort((a, b) => b.startDate.compareTo(a.startDate));
      debugPrint('📊 Total events (DEBUG): ${events.length}');
      return events;
    });
  }

  /// Récupérer tous les événements (pour debug)
  Future<List<Event>> getAllEvents() async {
    return await _retryOperation(() async {
      debugPrint('🔍 Getting all events (Future)...');
      final query = await _eventsCollection.get();

      final events = <Event>[];
      for (var doc in query.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final event = Event.fromFirestore(data, doc.id);
          events.add(event);
          debugPrint(
              '✅ Event loaded: ${event.title} - Status: ${event.status}');
        } catch (e) {
          debugPrint('❌ Error parsing event ${doc.id}: $e');
        }
      }

      events.sort((a, b) => b.startDate.compareTo(a.startDate));
      debugPrint('📊 Total events loaded: ${events.length}');
      return events;
    });
  }

  /// Stream pour récupérer tous les événements (admin)
  Stream<List<Event>> getAllEventsStream() {
    debugPrint('🔍 Starting getAllEventsStream query...');
    return _eventsCollection
        .snapshots()
        .timeout(const Duration(seconds: 10))
        .handleError((error) {
      debugPrint('⚠️ Stream error: $error');
      return _eventsCollection
          .get(const GetOptions(source: Source.cache))
          .then((snapshot) => Stream.value(snapshot));
    }).map((snapshot) {
      debugPrint(
          '🔍 All Events stream result: ${snapshot.docs.length} documents');

      final events = <Event>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final event = Event.fromFirestore(data, doc.id);
          events.add(event);
          debugPrint(
              '✅ Event loaded: ${event.title} - Status: ${event.status}');
        } catch (e) {
          debugPrint('❌ Error parsing event ${doc.id}: $e');
        }
      }

      events.sort((a, b) => b.startDate.compareTo(a.startDate));
      debugPrint('📊 Total events in stream: ${events.length}');
      return events;
    });
  }

  /// Mettre à jour le statut d'un événement
  Future<void> updateEventStatus(String eventId, EventStatus status) async {
    try {
      await _eventsCollection.doc(eventId).update({
        'status': status.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Event status updated: $eventId -> ${status.name}');
    } catch (e) {
      debugPrint('❌ Error updating event status: $e');
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  Future<List<Event>> getUpcomingEvents({int limit = 10}) async {
    try {
      // Simplifier la requête pour éviter les index composites
      final query =
          await _eventsCollection.where('status', isEqualTo: 'published').get();

      final events = query.docs
          .map((doc) =>
              Event.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .where((event) => event.startDate.isAfter(DateTime.now()))
          .toList();

      // Trier et limiter côté client
      events.sort((a, b) => a.startDate.compareTo(b.startDate));
      return events.take(limit).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des événements: $e');
    }
  }

  // =============== DONATIONS ===============

  Future<String> createDonation(Donation donation) async {
    try {
      final docRef = await _donationsCollection.add(donation.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création du don: $e');
    }
  }

  Future<void> updateDonation(Donation donation) async {
    try {
      await _donationsCollection
          .doc(donation.id)
          .update(donation.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du don: $e');
    }
  }

  Future<List<Donation>> getUserDonations(String userId) async {
    try {
      final query =
          await _donationsCollection.where('userId', isEqualTo: userId).get();

      final donations = query.docs
          .map((doc) => Donation.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Trier côté client
      donations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return donations;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des dons: $e');
    }
  }

  Stream<List<DonationCampaign>> watchActiveCampaigns() {
    return _donationCampaignsCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final campaigns = snapshot.docs
          .map((doc) => DonationCampaign.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .where((campaign) => campaign.endDate.isAfter(DateTime.now()))
          .toList();

      // Trier côté client
      campaigns.sort((a, b) => a.endDate.compareTo(b.endDate));
      return campaigns;
    });
  }

  // =============== DEBUG AND TESTING METHODS ===============

  /// Crée des événements d'exemple pour tester l'application
  Future<void> createSampleEvents() async {
    try {
      final now = DateTime.now();
      debugPrint('🔧 Creating sample events...');

      // Événement 1: Prière du vendredi
      final event1 = Event(
        id: 'sample_1',
        title: 'Prière du Vendredi',
        description:
            'Prière collective du vendredi avec sermon. Tous les fidèles sont invités à participer à cette prière hebdomadaire.',
        category: EventCategory.religious,
        status: EventStatus.published, // Explicitement published
        startDate:
            now.add(const Duration(days: 2)).copyWith(hour: 12, minute: 30),
        endDate: now.add(const Duration(days: 2)).copyWith(hour: 14, minute: 0),
        location: 'Mosquée Elhadj Daouda - Salle principale',
        maxParticipants: 200,
        currentParticipants: 45,
        requiresRegistration: false,
        organizer: 'Imam Ahmed',
        tags: ['prière', 'vendredi', 'sermon'],
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      // Événement 2: Cours de Coran
      final event2 = Event(
        id: 'sample_2',
        title: 'Cours de Coran pour Enfants',
        description:
            'Cours d\'apprentissage du Coran destiné aux enfants de 6 à 12 ans. Inscription obligatoire.',
        category: EventCategory.educational,
        status: EventStatus.published, // Explicitement published
        startDate:
            now.add(const Duration(days: 5)).copyWith(hour: 16, minute: 0),
        endDate: now.add(const Duration(days: 5)).copyWith(hour: 18, minute: 0),
        location: 'Mosquée Elhadj Daouda - Salle de cours',
        maxParticipants: 30,
        currentParticipants: 18,
        requiresRegistration: true,
        organizer: 'Professeur Fatou',
        tags: ['coran', 'enfants', 'éducation'],
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      // Événement 3: Soirée Ramadan
      final event3 = Event(
        id: 'sample_3',
        title: 'Soirée Ramadan Communautaire',
        description:
            'Soirée de rupture du jeûne en communauté avec repas partagé et récitation du Coran.',
        category: EventCategory.community,
        status: EventStatus.published, // Explicitement published
        startDate:
            now.add(const Duration(days: 10)).copyWith(hour: 19, minute: 0),
        endDate:
            now.add(const Duration(days: 10)).copyWith(hour: 22, minute: 0),
        location: 'Mosquée Elhadj Daouda - Grande salle',
        maxParticipants: 150,
        currentParticipants: 78,
        requiresRegistration: true,
        price: 0.0,
        organizer: 'Comité d\'organisation',
        tags: ['ramadan', 'iftar', 'communauté'],
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      // Événement 4: Collecte de fonds
      final event4 = Event(
        id: 'sample_4',
        title: 'Collecte pour l\'Orphelinat',
        description:
            'Campagne de collecte de fonds et de vêtements pour soutenir l\'orphelinat local.',
        category: EventCategory.fundraising,
        status: EventStatus.published, // Explicitement published
        startDate:
            now.add(const Duration(days: 7)).copyWith(hour: 10, minute: 0),
        endDate: now.add(const Duration(days: 7)).copyWith(hour: 16, minute: 0),
        location: 'Mosquée Elhadj Daouda - Hall d\'accueil',
        maxParticipants: 0, // Pas de limite
        currentParticipants: 0,
        requiresRegistration: false,
        organizer: 'Association caritative',
        tags: ['collecte', 'orphelinat', 'charité'],
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      // Ajouter les événements à Firestore avec debug
      debugPrint(
          '🔧 Adding event 1: ${event1.title} - Status: ${event1.status}');
      await _eventsCollection.doc('sample_1').set(event1.toFirestore());

      debugPrint(
          '🔧 Adding event 2: ${event2.title} - Status: ${event2.status}');
      await _eventsCollection.doc('sample_2').set(event2.toFirestore());

      debugPrint(
          '🔧 Adding event 3: ${event3.title} - Status: ${event3.status}');
      await _eventsCollection.doc('sample_3').set(event3.toFirestore());

      debugPrint(
          '🔧 Adding event 4: ${event4.title} - Status: ${event4.status}');
      await _eventsCollection.doc('sample_4').set(event4.toFirestore());

      debugPrint('✅ Sample events created successfully');

      // Vérification immédiate
      debugPrint('🔍 Verifying created events...');
      final query = await _eventsCollection.get();
      debugPrint('🔍 Total documents in collection: ${query.docs.length}');
      for (var doc in query.docs) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint(
            '🔍 Document ${doc.id}: title=${data['title']}, status=${data['status']}');
      }
    } catch (e) {
      debugPrint('❌ Error creating sample events: $e');
      throw Exception(
          'Erreur lors de la création des événements d\'exemple: $e');
    }
  }

  /// Supprime tous les événements d'exemple
  Future<void> deleteSampleEvents() async {
    try {
      await _eventsCollection.doc('sample_1').delete();
      await _eventsCollection.doc('sample_2').delete();
      await _eventsCollection.doc('sample_3').delete();
      await _eventsCollection.doc('sample_4').delete();
      debugPrint('✅ Sample events deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting sample events: $e');
    }
  }

  /// Corrige les événements existants en ajoutant le champ status manquant
  Future<void> fixExistingEvents() async {
    try {
      debugPrint('🔧 Starting to fix existing events...');

      // Récupérer tous les événements
      final allEventsQuery = await _eventsCollection.get();
      debugPrint('🔍 Found ${allEventsQuery.docs.length} events to check');

      int fixedCount = 0;

      for (var doc in allEventsQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Vérifier si le champ status manque
        if (!data.containsKey('status') || data['status'] == null) {
          debugPrint('🔧 Fixing event ${doc.id}: ${data['title']}');

          // Ajouter le champ status avec la valeur 'published'
          await _eventsCollection.doc(doc.id).update({
            'status': 'published',
            'updatedAt': DateTime.now().toIso8601String(),
          });

          fixedCount++;
        } else {
          debugPrint('✅ Event ${doc.id} already has status: ${data['status']}');
        }
      }

      debugPrint('✅ Fixed $fixedCount events successfully');
    } catch (e) {
      debugPrint('❌ Error fixing existing events: $e');
      throw Exception('Erreur lors de la correction des événements: $e');
    }
  }

  // Méthode pour corriger les événements existants sans status
  Future<void> fixExistingEventsStatus() async {
    debugPrint('🔧 Starting to fix existing events without status field...');

    try {
      final snapshot = await _eventsCollection.get();
      int fixedCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Si le champ status n'existe pas, l'ajouter
        if (!data.containsKey('status')) {
          await doc.reference.update({
            'status': 'published', // Par défaut, on les met en publié
          });
          fixedCount++;
          debugPrint('✅ Fixed event ${doc.id}: added status=published');
        }
      }

      debugPrint('🎉 Fixed $fixedCount events successfully!');
    } catch (e) {
      debugPrint('❌ Error fixing events: $e');
      rethrow;
    }
  }

  // =============== GENERAL UTILITIES ===============

  Future<void> incrementField(
      String collection, String docId, String field) async {
    try {
      await _firestore.collection(collection).doc(docId).update({
        field: FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'incrémentation: $e');
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final userCount = await _usersCollection.count().get();
      final eventCount = await _eventsCollection
          .where('status', isEqualTo: 'published')
          .count()
          .get();
      return {
        'users': userCount.count,
        'events': eventCount.count,
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }
}
