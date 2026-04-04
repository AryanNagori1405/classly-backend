import 'package:uuid/uuid.dart';

class Doubt {
  final String id;
  final String videoId;
  final int timestamp; // in seconds
  final String userId;
  final String userName;
  final String content;
  final bool isAnonymous;
  final List<String> replies;
  final List<int> upvotes; // list of user IDs who upvoted
  final bool isResolved;
  final String? teacherAnswer;
  final DateTime createdAt;

  Doubt({
    String? id,
    required this.videoId,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.content,
    required this.isAnonymous,
    this.replies = const [],
    this.upvotes = const [],
    this.isResolved = false,
    this.teacherAnswer,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'videoId': videoId,
    'timestamp': timestamp,
    'userId': userId,
    'userName': userName,
    'content': content,
    'isAnonymous': isAnonymous,
    'replies': replies,
    'upvotes': upvotes,
    'isResolved': isResolved,
    'teacherAnswer': teacherAnswer,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Doubt.fromJson(Map<String, dynamic> json) => Doubt(
    id: json['id'],
    videoId: json['videoId'],
    timestamp: json['timestamp'],
    userId: json['userId'],
    userName: json['userName'],
    content: json['content'],
    isAnonymous: json['isAnonymous'],
    replies: List<String>.from(json['replies'] ?? []),
    upvotes: List<int>.from(json['upvotes'] ?? []),
    isResolved: json['isResolved'] ?? false,
    teacherAnswer: json['teacherAnswer'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}