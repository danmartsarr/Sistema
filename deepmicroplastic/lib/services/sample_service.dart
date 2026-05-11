import '../models/spectrum_model.dart';
import 'firebase_service.dart';
import 'spectral_storage_service.dart';

/// CRUD operations for [SpectrumSample] records.
///
/// Metadata is stored in Firebase; spectral data (wavenumbers + intensities)
/// is stored separately on the MLP server via [SpectralStorageService].
/// Samples loaded from Firebase have an empty [SpectrumSample.spectralData]
/// until [hydrateSpectrum] is called.
class SampleService {
  static String _samplesPath(String institutionSlug) =>
      'institutions/$institutionSlug/samples';

  static Future<List<SpectrumSample>> loadForDataset(
    String institutionSlug,
    String datasetId,
  ) async {
    final data = await FirebaseService.get(_samplesPath(institutionSlug));
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

  /// Fetches spectral data from the MLP server and attaches it to [sample].
  ///
  /// No-ops if [sample.spectralData] is already populated.
  static Future<SpectrumSample> hydrateSpectrum(
    SpectrumSample sample,
    String institutionSlug,
    String datasetId,
  ) async {
    if (sample.spectralData.isNotEmpty) return sample;
    final spectrum = await SpectralStorageService.load(
      institutionSlug: institutionSlug,
      datasetId: datasetId,
      sampleId: sample.id,
    );
    sample.spectralData = spectrum;
    return sample;
  }

  static SpectrumSample _fromMap(String id, Map<String, dynamic> m) {
    final result = _resultFromMap(m['result']);
    return SpectrumSample(
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
      spectralData: const [], 
      result: result,
      notes: (m['notes'] as String?) ?? '',
      isVerified: (m['isVerified'] as bool?) ?? false,
      verifiedBy: (m['verifiedBy'] as String?) ?? '',
    );
  }

  static IdentificationResult? _resultFromMap(dynamic raw) {
    if (raw == null) return null;
    final m = raw as Map<String, dynamic>;
    final polymer = PolymerType.values.firstWhere(
      (p) => p.name == m['polymer'],
      orElse: () => PolymerType.unknown,
    );
    final attentionRaw = (m['attentionMap'] as List?) ?? const [];
    final attentionMap = attentionRaw
        .map((e) => AttentionPoint(
              ((e as Map)['wn'] as num).toDouble(),
              (e['att'] as num).toDouble(),
            ))
        .toList();
    final keyPeaksRaw = (m['keyPeaks'] as List?) ?? const [];
    return IdentificationResult(
      polymer:            polymer,
      confidence:         ((m['confidence'] as num?) ?? 0).toDouble(),
      decisionWavenumber: ((m['decisionWavenumber'] as num?) ?? 0).toDouble(),
      attentionMap:       attentionMap,
      reasoning:          (m['reasoning'] as String?) ?? '',
      keyPeaks:           keyPeaksRaw.map((e) => e.toString()).toList(),
    );
  }

  static Map<String, dynamic> _resultToMap(IdentificationResult r) => {
        'polymer':             r.polymer.name,
        'confidence':          r.confidence,
        'decisionWavenumber':  r.decisionWavenumber,
        'reasoning':           r.reasoning,
        'keyPeaks':            r.keyPeaks,
        'attentionMap':        r.attentionMap
            .map((p) => {'wn': p.wavenumber, 'att': p.attention})
            .toList(),
      };

  static Future<bool> save(
    SpectrumSample sample,
    String institutionSlug,
    String datasetId,
    String createdBy,
  ) async {
    final payload = <String, dynamic>{
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
      if (sample.result != null) 'result': _resultToMap(sample.result!),
    };

    final ok = await FirebaseService.set(
      '${_samplesPath(institutionSlug)}/${sample.id}',
      payload,
    );
    if (!ok) return false;

    if (sample.spectralData.isNotEmpty) {
      await SpectralStorageService.save(
        institutionSlug: institutionSlug,
        datasetId:       datasetId,
        sampleId:        sample.id,
        spectralData:    sample.spectralData,
      );
    }
    return true;
  }

  static Future<bool> update(
    SpectrumSample sample,
    String institutionSlug,
  ) async {
    final patch = <String, dynamic>{
      'collectionSite': sample.collectionSite,
      'notes':          sample.notes,
      'isVerified':     sample.isVerified,
      'verifiedBy':     sample.verifiedBy,
      if (sample.result != null) 'result': _resultToMap(sample.result!),
    };
    return FirebaseService.update(
      '${_samplesPath(institutionSlug)}/${sample.id}',
      patch,
    );
  }

  static Future<bool> delete(
    String institutionSlug,
    String datasetId,
    String sampleId,
  ) async {
    await SpectralStorageService.delete(
      institutionSlug: institutionSlug,
      datasetId: datasetId,
      sampleId: sampleId,
    );
    return FirebaseService.delete(
      '${_samplesPath(institutionSlug)}/$sampleId',
    );
  }
}
