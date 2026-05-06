import '../models/institution_model.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class InstitutionService {
  static Future<bool> hasAny() async {
    final data = await FirebaseService.get('institutions');
    if (data == null) return false;
    final map = data as Map<String, dynamic>;
    return map.entries.any((e) => (e.value as Map?)?['info'] != null);
  }

  static Future<InstitutionModel?> get(String slug) async {
    final data = await FirebaseService.get('institutions/$slug/info');
    if (data == null) return null;
    return InstitutionModel.fromMap(slug, data as Map<String, dynamic>);
  }

  static Future<List<InstitutionModel>> listAll() async {
    final data = await FirebaseService.get('institutions');
    if (data == null) return [];
    final map = data as Map<String, dynamic>;
    final out = <InstitutionModel>[];
    for (final e in map.entries) {
      final node = e.value as Map<String, dynamic>?;
      final info = node?['info'] as Map<String, dynamic>?;
      if (info != null) out.add(InstitutionModel.fromMap(e.key, info));
    }
    out.sort((a, b) => a.name.compareTo(b.name));
    return out;
  }

  /// Creates the institution metadata + the initial admin in a single call.
  /// Used by both the first-run flow and admin-only registration.
  static Future<bool> createWithAdmin({
    required InstitutionModel institution,
    required UserModel admin,
  }) async {
    final infoOk = await FirebaseService.set(
      'institutions/${institution.slug}/info',
      institution.toMap(),
    );
    if (!infoOk) return false;
    final userOk = await FirebaseService.set(
      'institutions/${institution.slug}/users/${admin.username}',
      admin.toMap(),
    );
    return userOk;
  }

  static Future<bool> delete(String slug) async {
    return FirebaseService.delete('institutions/$slug');
  }
}
