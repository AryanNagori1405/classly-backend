import 'package:shared_preferences/shared_preferences.dart';

class FirstTimeUserManager {
  // Key for first time ever (never reset)
  static const String _firstTimeEverKey = 'app_first_launch';

  /// Check if this is the very first time app is opened (ever)
  static Future<bool> isFirstTimeLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool(_firstTimeEverKey) ?? true;
    
    // If first time, mark it as done immediately
    if (isFirstTime) {
      await prefs.setBool(_firstTimeEverKey, false);
    }
    
    return isFirstTime;
  }

  /// Reset (for testing only)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstTimeEverKey);
  }
}