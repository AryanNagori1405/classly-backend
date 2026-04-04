import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._apiService) {
    _loadUserFromPrefs();
  }

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;

  // Mock user data for testing
  Future<void> _loadUserFromPrefs() async {
    // In a real app, you would load from SharedPreferences
    // For now, we'll use mock data
    try {
      _user = User(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        role: 'student',
        profileImage: 'https://via.placeholder.com/100',
        bio: 'Passionate learner',
        coursesCount: 5,
        videosCount: 24,
        rating: 4.8,
        createdAt: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user data';
      debugPrint('Error loading user: $e');
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Call API
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      // Create user from response
      _user = User(
        id: response['user']['id'] ?? 1,
        name: response['user']['name'] ?? 'User',
        email: response['user']['email'] ?? email,
        role: response['user']['role'] ?? 'student',
        profileImage: response['user']['profile_image'],
        bio: response['user']['bio'],
        createdAt: DateTime.now(),
      );

      _token = response['token'];

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Call API
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      // Create user from response
      _user = User(
        id: response['user']['id'] ?? 1,
        name: response['user']['name'] ?? name,
        email: response['user']['email'] ?? email,
        role: response['user']['role'] ?? role,
        profileImage: response['user']['profile_image'],
        bio: response['user']['bio'],
        createdAt: DateTime.now(),
      );

      _token = response['token'];

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      debugPrint('Signup error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Clear local data
      _user = null;
      _token = null;
      _error = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to logout';
      debugPrint('Logout error: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}