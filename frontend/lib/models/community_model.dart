import 'package:uuid/uuid.dart';

class Community {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final String icon;
  final String subject;
  final List<String> members;
  final List<String> moderators;
  final bool isPrivate;
  final int membersCount;
  final DateTime createdAt;

  Community({
    String? id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.icon,
    required this.subject,
    this.members = const [],
    this.moderators = const [],
    this.isPrivate = false,
    this.membersCount = 0,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'createdBy': createdBy,
    'icon': icon,
    'subject': subject,
    'members': members,
    'moderators': moderators,
    'isPrivate': isPrivate,
    'membersCount': membersCount,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Community.fromJson(Map<String, dynamic> json) => Community(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    createdBy: json['createdBy'],
    icon: json['icon'],
    subject: json['subject'],
    members: List<String>.from(json['members'] ?? []),
    moderators: List<String>.from(json['moderators'] ?? []),
    isPrivate: json['isPrivate'] ?? false,
    membersCount: json['membersCount'] ?? 0,
    createdAt: DateTime.parse(json['createdAt']),
  );
}