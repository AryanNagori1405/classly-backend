class Comment {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final String videoId;
  final String timestampId;
  final DateTime createdAt;
  final bool isAnonymous;
  final int upvotes;

  const Comment({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.videoId,
    required this.timestampId,
    required this.createdAt,
    this.isAnonymous = false,
    this.upvotes = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'authorId': authorId,
        'authorName': authorName,
        'videoId': videoId,
        'timestampId': timestampId,
        'createdAt': createdAt.toIso8601String(),
        'isAnonymous': isAnonymous,
        'upvotes': upvotes,
      };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id']?.toString() ?? '',
        content: json['content'] as String? ?? '',
        authorId: json['authorId']?.toString() ?? json['author_id']?.toString() ?? '',
        authorName: json['authorName'] as String? ?? json['author_name'] as String? ?? '',
        videoId: json['videoId']?.toString() ?? json['video_id']?.toString() ?? '',
        timestampId: json['timestampId']?.toString() ?? json['timestamp_id']?.toString() ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        isAnonymous: json['isAnonymous'] as bool? ?? json['is_anonymous'] as bool? ?? false,
        upvotes: json['upvotes'] as int? ?? 0,
      );

  Comment copyWith({
    String? id,
    String? content,
    String? authorId,
    String? authorName,
    String? videoId,
    String? timestampId,
    DateTime? createdAt,
    bool? isAnonymous,
    int? upvotes,
  }) =>
      Comment(
        id: id ?? this.id,
        content: content ?? this.content,
        authorId: authorId ?? this.authorId,
        authorName: authorName ?? this.authorName,
        videoId: videoId ?? this.videoId,
        timestampId: timestampId ?? this.timestampId,
        createdAt: createdAt ?? this.createdAt,
        isAnonymous: isAnonymous ?? this.isAnonymous,
        upvotes: upvotes ?? this.upvotes,
      );
}
