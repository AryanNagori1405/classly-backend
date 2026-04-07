import 'package:uuid/uuid.dart';

class TimestampComment {
  final String id;
  final String videoId;
  final String userId;
  final String userName;
  final int timestamp; // in seconds
  final String comment;
  final String commentType; // 'doubt' or 'suggestion'
  final List<String> replies;
  final int upvotes;
  final bool isResolved;
  final String? teacherAnswer;
  final DateTime createdAt;

  TimestampComment({
    String? id,
    required this.videoId,
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.comment,
    required this.commentType,
    this.replies = const [],
    this.upvotes = 0,
    this.isResolved = false,
    this.teacherAnswer,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  String get formattedTimestamp {
    final minutes = timestamp ~/ 60;
    final seconds = timestamp % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'videoId': videoId,
    'userId': userId,
    'userName': userName,
    'timestamp': timestamp,
    'comment': comment,
    'commentType': commentType,
    'replies': replies,
    'upvotes': upvotes,
    'isResolved': isResolved,
    'teacherAnswer': teacherAnswer,
    'createdAt': createdAt.toIso8601String(),
  };

  factory TimestampComment.fromJson(Map<String, dynamic> json) =>
      TimestampComment(
        id: json['id'],
        videoId: json['videoId'],
        userId: json['userId'],
        userName: json['userName'],
        timestamp: json['timestamp'],
        comment: json['comment'],
        commentType: json['commentType'],
        replies: List<String>.from(json['replies'] ?? []),
        upvotes: json['upvotes'] ?? 0,
        isResolved: json['isResolved'] ?? false,
        teacherAnswer: json['teacherAnswer'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}