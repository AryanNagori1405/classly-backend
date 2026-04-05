import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Returns e.g. 'Jan 15, 2024'
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Returns e.g. 'Jan 15, 2024 at 2:30 PM'
  static String formatDateTime(DateTime dt) {
    return DateFormat("MMM d, yyyy 'at' h:mm a").format(dt);
  }

  /// Returns relative strings like '2 hours ago', 'yesterday', 'just now'.
  static String formatRelativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${m == 1 ? 'minute' : 'minutes'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    }

    final today = DateTime(now.year, now.month, now.day);
    final dtDay = DateTime(dt.year, dt.month, dt.day);
    final daysDiff = today.difference(dtDay).inDays;

    if (daysDiff == 1) return 'yesterday';
    if (daysDiff < 7) return '$daysDiff days ago';
    if (daysDiff < 30) {
      final weeks = (daysDiff / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    }
    if (daysDiff < 365) {
      final months = (daysDiff / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
    final years = (daysDiff / 365).floor();
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  }

  /// Returns 'MM:SS' for durations under an hour, 'HH:MM:SS' otherwise.
  static String formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Returns e.g. '2 days 3 hours left' or 'Expired'.
  static String formatCountdown(DateTime expiresAt) {
    final now = DateTime.now();
    if (expiresAt.isBefore(now)) return 'Expired';
    final diff = expiresAt.difference(now);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    if (days > 0) {
      return '$days ${days == 1 ? 'day' : 'days'} ${hours > 0 ? '$hours ${hours == 1 ? 'hour' : 'hours'} ' : ''}left';
    }
    if (hours > 0) {
      final minutes = diff.inMinutes % 60;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ${minutes > 0 ? '$minutes min ' : ''}left';
    }
    final minutes = diff.inMinutes;
    return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} left';
  }

  /// Returns whole days remaining (0 if expired).
  static int getDaysRemaining(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }
}
