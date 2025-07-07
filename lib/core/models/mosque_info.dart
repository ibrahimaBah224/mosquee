import 'package:equatable/equatable.dart';

class MosqueInfo extends Equatable {
  final String id;
  final String name;
  final String nameArabic;
  final String slogan;
  final String description;

  // Localisation
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String timezone;

  // Informations de contact
  final String phone;
  final String email;
  final String website;
  final String supportEmail;

  // Réseaux sociaux
  final String? facebookUrl;
  final String? instagramUrl;
  final String? youtubeUrl;
  final String? twitterUrl;
  final String? tiktokUrl;

  // Horaires d'ouverture
  final Map<String, String> openingHours; // Lundi-Dimanche avec horaires

  // Imam et responsables
  final String? imamName;
  final String? imamPhone;
  final String? imamEmail;
  final String? presidentName;
  final String? presidentPhone;
  final String? presidentEmail;

  // Informations financières
  final String? bankAccount;
  final String? mobileMoneyNumber;
  final String? paypalAccount;

  // Capacité et équipements
  final int capacity;
  final bool hasParking;
  final bool hasWuduArea;
  final bool hasWomenSection;
  final bool hasChildrenArea;
  final bool hasLibrary;
  final bool hasClassrooms;
  final bool hasKitchen;
  final bool isWheelchairAccessible;

  // Services proposés
  final List<String>
      services; // Ex: cours de Coran, mariage, consultation religieuse

  // Configuration de l'application
  final String appVersion;
  final String logoUrl;
  final String bannerImageUrl;
  final String primaryColor;
  final String secondaryColor;

  // Métadonnées
  final DateTime createdAt;
  final DateTime updatedAt;
  final String lastUpdatedBy;

  const MosqueInfo({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.slogan,
    required this.description,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.phone,
    required this.email,
    required this.website,
    required this.supportEmail,
    this.facebookUrl,
    this.instagramUrl,
    this.youtubeUrl,
    this.twitterUrl,
    this.tiktokUrl,
    required this.openingHours,
    this.imamName,
    this.imamPhone,
    this.imamEmail,
    this.presidentName,
    this.presidentPhone,
    this.presidentEmail,
    this.bankAccount,
    this.mobileMoneyNumber,
    this.paypalAccount,
    required this.capacity,
    this.hasParking = false,
    this.hasWuduArea = true,
    this.hasWomenSection = false,
    this.hasChildrenArea = false,
    this.hasLibrary = false,
    this.hasClassrooms = false,
    this.hasKitchen = false,
    this.isWheelchairAccessible = false,
    this.services = const [],
    required this.appVersion,
    this.logoUrl = '',
    this.bannerImageUrl = '',
    this.primaryColor = '#2E7D32',
    this.secondaryColor = '#1565C0',
    required this.createdAt,
    required this.updatedAt,
    required this.lastUpdatedBy,
  });

  factory MosqueInfo.fromFirestore(Map<String, dynamic> data, String id) {
    return MosqueInfo(
      id: id,
      name: data['name'] ?? '',
      nameArabic: data['nameArabic'] ?? '',
      slogan: data['slogan'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      country: data['country'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      timezone: data['timezone'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      website: data['website'] ?? '',
      supportEmail: data['supportEmail'] ?? '',
      facebookUrl: data['facebookUrl'],
      instagramUrl: data['instagramUrl'],
      youtubeUrl: data['youtubeUrl'],
      twitterUrl: data['twitterUrl'],
      tiktokUrl: data['tiktokUrl'],
      openingHours: Map<String, String>.from(data['openingHours'] ?? {}),
      imamName: data['imamName'],
      imamPhone: data['imamPhone'],
      imamEmail: data['imamEmail'],
      presidentName: data['presidentName'],
      presidentPhone: data['presidentPhone'],
      presidentEmail: data['presidentEmail'],
      bankAccount: data['bankAccount'],
      mobileMoneyNumber: data['mobileMoneyNumber'],
      paypalAccount: data['paypalAccount'],
      capacity: data['capacity'] ?? 0,
      hasParking: data['hasParking'] ?? false,
      hasWuduArea: data['hasWuduArea'] ?? true,
      hasWomenSection: data['hasWomenSection'] ?? false,
      hasChildrenArea: data['hasChildrenArea'] ?? false,
      hasLibrary: data['hasLibrary'] ?? false,
      hasClassrooms: data['hasClassrooms'] ?? false,
      hasKitchen: data['hasKitchen'] ?? false,
      isWheelchairAccessible: data['isWheelchairAccessible'] ?? false,
      services: List<String>.from(data['services'] ?? []),
      appVersion: data['appVersion'] ?? '1.0.0',
      logoUrl: data['logoUrl'] ?? '',
      bannerImageUrl: data['bannerImageUrl'] ?? '',
      primaryColor: data['primaryColor'] ?? '#2E7D32',
      secondaryColor: data['secondaryColor'] ?? '#1565C0',
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      lastUpdatedBy: data['lastUpdatedBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameArabic': nameArabic,
      'slogan': slogan,
      'description': description,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'phone': phone,
      'email': email,
      'website': website,
      'supportEmail': supportEmail,
      'facebookUrl': facebookUrl,
      'instagramUrl': instagramUrl,
      'youtubeUrl': youtubeUrl,
      'twitterUrl': twitterUrl,
      'tiktokUrl': tiktokUrl,
      'openingHours': openingHours,
      'imamName': imamName,
      'imamPhone': imamPhone,
      'imamEmail': imamEmail,
      'presidentName': presidentName,
      'presidentPhone': presidentPhone,
      'presidentEmail': presidentEmail,
      'bankAccount': bankAccount,
      'mobileMoneyNumber': mobileMoneyNumber,
      'paypalAccount': paypalAccount,
      'capacity': capacity,
      'hasParking': hasParking,
      'hasWuduArea': hasWuduArea,
      'hasWomenSection': hasWomenSection,
      'hasChildrenArea': hasChildrenArea,
      'hasLibrary': hasLibrary,
      'hasClassrooms': hasClassrooms,
      'hasKitchen': hasKitchen,
      'isWheelchairAccessible': isWheelchairAccessible,
      'services': services,
      'appVersion': appVersion,
      'logoUrl': logoUrl,
      'bannerImageUrl': bannerImageUrl,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastUpdatedBy': lastUpdatedBy,
    };
  }

  MosqueInfo copyWith({
    String? name,
    String? nameArabic,
    String? slogan,
    String? description,
    String? address,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? timezone,
    String? phone,
    String? email,
    String? website,
    String? supportEmail,
    String? facebookUrl,
    String? instagramUrl,
    String? youtubeUrl,
    String? twitterUrl,
    String? tiktokUrl,
    Map<String, String>? openingHours,
    String? imamName,
    String? imamPhone,
    String? imamEmail,
    String? presidentName,
    String? presidentPhone,
    String? presidentEmail,
    String? bankAccount,
    String? mobileMoneyNumber,
    String? paypalAccount,
    int? capacity,
    bool? hasParking,
    bool? hasWuduArea,
    bool? hasWomenSection,
    bool? hasChildrenArea,
    bool? hasLibrary,
    bool? hasClassrooms,
    bool? hasKitchen,
    bool? isWheelchairAccessible,
    List<String>? services,
    String? appVersion,
    String? logoUrl,
    String? bannerImageUrl,
    String? primaryColor,
    String? secondaryColor,
    DateTime? updatedAt,
    String? lastUpdatedBy,
  }) {
    return MosqueInfo(
      id: id,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      slogan: slogan ?? this.slogan,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      supportEmail: supportEmail ?? this.supportEmail,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      tiktokUrl: tiktokUrl ?? this.tiktokUrl,
      openingHours: openingHours ?? this.openingHours,
      imamName: imamName ?? this.imamName,
      imamPhone: imamPhone ?? this.imamPhone,
      imamEmail: imamEmail ?? this.imamEmail,
      presidentName: presidentName ?? this.presidentName,
      presidentPhone: presidentPhone ?? this.presidentPhone,
      presidentEmail: presidentEmail ?? this.presidentEmail,
      bankAccount: bankAccount ?? this.bankAccount,
      mobileMoneyNumber: mobileMoneyNumber ?? this.mobileMoneyNumber,
      paypalAccount: paypalAccount ?? this.paypalAccount,
      capacity: capacity ?? this.capacity,
      hasParking: hasParking ?? this.hasParking,
      hasWuduArea: hasWuduArea ?? this.hasWuduArea,
      hasWomenSection: hasWomenSection ?? this.hasWomenSection,
      hasChildrenArea: hasChildrenArea ?? this.hasChildrenArea,
      hasLibrary: hasLibrary ?? this.hasLibrary,
      hasClassrooms: hasClassrooms ?? this.hasClassrooms,
      hasKitchen: hasKitchen ?? this.hasKitchen,
      isWheelchairAccessible:
          isWheelchairAccessible ?? this.isWheelchairAccessible,
      services: services ?? this.services,
      appVersion: appVersion ?? this.appVersion,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
    );
  }

  // Getters utiles
  String get fullAddress => '$address, $city, $country';
  String get displayName => name;
  String get coordinates =>
      '${latitude.toStringAsFixed(4)}°N, ${longitude.abs().toStringAsFixed(4)}°${longitude < 0 ? 'W' : 'E'}';

  bool get hasSocialMedia =>
      facebookUrl?.isNotEmpty == true ||
      instagramUrl?.isNotEmpty == true ||
      youtubeUrl?.isNotEmpty == true ||
      twitterUrl?.isNotEmpty == true ||
      tiktokUrl?.isNotEmpty == true;

  @override
  List<Object?> get props => [
        id,
        name,
        nameArabic,
        slogan,
        description,
        address,
        city,
        country,
        latitude,
        longitude,
        timezone,
        phone,
        email,
        website,
        supportEmail,
        facebookUrl,
        instagramUrl,
        youtubeUrl,
        twitterUrl,
        tiktokUrl,
        openingHours,
        imamName,
        imamPhone,
        imamEmail,
        presidentName,
        presidentPhone,
        presidentEmail,
        bankAccount,
        mobileMoneyNumber,
        paypalAccount,
        capacity,
        hasParking,
        hasWuduArea,
        hasWomenSection,
        hasChildrenArea,
        hasLibrary,
        hasClassrooms,
        hasKitchen,
        isWheelchairAccessible,
        services,
        appVersion,
        logoUrl,
        bannerImageUrl,
        primaryColor,
        secondaryColor,
        createdAt,
        updatedAt,
        lastUpdatedBy,
      ];
}
