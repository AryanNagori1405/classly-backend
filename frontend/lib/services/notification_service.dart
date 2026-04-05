import 'package:flutter/material.dart';

/// Lightweight notification service.
/// Uses SnackBars for local in-app notifications.
class NotificationService {
  NotificationService._();

  /// Shows a snackbar-style notification via the nearest [ScaffoldMessenger].
  static void showLocalNotification(
    BuildContext context, {
    required String title,
    required String body,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            if (body.isNotEmpty)
              Text(body, style: const TextStyle(fontSize: 13)),
          ],
        ),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Placeholder: schedule a notification when a video is about to expire.
  static Future<void> scheduleVideoExpiryNotification(
    String videoTitle,
    DateTime expiresAt,
  ) async {
    // TODO: integrate flutter_local_notifications for actual scheduling.
    debugPrint(
        '[NotificationService] Scheduled expiry notification for "$videoTitle" at $expiresAt');
  }

  /// Placeholder: cancel a previously scheduled notification.
  static Future<void> cancelNotification(String videoId) async {
    // TODO: integrate flutter_local_notifications for cancellation.
    debugPrint('[NotificationService] Cancelled notification for video $videoId');
  }
}
