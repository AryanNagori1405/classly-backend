class Feedback {
  final String id;
  final String content;
  final String category; // 'suggestion' | 'bug' | 'improvement' | 'other'
  final String teacherId;
  final String? senderId;
  final DateTime createdAt;
  final String? response;
  final DateTime? respondedAt;

  const Feedback({
    required this.id,
    required this.content,
    required this.category,
    required this.teacherId,
    this.senderId,
    required this.createdAt,
    this.response,
    this.respondedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'category': category,
        'teacherId': teacherId,
        'senderId': senderId,
        'createdAt': createdAt.toIso8601String(),
        'response': response,
        'respondedAt': respondedAt?.toIso8601String(),
      };

  factory Feedback.fromJson(Map<String, dynamic> json) => Feedback(
        id: json['id']?.toString() ?? '',
        content: json['content'] as String? ?? json['message'] as String? ?? '',
        category: json['category'] as String? ?? 'other',
        teacherId: json['teacherId']?.toString() ?? json['teacher_id']?.toString() ?? '',
        senderId: json['senderId']?.toString() ?? json['sender_id']?.toString(),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        response: json['response'] as String?,
        respondedAt: json['respondedAt'] != null
            ? DateTime.tryParse(json['respondedAt'] as String)
            : null,
      );
}
