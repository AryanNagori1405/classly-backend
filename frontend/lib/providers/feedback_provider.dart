import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FeedbackProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<dynamic> _feedbackList = [];
  bool _isLoading = false;
  String? _error;

  FeedbackProvider(this._apiService);

  List<dynamic> get feedbackList => _feedbackList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> submitFeedback(
    String content,
    String category,
    String teacherId,
    String token,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final id = int.tryParse(teacherId);
      if (id == null) throw 'Invalid teacher ID';
      await _apiService.sendFeedback(
        token: token,
        teacherId: id,
        message: content,
        category: category,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchReceivedFeedback(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _apiService.getReceivedFeedback(token: token);
      _feedbackList = result['feedback'] as List? ?? [];
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
