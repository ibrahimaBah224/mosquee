import 'package:equatable/equatable.dart';

enum MuezzinStatus {
  principal, // Muezzin principal
  assistant, // Muezzin assistant
  remplacant, // Muezzin remplaçant
}

enum PrayerAssignment {
  fajr, // Prière de l'aube
  dhuhr, // Prière de midi
  asr, // Prière de l'après-midi
  maghrib, // Prière du coucher
  isha, // Prière de la nuit
  jumma, // Prière du vendredi
  eid, // Prières de l'Aïd
  all, // Toutes les prières
}

class Muezzin extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String fullNameArabic;
  final MuezzinStatus status;
  final List<PrayerAssignment> assignedPrayers;

  // Informations personnelles
  final String? phone;
  final String? email;
  final String? address;
  final DateTime? birthDate;
  final String? nationality;
  final String? photoUrl;

  // Informations professionnelles
  final String? voiceQuality; // Description de la qualité vocale
  final List<String> recitationStyles; // Styles de récitation
  final String? training; // Formation reçue
  final String? experience; // Expérience antérieure

  // Planning et disponibilité
  final Map<String, Map<String, bool>>
      weeklyAvailability; // Jour -> Prière -> Disponible
  final List<String>
      specialOccasions; // Occasions spéciales (Ramadan, Aïd, etc.)
  final String? preferredSchedule; // Horaires préférés

  // Statut et engagement
  final bool isActive;
  final bool isVolunteer; // Bénévole ou employé
  final DateTime? startDate; // Date de début
  final DateTime? endDate; // Date de fin (si applicable)
  final double? monthlyCompensation; // Compensation mensuelle (si applicable)

  // Compétences et langues
  final List<String> languages; // Langues parlées
  final bool canReadArabic; // Peut lire l'arabe
  final bool canMemorizeQuran; // Peut mémoriser le Coran
  final String? quranMemorization; // Niveau de mémorisation du Coran

  // Contact d'urgence
  final String? emergencyContact;
  final String? emergencyPhone;

  // Évaluations et notes
  final double? performanceRating; // Note de performance (1-5)
  final List<String> feedback; // Commentaires
  final DateTime? lastEvaluation; // Dernière évaluation

  // Métadonnées
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const Muezzin({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullNameArabic,
    required this.status,
    required this.assignedPrayers,
    this.phone,
    this.email,
    this.address,
    this.birthDate,
    this.nationality,
    this.photoUrl,
    this.voiceQuality,
    this.recitationStyles = const [],
    this.training,
    this.experience,
    this.weeklyAvailability = const {},
    this.specialOccasions = const [],
    this.preferredSchedule,
    this.isActive = true,
    this.isVolunteer = true,
    this.startDate,
    this.endDate,
    this.monthlyCompensation,
    this.languages = const ['Français', 'Arabe'],
    this.canReadArabic = true,
    this.canMemorizeQuran = false,
    this.quranMemorization,
    this.emergencyContact,
    this.emergencyPhone,
    this.performanceRating,
    this.feedback = const [],
    this.lastEvaluation,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory Muezzin.fromFirestore(Map<String, dynamic> data, String id) {
    return Muezzin(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      fullNameArabic: data['fullNameArabic'] ?? '',
      status: MuezzinStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MuezzinStatus.assistant,
      ),
      assignedPrayers: (data['assignedPrayers'] as List<dynamic>?)
              ?.map((e) => PrayerAssignment.values.firstWhere(
                    (prayer) => prayer.name == e,
                    orElse: () => PrayerAssignment.all,
                  ))
              .toList() ??
          [PrayerAssignment.all],
      phone: data['phone'],
      email: data['email'],
      address: data['address'],
      birthDate:
          data['birthDate'] != null ? DateTime.parse(data['birthDate']) : null,
      nationality: data['nationality'],
      photoUrl: data['photoUrl'],
      voiceQuality: data['voiceQuality'],
      recitationStyles: List<String>.from(data['recitationStyles'] ?? []),
      training: data['training'],
      experience: data['experience'],
      weeklyAvailability: data['weeklyAvailability'] != null
          ? Map<String, Map<String, bool>>.from(
              (data['weeklyAvailability'] as Map).map(
                (key, value) => MapEntry(
                  key.toString(),
                  Map<String, bool>.from(value),
                ),
              ),
            )
          : {},
      specialOccasions: List<String>.from(data['specialOccasions'] ?? []),
      preferredSchedule: data['preferredSchedule'],
      isActive: data['isActive'] ?? true,
      isVolunteer: data['isVolunteer'] ?? true,
      startDate:
          data['startDate'] != null ? DateTime.parse(data['startDate']) : null,
      endDate: data['endDate'] != null ? DateTime.parse(data['endDate']) : null,
      monthlyCompensation: data['monthlyCompensation']?.toDouble(),
      languages: List<String>.from(data['languages'] ?? ['Français', 'Arabe']),
      canReadArabic: data['canReadArabic'] ?? true,
      canMemorizeQuran: data['canMemorizeQuran'] ?? false,
      quranMemorization: data['quranMemorization'],
      emergencyContact: data['emergencyContact'],
      emergencyPhone: data['emergencyPhone'],
      performanceRating: data['performanceRating']?.toDouble(),
      feedback: List<String>.from(data['feedback'] ?? []),
      lastEvaluation: data['lastEvaluation'] != null
          ? DateTime.parse(data['lastEvaluation'])
          : null,
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'fullNameArabic': fullNameArabic,
      'status': status.name,
      'assignedPrayers': assignedPrayers.map((e) => e.name).toList(),
      'phone': phone,
      'email': email,
      'address': address,
      'birthDate': birthDate?.toIso8601String(),
      'nationality': nationality,
      'photoUrl': photoUrl,
      'voiceQuality': voiceQuality,
      'recitationStyles': recitationStyles,
      'training': training,
      'experience': experience,
      'weeklyAvailability': weeklyAvailability,
      'specialOccasions': specialOccasions,
      'preferredSchedule': preferredSchedule,
      'isActive': isActive,
      'isVolunteer': isVolunteer,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'monthlyCompensation': monthlyCompensation,
      'languages': languages,
      'canReadArabic': canReadArabic,
      'canMemorizeQuran': canMemorizeQuran,
      'quranMemorization': quranMemorization,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'performanceRating': performanceRating,
      'feedback': feedback,
      'lastEvaluation': lastEvaluation?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  Muezzin copyWith({
    String? firstName,
    String? lastName,
    String? fullNameArabic,
    MuezzinStatus? status,
    List<PrayerAssignment>? assignedPrayers,
    String? phone,
    String? email,
    String? address,
    DateTime? birthDate,
    String? nationality,
    String? photoUrl,
    String? voiceQuality,
    List<String>? recitationStyles,
    String? training,
    String? experience,
    Map<String, Map<String, bool>>? weeklyAvailability,
    List<String>? specialOccasions,
    String? preferredSchedule,
    bool? isActive,
    bool? isVolunteer,
    DateTime? startDate,
    DateTime? endDate,
    double? monthlyCompensation,
    List<String>? languages,
    bool? canReadArabic,
    bool? canMemorizeQuran,
    String? quranMemorization,
    String? emergencyContact,
    String? emergencyPhone,
    double? performanceRating,
    List<String>? feedback,
    DateTime? lastEvaluation,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Muezzin(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullNameArabic: fullNameArabic ?? this.fullNameArabic,
      status: status ?? this.status,
      assignedPrayers: assignedPrayers ?? this.assignedPrayers,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      nationality: nationality ?? this.nationality,
      photoUrl: photoUrl ?? this.photoUrl,
      voiceQuality: voiceQuality ?? this.voiceQuality,
      recitationStyles: recitationStyles ?? this.recitationStyles,
      training: training ?? this.training,
      experience: experience ?? this.experience,
      weeklyAvailability: weeklyAvailability ?? this.weeklyAvailability,
      specialOccasions: specialOccasions ?? this.specialOccasions,
      preferredSchedule: preferredSchedule ?? this.preferredSchedule,
      isActive: isActive ?? this.isActive,
      isVolunteer: isVolunteer ?? this.isVolunteer,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      monthlyCompensation: monthlyCompensation ?? this.monthlyCompensation,
      languages: languages ?? this.languages,
      canReadArabic: canReadArabic ?? this.canReadArabic,
      canMemorizeQuran: canMemorizeQuran ?? this.canMemorizeQuran,
      quranMemorization: quranMemorization ?? this.quranMemorization,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      performanceRating: performanceRating ?? this.performanceRating,
      feedback: feedback ?? this.feedback,
      lastEvaluation: lastEvaluation ?? this.lastEvaluation,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      createdBy: createdBy ?? this.createdBy,
    );
  }

  // Getters utiles
  String get fullName => '$firstName $lastName';
  String get displayName => fullName;
  String get statusDisplayName {
    switch (status) {
      case MuezzinStatus.principal:
        return 'Muezzin Principal';
      case MuezzinStatus.assistant:
        return 'Muezzin Assistant';
      case MuezzinStatus.remplacant:
        return 'Muezzin Remplaçant';
    }
  }

  List<String> get assignedPrayersDisplayNames {
    return assignedPrayers.map((prayer) {
      switch (prayer) {
        case PrayerAssignment.fajr:
          return 'Fajr';
        case PrayerAssignment.dhuhr:
          return 'Dhuhr';
        case PrayerAssignment.asr:
          return 'Asr';
        case PrayerAssignment.maghrib:
          return 'Maghrib';
        case PrayerAssignment.isha:
          return 'Isha';
        case PrayerAssignment.jumma:
          return 'Vendredi';
        case PrayerAssignment.eid:
          return 'Aïd';
        case PrayerAssignment.all:
          return 'Toutes';
      }
    }).toList();
  }

  String get employmentType => isVolunteer ? 'Bénévole' : 'Employé';

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  Duration? get serviceYears {
    if (startDate == null) return null;
    return DateTime.now().difference(startDate!);
  }

  bool get hasContact => phone?.isNotEmpty == true || email?.isNotEmpty == true;

  bool get needsEvaluation {
    if (lastEvaluation == null) return true;
    return DateTime.now().difference(lastEvaluation!).inDays > 180; // 6 mois
  }

  String get performanceLevel {
    if (performanceRating == null) return 'Non évalué';
    if (performanceRating! >= 4.5) return 'Excellent';
    if (performanceRating! >= 3.5) return 'Bon';
    if (performanceRating! >= 2.5) return 'Satisfaisant';
    return 'À améliorer';
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        fullNameArabic,
        status,
        assignedPrayers,
        phone,
        email,
        address,
        birthDate,
        nationality,
        photoUrl,
        voiceQuality,
        recitationStyles,
        training,
        experience,
        weeklyAvailability,
        specialOccasions,
        preferredSchedule,
        isActive,
        isVolunteer,
        startDate,
        endDate,
        monthlyCompensation,
        languages,
        canReadArabic,
        canMemorizeQuran,
        quranMemorization,
        emergencyContact,
        emergencyPhone,
        performanceRating,
        feedback,
        lastEvaluation,
        createdAt,
        updatedAt,
        createdBy,
      ];
}
