import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/spectrum_model.dart';

/// Persiste e recupera dados espectrais via servidor MLP, em CSVs por dataset.
///
/// O servidor mantém `spectra_data/<datasetId>.csv` onde a primeira coluna é o
/// `sampleId` e as demais são intensidades indexadas pelos números de onda
/// (header do CSV).
class SpectralStorageService {
  static const String _baseUrl = 'http://localhost:8000';

  static Future<bool> save({
    required String datasetId,
    required String sampleId,
    required List<SpectralPoint> spectralData,
  }) async {
    if (spectralData.isEmpty) return false;
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/spectra/$datasetId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'sample_id':   sampleId,
              'wavenumbers': spectralData.map((p) => p.wavenumber).toList(),
              'intensities': spectralData.map((p) => p.intensity).toList(),
            }),
          )
          .timeout(const Duration(seconds: 30));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('SpectralStorage.save error: $e');
      return false;
    }
  }

  static Future<List<SpectralPoint>> load({
    required String datasetId,
    required String sampleId,
  }) async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/spectra/$datasetId/$sampleId'))
          .timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) return [];
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final wn   = (json['wavenumbers'] as List).cast<num>();
      final inten = (json['intensities'] as List).cast<num>();
      return List.generate(
        wn.length,
        (i) => SpectralPoint(wn[i].toDouble(), inten[i].toDouble()),
      );
    } catch (e) {
      debugPrint('SpectralStorage.load error: $e');
      return [];
    }
  }

  static Future<bool> delete({
    required String datasetId,
    required String sampleId,
  }) async {
    try {
      final res = await http
          .delete(Uri.parse('$_baseUrl/spectra/$datasetId/$sampleId'))
          .timeout(const Duration(seconds: 15));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
