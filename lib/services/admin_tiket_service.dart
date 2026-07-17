import 'package:dio/dio.dart';
import '../helpers/api_routes.dart';
import '../services/api_client.dart';

class AdminTiketService {
  static final Dio _dio = ApiClient.dio;

  // ===========================================================================
  // GET /api/admin/tiket — Semua tiket masuk ke admin
  // ===========================================================================

  static Future<List<Map<String, dynamic>>> getTiketList() async {
    try {
      final response = await _dio.get(ApiRoutes.adminTiket);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ===========================================================================
  // GET /api/admin/tiket/:id — Detail + messages
  // ===========================================================================

  static Future<Map<String, dynamic>?> getTiketDetail(int id) async {
    try {
      final response = await _dio.get(ApiRoutes.adminTiketDetail(id));
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ===========================================================================
  // POST /api/admin/tiket/:id/reply — Body: { "text": "..." }
  // ===========================================================================

  static Future<Map<String, dynamic>?> replyTiket(int id, String text) async {
    try {
      final response = await _dio.post(
        ApiRoutes.adminTiketReply(id),
        data: {'text': text},
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ===========================================================================
  // PUT /api/admin/tiket/:id/status — Body: { "status": "Proses|Selesai|Batal" }
  // ===========================================================================

  static Future<bool> updateStatus(int id, String status) async {
    try {
      final response = await _dio.put(
        ApiRoutes.adminTiketStatus(id),
        data: {'status': status},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
