import 'package:equatable/equatable.dart';

enum ImamRank {
  principal, // Imam principal
  adjoint, // Imam adjoint
  assistant, // Imam assistant
  visiteur, // Imam visiteur
}

enum ImamSpecialty {
  khutba, // Prêche du vendredi
  tarawih, // Prières de Tarawih (Ramadan)
  courses, // Cours et enseignement
  marriage, // Mariages religieux
  funeral, // Services funéraires
  general, // Services généraux
}

class Imam extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String fullNameArabic;
  final ImamRank rank;
  final int orderInHierarchy; // 1 = plus haut rang
  final List<ImamSpecialty> specialties;

  // Informations personnelles
  final String? phone;
  final String? email;
  final String? address;
  final DateTime? birthDate;
  final String? nationality;
  final String? photoUrl;

  // Informations religieuses
  final String? education; // Formation islamique
  final String? certifications; // Diplômes/certifications
  final List<String> languages; // Langues parlées
  final String? biography; // Biographie courte

  // Horaires et disponibilité
  final Map<String, List<String>> weeklySchedule; // Jour -> List des heures
  final bool isActive;
  final DateTime? startDate; // Date de début de service
  final DateTime? endDate; // Date de fin (si applicable)

  // Contact d'urgence
  final String? emergencyContact;
  final String? emergencyPhone;

  // Métadonnées
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const Imam({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullNameArabic,
    required this.rank,
    required this.orderInHierarchy,
    required this.specialties,
    this.phone,
    this.email,
    this.address,
    this.birthDate,
    this.nationality,
    this.photoUrl,
    this.education,
    this.certifications,
    this.languages = const ['Français', 'Arabe'],
    this.biography,
    this.weeklySchedule = const {},
    this.isActive = true,
    this.startDate,
    this.endDate,
    this.emergencyContact,
    this.emergencyPhone,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory Imam.fromFirestore(Map<String, dynamic> data, String id) {
    return Imam(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      fullNameArabic: data['fullNameArabic'] ?? '',
      rank: ImamRank.values.firstWhere(
        (e) => e.name == data['rank'],
        orElse: () => ImamRank.assistant,
      ),
      orderInHierarchy: data['orderInHierarchy'] ?? 99,
      specialties: (data['specialties'] as List<dynamic>?)
              ?.map((e) => ImamSpecialty.values.firstWhere(
                    (spec) => spec.name == e,
                    orElse: () => ImamSpecialty.general,
                  ))
              .toList() ??
          [ImamSpecialty.general],
      phone: data['phone'],
      email: data['email'],
      address: data['address'],
      birthDate:
          data['birthDate'] != null ? DateTime.parse(data['birthDate']) : null,
      nationality: data['nationality'],
      photoUrl: data['photoUrl'],
      education: data['education'],
      certifications: data['certifications'],
      languages: List<String>.from(data['languages'] ?? ['Français', 'Arabe']),
      biography: data['biography'],
      weeklySchedule: data['weeklySchedule'] != null
          ? Map<String, List<String>>.from(
              (data['weeklySchedule'] as Map).map(
                (key, value) =>
                    MapEntry(key.toString(), List<String>.from(value)),
              ),
            )
          : {},
      isActive: data['isActive'] ?? true,
      startDate:
          data['startDate'] != null ? DateTime.parse(data['startDate']) : null,
      endDate: data['endDate'] != null ? DateTime.parse(data['endDate']) : null,
      emergencyContact: data['emergencyContact'],
      emergencyPhone: data['emergencyPhone'],
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
      'rank': rank.name,
      'orderInHierarchy': orderInHierarchy,
      'specialties': specialties.map((e) => e.name).toList(),
      'phone': phone,
      'email': email,
      'address': address,
      'birthDate': birthDate?.toIso8601String(),
      'nationality': nationality,
      'photoUrl': photoUrl,
      'education': education,
      'certifications': certifications,
      'languages': languages,
      'biography': biography,
      'weeklySchedule': weeklySchedule,
      'isActive': isActive,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  Imam copyWith({
    String? firstName,
    String? lastName,
    String? fullNameArabic,
    ImamRank? rank,
    int? orderInHierarchy,
    List<ImamSpecialty>? specialties,
    String? phone,
    String? email,
    String? address,
    DateTime? birthDate,
    String? nationality,
    String? photoUrl,
    String? education,
    String? certifications,
    List<String>? languages,
    String? biography,
    Map<String, List<String>>? weeklySchedule,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    String? emergencyContact,
    String? emergencyPhone,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Imam(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullNameArabic: fullNameArabic ?? this.fullNameArabic,
      rank: rank ?? this.rank,
      orderInHierarchy: orderInHierarchy ?? this.orderInHierarchy,
      specialties: specialties ?? this.specialties,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      nationality: nationality ?? this.nationality,
      photoUrl: photoUrl ?? this.photoUrl,
      education: education ?? this.education,
      certifications: certifications ?? this.certifications,
      languages: languages ?? this.languages,
      biography: biography ?? this.biography,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      createdBy: createdBy ?? this.createdBy,
    );
  }

  // Getters utiles
  String get fullName => '$firstName $lastName';
  String get displayName => fullName;
  String get rankDisplayName {
    switch (rank) {
      case ImamRank.principal:
        return 'Imam Principal';
      case ImamRank.adjoint:
        return 'Imam Adjoint';
      case ImamRank.assistant:
        return 'Imam Assistant';
      case ImamRank.visiteur:
        return 'Imam Visiteur';
    }
  }

  List<String> get specialtyDisplayNames {
    return specialties.map((specialty) {
      switch (specialty) {
        case ImamSpecialty.khutba:
          return 'Prêche du vendredi';
        case ImamSpecialty.tarawih:
          return 'Prières de Tarawih';
        case ImamSpecialty.courses:
          return 'Cours et enseignement';
        case ImamSpecialty.marriage:
          return 'Mariages religieux';
        case ImamSpecialty.funeral:
          return 'Services funéraires';
        case ImamSpecialty.general:
          return 'Services généraux';
      }
    }).toList();
  }

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

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        fullNameArabic,
        rank,
        orderInHierarchy,
        specialties,
        phone,
        email,
        address,
        birthDate,
        nationality,
        photoUrl,
        education,
        certifications,
        languages,
        biography,
        weeklySchedule,
        isActive,
        startDate,
        endDate,
        emergencyContact,
        emergencyPhone,
        createdAt,
        updatedAt,
        createdBy,
      ];
}
