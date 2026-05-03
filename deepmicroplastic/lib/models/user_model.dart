import 'dart:convert';

class UserModel {
  final String username;
  final String name;
  final String email;
  final String institution;
  final String department;
  final String role; // 'admin' | 'researcher'
  final String passwordHash;
  final DateTime createdAt;

  const UserModel({
    required this.username,
    required this.name,
    required this.email,
    required this.institution,
    this.department = '',
    this.role = 'researcher',
    required this.passwordHash,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  String get displayName => name.isNotEmpty ? name : username;

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'institution': institution,
        'department': department,
        'role': role,
        'passwordHash': passwordHash,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory UserModel.fromMap(String username, Map<String, dynamic> map) =>
      UserModel(
        username: username,
        name: (map['name'] as String?) ?? '',
        email: (map['email'] as String?) ?? '',
        institution: (map['institution'] as String?) ?? '',
        department: (map['department'] as String?) ?? '',
        role: (map['role'] as String?) ?? 'researcher',
        passwordHash: (map['passwordHash'] as String?) ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          (map['createdAt'] as int?) ?? 0,
        ),
      );

  UserModel copyWith({
    String? name,
    String? email,
    String? institution,
    String? department,
    String? role,
    String? passwordHash,
  }) =>
      UserModel(
        username: username,
        name: name ?? this.name,
        email: email ?? this.email,
        institution: institution ?? this.institution,
        department: department ?? this.department,
        role: role ?? this.role,
        passwordHash: passwordHash ?? this.passwordHash,
        createdAt: createdAt,
      );

  // Basic obfuscation for internal lab use.
  // For production use Firebase Authentication instead.
  static String hashPassword(String password) {
    final bytes = utf8.encode('raviDeepMp_$password');
    return base64.encode(bytes);
  }
}
