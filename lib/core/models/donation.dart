import 'package:equatable/equatable.dart';

enum DonationType { zakat, sadaqah, masjid, education, charity, emergency }

enum DonationStatus { pending, completed, failed, refunded }

enum PaymentMethod { card, paypal, bankTransfer, cash }

class Donation extends Equatable {
  final String id;
  final String? userId;
  final String donorName;
  final String? donorEmail;
  final String? donorPhone;
  final double amount;
  final String currency;
  final DonationType type;
  final DonationStatus status;
  final PaymentMethod paymentMethod;
  final String? transactionId;
  final String? message;
  final bool isAnonymous;
  final bool isRecurring;
  final String? recurringPeriod; // monthly, yearly
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? paymentMetadata;

  const Donation({
    required this.id,
    this.userId,
    required this.donorName,
    this.donorEmail,
    this.donorPhone,
    required this.amount,
    this.currency = 'EUR',
    required this.type,
    this.status = DonationStatus.pending,
    required this.paymentMethod,
    this.transactionId,
    this.message,
    this.isAnonymous = false,
    this.isRecurring = false,
    this.recurringPeriod,
    required this.createdAt,
    this.completedAt,
    this.paymentMetadata,
  });

  factory Donation.fromFirestore(Map<String, dynamic> data, String id) {
    return Donation(
      id: id,
      userId: data['userId'],
      donorName: data['donorName'] ?? '',
      donorEmail: data['donorEmail'],
      donorPhone: data['donorPhone'],
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'EUR',
      type: DonationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => DonationType.sadaqah,
      ),
      status: DonationStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => DonationStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == data['paymentMethod'],
        orElse: () => PaymentMethod.card,
      ),
      transactionId: data['transactionId'],
      message: data['message'],
      isAnonymous: data['isAnonymous'] ?? false,
      isRecurring: data['isRecurring'] ?? false,
      recurringPeriod: data['recurringPeriod'],
      createdAt: DateTime.parse(data['createdAt']),
      completedAt: data['completedAt'] != null
          ? DateTime.parse(data['completedAt'])
          : null,
      paymentMetadata: data['paymentMetadata']?.cast<String, dynamic>(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'donorName': donorName,
      'donorEmail': donorEmail,
      'donorPhone': donorPhone,
      'amount': amount,
      'currency': currency,
      'type': type.name,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'transactionId': transactionId,
      'message': message,
      'isAnonymous': isAnonymous,
      'isRecurring': isRecurring,
      'recurringPeriod': recurringPeriod,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'paymentMetadata': paymentMetadata,
    };
  }

  Donation copyWith({
    String? userId,
    String? donorName,
    String? donorEmail,
    String? donorPhone,
    double? amount,
    String? currency,
    DonationType? type,
    DonationStatus? status,
    PaymentMethod? paymentMethod,
    String? transactionId,
    String? message,
    bool? isAnonymous,
    bool? isRecurring,
    String? recurringPeriod,
    DateTime? completedAt,
    Map<String, dynamic>? paymentMetadata,
  }) {
    return Donation(
      id: id,
      userId: userId ?? this.userId,
      donorName: donorName ?? this.donorName,
      donorEmail: donorEmail ?? this.donorEmail,
      donorPhone: donorPhone ?? this.donorPhone,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      message: message ?? this.message,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPeriod: recurringPeriod ?? this.recurringPeriod,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      paymentMetadata: paymentMetadata ?? this.paymentMetadata,
    );
  }

  String get displayName => isAnonymous ? 'Donateur anonyme' : donorName;

  @override
  List<Object?> get props => [
        id,
        userId,
        donorName,
        donorEmail,
        donorPhone,
        amount,
        currency,
        type,
        status,
        paymentMethod,
        transactionId,
        message,
        isAnonymous,
        isRecurring,
        recurringPeriod,
        createdAt,
        completedAt,
        paymentMetadata,
      ];
}

class DonationCampaign extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DonationType type;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DonationCampaign({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.currency = 'EUR',
    required this.type,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DonationCampaign.fromFirestore(Map<String, dynamic> data, String id) {
    return DonationCampaign(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      targetAmount: (data['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'EUR',
      type: DonationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => DonationType.charity,
      ),
      startDate: DateTime.parse(data['startDate']),
      endDate: DateTime.parse(data['endDate']),
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'currency': currency,
      'type': type.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double get progressPercentage =>
      targetAmount > 0 ? (currentAmount / targetAmount * 100).clamp(0, 100) : 0;
  bool get isCompleted => currentAmount >= targetAmount;
  bool get isExpired => DateTime.now().isAfter(endDate);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        targetAmount,
        currentAmount,
        currency,
        type,
        startDate,
        endDate,
        isActive,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
