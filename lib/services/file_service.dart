import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';
import '../helpers/api_routes.dart';

// ============================================================================
// File Service — Signed URL for protected files
// ============================================================================

class FileService {
  static Dio get _dio => ApiClient.dio;

  /// Request a signed URL for a protected file path (auth required).
  /// Returns the temporary URL and expiry time in seconds.
  static Future<Map<String, dynamic>?> getSignedUrl(String filePath) async {
    try {
      final response = await _dio.get(
        ApiRoutes.fileSignedUrl,
        queryParameters: {'path': filePath},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error getting signed URL: $e');
      return null;
    }
  }
}
