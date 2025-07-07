import 'package:equatable/equatable.dart';

enum NewsCategory { announcement, religious, community, education, event }

enum NewsStatus { draft, published, archived }

class News extends Equatable {
  final String id;
  final String title;
  final String content;
  final String excerpt;
  final String? imageUrl;
  final List<String> imageUrls;
  final NewsCategory category;
  final NewsStatus status;
  final List<String> tags;
  final String authorId;
  final String authorName;
  final bool isPinned;
  final bool allowComments;
  final int viewCount;
  final DateTime publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const News({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    this.imageUrl,
    this.imageUrls = const [],
    required this.category,
    this.status = NewsStatus.draft,
    this.tags = const [],
    required this.authorId,
    required this.authorName,
    this.isPinned = false,
    this.allowComments = true,
    this.viewCount = 0,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory News.fromFirestore(Map<String, dynamic> data, String id) {
    return News(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      excerpt: data['excerpt'] ?? '',
      imageUrl: data['imageUrl'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      category: NewsCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => NewsCategory.announcement,
      ),
      status: NewsStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => NewsStatus.draft,
      ),
      tags: List<String>.from(data['tags'] ?? []),
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      isPinned: data['isPinned'] ?? false,
      allowComments: data['allowComments'] ?? true,
      viewCount: data['viewCount'] ?? 0,
      publishedAt: DateTime.parse(data['publishedAt']),
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'category': category.name,
      'status': status.name,
      'tags': tags,
      'authorId': authorId,
      'authorName': authorName,
      'isPinned': isPinned,
      'allowComments': allowComments,
      'viewCount': viewCount,
      'publishedAt': publishedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  News copyWith({
    String? title,
    String? content,
    String? excerpt,
    String? imageUrl,
    List<String>? imageUrls,
    NewsCategory? category,
    NewsStatus? status,
    List<String>? tags,
    String? authorId,
    String? authorName,
    bool? isPinned,
    bool? allowComments,
    int? viewCount,
    DateTime? publishedAt,
    DateTime? updatedAt,
  }) {
    return News(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isPinned: isPinned ?? this.isPinned,
      allowComments: allowComments ?? this.allowComments,
      viewCount: viewCount ?? this.viewCount,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  bool get isPublished => status == NewsStatus.published;
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} mois';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        excerpt,
        imageUrl,
        imageUrls,
        category,
        status,
        tags,
        authorId,
        authorName,
        isPinned,
        allowComments,
        viewCount,
        publishedAt,
        createdAt,
        updatedAt,
      ];
}

class Comment extends Equatable {
  final String id;
  final String newsId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final bool isApproved;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.newsId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    this.isApproved = false,
    required this.createdAt,
  });

  factory Comment.fromFirestore(Map<String, dynamic> data, String id) {
    return Comment(
      id: id,
      newsId: data['newsId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      content: data['content'] ?? '',
      isApproved: data['isApproved'] ?? false,
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'newsId': newsId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'isApproved': isApproved,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        newsId,
        userId,
        userName,
        userPhotoUrl,
        content,
        isApproved,
        createdAt,
      ];
}
