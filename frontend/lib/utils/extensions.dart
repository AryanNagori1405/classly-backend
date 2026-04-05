import 'date_formatter.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  bool get isValidEmail {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(trim());
  }

  bool get isValidUID {
    final trimmed = trim();
    if (trimmed.length < 4 || trimmed.length > 20) return false;
    final uidRegex = RegExp(r'^[a-zA-Z0-9\-_]+$');
    return uidRegex.hasMatch(trimmed);
  }
}

extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  String get formattedRelative => DateFormatter.formatRelativeTime(this);
}

extension ListExtension<T> on List<T> {
  T? get safeFirst => isEmpty ? null : first;

  T? get safeLast => isEmpty ? null : last;

  Map<K, List<T>> groupBy<K>(K Function(T) key) {
    final map = <K, List<T>>{};
    for (final item in this) {
      final k = key(item);
      map.putIfAbsent(k, () => []).add(item);
    }
    return map;
  }
}

extension IntExtension on int {
  /// Formats large numbers: 1000 → '1K', 1500000 → '1.5M'.
  String get formatCount {
    if (this >= 1000000) {
      final val = this / 1000000;
      return '${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(1)}M';
    }
    if (this >= 1000) {
      final val = this / 1000;
      return '${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(1)}K';
    }
    return toString();
  }
}

extension DoubleExtension on double {
  /// Returns a star string e.g. '★★★★☆' for rating 4.2.
  String get toStars {
    final full = clamp(0.0, 5.0).round();
    final empty = 5 - full;
    return '${'★' * full}${'☆' * empty}';
  }
}
