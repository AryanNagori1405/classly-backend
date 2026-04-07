import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class StorageService {
  static const String _userKey = 'classly_user';
  static const String _tokenKey = 'classly_token';
  static const String _isAuthenticatedKey = 'classly_is_authenticated';

  /// Save user to local storage
  static Future<bool> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (e) {
      return false;
    }
  }

  /// Get user from local storage
  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson == null) return null;
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Save token to local storage
  static Future<bool> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_tokenKey, token);
    } catch (e) {
      return false;
    }
  }

  /// Get token from local storage
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Set authentication state
  static Future<bool> setAuthenticated(bool isAuthenticated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_isAuthenticatedKey, isAuthenticated);
    } catch (e) {
      return false;
    }
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isAuthenticatedKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Clear all data (logout)
  static Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
      await prefs.remove(_isAuthenticatedKey);
      return true;
    } catch (e) {
      return false;
    }
  }
}