class Course {
  final int id;
  final String title;
  final String description;
  final String instructor;
  final String? thumbnail;
  final int videosCount;
  final int enrolledCount;
  final double rating;
  final String level; // 'beginner', 'intermediate', 'advanced'
  final List<String> tags;
  final bool isEnrolled;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    this.thumbnail,
    this.videosCount = 0,
    this.enrolledCount = 0,
    this.rating = 0.0,
    this.level = 'beginner',
    this.tags = const [],
    this.isEnrolled = false,
    required this.createdAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructor: json['instructor'] ?? '',
      thumbnail: json['thumbnail'],
      videosCount: json['videos_count'] ?? 0,
      enrolledCount: json['enrolled_count'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      level: json['level'] ?? 'beginner',
      tags: List<String>.from(json['tags'] ?? []),
      isEnrolled: json['is_enrolled'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor': instructor,
      'thumbnail': thumbnail,
      'videos_count': videosCount,
      'enrolled_count': enrolledCount,
      'rating': rating,
      'level': level,
      'tags': tags,
      'is_enrolled': isEnrolled,
      'created_at': createdAt.toIso8601String(),
    };
  }
}