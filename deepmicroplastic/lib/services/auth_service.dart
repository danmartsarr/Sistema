import '../models/user_model.dart';
import 'firebase_service.dart';

class AuthService {
  static Future<UserModel?> login(String username, String password) async {
    final data = await FirebaseService.get('users/$username');
    if (data == null) return null;
    final user = UserModel.fromMap(username, data as Map<String, dynamic>);
    if (user.passwordHash != UserModel.hashPassword(password)) return null;
    return user;
  }

  static Future<bool> hasAnyUser() async {
    final data = await FirebaseService.get('users');
    return data != null;
  }

  static Future<bool> usernameExists(String username) async {
    final data = await FirebaseService.get('users/$username');
    return data != null;
  }

  static Future<bool> createUser(UserModel user) async {
    return FirebaseService.set('users/${user.username}', user.toMap());
  }

  static Future<bool> updateUser(UserModel user) async {
    return FirebaseService.update('users/${user.username}', {
      'name': user.name,
      'email': user.email,
      'institution': user.institution,
      'department': user.department,
      'role': user.role,
    });
  }

  static Future<bool> changePassword(
      String username, String newPassword) async {
    return FirebaseService.update('users/$username', {
      'passwordHash': UserModel.hashPassword(newPassword),
    });
  }

  static Future<bool> deleteUser(String username) async {
    return FirebaseService.delete('users/$username');
  }

  static Future<List<UserModel>> listUsers() async {
    final data = await FirebaseService.get('users');
    if (data == null) return [];
    final map = data as Map<String, dynamic>;
    return map.entries
        .map((e) => UserModel.fromMap(e.key, e.value as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
  }
}
