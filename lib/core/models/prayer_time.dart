import 'package:equatable/equatable.dart';

class PrayerTime extends Equatable {
  final String id;
  final String name;
  final String nameArabic;
  final String time; // Format HH:mm
  final bool isEnabled;
  final DateTime date;
  final int adjustmentMinutes; // Ajustement manuel en minutes
  final DateTime createdAt;
  final DateTime updatedAt;

  const PrayerTime({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.time,
    this.isEnabled = true,
    required this.date,
    this.adjustmentMinutes = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PrayerTime.fromFirestore(Map<String, dynamic> data, String id) {
    return PrayerTime(
      id: id,
      name: data['name'] ?? '',
      nameArabic: data['nameArabic'] ?? '',
      time: data['time'] ?? '',
      isEnabled: data['isEnabled'] ?? true,
      date: DateTime.parse(data['date']),
      adjustmentMinutes: data['adjustmentMinutes'] ?? 0,
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameArabic': nameArabic,
      'time': time,
      'isEnabled': isEnabled,
      'date': date.toIso8601String(),
      'adjustmentMinutes': adjustmentMinutes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PrayerTime copyWith({
    String? name,
    String? nameArabic,
    String? time,
    bool? isEnabled,
    DateTime? date,
    int? adjustmentMinutes,
    DateTime? updatedAt,
  }) {
    return PrayerTime(
      id: id,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
      date: date ?? this.date,
      adjustmentMinutes: adjustmentMinutes ?? this.adjustmentMinutes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Obtient l'heure ajustée avec les minutes d'ajustement
  String get adjustedTime {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final totalMinutes = hour * 60 + minute + adjustmentMinutes;
    final adjustedHour = (totalMinutes ~/ 60) % 24;
    final adjustedMinute = totalMinutes % 60;

    return '${adjustedHour.toString().padLeft(2, '0')}:${adjustedMinute.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameArabic,
        time,
        isEnabled,
        date,
        adjustmentMinutes,
        createdAt,
        updatedAt,
      ];
}

class PrayerConfiguration extends Equatable {
  final String id;
  final String mosqueName;
  final double latitude;
  final double longitude;
  final String timezone;
  final String calculationMethod;
  final Map<String, int> adjustments; // Ajustements par prière
  final bool automaticCalculation;
  final DateTime updatedAt;

  const PrayerConfiguration({
    required this.id,
    required this.mosqueName,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.calculationMethod,
    required this.adjustments,
    this.automaticCalculation = true,
    required this.updatedAt,
  });

  factory PrayerConfiguration.fromFirestore(
      Map<String, dynamic> data, String id) {
    return PrayerConfiguration(
      id: id,
      mosqueName: data['mosqueName'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      timezone: data['timezone'] ?? '',
      calculationMethod: data['calculationMethod'] ?? '',
      adjustments: Map<String, int>.from(data['adjustments'] ?? {}),
      automaticCalculation: data['automaticCalculation'] ?? true,
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mosqueName': mosqueName,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'calculationMethod': calculationMethod,
      'adjustments': adjustments,
      'automaticCalculation': automaticCalculation,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        mosqueName,
        latitude,
        longitude,
        timezone,
        calculationMethod,
        adjustments,
        automaticCalculation,
        updatedAt,
      ];
}
