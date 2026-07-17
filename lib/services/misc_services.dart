import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';
import '../helpers/api_routes.dart';
import '../models/auth_models.dart';
import '../models/berita_model.dart';

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

// ============================================================================
// Berita Service
// ============================================================================

class BeritaService {
  static Dio get _dio => ApiClient.dio;

  /// Fetch Paginated News List
  static Future<List<BeritaItem>> getBerita({int page = 1, int size = 10}) async {
    try {
      final response = await _dio.get(
        ApiRoutes.berita,
        queryParameters: {'page': page, 'size': size},
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => BeritaItem.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching berita: $e');
      return [];
    }
  }

  /// Fetch News Detail
  static Future<BeritaDetail?> getBeritaDetail(int id) async {
    try {
      final response = await _dio.get(ApiRoutes.beritaDetail(id));
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null) {
          return BeritaDetail.fromJson(data as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching berita detail: $e');
      return null;
    }
  }
}

// ============================================================================
// Health Check Service
// ============================================================================

class HealthService {
  static Dio get _dio => ApiClient.dio;

  /// Health check endpoint - verifies server is up (no auth required)
  static Future<bool> healthCheck() async {
    try {
      final response = await _dio.get(
        ApiRoutes.health,
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      final isHealthy = response.statusCode == 200 && response.data?['status'] == 'ok';
      if (kDebugMode) {
        debugPrint('🏥 Health check: ${isHealthy ? "✅ OK" : "❌ FAILED"} (${response.statusCode})');
      }
      return isHealthy;
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 Health check failed: $e');
      return false;
    }
  }

  /// Readiness check endpoint - verifies server + DB connection
  static Future<bool> readyCheck() async {
    try {
      final response = await _dio.get(
        ApiRoutes.ready,
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      final isReady = response.statusCode == 200 && response.data?['status'] == 'ready';
      if (kDebugMode) {
        debugPrint('🔌 Ready check: ${isReady ? "✅ READY" : "❌ NOT READY"} (${response.statusCode})');
      }
      return isReady;
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 Ready check failed: $e');
      return false;
    }
  }
}
