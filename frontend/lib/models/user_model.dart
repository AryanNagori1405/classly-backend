class User {
  final int id;
  final String regNo;
  final String name;
  final String email;
  final String phone;
  final String role; // 'student' | 'teacher' | 'admin'
  final String profileImage;
  final String bio;
  final DateTime createdAt;
  final bool isVerified;

  User({
    this.id = 0,
    required this.regNo,
    required this.name,
    this.email = '',
    this.phone = '',
    required this.role,
    this.profileImage = 'https://via.placeholder.com/100',
    this.bio = '',
    DateTime? createdAt,
    this.isVerified = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'reg_no': regNo,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'profileImage': profileImage,
        'bio': bio,
        'createdAt': createdAt.toIso8601String(),
        'isVerified': isVerified,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int? ?? 0,
        regNo: json['reg_no'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        role: json['role'] as String? ?? 'student',
        profileImage: (json['profileImage'] ?? json['profile_image'])
                as String? ??
            'https://via.placeholder.com/100',
        bio: json['bio'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        isVerified: json['isVerified'] ?? json['is_verified'] as bool? ?? false,
      );

  User copyWith({
    String? regNo,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profileImage,
    String? bio,
    bool? isVerified,
  }) =>
      User(
        id: id,
        regNo: regNo ?? this.regNo,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        profileImage: profileImage ?? this.profileImage,
        bio: bio ?? this.bio,
        createdAt: createdAt,
        isVerified: isVerified ?? this.isVerified,
      );
}
