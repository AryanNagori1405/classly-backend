import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator → localhost
  // For physical devices use your machine's local IP, e.g. http://192.168.1.x:5000/api

  static const Duration _timeout = Duration(seconds: 30);

  // ── helpers ─────────────────────────────────────────────────────────────────

  Map<String, String> _headers({String? token}) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  String _mapError(Object e) {
    if (e is TimeoutException) {
      return 'Request timed out. Please check your connection and try again.';
    }
    if (e is SocketException) {
      return 'Cannot reach server. Make sure the backend is running and check your network.';
    }
    return e.toString();
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body,
      {String? token}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: _headers(token: token),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) return data;
      throw data['message'] ?? 'Request failed (${response.statusCode})';
    } on TimeoutException catch (e) {
      throw _mapError(e);
    } on SocketException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> _get(String path, {String? token}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$path'),
            headers: _headers(token: token),
          )
          .timeout(_timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) return data;
      throw data['message'] ?? 'Request failed (${response.statusCode})';
    } on TimeoutException catch (e) {
      throw _mapError(e);
    } on SocketException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> body,
      {String? token}) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$path'),
            headers: _headers(token: token),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) return data;
      throw data['message'] ?? 'Request failed (${response.statusCode})';
    } on TimeoutException catch (e) {
      throw _mapError(e);
    } on SocketException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> _delete(String path, {String? token}) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$path'),
            headers: _headers(token: token),
          )
          .timeout(_timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) return data;
      throw data['message'] ?? 'Request failed (${response.statusCode})';
    } on TimeoutException catch (e) {
      throw _mapError(e);
    } on SocketException catch (e) {
      throw _mapError(e);
    }
  }

  // ── AUTH ─────────────────────────────────────────────────────────────────────

  /// Step 1 – verify UID or Registration ID and receive an OTP
  Future<Map<String, dynamic>> verifyUID({String? uid, String? regId}) =>
      _post('/auth/verify-uid', {
        if (uid != null) 'uid': uid,
        if (regId != null) 'reg_id': regId,
      });

  /// Step 2 – verify the OTP and receive a JWT
  Future<Map<String, dynamic>> verifyOTP({
    required int userId,
    required String otp,
  }) =>
      _post('/auth/verify-otp', {'user_id': userId, 'otp': otp});

  /// Refresh token
  Future<Map<String, dynamic>> refreshToken({required String token}) =>
      _post('/auth/refresh-token', {'token': token});

  /// Logout (client-side token disposal; server acknowledges)
  Future<void> logout({required String token}) =>
      _post('/auth/logout', {}, token: token);

  /// Register a user (admin / seeding)
  Future<Map<String, dynamic>> register({
    required String name,
    String? uid,
    String? regId,
    String role = 'student',
    String? department,
    String? semester,
    String? email,
    String? phone,
  }) =>
      _post('/auth/register', {
        'name': name,
        if (uid != null) 'uid': uid,
        if (regId != null) 'reg_id': regId,
        'role': role,
        if (department != null) 'department': department,
        if (semester != null) 'semester': semester,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      });

  /// Get own profile
  Future<Map<String, dynamic>> getMyProfile({required String token}) =>
      _get('/auth/me', token: token);

  // ── USERS ────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getUserProfile({required String token}) =>
      _get('/users/profile', token: token);

  Future<Map<String, dynamic>> updateUserProfile({
    required String token,
    required Map<String, dynamic> data,
  }) =>
      _put('/users/profile', data, token: token);

  Future<Map<String, dynamic>> getTeachers({required String token}) =>
      _get('/users/teachers', token: token);

  Future<Map<String, dynamic>> getPublicProfile({
    required String token,
    required int userId,
  }) =>
      _get('/users/$userId', token: token);

  // ── VIDEOS / LECTURES ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getVideos({
    required String token,
    String? subject,
    String? search,
    String sortBy = 'newest',
  }) =>
      _get(
        '/videos?sortBy=$sortBy'
        '${subject != null ? '&subject=$subject' : ''}'
        '${search != null ? '&search=${Uri.encodeComponent(search)}' : ''}',
        token: token,
      );

  Future<Map<String, dynamic>> getVideo({
    required String token,
    required int videoId,
  }) =>
      _get('/videos/$videoId', token: token);

  Future<Map<String, dynamic>> uploadLecture({
    required String token,
    required Map<String, dynamic> data,
  }) =>
      _post('/videos', data, token: token);

  Future<Map<String, dynamic>> updateLecture({
    required String token,
    required int videoId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/videos/$videoId'),
            headers: _headers(token: token),
            body: jsonEncode(data),
          )
          .timeout(_timeout);
      final result = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) return result;
      throw result['message'] ?? 'Update failed';
    } on TimeoutException catch (e) {
      throw _mapError(e);
    } on SocketException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> downloadVideo({
    required String token,
    required int videoId,
  }) =>
      _post('/videos/$videoId/download', {}, token: token);

  Future<Map<String, dynamic>> upvoteVideo({
    required String token,
    required int videoId,
  }) =>
      _post('/videos/$videoId/upvote', {}, token: token);

  Future<Map<String, dynamic>> getExpiringVideos({required String token}) =>
      _get('/videos/expiring/soon', token: token);

  // ── TIMESTAMPS / DOUBTS ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTimestamps({
    required String token,
    required int videoId,
    String sortBy = 'newest',
  }) =>
      _get('/timestamps/video/$videoId/timestamps?sortBy=$sortBy', token: token);

  Future<Map<String, dynamic>> addTimestampDoubt({
    required String token,
    required int videoId,
    required String timestampValue,
    required String questionText,
  }) =>
      _post('/timestamps/video/$videoId/timestamps', {
        'timestamp_value': timestampValue,
        'question_text': questionText,
      }, token: token);

  Future<Map<String, dynamic>> resolveDoubt({
    required String token,
    required int timestampId,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/timestamps/$timestampId/resolve'),
            headers: _headers(token: token),
          )
          .timeout(_timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) return data;
      throw data['message'] ?? 'Failed to resolve';
    } on TimeoutException catch (e) {
      throw _mapError(e);
    } on SocketException catch (e) {
      throw _mapError(e);
    }
    }
  }

  Future<Map<String, dynamic>> addComment({
    required String token,
    required int timestampId,
    required String commentText,
    bool isAnonymous = false,
  }) =>
      _post('/timestamps/$timestampId/comments', {
        'comment_text': commentText,
        'is_anonymous': isAnonymous,
      }, token: token);

  Future<Map<String, dynamic>> getTimestampFAQ({
    required String token,
    required int videoId,
  }) =>
      _get('/timestamps/video/$videoId/faq', token: token);

  // ── NOTES ────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getVideoNotes({
    required String token,
    required int videoId,
  }) =>
      _get('/notes/video/$videoId/notes', token: token);

  Future<Map<String, dynamic>> uploadNote({
    required String token,
    required int videoId,
    required String noteTitle,
    required String fileUrl,
    String fileType = 'pdf',
  }) =>
      _post('/notes/video/$videoId/notes', {
        'note_title': noteTitle,
        'file_url': fileUrl,
        'file_type': fileType,
      }, token: token);

  // ── COMMUNITIES ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getCommunities({
    required String token,
    String? search,
    String? category,
  }) =>
      _get(
        '/communities'
        '${search != null ? '?search=${Uri.encodeComponent(search)}' : ''}'
        '${category != null ? (search != null ? '&' : '?') + 'category=$category' : ''}',
        token: token,
      );

  Future<Map<String, dynamic>> getCommunity({
    required String token,
    required int communityId,
  }) =>
      _get('/communities/$communityId', token: token);

  Future<Map<String, dynamic>> createCommunity({
    required String token,
    required String name,
    String? description,
    String? category,
    bool isPrivate = false,
  }) =>
      _post('/communities', {
        'name': name,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        'is_private': isPrivate,
      }, token: token);

  Future<Map<String, dynamic>> joinCommunity({
    required String token,
    required int communityId,
  }) =>
      _post('/communities/$communityId/join', {}, token: token);

  Future<Map<String, dynamic>> leaveCommunity({
    required String token,
    required int communityId,
  }) =>
      _post('/communities/$communityId/leave', {}, token: token);

  Future<Map<String, dynamic>> getCommunityPosts({
    required String token,
    required int communityId,
  }) =>
      _get('/communities/$communityId/posts', token: token);

  Future<Map<String, dynamic>> createPost({
    required String token,
    required int communityId,
    required String content,
  }) =>
      _post('/communities/$communityId/posts', {'content': content},
          token: token);

  Future<Map<String, dynamic>> likePost({
    required String token,
    required int communityId,
    required int postId,
  }) =>
      _post('/communities/$communityId/posts/$postId/like', {}, token: token);

  // ── ANONYMOUS FEEDBACK ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> sendFeedback({
    required String token,
    required int teacherId,
    required String message,
    String category = 'suggestion',
  }) =>
      _post('/feedback', {
        'teacher_id': teacherId,
        'message': message,
        'category': category,
      }, token: token);

  Future<Map<String, dynamic>> getReceivedFeedback({required String token}) =>
      _get('/feedback/received', token: token);

  Future<Map<String, dynamic>> getAllFeedback({required String token}) =>
      _get('/feedback/all', token: token);

  Future<Map<String, dynamic>> respondToFeedback({
    required String token,
    required int feedbackId,
    required String response,
  }) =>
      _put('/feedback/$feedbackId/response', {'response': response},
          token: token);

  Future<Map<String, dynamic>> getFeedbackAnalytics({required String token}) =>
      _get('/feedback/analytics', token: token);

  // ── BOOKMARKS ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getBookmarks({required String token}) =>
      _get('/bookmarks', token: token);

  Future<Map<String, dynamic>> addBookmark({
    required String token,
    required int videoId,
  }) =>
      _post('/bookmarks/$videoId', {}, token: token);

  Future<Map<String, dynamic>> removeBookmark({
    required String token,
    required int videoId,
  }) =>
      _delete('/bookmarks/$videoId', token: token);

  // ── ANALYTICS ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTeacherAnalytics({required String token}) =>
      _get('/analytics/teacher', token: token);

  // ── ADMIN ────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> adminGetUsers({
    required String token,
    String? role,
  }) =>
      _get('/admin/users${role != null ? '?role=$role' : ''}', token: token);

  Future<Map<String, dynamic>> adminUpdateUser({
    required String token,
    required int userId,
    required bool isActive,
    String? reason,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/admin/users/$userId'),
            headers: _headers(token: token),
            body: jsonEncode({'is_active': isActive, if (reason != null) 'reason': reason}),
          )
          .timeout(_timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) return data;
      throw data['message'] ?? 'Update failed';
    } on TimeoutException catch (e) {
      throw _mapError(e);
    } on SocketException catch (e) {
      throw _mapError(e);
    }
    }
  }

  Future<Map<String, dynamic>> adminGetAllFeedback({required String token}) =>
      _get('/feedback/all', token: token);

  // ── CONTRIBUTIONS ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getContributions({
    required String token,
    int? relatedVideoId,
    String? search,
  }) {
    String path = '/contributions';
    final params = <String>[];
    if (relatedVideoId != null) params.add('related_video_id=$relatedVideoId');
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (params.isNotEmpty) path += '?${params.join('&')}';
    return _get(path, token: token);
  }

  Future<Map<String, dynamic>> getMyContributions({required String token}) =>
      _get('/contributions/my', token: token);

  Future<Map<String, dynamic>> uploadContribution({
    required String token,
    required String title,
    required String fileUrl,
    String? description,
    String? fileType,
    int? relatedVideoId,
  }) =>
      _post('/contributions', {
        'title': title,
        'file_url': fileUrl,
        if (description != null) 'description': description,
        if (fileType != null) 'file_type': fileType,
        if (relatedVideoId != null) 'related_video_id': relatedVideoId,
      }, token: token);

  Future<Map<String, dynamic>> upvoteContribution({
    required String token,
    required int contributionId,
  }) =>
      _post('/contributions/$contributionId/upvote', {}, token: token);

  Future<Map<String, dynamic>> deleteContribution({
    required String token,
    required int contributionId,
  }) =>
      _delete('/contributions/$contributionId', token: token);

  // ── WATCH HISTORY ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getWatchHistory({required String token}) =>
      _get('/videos/watch-history/me', token: token);

  Future<Map<String, dynamic>> updateWatchProgress({
    required String token,
    required int videoId,
    required int lastWatchTime,
  }) =>
      _put('/videos/$videoId/watch-progress', {'last_watch_time': lastWatchTime},
          token: token);
}
