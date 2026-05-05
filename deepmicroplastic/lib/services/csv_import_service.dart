import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/spectrum_model.dart';

/// Resultado de uma linha do CSV processada pelo servidor.
///
/// `originalCsvName` preserva o nome retornado pelo servidor (vem da coluna
/// "name"/"sample" do CSV) — usado apenas como rastreabilidade. O ID que
/// identifica a amostra no sistema é gerado aleatoriamente na importação,
/// não é derivado dele.
class CsvSampleResult {
  final int row;
  final String originalCsvName;
  final IdentificationResult identification;
  final List<SpectralPoint> spectralData;

  const CsvSampleResult({
    required this.row,
    required this.originalCsvName,
    required this.identification,
    required this.spectralData,
  });
}

class CsvImportService {
  static const String _baseUrl = 'http://localhost:8000';

  /// Envia o arquivo CSV para o servidor e retorna as predições por linha.
  ///
  /// O servidor remove automaticamente colunas categóricas — o CSV pode
  /// conter colunas como "name", "sample", "interpretation", etc. sem
  /// pré-processamento manual.
  static Future<List<CsvSampleResult>> predictFromCsv(
    String filePath,
    String fileName,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/predict_csv'),
    );

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      filePath,
      filename: fileName,
    ));

    final streamedResponse = await request.send().timeout(
      const Duration(minutes: 5),
    );
    final body = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode != 200) {
      final detail = _parseErrorDetail(body);
      throw Exception(detail);
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    final rawList = json['results'] as List<dynamic>;

    return rawList.map((r) => _parseResult(r as Map<String, dynamic>)).toList();
  }

  static CsvSampleResult _parseResult(Map<String, dynamic> r) {
    final polymer    = _mapPolymer(r['polymer'] as String);
    final confidence = (r['confidence'] as num).toDouble();

    final attnRaw = r['attention'] as List<dynamic>? ?? [];
    final attentionMap = attnRaw
        .map((a) => AttentionPoint(
              (a['wavenumber'] as num).toDouble(),
              (a['attention'] as num).toDouble(),
            ))
        .toList();

    final specRaw = r['spectral_data'] as List<dynamic>? ?? [];
    final spectralData = specRaw
        .map((p) => SpectralPoint(
              (p['wavenumber'] as num).toDouble(),
              (p['intensity'] as num).toDouble(),
            ))
        .toList();

    final identification = IdentificationResult(
      polymer:            polymer,
      confidence:         confidence,
      decisionWavenumber: _decisionWavenumber(polymer),
      attentionMap:       attentionMap,
      reasoning:          _reasoning(polymer, confidence),
      keyPeaks:           _keyPeaks(polymer),
    );

    return CsvSampleResult(
      row:             r['row'] as int,
      originalCsvName: r['sample_name'] as String,
      identification:  identification,
      spectralData:    spectralData,
    );
  }

  static PolymerType _mapPolymer(String name) => switch (name) {
        'PE'             => PolymerType.pe,
        'PP'             => PolymerType.pp,
        'PS'             => PolymerType.ps,
        'PA'             => PolymerType.nylon,
        'EVA'            => PolymerType.eva,
        'cellulose_like' => PolymerType.cellulose,
        _                => PolymerType.unknown,
      };

  static double _decisionWavenumber(PolymerType p) => switch (p) {
        PolymerType.pe        => 2919.0,
        PolymerType.pp        => 2962.0,
        PolymerType.ps        => 758.0,
        PolymerType.nylon     => 1640.0,
        PolymerType.eva       => 1735.0,
        PolymerType.cellulose => 1060.0,
        _                     => 1000.0,
      };

  static String _reasoning(PolymerType p, double conf) {
    final pct = (conf * 100).toStringAsFixed(1);
    return switch (p) {
      PolymerType.pe =>
        'Espectro dominado por estiramento C–H₂ em 2919 e 2850 cm⁻¹ e '
        'balanço CH₂ em 720 cm⁻¹, padrão diagnóstico de polietileno. '
        'Confiança: $pct%.',
      PolymerType.pp =>
        'Bandas de CH₃ em 2962 cm⁻¹ e bandas de esqueleto em 998 e '
        '841 cm⁻¹ indicam polipropileno. Confiança: $pct%.',
      PolymerType.ps =>
        'Estiramentos aromáticos C–H acima de 3000 cm⁻¹ e bandas '
        'diagnósticas em 757 e 698 cm⁻¹ caracterizam poliestireno. '
        'Confiança: $pct%.',
      PolymerType.nylon =>
        'Bandas de amida I (1640 cm⁻¹) e amida II (1540 cm⁻¹) confirmam '
        'poliamida (Nylon). Confiança: $pct%.',
      PolymerType.eva =>
        'Estiramento C=O de éster em 1735 cm⁻¹ marca EVA. '
        'Confiança: $pct%.',
      PolymerType.cellulose =>
        'Banda larga O–H (~3400 cm⁻¹) e C–O (1060 cm⁻¹) indicam '
        'material celulósico. Confiança: $pct%.',
      _ =>
        'Polímero não identificado com confiança suficiente ($pct%).',
    };
  }

  static List<String> _keyPeaks(PolymerType p) => switch (p) {
        PolymerType.pe => [
            '2919 cm⁻¹ — estiramento assimétrico CH₂',
            '2850 cm⁻¹ — estiramento simétrico CH₂',
            '1471 cm⁻¹ — deformação CH₂',
            '720 cm⁻¹  — balanço CH₂',
          ],
        PolymerType.pp => [
            '2962 cm⁻¹ — estiramento CH₃',
            '1460 cm⁻¹ — deformação CH₂/CH₃',
            '998 cm⁻¹  — esqueleto isotático',
            '841 cm⁻¹  — balanço CH₂',
          ],
        PolymerType.ps => [
            '3060 cm⁻¹ — C–H aromático',
            '1601 cm⁻¹ — C=C aromático',
            '757 cm⁻¹  — deformação C–H fora do plano',
            '698 cm⁻¹  — vibração do anel',
          ],
        PolymerType.nylon => [
            '3300 cm⁻¹ — estiramento N–H',
            '1640 cm⁻¹ — amida I (C=O)',
            '1540 cm⁻¹ — amida II (N–H + C–N)',
          ],
        PolymerType.eva => [
            '1735 cm⁻¹ — estiramento C=O éster',
            '1238 cm⁻¹ — estiramento C–O éster',
            '720 cm⁻¹  — balanço CH₂',
          ],
        PolymerType.cellulose => [
            '3400 cm⁻¹ — estiramento O–H',
            '1060 cm⁻¹ — C–O–C glicosídico',
            '897 cm⁻¹  — deformação β-glicosídica',
          ],
        _ => ['Bandas diagnósticas não disponíveis.'],
      };

  static String _parseErrorDetail(String body) {
    try {
      final j = jsonDecode(body) as Map<String, dynamic>;
      return j['detail'] as String? ?? body;
    } catch (_) {
      return body;
    }
  }
}
