import 'dart:convert';

class UserModel {
  /// `/institutions/<institutionSlug>/users/<username>`.
  final String institutionSlug;
  final String username;
  final String name;
  final String email;
  final String department;
  final String role; 
  final String passwordHash;
  final DateTime createdAt;

  const UserModel({
    required this.institutionSlug,
    required this.username,
    required this.name,
    required this.email,
    this.department = '',
    this.role = 'researcher',
    required this.passwordHash,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  String get displayName => name.isNotEmpty ? name : username;

  Map<String, dynamic> toMap() => {
        'name':         name,
        'email':        email,
        'department':   department,
        'role':         role,
        'passwordHash': passwordHash,
        'createdAt':    createdAt.millisecondsSinceEpoch,
      };

  factory UserModel.fromMap(
    String institutionSlug,
    String username,
    Map<String, dynamic> map,
  ) =>
      UserModel(
        institutionSlug: institutionSlug,
        username:        username,
        name:            (map['name'] as String?) ?? '',
        email:           (map['email'] as String?) ?? '',
        department:      (map['department'] as String?) ?? '',
        role:            (map['role'] as String?) ?? 'researcher',
        passwordHash:    (map['passwordHash'] as String?) ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          (map['createdAt'] as int?) ?? 0,
        ),
      );

  UserModel copyWith({
    String? name,
    String? email,
    String? department,
    String? role,
    String? passwordHash,
  }) =>
      UserModel(
        institutionSlug: institutionSlug,
        username:        username,
        name:            name ?? this.name,
        email:           email ?? this.email,
        department:      department ?? this.department,
        role:            role ?? this.role,
        passwordHash:    passwordHash ?? this.passwordHash,
        createdAt:       createdAt,
      );

  static String hashPassword(String password) {
    final bytes = utf8.encode('raviDeepMp_$password');
    return base64.encode(bytes);
  }
}
