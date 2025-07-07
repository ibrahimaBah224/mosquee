import '../models/event.dart';
import '../services/firestore_service.dart';
import '../di/dependency_injection.dart';

class EventRepository {
  final FirestoreService _firestoreService = getIt<FirestoreService>();

  Future<String> createEvent(Event event) async {
    return await _firestoreService.createEvent(event);
  }

  Future<void> updateEvent(Event event) async {
    await _firestoreService.updateEvent(event);
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestoreService.deleteEvent(eventId);
  }

  Future<Event?> getEvent(String eventId) async {
    return await _firestoreService.getEvent(eventId);
  }

  Stream<List<Event>> watchPublishedEvents() {
    return _firestoreService.watchPublishedEvents();
  }

  Future<List<Event>> getUpcomingEvents({int limit = 10}) async {
    return await _firestoreService.getUpcomingEvents(limit: limit);
  }

  Future<List<Event>> getEventsByCategory(EventCategory category) async {
    // Cette méthode pourrait être ajoutée au FirestoreService si nécessaire
    final allEvents = await _firestoreService.getUpcomingEvents(limit: 100);
    return allEvents.where((event) => event.category == category).toList();
  }

  Future<void> registerForEvent(EventRegistration registration) async {
    // Logique d'inscription à un événement
    // Cette méthode nécessiterait une collection dédiée aux inscriptions
  }

  Future<List<EventRegistration>> getEventRegistrations(String eventId) async {
    // Récupérer les inscriptions pour un événement
    return [];
  }

  Future<void> publishEvent(String eventId) async {
    final event = await getEvent(eventId);
    if (event != null) {
      final publishedEvent = event.copyWith(
        status: EventStatus.published,
        updatedAt: DateTime.now(),
      );
      await updateEvent(publishedEvent);
    }
  }

  Future<void> cancelEvent(String eventId) async {
    final event = await getEvent(eventId);
    if (event != null) {
      final cancelledEvent = event.copyWith(
        status: EventStatus.cancelled,
        updatedAt: DateTime.now(),
      );
      await updateEvent(cancelledEvent);
    }
  }
}
