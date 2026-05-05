import '../models/spectrum_model.dart';
import 'firebase_service.dart';
import 'spectral_storage_service.dart';

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

  /// Carrega o espectro persistido (CSV no servidor) e injeta na amostra.
  /// Retorna a mesma instância para encadeamento.
  static Future<SpectrumSample> hydrateSpectrum(
    SpectrumSample sample,
    String datasetId,
  ) async {
    if (sample.spectralData.isNotEmpty) return sample;
    final spectrum = await SpectralStorageService.load(
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
      spectralData: const [], // hidratado sob demanda via SpectralStorageService
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

  /// Persiste a amostra no Firebase. Se houver `spectralData`, ele é gravado
  /// no CSV do dataset via servidor MLP — assim os dados ficam fora do RTDB
  /// (que tem limite de tamanho de nó) e ficam exportáveis para retreino.
  static Future<bool> save(
      SpectrumSample sample, String datasetId, String createdBy) async {
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

    final ok = await FirebaseService.set('samples/${sample.id}', payload);
    if (!ok) return false;

    if (sample.spectralData.isNotEmpty) {
      await SpectralStorageService.save(
        datasetId:    datasetId,
        sampleId:     sample.id,
        spectralData: sample.spectralData,
      );
    }
    return true;
  }

  static Future<bool> update(SpectrumSample sample) async {
    final patch = <String, dynamic>{
      'collectionSite': sample.collectionSite,
      'notes':          sample.notes,
      'isVerified':     sample.isVerified,
      'verifiedBy':     sample.verifiedBy,
      if (sample.result != null) 'result': _resultToMap(sample.result!),
    };
    return FirebaseService.update('samples/${sample.id}', patch);
  }

  static Future<bool> delete(String sampleId, {String? datasetId}) async {
    if (datasetId != null) {
      await SpectralStorageService.delete(
        datasetId: datasetId,
        sampleId: sampleId,
      );
    }
    return FirebaseService.delete('samples/$sampleId');
  }
}
