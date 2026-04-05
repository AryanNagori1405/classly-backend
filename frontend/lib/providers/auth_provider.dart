import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  bool _isNetworkError = false;

  // Holds data between the two OTP steps
  int? _pendingUserId;
  String? _pendingUserRole;

  AuthProvider(this._apiService) {
    _loadUserFromStorage();
  }

  // ── getters ─────────────────────────────────────────────────────────────────
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;
  int? get pendingUserId => _pendingUserId;
  String? get pendingUserRole => _pendingUserRole;
  /// True when the last error was a network / timeout issue (useful for showing retry UI).
  bool get isNetworkError => _isNetworkError;

  // ── Persistence ──────────────────────────────────────────────────────────────
  Future<void> _loadUserFromStorage() async {
    try {
      final isAuth = await StorageService.isAuthenticated();
      if (isAuth) {
        final user = await StorageService.getUser();
        final token = await StorageService.getToken();
        if (user != null && token != null) {
          _user = user;
          _token = token;
        } else {
          await StorageService.clearAll();
        }
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }
    notifyListeners();
  }

  // ── Step 1: verify UID / RegId → receive OTP ────────────────────────────────
  Future<bool> verifyUID({String? uid, String? regId}) async {
    _isLoading = true;
    _error = null;
    _isNetworkError = false;
    notifyListeners();
    try {
      final response = await _apiService.verifyUID(uid: uid, regId: regId);
      _pendingUserId = response['user_id'] as int?;
      _pendingUserRole = response['role'] as String?;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final msg = e.toString();
      _error = msg;
      _isNetworkError = msg.contains('timed out') || msg.contains('Cannot reach');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Step 2: verify OTP → get JWT and log in ─────────────────────────────────
  Future<bool> verifyOTP({required String otp}) async {
    if (_pendingUserId == null) {
      _error = 'No pending OTP session. Please enter your UID again.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _error = null;
    _isNetworkError = false;
    notifyListeners();
    try {
      final response =
          await _apiService.verifyOTP(userId: _pendingUserId!, otp: otp);

      final userData = response['user'] as Map<String, dynamic>;
      _token = response['token'] as String?;
      _user = User(
        id: userData['id'] as int? ?? 0,
        uid: userData['uid'] as String? ?? '',
        regId: userData['reg_id'] as String? ?? '',
        name: userData['name'] as String? ?? '',
        email: userData['email'] as String? ?? '',
        role: userData['role'] as String? ?? 'student',
        department: userData['department'] as String? ?? '',
        semester: userData['semester'] as String? ?? '',
        profileImage: userData['profile_image'] as String? ??
            'https://via.placeholder.com/100',
        bio: userData['bio'] as String? ?? '',
        isVerified: userData['is_verified'] as bool? ?? false,
        createdAt: DateTime.now(),
      );

      // Persist
      await StorageService.saveUser(_user!);
      await StorageService.saveToken(_token!);
      await StorageService.setAuthenticated(true);

      _pendingUserId = null;
      _pendingUserRole = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final msg = e.toString();
      _error = msg;
      _isNetworkError = msg.contains('timed out') || msg.contains('Cannot reach');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      if (_token != null) {
        await _apiService.logout(token: _token!);
      }
    } catch (_) {}
    await StorageService.clearAll();
    _user = null;
    _token = null;
    _error = null;
    _isNetworkError = false;
    _pendingUserId = null;
    notifyListeners();
  }

  // ── Update profile ───────────────────────────────────────────────────────────
  Future<void> updateUser(User updatedUser) async {
    _user = updatedUser;
    await StorageService.saveUser(_user!);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    _isNetworkError = false;
    notifyListeners();
  }
}
