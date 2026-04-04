class User {
  final int id;
  final String name;
  final String email;
  final String role; // 'student' or 'teacher'
  final String? profileImage;
  final String? bio;
  final int coursesCount;
  final int videosCount;
  final double rating;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    this.bio,
    this.coursesCount = 0,
    this.videosCount = 0,
    this.rating = 0.0,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      profileImage: json['profile_image'],
      bio: json['bio'],
      coursesCount: json['courses_count'] ?? 0,
      videosCount: json['videos_count'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profile_image': profileImage,
      'bio': bio,
      'courses_count': coursesCount,
      'videos_count': videosCount,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }
}