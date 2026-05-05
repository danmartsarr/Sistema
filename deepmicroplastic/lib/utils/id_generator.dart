import 'dart:math';

/// Gera identificadores curtos, aleatórios e rastreáveis para amostras.
///
/// Formato: `<PREFIX>-<6 chars alfanuméricos>`  (ex.: `PF-X7K2N9`).
/// Espaço amostral: 36^6 ≈ 2,17 bilhões — colisão desprezível para
/// escalas típicas de pesquisa.
class SampleIdGenerator {
  static final _rand     = Random.secure();
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // sem 0/O/1/I

  /// Gera o nome visível da amostra a partir do nome do dataset.
  /// O prefixo são as iniciais (até 2) das primeiras palavras significativas.
  static String generateName(String datasetName) {
    final prefix = _prefixFromDataset(datasetName);
    return '$prefix-${_randomSuffix(6)}';
  }

  /// Gera o ID interno (Firebase). Único por amostra independentemente do dataset.
  static String generateInternalId() => 'smp-${_randomSuffix(12).toLowerCase()}';

  static String _prefixFromDataset(String name) {
    final words = name
        .split(RegExp(r'[\s—/,\-–]+'))
        .where((w) => w.length >= 3 && RegExp(r'^[A-Za-zÀ-ÿ]').hasMatch(w))
        .toList();
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    if (words.isNotEmpty) {
      return words[0].substring(0, min(3, words[0].length)).toUpperCase();
    }
    return 'SMP';
  }

  static String _randomSuffix(int length) => List.generate(
        length,
        (_) => _alphabet[_rand.nextInt(_alphabet.length)],
      ).join();
}
