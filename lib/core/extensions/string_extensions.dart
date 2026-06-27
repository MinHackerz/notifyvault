/// Extension methods for String.
extension StringExtensions on String {
  /// Truncate to a maximum length with ellipsis.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}…';
  }

  /// Capitalize the first letter.
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word.
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalized).join(' ');
  }

  /// Normalize for search comparison (lowercase, trim, remove extra spaces).
  String get searchNormalized {
    return toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Extract the first N characters as initials (for avatar display).
  String initials([int count = 2]) {
    final words = trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words[0].substring(0, count.clamp(1, words[0].length)).toUpperCase();
    }
    return words
        .take(count)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();
  }

  /// Check if string contains any of the given keywords.
  bool containsAny(List<String> keywords) {
    final lower = toLowerCase();
    return keywords.any((k) => lower.contains(k.toLowerCase()));
  }
}
