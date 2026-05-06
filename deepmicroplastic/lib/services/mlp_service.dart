import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/spectrum_model.dart';

class MlpService {
  static const String _baseUrl = 'http://localhost:8000';

  static Future<IdentificationResult?> identify(SpectrumSample sample) async {
    if (sample.spectralData.isEmpty) return null;

    final data = sample.asAbsorbance;
    final body = jsonEncode({
      'wavenumbers': data.map((p) => p.wavenumber).toList(),
      'intensities': data.map((p) => p.intensity).toList(),
    });

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/predict'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        debugPrint('MLP server error: ${response.statusCode} ${response.body}');
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseResult(json);
    } catch (e) {
      debugPrint('MLP inference error: $e');
      return null;
    }
  }

  static IdentificationResult _parseResult(Map<String, dynamic> json) {
    final polymerStr = json['polymer'] as String;
    final confidence = (json['confidence'] as num).toDouble();
    final polymer    = _mapPolymer(polymerStr);

    final attnRaw = json['attention'] as List<dynamic>? ?? [];
    final attentionMap = attnRaw
        .map((a) => AttentionPoint(
              (a['wavenumber'] as num).toDouble(),
              (a['attention'] as num).toDouble(),
            ))
        .toList();

    return IdentificationResult(
      polymer:           polymer,
      confidence:        confidence,
      decisionWavenumber: _decisionWavenumber(polymer),
      attentionMap:      attentionMap,
      reasoning:         _reasoning(polymer, confidence),
      keyPeaks:          _keyPeaks(polymer),
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
        'Confiança do modelo: $pct%.',
      PolymerType.pp =>
        'Bandas características de CH₃ em 2962 cm⁻¹, deformação CH₂ em '
        '1460 cm⁻¹ e bandas de esqueleto em 998 e 841 cm⁻¹ indicam '
        'polipropileno. Confiança: $pct%.',
      PolymerType.ps =>
        'Estiramentos C–H aromáticos acima de 3000 cm⁻¹ e bandas '
        'diagnósticas do anel em 757 e 698 cm⁻¹ caracterizam '
        'poliestireno. Confiança: $pct%.',
      PolymerType.nylon =>
        'Estiramento N–H em ~3300 cm⁻¹ e bandas de amida I (1640 cm⁻¹) '
        'e amida II (1540 cm⁻¹) confirmam poliamida (Nylon). '
        'Confiança: $pct%.',
      PolymerType.eva =>
        'Estiramento C=O de éster em 1735 cm⁻¹ e C–O em 1238 cm⁻¹ '
        'são marcadores diagnósticos de EVA (copolímero etileno-acetato '
        'de vinila). Confiança: $pct%.',
      PolymerType.cellulose =>
        'Banda larga O–H em ~3400 cm⁻¹ e estiramento C–O em 1060 cm⁻¹ '
        'sugerem material de origem celulósica, possivelmente fibra '
        'natural. Confiança: $pct%.',
      _ =>
        'O modelo não identificou um polímero com confiança suficiente '
        '($pct%). Revise a qualidade do espectro ou colete mais dados.',
    };
  }

  static List<String> _keyPeaks(PolymerType p) => switch (p) {
        PolymerType.pe => [
            '2919 cm⁻¹ — estiramento assimétrico CH₂',
            '2850 cm⁻¹ — estiramento simétrico CH₂',
            '1471 cm⁻¹ — deformação CH₂ (scissoring)',
            '720 cm⁻¹  — balanço CH₂ (rocking)',
          ],
        PolymerType.pp => [
            '2962 cm⁻¹ — estiramento assimétrico CH₃',
            '2920 cm⁻¹ — estiramento assimétrico CH₂',
            '1460 cm⁻¹ — deformação CH₂/CH₃',
            '1380 cm⁻¹ — deformação simétrica CH₃',
            '998 cm⁻¹  — balanço CH₃ (esqueleto isotático)',
            '841 cm⁻¹  — balanço CH₂',
          ],
        PolymerType.ps => [
            '3060 cm⁻¹ — estiramento C–H aromático',
            '1601 cm⁻¹ — estiramento C=C aromático',
            '1493 cm⁻¹ — estiramento C=C aromático',
            '757 cm⁻¹  — deformação C–H fora do plano (mono-substituído)',
            '698 cm⁻¹  — vibração do anel',
          ],
        PolymerType.nylon => [
            '3300 cm⁻¹ — estiramento N–H',
            '2932 cm⁻¹ — estiramento C–H',
            '1640 cm⁻¹ — amida I (C=O)',
            '1540 cm⁻¹ — amida II (N–H + C–N)',
            '1265 cm⁻¹ — amida III',
          ],
        PolymerType.eva => [
            '2919 cm⁻¹ — estiramento CH₂',
            '1735 cm⁻¹ — estiramento C=O (éster acetato)',
            '1238 cm⁻¹ — estiramento C–O (éster)',
            '1020 cm⁻¹ — estiramento C–O',
            '720 cm⁻¹  — balanço CH₂',
          ],
        PolymerType.cellulose => [
            '3400 cm⁻¹ — estiramento O–H (largo)',
            '2900 cm⁻¹ — estiramento C–H',
            '1640 cm⁻¹ — deformação O–H (água adsorvida)',
            '1060 cm⁻¹ — estiramento C–O–C (glicosídico)',
            '897 cm⁻¹  — deformação C–H (β-glicosídico)',
          ],
        _ => ['Bandas diagnósticas não disponíveis para este polímero.'],
      };
}
