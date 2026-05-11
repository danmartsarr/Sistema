import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/spectrum_model.dart';

/// Persists and retrieves raw spectral data (wavenumbers + intensities) via
/// the MLP server's `/spectra` endpoints.
///
/// Each dataset's spectra are stored in a CSV file on the server, indexed by
/// `sample_id`. This keeps large float arrays out of Firebase.
class SpectralStorageService {
  static const String _baseUrl = 'http://localhost:8000';

  static Future<bool> save({
    required String institutionSlug,
    required String datasetId,
    required String sampleId,
    required List<SpectralPoint> spectralData,
  }) async {
    if (spectralData.isEmpty) return false;
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/spectra/$institutionSlug/$datasetId'),
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
    required String institutionSlug,
    required String datasetId,
    required String sampleId,
  }) async {
    try {
      final res = await http
          .get(Uri.parse(
              '$_baseUrl/spectra/$institutionSlug/$datasetId/$sampleId'))
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
    required String institutionSlug,
    required String datasetId,
    required String sampleId,
  }) async {
    try {
      final res = await http
          .delete(Uri.parse(
              '$_baseUrl/spectra/$institutionSlug/$datasetId/$sampleId'))
          .timeout(const Duration(seconds: 15));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
