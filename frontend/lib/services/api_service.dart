import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api'; // Change to your backend URL

  /// Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Login failed: ${response.body}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  /// Login with UID and Registration ID
  Future<Map<String, dynamic>> loginWithUID({
    required String uid,
    required String regId,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login-uid'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'uid': uid,
          'regId': regId,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'UID verification failed: ${response.body}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  /// Register with email and password
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String uid,
    required String regId,
    required String department,
    required String semester,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'uid': uid,
          'regId': regId,
          'department': department,
          'semester': semester,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw 'Registration failed: ${response.body}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  /// Logout
  Future<void> logout({required String token}) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      throw 'Logout failed: $e';
    }
  }
}