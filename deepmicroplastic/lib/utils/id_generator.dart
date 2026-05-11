import 'dart:math';

/// Short, random, traceable sample identifiers.
///
/// Format: `<PREFIX>-<6 alphanumeric chars>` (e.g. `PF-X7K2N9`).
/// Sample space: 36^6 ≈ 2.17 billion — collision probability negligible at research scale.
class SampleIdGenerator {
  static final _rand     = Random.secure();
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0/O/1/I

  /// Generates the visible sample name from the dataset name (up to 2 initials as prefix).
  static String generateName(String datasetName) {
    final prefix = _prefixFromDataset(datasetName);
    return '$prefix-${_randomSuffix(6)}';
  }

  /// Generates the internal Firebase ID, unique per sample regardless of dataset.
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
