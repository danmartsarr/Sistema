import '../models/spectrum_model.dart';
import 'firebase_service.dart';

class SampleService {
  static Future<List<SpectrumSample>> loadForDataset(String datasetId) async {
    final data = await FirebaseService.get('samples');
    if (data == null) return [];
    final map = data as Map<String, dynamic>;
    final results = <SpectrumSample>[];
    for (final entry in map.entries) {
      final m = entry.value as Map<String, dynamic>;
      if (m['datasetId'] == datasetId) {
        results.add(_fromMap(entry.key, m));
      }
    }
    results.sort((a, b) => a.name.compareTo(b.name));
    return results;
  }

  static SpectrumSample _fromMap(String id, Map<String, dynamic> m) =>
      SpectrumSample(
        id: id,
        name: (m['name'] as String?) ?? '',
        collectionSite: (m['collectionSite'] as String?) ?? '',
        collectionDate: DateTime.fromMillisecondsSinceEpoch(
          (m['collectionDate'] as int?) ?? 0,
        ),
        dataType: DataType.values.firstWhere(
          (v) => v.name == m['dataType'],
          orElse: () => DataType.absorbance,
        ),
        spectralData: [],
        notes: (m['notes'] as String?) ?? '',
        isVerified: (m['isVerified'] as bool?) ?? false,
        verifiedBy: (m['verifiedBy'] as String?) ?? '',
      );

  static Future<bool> save(
      SpectrumSample sample, String datasetId, String createdBy) async {
    return FirebaseService.set('samples/${sample.id}', {
      'datasetId': datasetId,
      'name': sample.name,
      'collectionSite': sample.collectionSite,
      'collectionDate': sample.collectionDate.millisecondsSinceEpoch,
      'dataType': sample.dataType.name,
      'notes': sample.notes,
      'isVerified': sample.isVerified,
      'verifiedBy': sample.verifiedBy,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'createdBy': createdBy,
    });
  }

  static Future<bool> update(SpectrumSample sample) async {
    return FirebaseService.update('samples/${sample.id}', {
      'collectionSite': sample.collectionSite,
      'notes': sample.notes,
      'isVerified': sample.isVerified,
      'verifiedBy': sample.verifiedBy,
    });
  }

  static Future<bool> delete(String sampleId) async {
    return FirebaseService.delete('samples/$sampleId');
  }
}
