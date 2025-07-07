import 'package:equatable/equatable.dart';

enum EventStatus { draft, published, cancelled, completed }

enum EventCategory { religious, educational, community, fundraising, social }

class Event extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final EventCategory category;
  final EventStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final double? latitude;
  final double? longitude;
  final int maxParticipants;
  final int currentParticipants;
  final bool requiresRegistration;
  final double? price;
  final String organizer;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.category,
    this.status = EventStatus.draft,
    required this.startDate,
    required this.endDate,
    required this.location,
    this.latitude,
    this.longitude,
    this.maxParticipants = 0,
    this.currentParticipants = 0,
    this.requiresRegistration = false,
    this.price,
    required this.organizer,
    this.tags = const [],
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory Event.fromFirestore(Map<String, dynamic> data, String id) {
    return Event(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      category: EventCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => EventCategory.community,
      ),
      status: EventStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => EventStatus.draft,
      ),
      startDate: DateTime.parse(data['startDate']),
      endDate: DateTime.parse(data['endDate']),
      location: data['location'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      maxParticipants: data['maxParticipants'] ?? 0,
      currentParticipants: data['currentParticipants'] ?? 0,
      requiresRegistration: data['requiresRegistration'] ?? false,
      price: data['price']?.toDouble(),
      organizer: data['organizer'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      metadata: data['metadata']?.cast<String, dynamic>(),
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category.name,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'requiresRegistration': requiresRegistration,
      'price': price,
      'organizer': organizer,
      'tags': tags,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  Event copyWith({
    String? title,
    String? description,
    String? imageUrl,
    EventCategory? category,
    EventStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    double? latitude,
    double? longitude,
    int? maxParticipants,
    int? currentParticipants,
    bool? requiresRegistration,
    double? price,
    String? organizer,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      requiresRegistration: requiresRegistration ?? this.requiresRegistration,
      price: price ?? this.price,
      organizer: organizer ?? this.organizer,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      createdBy: createdBy,
    );
  }

  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isOngoing =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  bool get isPast => endDate.isBefore(DateTime.now());
  bool get isFull =>
      maxParticipants > 0 && currentParticipants >= maxParticipants;
  bool get canRegister =>
      requiresRegistration && !isFull && (isUpcoming || isOngoing);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        category,
        status,
        startDate,
        endDate,
        location,
        latitude,
        longitude,
        maxParticipants,
        currentParticipants,
        requiresRegistration,
        price,
        organizer,
        tags,
        metadata,
        createdAt,
        updatedAt,
        createdBy,
      ];
}

class EventRegistration extends Equatable {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final DateTime registeredAt;
  final bool isConfirmed;
  final bool hasAttended;
  final Map<String, dynamic>? additionalInfo;

  const EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    required this.registeredAt,
    this.isConfirmed = false,
    this.hasAttended = false,
    this.additionalInfo,
  });

  factory EventRegistration.fromFirestore(
      Map<String, dynamic> data, String id) {
    return EventRegistration(
      id: id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userPhone: data['userPhone'],
      registeredAt: DateTime.parse(data['registeredAt']),
      isConfirmed: data['isConfirmed'] ?? false,
      hasAttended: data['hasAttended'] ?? false,
      additionalInfo: data['additionalInfo']?.cast<String, dynamic>(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'registeredAt': registeredAt.toIso8601String(),
      'isConfirmed': isConfirmed,
      'hasAttended': hasAttended,
      'additionalInfo': additionalInfo,
    };
  }

  @override
  List<Object?> get props => [
        id,
        eventId,
        userId,
        userName,
        userEmail,
        userPhone,
        registeredAt,
        isConfirmed,
        hasAttended,
        additionalInfo,
      ];
}
