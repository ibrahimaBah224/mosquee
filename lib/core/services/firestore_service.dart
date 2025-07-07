import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../models/prayer_time.dart';
import '../models/event.dart';
import '../models/donation.dart';
import '../models/news.dart';
import '../models/book.dart';

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
  CollectionReference get _eventRegistrationsCollection =>
      _firestore.collection('event_registrations');
  CollectionReference get _donationsCollection =>
      _firestore.collection('donations');
  CollectionReference get _donationCampaignsCollection =>
      _firestore.collection('donation_campaigns');
  CollectionReference get _newsCollection => _firestore.collection('news');
  CollectionReference get _commentsCollection =>
      _firestore.collection('comments');
  CollectionReference get _booksCollection => _firestore.collection('books');
  CollectionReference get _bookRatingsCollection =>
      _firestore.collection('book_ratings');

  /// Initialize Firestore with settings
  Future<void> initialize() async {
    try {
      // Enable offline persistence
      _firestore.settings = const Settings(persistenceEnabled: true);

      if (kDebugMode) {
        print('Firestore Service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firestore Service: $e');
      }
    }
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
          .orderBy('date')
          .get();

      return query.docs
          .map((doc) => PrayerTime.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
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
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PrayerTime.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
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
    return _eventsCollection
        .where('status', isEqualTo: 'published')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Event.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<List<Event>> getUpcomingEvents({int limit = 10}) async {
    try {
      final query = await _eventsCollection
          .where('status', isEqualTo: 'published')
          .where('startDate', isGreaterThan: DateTime.now().toIso8601String())
          .orderBy('startDate')
          .limit(limit)
          .get();

      return query.docs
          .map((doc) =>
              Event.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
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
      final query = await _donationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => Donation.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des dons: $e');
    }
  }

  Stream<List<DonationCampaign>> watchActiveCampaigns() {
    return _donationCampaignsCollection
        .where('isActive', isEqualTo: true)
        .where('endDate', isGreaterThan: DateTime.now().toIso8601String())
        .orderBy('endDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DonationCampaign.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // =============== NEWS ===============

  Future<String> createNews(News news) async {
    try {
      final docRef = await _newsCollection.add(news.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'actualité: $e');
    }
  }

  Future<void> updateNews(News news) async {
    try {
      await _newsCollection.doc(news.id).update(news.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'actualité: $e');
    }
  }

  Stream<List<News>> watchPublishedNews() {
    return _newsCollection
        .where('status', isEqualTo: 'published')
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                News.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<List<News>> getLatestNews({int limit = 5}) async {
    try {
      final query = await _newsCollection
          .where('status', isEqualTo: 'published')
          .orderBy('publishedAt', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) =>
              News.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des actualités: $e');
    }
  }

  // =============== BOOKS ===============

  Future<String> createBook(Book book) async {
    try {
      final docRef = await _booksCollection.add(book.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du livre: $e');
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      await _booksCollection.doc(book.id).update(book.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du livre: $e');
    }
  }

  Stream<List<Book>> watchPublicBooks() {
    return _booksCollection
        .where('isPublic', isEqualTo: true)
        .where('status', isEqualTo: 'available')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Book.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<List<Book>> getBooksByCategory(BookCategory category) async {
    try {
      final query = await _booksCollection
          .where('category', isEqualTo: category.name)
          .where('isPublic', isEqualTo: true)
          .where('status', isEqualTo: 'available')
          .orderBy('title')
          .get();

      return query.docs
          .map((doc) =>
              Book.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des livres: $e');
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
      final newsCount = await _newsCollection
          .where('status', isEqualTo: 'published')
          .count()
          .get();
      final bookCount = await _booksCollection
          .where('isPublic', isEqualTo: true)
          .count()
          .get();

      return {
        'users': userCount.count,
        'events': eventCount.count,
        'news': newsCount.count,
        'books': bookCount.count,
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }
}
