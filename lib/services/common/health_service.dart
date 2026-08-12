import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../api_client.dart';
import '../../utils/api_routes.dart';

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
