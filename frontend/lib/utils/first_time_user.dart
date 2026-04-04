import 'package:shared_preferences/shared_preferences.dart';

class FirstTimeUserManager {
  static const String _key = 'has_seen_welcome';

  /// Check if user has seen welcome screen
  static Future<bool> hasSeenWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// Mark welcome screen as seen
  static Future<void> markWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  /// Reset (for testing/logout)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}