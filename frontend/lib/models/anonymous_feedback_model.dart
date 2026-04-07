import 'package:uuid/uuid.dart';

class AnonymousFeedback {
  final String id;
  final String videoId;
  final String content;
  final String feedbackType; // 'suggestion' or 'improvement'
  final String? ipAddress;
  final String? deviceId;
  final String? realUserId; // Admin can see this
  final DateTime createdAt;
  final bool isViewed;

  AnonymousFeedback({
    String? id,
    required this.videoId,
    required this.content,
    required this.feedbackType,
    this.ipAddress,
    this.deviceId,
    this.realUserId,
    DateTime? createdAt,
    this.isViewed = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'videoId': videoId,
    'content': content,
    'feedbackType': feedbackType,
    'ipAddress': ipAddress,
    'deviceId': deviceId,
    'realUserId': realUserId,
    'createdAt': createdAt.toIso8601String(),
    'isViewed': isViewed,
  };

  factory AnonymousFeedback.fromJson(Map<String, dynamic> json) =>
      AnonymousFeedback(
        id: json['id'],
        videoId: json['videoId'],
        content: json['content'],
        feedbackType: json['feedbackType'],
        ipAddress: json['ipAddress'],
        deviceId: json['deviceId'],
        realUserId: json['realUserId'],
        createdAt: DateTime.parse(json['createdAt']),
        isViewed: json['isViewed'] ?? false,
      );
}