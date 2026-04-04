class User {
  final String id;
  final String uid; // UID (unique identifier)
  final String regId; // Registration ID
  final String name;
  final String email;
  final String role; // 'student' or 'teacher'
  final String department;
  final String semester;
  final String profileImage;
  final String bio;
  final List<String> enrolledCourses;
  final List<String> joinedCommunities;
  final int coursesCount;
  final int videosCount;
  final double rating;
  final DateTime createdAt;
  final bool isVerified;

  User({
    String? id,
    required this.uid,
    required this.regId,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.semester,
    this.profileImage = 'https://via.placeholder.com/100',
    this.bio = '',
    this.enrolledCourses = const [],
    this.joinedCommunities = const [],
    this.coursesCount = 0,
    this.videosCount = 0,
    this.rating = 0.0,
    DateTime? createdAt,
    this.isVerified = false,
  })  : id = id ?? uid,
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'uid': uid,
    'regId': regId,
    'name': name,
    'email': email,
    'role': role,
    'department': department,
    'semester': semester,
    'profileImage': profileImage,
    'bio': bio,
    'enrolledCourses': enrolledCourses,
    'joinedCommunities': joinedCommunities,
    'coursesCount': coursesCount,
    'videosCount': videosCount,
    'rating': rating,
    'createdAt': createdAt.toIso8601String(),
    'isVerified': isVerified,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    uid: json['uid'],
    regId: json['regId'],
    name: json['name'],
    email: json['email'],
    role: json['role'],
    department: json['department'],
    semester: json['semester'],
    profileImage: json['profileImage'] ?? 'https://via.placeholder.com/100',
    bio: json['bio'] ?? '',
    enrolledCourses: List<String>.from(json['enrolledCourses'] ?? []),
    joinedCommunities: List<String>.from(json['joinedCommunities'] ?? []),
    coursesCount: json['coursesCount'] ?? 0,
    videosCount: json['videosCount'] ?? 0,
    rating: (json['rating'] ?? 0).toDouble(),
    createdAt: DateTime.parse(json['createdAt']),
    isVerified: json['isVerified'] ?? false,
  );
}