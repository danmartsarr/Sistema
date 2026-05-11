import '../models/spectrum_model.dart';
import 'firebase_service.dart';

/// CRUD operations for [SpectrumDataset] records stored in Firebase.
///
/// Deleting a dataset also removes all associated samples to avoid orphans.
class DatasetService {
  static String _datasetsPath(String institutionSlug) =>
      'institutions/$institutionSlug/datasets';

  static Future<List<SpectrumDataset>> loadAll(String institutionSlug) async {
    final data = await FirebaseService.get(_datasetsPath(institutionSlug));
    if (data == null) return [];
    final map = data as Map<String, dynamic>;
    final list = map.entries
        .map((e) => _fromMap(e.key, e.value as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  static SpectrumDataset _fromMap(String id, Map<String, dynamic> m) =>
      SpectrumDataset(
        id: id,
        name: (m['name'] as String?) ?? '',
        description: (m['description'] as String?) ?? '',
        location: (m['location'] as String?) ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          (m['createdAt'] as int?) ?? 0,
        ),
        samples: [],
        microscopeMode: MicroscopeMode.values.firstWhere(
          (v) => v.name == m['microscopeMode'],
          orElse: () => MicroscopeMode.atr,
        ),
        microscopeModel: (m['microscopeModel'] as String?) ?? '',
        resolution: ((m['resolution'] ?? 4) as num).toDouble(),
        numScans: (m['numScans'] as int?) ?? 64,
        detectorType: (m['detectorType'] as String?) ?? 'MCT',
        crystalType: (m['crystalType'] as String?) ?? 'Diamante',
        dataType: DataType.values.firstWhere(
          (v) => v.name == m['dataType'],
          orElse: () => DataType.absorbance,
        ),
      );

  static Future<String?> save(
    SpectrumDataset dataset,
    String institutionSlug,
    String createdBy,
  ) async {
    final id = 'ds-${DateTime.now().millisecondsSinceEpoch}';
    final ok = await FirebaseService.set(
      '${_datasetsPath(institutionSlug)}/$id',
      {
        'name': dataset.name,
        'description': dataset.description,
        'location': dataset.location,
        'createdAt': dataset.createdAt.millisecondsSinceEpoch,
        'createdBy': createdBy,
        'microscopeMode': dataset.microscopeMode.name,
        'microscopeModel': dataset.microscopeModel,
        'resolution': dataset.resolution,
        'numScans': dataset.numScans,
        'detectorType': dataset.detectorType,
        'crystalType': dataset.crystalType,
        'dataType': dataset.dataType.name,
      },
    );
    return ok ? id : null;
  }

  static Future<bool> delete(String institutionSlug, String datasetId) async {
    // Remove all samples of this dataset first.
    final samplesPath = 'institutions/$institutionSlug/samples';
    final data = await FirebaseService.get(samplesPath);
    if (data != null) {
      final map = data as Map<String, dynamic>;
      for (final entry in map.entries) {
        final m = entry.value as Map<String, dynamic>;
        if (m['datasetId'] == datasetId) {
          await FirebaseService.delete('$samplesPath/${entry.key}');
        }
      }
    }
    return FirebaseService.delete(
      '${_datasetsPath(institutionSlug)}/$datasetId',
    );
  }
}
