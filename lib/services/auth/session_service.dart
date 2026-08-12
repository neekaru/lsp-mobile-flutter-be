import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../api_client.dart';
import '../../utils/api_routes.dart';
import '../../models/auth_models.dart';

// ============================================================================
// Auth & Session Service
// ============================================================================

class AuthSessionService {
  static Dio get _dio => ApiClient.dio;

  /// Fetch active login sessions
  static Future<List<LoginSession>> getActiveSessions() async {
    try {
      final response = await _dio.get(ApiRoutes.sessions);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => LoginSession.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching active sessions: $e');
      return [];
    }
  }

  /// Delete a login session by session ID
  static Future<bool> deleteSession(int id) async {
    try {
      final response = await _dio.delete(
        ApiRoutes.sessions,
        data: {'id': id},
      );
      if (response.statusCode == 200) {
        if (response.data != null && response.data is Map) {
          final data = response.data as Map;
          return data['status'] == 'success' ||
              data['data'] == true ||
              data['success'] == true;
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('🔴 Error deleting session: $e');
      return false;
    }
  }
}
