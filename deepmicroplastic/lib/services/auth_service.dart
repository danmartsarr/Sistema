import '../models/user_model.dart';
import 'firebase_service.dart';

class AuthService {
  static String _userPath(String institutionSlug, String username) =>
      'institutions/$institutionSlug/users/$username';

  static String _usersPath(String institutionSlug) =>
      'institutions/$institutionSlug/users';

  static Future<UserModel?> login(
    String institutionSlug,
    String username,
    String password,
  ) async {
    final data = await FirebaseService.get(_userPath(institutionSlug, username));
    if (data == null) return null;
    final user = UserModel.fromMap(
      institutionSlug,
      username,
      data as Map<String, dynamic>,
    );
    if (user.passwordHash != UserModel.hashPassword(password)) return null;
    return user;
  }

  static Future<bool> usernameExists(
      String institutionSlug, String username) async {
    final data = await FirebaseService.get(_userPath(institutionSlug, username));
    return data != null;
  }

  static Future<bool> createUser(UserModel user) async {
    return FirebaseService.set(
      _userPath(user.institutionSlug, user.username),
      user.toMap(),
    );
  }

  static Future<bool> updateUser(UserModel user) async {
    return FirebaseService.update(_userPath(user.institutionSlug, user.username), {
      'name':       user.name,
      'email':      user.email,
      'department': user.department,
      'role':       user.role,
    });
  }

  static Future<bool> changePassword(
      String institutionSlug, String username, String newPassword) async {
    return FirebaseService.update(_userPath(institutionSlug, username), {
      'passwordHash': UserModel.hashPassword(newPassword),
    });
  }

  static Future<bool> deleteUser(String institutionSlug, String username) async {
    return FirebaseService.delete(_userPath(institutionSlug, username));
  }

  static Future<List<UserModel>> listUsers(String institutionSlug) async {
    final data = await FirebaseService.get(_usersPath(institutionSlug));
    if (data == null) return [];
    final map = data as Map<String, dynamic>;
    return map.entries
        .map((e) => UserModel.fromMap(
              institutionSlug,
              e.key,
              e.value as Map<String, dynamic>,
            ))
        .toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
  }
}
