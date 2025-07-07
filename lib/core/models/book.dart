import 'package:equatable/equatable.dart';

enum BookCategory { quran, hadith, fiqh, seerah, aqidah, arabic, general }

enum BookType { pdf, audio, video, epub }

enum BookStatus { available, borrowed, maintenance, archived }

class Book extends Equatable {
  final String id;
  final String title;
  final String titleArabic;
  final String author;
  final String authorArabic;
  final String description;
  final String? isbn;
  final BookCategory category;
  final BookType type;
  final BookStatus status;
  final String? coverImageUrl;
  final String? fileUrl;
  final int? pageCount;
  final String? duration; // Pour les audio/vidéo
  final double? fileSize; // En MB
  final List<String> tags;
  final String language;
  final bool isPublic;
  final int downloadCount;
  final double rating;
  final int ratingCount;
  final DateTime publishedDate;
  final DateTime addedAt;
  final DateTime updatedAt;
  final String addedBy;

  const Book({
    required this.id,
    required this.title,
    this.titleArabic = '',
    required this.author,
    this.authorArabic = '',
    required this.description,
    this.isbn,
    required this.category,
    required this.type,
    this.status = BookStatus.available,
    this.coverImageUrl,
    this.fileUrl,
    this.pageCount,
    this.duration,
    this.fileSize,
    this.tags = const [],
    this.language = 'fr',
    this.isPublic = true,
    this.downloadCount = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    required this.publishedDate,
    required this.addedAt,
    required this.updatedAt,
    required this.addedBy,
  });

  factory Book.fromFirestore(Map<String, dynamic> data, String id) {
    return Book(
      id: id,
      title: data['title'] ?? '',
      titleArabic: data['titleArabic'] ?? '',
      author: data['author'] ?? '',
      authorArabic: data['authorArabic'] ?? '',
      description: data['description'] ?? '',
      isbn: data['isbn'],
      category: BookCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => BookCategory.general,
      ),
      type: BookType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => BookType.pdf,
      ),
      status: BookStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => BookStatus.available,
      ),
      coverImageUrl: data['coverImageUrl'],
      fileUrl: data['fileUrl'],
      pageCount: data['pageCount'],
      duration: data['duration'],
      fileSize: data['fileSize']?.toDouble(),
      tags: List<String>.from(data['tags'] ?? []),
      language: data['language'] ?? 'fr',
      isPublic: data['isPublic'] ?? true,
      downloadCount: data['downloadCount'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      publishedDate: DateTime.parse(data['publishedDate']),
      addedAt: DateTime.parse(data['addedAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      addedBy: data['addedBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'titleArabic': titleArabic,
      'author': author,
      'authorArabic': authorArabic,
      'description': description,
      'isbn': isbn,
      'category': category.name,
      'type': type.name,
      'status': status.name,
      'coverImageUrl': coverImageUrl,
      'fileUrl': fileUrl,
      'pageCount': pageCount,
      'duration': duration,
      'fileSize': fileSize,
      'tags': tags,
      'language': language,
      'isPublic': isPublic,
      'downloadCount': downloadCount,
      'rating': rating,
      'ratingCount': ratingCount,
      'publishedDate': publishedDate.toIso8601String(),
      'addedAt': addedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'addedBy': addedBy,
    };
  }

  Book copyWith({
    String? title,
    String? titleArabic,
    String? author,
    String? authorArabic,
    String? description,
    String? isbn,
    BookCategory? category,
    BookType? type,
    BookStatus? status,
    String? coverImageUrl,
    String? fileUrl,
    int? pageCount,
    String? duration,
    double? fileSize,
    List<String>? tags,
    String? language,
    bool? isPublic,
    int? downloadCount,
    double? rating,
    int? ratingCount,
    DateTime? publishedDate,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      titleArabic: titleArabic ?? this.titleArabic,
      author: author ?? this.author,
      authorArabic: authorArabic ?? this.authorArabic,
      description: description ?? this.description,
      isbn: isbn ?? this.isbn,
      category: category ?? this.category,
      type: type ?? this.type,
      status: status ?? this.status,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      pageCount: pageCount ?? this.pageCount,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      tags: tags ?? this.tags,
      language: language ?? this.language,
      isPublic: isPublic ?? this.isPublic,
      downloadCount: downloadCount ?? this.downloadCount,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      publishedDate: publishedDate ?? this.publishedDate,
      addedAt: addedAt,
      updatedAt: updatedAt ?? DateTime.now(),
      addedBy: addedBy,
    );
  }

  String get fileSizeFormatted {
    if (fileSize == null) return '';
    if (fileSize! < 1) return '${(fileSize! * 1024).toStringAsFixed(0)} KB';
    return '${fileSize!.toStringAsFixed(1)} MB';
  }

  bool get isAudio => type == BookType.audio;
  bool get isVideo => type == BookType.video;
  bool get isPdf => type == BookType.pdf;
  bool get isEpub => type == BookType.epub;

  @override
  List<Object?> get props => [
        id,
        title,
        titleArabic,
        author,
        authorArabic,
        description,
        isbn,
        category,
        type,
        status,
        coverImageUrl,
        fileUrl,
        pageCount,
        duration,
        fileSize,
        tags,
        language,
        isPublic,
        downloadCount,
        rating,
        ratingCount,
        publishedDate,
        addedAt,
        updatedAt,
        addedBy,
      ];
}

class BookRating extends Equatable {
  final String id;
  final String bookId;
  final String userId;
  final String userName;
  final double rating;
  final String? review;
  final DateTime createdAt;

  const BookRating({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.review,
    required this.createdAt,
  });

  factory BookRating.fromFirestore(Map<String, dynamic> data, String id) {
    return BookRating(
      id: id,
      bookId: data['bookId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      review: data['review'],
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookId': bookId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'review': review,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        bookId,
        userId,
        userName,
        rating,
        review,
        createdAt,
      ];
}
