import 'package:flutter/material.dart';

enum PolymerType { pe, pp, pet, ps, nylon, eva, cellulose, unknown }
enum DataType { absorbance, transmittance }
enum MicroscopeMode { atr, transmission, reflection }

extension PolymerTypeLabel on PolymerType {
  String get label {
    switch (this) {
      case PolymerType.pe: return 'PE';
      case PolymerType.pp: return 'PP';
      case PolymerType.pet: return 'PET';
      case PolymerType.ps: return 'PS';
      case PolymerType.nylon: return 'Nylon';
      case PolymerType.eva: return 'EVA';
      case PolymerType.cellulose: return 'Celulose';
      case PolymerType.unknown: return 'Desconhecido';
    }
  }

  String get fullName {
    switch (this) {
      case PolymerType.pe: return 'Polietileno (PE)';
      case PolymerType.pp: return 'Polipropileno (PP)';
      case PolymerType.pet: return 'Politereftalato de Etileno (PET)';
      case PolymerType.ps: return 'Poliestireno (PS)';
      case PolymerType.nylon: return 'Nylon (PA)';
      case PolymerType.eva: return 'Etileno-Acetato de Vinila (EVA)';
      case PolymerType.cellulose: return 'Celulose / Material Natural';
      case PolymerType.unknown: return 'Polímero Desconhecido';
    }
  }

  Color get color {
    switch (this) {
      case PolymerType.pe: return const Color(0xFF00E5FF);
      case PolymerType.pp: return const Color(0xFFFF9800);
      case PolymerType.pet: return const Color(0xFFCE93D8);
      case PolymerType.ps: return const Color(0xFF69F0AE);
      case PolymerType.nylon: return const Color(0xFFFF80AB);
      case PolymerType.eva: return const Color(0xFFFFD54F);
      case PolymerType.cellulose: return const Color(0xFF81C784);
      case PolymerType.unknown: return const Color(0xFF9E9E9E);
    }
  }
}

extension MicroscopeModeLabel on MicroscopeMode {
  String get label {
    switch (this) {
      case MicroscopeMode.atr: return 'ATR';
      case MicroscopeMode.transmission: return 'Transmissão';
      case MicroscopeMode.reflection: return 'Reflexão';
    }
  }
}

/// A single (wavenumber cm⁻¹, intensity) pair in an FTIR spectrum.
class SpectralPoint {
  final double wavenumber;
  final double intensity;
  const SpectralPoint(this.wavenumber, this.intensity);
}

/// Gradient-saliency value at a given wavenumber, used to highlight
/// spectral regions that most influenced the model's prediction (0–1).
class AttentionPoint {
  final double wavenumber;
  final double attention;
  const AttentionPoint(this.wavenumber, this.attention);
}

/// Output produced by the MLP server for a single spectrum.
class IdentificationResult {
  final PolymerType polymer;
  final double confidence;
  final double decisionWavenumber;
  final List<AttentionPoint> attentionMap;
  final String reasoning;
  final List<String> keyPeaks;

  const IdentificationResult({
    required this.polymer,
    required this.confidence,
    required this.decisionWavenumber,
    required this.attentionMap,
    required this.reasoning,
    required this.keyPeaks,
  });
}

/// A single microplastic sample with its metadata and FTIR spectrum.
///
/// Instrument/calibration parameters are stored in the parent [SpectrumDataset].
/// [spectralData] is lazy-loaded — it is empty when fetched from Firebase and
/// must be populated via [SampleService.hydrateSpectrum] before use.
class SpectrumSample {
  final String id;
  String name;
  String collectionSite;
  DateTime collectionDate;
  DataType dataType; 
  List<SpectralPoint> spectralData;
  IdentificationResult? result;
  String notes;
  bool isVerified;
  String verifiedBy;

  SpectrumSample({
    required this.id,
    required this.name,
    required this.collectionSite,
    required this.collectionDate,
    required this.dataType,
    required this.spectralData,
    this.result,
    this.notes = '',
    this.isVerified = false,
    this.verifiedBy = '',
  });

  /// Converts to transmittance using an approximate Beer–Lambert inversion.
  List<SpectralPoint> get asTransmittance {
    if (dataType == DataType.transmittance) return spectralData;
    return spectralData
        .map((p) => SpectralPoint(p.wavenumber, (100.0 * (1 - p.intensity / 1.5)).clamp(0.0, 100.0)))
        .toList();
  }

  /// Converts to absorbance. The MLP server always expects absorbance input.
  List<SpectralPoint> get asAbsorbance {
    if (dataType == DataType.absorbance) return spectralData;
    return spectralData
        .map((p) => SpectralPoint(p.wavenumber, (1 - p.intensity / 100) * 1.5))
        .toList();
  }
}

/// A collection of [SpectrumSample]s captured under the same instrument setup.
class SpectrumDataset {
  final String id;
  String name;
  String description;
  String location;
  DateTime createdAt;
  List<SpectrumSample> samples;

  MicroscopeMode microscopeMode;
  String microscopeModel;
  double resolution;
  int numScans;
  String detectorType;
  String crystalType;
  DataType dataType;

  SpectrumDataset({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.createdAt,
    required this.samples,
    this.microscopeMode = MicroscopeMode.atr,
    this.microscopeModel = '',
    this.resolution = 4,
    this.numScans = 64,
    this.detectorType = 'MCT',
    this.crystalType = 'Diamante',
    this.dataType = DataType.absorbance,
  });

  int get analyzedCount => samples.where((s) => s.result != null).length;
  int get verifiedCount => samples.where((s) => s.isVerified).length;

  Map<PolymerType, int> get polymerDistribution {
    final map = <PolymerType, int>{};
    for (final s in samples) {
      if (s.result != null) {
        map[s.result!.polymer] = (map[s.result!.polymer] ?? 0) + 1;
      }
    }
    return map;
  }

  double get avgConfidence {
    final analyzed = samples.where((s) => s.result != null).toList();
    if (analyzed.isEmpty) return 0;
    return analyzed.map((s) => s.result!.confidence).reduce((a, b) => a + b) / analyzed.length;
  }
}
