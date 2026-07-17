import 'package:dio/dio.dart';
import '../helpers/api_routes.dart';
import '../services/api_client.dart';

class PengumumanService {
  static final Dio _dio = ApiClient.dio;

  // ===========================================================================
  // GET /api/pengumuman — Semua role yang login
  // ===========================================================================

  static Future<List<Map<String, dynamic>>> getPengumuman() async {
    try {
      final response = await _dio.get(ApiRoutes.pengumuman);
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
  // POST /api/admin/pengumuman — Admin only
  // ===========================================================================

  static Future<Map<String, dynamic>?> createPengumuman({
    required String judul,
    required String isi,
    required String tanggal,
    required String tanggalKadaluarsa,
  }) async {
    try {
      final response = await _dio.post(
        ApiRoutes.adminPengumuman,
        data: {
          'judul': judul,
          'isi': isi,
          'tanggal': tanggal,
          'tanggal_kadaluarsa': tanggalKadaluarsa,
        },
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
  // PUT /api/admin/pengumuman/:id — Admin only (partial update)
  // ===========================================================================

  static Future<bool> updatePengumuman(
    int id, {
    String? judul,
    String? isi,
    String? tanggal,
    String? tanggalKadaluarsa,
    bool? isAktif,
  }) async {
    try {
      final Map<String, dynamic> payload = {};
      if (judul != null) payload['judul'] = judul;
      if (isi != null) payload['isi'] = isi;
      if (tanggal != null) payload['tanggal'] = tanggal;
      if (tanggalKadaluarsa != null) {
        payload['tanggal_kadaluarsa'] = tanggalKadaluarsa;
      }
      if (isAktif != null) payload['is_aktif'] = isAktif;

      final response = await _dio.put(
        ApiRoutes.adminPengumumanDetail(id),
        data: payload,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ===========================================================================
  // DELETE /api/admin/pengumuman/:id — Soft-delete (is_aktif=false)
  // ===========================================================================

  static Future<bool> deletePengumuman(int id) async {
    try {
      final response = await _dio.delete(
        ApiRoutes.adminPengumumanDetail(id),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
