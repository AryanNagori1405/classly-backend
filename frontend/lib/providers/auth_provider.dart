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

  AuthProvider(this._apiService) {
    _loadUserFromStorage();
  }

  // ── getters ─────────────────────────────────────────────────────────────────
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;
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

  // ── Register ─────────────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String regNo,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    _isNetworkError = false;
    notifyListeners();
    try {
      await _apiService.register(
        name: name,
        email: email,
        phone: phone,
        regNo: regNo,
        password: password,
        role: role,
      );
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

  // ── Login ─────────────────────────────────────────────────────────────────────
  Future<bool> login({
    required String regNo,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    _isNetworkError = false;
    notifyListeners();
    try {
      final response = await _apiService.login(regNo: regNo, password: password);

      final userData = response['user'] as Map<String, dynamic>;
      _token = response['token'] as String?;
      _user = User.fromJson(userData);

      // Persist
      await StorageService.saveUser(_user!);
      await StorageService.saveToken(_token!);
      await StorageService.setAuthenticated(true);

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
