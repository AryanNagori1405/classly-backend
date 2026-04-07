import 'package:uuid/uuid.dart';

class Video {
  final String id;
  final String title;
  final String description;
  final String uploadedBy; // Teacher UID
  final String videoUrl;
  final String thumbnailUrl;
  final String subject;
  final String category;
  final int duration; // in seconds
  final DateTime createdAt;
  final DateTime expiresAt;
  final int views;
  final double rating;
  final List<String> tags;
  final String? notesUrl;
  final bool isPinned;
  final int downloadsCount;
  final List<String> allowedUserIds;

  Video({
    String? id,
    required this.title,
    required this.description,
    required this.uploadedBy,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.subject,
    required this.category,
    required this.duration,
    required this.createdAt,
    DateTime? expiresAt,
    this.views = 0,
    this.rating = 0.0,
    this.tags = const [],
    this.notesUrl,
    this.isPinned = false,
    this.downloadsCount = 0,
    this.allowedUserIds = const [],
  })  : id = id ?? const Uuid().v4(),
        expiresAt = expiresAt ?? createdAt.add(const Duration(days: 7));

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isExpiringSoon => 
      DateTime.now().difference(expiresAt).inDays <= 1;
  int get daysRemaining => 
      expiresAt.difference(DateTime.now()).inDays;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'uploadedBy': uploadedBy,
    'videoUrl': videoUrl,
    'thumbnailUrl': thumbnailUrl,
    'subject': subject,
    'category': category,
    'duration': duration,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'views': views,
    'rating': rating,
    'tags': tags,
    'notesUrl': notesUrl,
    'isPinned': isPinned,
    'downloadsCount': downloadsCount,
    'allowedUserIds': allowedUserIds,
  };

  factory Video.fromJson(Map<String, dynamic> json) => Video(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    uploadedBy: json['uploadedBy'],
    videoUrl: json['videoUrl'],
    thumbnailUrl: json['thumbnailUrl'],
    subject: json['subject'],
    category: json['category'],
    duration: json['duration'],
    createdAt: DateTime.parse(json['createdAt']),
    expiresAt: DateTime.parse(json['expiresAt']),
    views: json['views'] ?? 0,
    rating: (json['rating'] ?? 0).toDouble(),
    tags: List<String>.from(json['tags'] ?? []),
    notesUrl: json['notesUrl'],
    isPinned: json['isPinned'] ?? false,
    downloadsCount: json['downloadsCount'] ?? 0,
    allowedUserIds: List<String>.from(json['allowedUserIds'] ?? []),
  );
}