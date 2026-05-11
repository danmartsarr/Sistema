/// A research institution that owns datasets and users in the system.
///
/// The [slug] is derived from the institution's name via [slugify] and serves
/// as the Firebase namespace key (e.g. `'universidade-de-sao-paulo'`).
class InstitutionModel {
  final String slug;
  final String name;
  final String createdBy;
  final DateTime createdAt;

  const InstitutionModel({
    required this.slug,
    required this.name,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'name':      name,
        'createdBy': createdBy,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory InstitutionModel.fromMap(String slug, Map<String, dynamic> m) =>
      InstitutionModel(
        slug:      slug,
        name:      (m['name'] as String?) ?? slug,
        createdBy: (m['createdBy'] as String?) ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          (m['createdAt'] as int?) ?? 0,
        ),
      );

  /// e.g. "Universidade de São Paulo" → "universidade-de-sao-paulo".
  static String slugify(String name) {
    final lowered = name.toLowerCase().trim();
    final ascii = lowered
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll('ñ', 'n');
    final cleaned = ascii.replaceAll(RegExp(r'[^a-z0-9\s-]'), '');
    return cleaned.replaceAll(RegExp(r'\s+'), '-').replaceAll(RegExp(r'-+'), '-');
  }
}
