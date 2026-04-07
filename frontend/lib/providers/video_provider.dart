import 'package:flutter/material.dart';
import '../services/api_service.dart';

class VideoProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<dynamic> _videos = [];
  bool _isLoading = false;
  String? _error;

  VideoProvider(this._apiService);

  List<dynamic> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchVideos(
    String token, {
    String? subject,
    String? search,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _apiService.getVideos(
        token: token,
        subject: subject,
        search: search,
      );
      _videos = result['videos'] as List? ?? [];
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchVideoById(
    String id,
    String token,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final videoId = int.tryParse(id);
      if (videoId == null) throw 'Invalid video ID';
      final result = await _apiService.getVideo(token: token, videoId: videoId);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
