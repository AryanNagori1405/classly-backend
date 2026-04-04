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
        uid: 'STU001',
        regId: 'REG001',
        name: 'John Doe',
        email: 'john@college.edu',
        role: 'student',
        department: 'Computer Science',
        semester: '4',
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
        uid: response['user']['uid'] ?? 'STU001',
        regId: response['user']['regId'] ?? 'REG001',
        name: response['user']['name'] ?? 'User',
        email: response['user']['email'] ?? email,
        role: response['user']['role'] ?? 'student',
        department: response['user']['department'] ?? 'CS',
        semester: response['user']['semester'] ?? '1',
        profileImage: response['user']['profileImage'],
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

  /// Login using UID and Registration ID
  Future<bool> loginWithUID({
    required String uid,
    required String regId,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Call API for UID verification
      final response = await _apiService.loginWithUID(
        uid: uid,
        regId: regId,
        role: role,
      );

      // Create user from response
      _user = User(
        uid: response['user']['uid'] ?? uid,
        regId: response['user']['regId'] ?? regId,
        name: response['user']['name'] ?? 'Student',
        email: response['user']['email'] ?? '$uid@college.edu',
        role: response['user']['role'] ?? role,
        department: response['user']['department'] ?? 'Unknown',
        semester: response['user']['semester'] ?? '1',
        profileImage: response['user']['profileImage'] ?? 'https://via.placeholder.com/100',
        bio: response['user']['bio'] ?? '',
        enrolledCourses: List<String>.from(response['user']['enrolledCourses'] ?? []),
        joinedCommunities: List<String>.from(response['user']['joinedCommunities'] ?? []),
        createdAt: DateTime.parse(response['user']['createdAt'] ?? DateTime.now().toIso8601String()),
        isVerified: response['user']['isVerified'] ?? false,
      );

      _token = response['token'];

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      debugPrint('UID Login error: $e');
      return false;
    }
  }

  /// Signup with all required fields
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String role,
    String uid = '',
    String regId = '',
    String department = 'Unknown',
    String semester = '1',
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // If uid and regId are not provided, generate them
      final finalUid = uid.isEmpty ? 'STU${DateTime.now().millisecondsSinceEpoch}' : uid;
      final finalRegId = regId.isEmpty ? 'REG${DateTime.now().millisecondsSinceEpoch}' : regId;

      // Call API
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        role: role,
        uid: finalUid,
        regId: finalRegId,
        department: department,
        semester: semester,
      );

      // Create user from response
      _user = User(
        uid: response['user']['uid'] ?? finalUid,
        regId: response['user']['regId'] ?? finalRegId,
        name: response['user']['name'] ?? name,
        email: response['user']['email'] ?? email,
        role: response['user']['role'] ?? role,
        department: response['user']['department'] ?? department,
        semester: response['user']['semester'] ?? semester,
        profileImage: response['user']['profileImage'] ?? 'https://via.placeholder.com/100',
        bio: response['user']['bio'] ?? '',
        createdAt: DateTime.now(),
        isVerified: response['user']['isVerified'] ?? false,
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