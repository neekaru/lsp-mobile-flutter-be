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

  static Future<Map<String, dynamic>?> uploadBeritaFoto(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(
        ApiRoutes.adminBeritaUploadFoto,
        data: formData,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading berita foto: $e');
      return null;
    }
  }

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

  /// Admin: Create News (POST /api/admin/berita)
  static Future<Map<String, dynamic>?> createAdminBerita({
    required String judul,
    required String headline,
    required String isi,
    required int idKategori,
    String? foto,
    String showImage = '1',
  }) async {
    try {
      final Map<String, dynamic> body = {
        'judul': judul,
        'headline': headline,
        'isi': isi,
        'id_kategori': idKategori,
        'show_image': showImage,
      };
      if (foto != null && foto.isNotEmpty) {
        body['foto'] = foto;
      }

      final response = await _dio.post(
        ApiRoutes.adminBerita,
        data: body,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error creating admin berita: $e');
      return null;
    }
  }

  /// Admin: Edit/Update News (PUT /api/admin/berita/{id})
  static Future<Map<String, dynamic>?> updateAdminBerita(
    int id, {
    String? judul,
    String? headline,
    String? isi,
    int? idKategori,
    String? foto,
    String? showImage,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (judul != null) body['judul'] = judul;
      if (headline != null) body['headline'] = headline;
      if (isi != null) body['isi'] = isi;
      if (idKategori != null) body['id_kategori'] = idKategori;
      if (foto != null) body['foto'] = foto;
      if (showImage != null) body['show_image'] = showImage;

      final response = await _dio.put(
        ApiRoutes.adminBeritaDetail(id),
        data: body,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error updating admin berita: $e');
      return null;
    }
  }

  /// Admin: Delete News (DELETE /api/admin/berita/{id})
  static Future<bool> deleteAdminBerita(int id) async {
    try {
      final response = await _dio.delete(ApiRoutes.adminBeritaDetail(id));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('🔴 Error deleting admin berita: $e');
      return false;
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
