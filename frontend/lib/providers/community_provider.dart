import 'package:classly_frontend/services/api_service.dart';
import 'package:flutter/material.dart';

class CommunityProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<dynamic> _communities = [];
  bool _isLoading = false;
  String? _error;

  CommunityProvider(this._apiService);

  List<dynamic> get communities => _communities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCommunities(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _apiService.getCommunities(token: token);
      _communities = result['communities'] as List? ?? [];
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> joinCommunity(String id, String token) async {
    _error = null;
    try {
      final communityId = int.tryParse(id);
      if (communityId == null) throw 'Invalid community ID';
      await _apiService.joinCommunity(token: token, communityId: communityId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
