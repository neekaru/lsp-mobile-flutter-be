import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

class AsesiService {
  static Dio get _dio => ApiClient.dio;

  /// 1. Get Instansi Profile (GET /api/asesi/instansi)
  static Future<Map<String, dynamic>?> getInstansi() async {
    try {
      final response = await _dio.get('/api/asesi/instansi');
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting instansi: $e');
      return null;
    }
  }

  /// 2. Update Instansi Profile (PUT /api/asesi/instansi)
  static Future<bool> updateInstansi(String tipeInstansi, Map<String, String> dataInstansi) async {
    try {
      final response = await _dio.put(
        '/api/asesi/instansi',
        data: {
          'tipe_instansi': tipeInstansi,
          'data_instansi': dataInstansi,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating instansi: $e');
      return false;
    }
  }

  /// 3. List Sertifikat (GET /api/asesi/sertifikat)
  static Future<List<Map<String, dynamic>>> getSertifikatList() async {
    try {
      final response = await _dio.get('/api/asesi/sertifikat');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting sertifikat list: $e');
      return [];
    }
  }

  /// 4. Detail Sertifikat (GET /api/asesi/sertifikat/:id)
  static Future<Map<String, dynamic>?> getSertifikatDetail(int id) async {
    try {
      final response = await _dio.get('/api/asesi/sertifikat/$id');
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting sertifikat detail: $e');
      return null;
    }
  }

  /// 5. Upload Foto & TTD (POST /api/asesi/sertifikat/:id/upload-ttd)
  /// Supports single/multi-file uploads
  static Future<Map<String, dynamic>?> uploadTtd(int id, List<String> filePaths) async {
    try {
      final List<MultipartFile> files = [];
      for (final path in filePaths) {
        files.add(await MultipartFile.fromFile(path));
      }

      FormData formData;
      if (files.length == 1) {
        formData = FormData.fromMap({
          'file': files.first,
        });
      } else {
        formData = FormData.fromMap({
          'file': files,
        });
      }

      final response = await _dio.post(
        '/api/asesi/sertifikat/$id/upload-ttd',
        data: formData,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading TTD/foto: $e');
      return null;
    }
  }

  /// 6. Download Sertifikat PDF URL (GET /api/asesi/sertifikat/:id/download)
  static Future<String?> downloadSertifikat(int id) async {
    try {
      final response = await _dio.get('/api/asesi/sertifikat/$id/download');
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data']?['download_url'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error downloading sertifikat: $e');
      return null;
    }
  }

  /// 7. Daftar Sertifikasi (POST /api/sertifikasi/daftar)
  static Future<Map<String, dynamic>?> daftarSertifikasi({
    required int skemaId,
    required int tukId,
    String? tanggalRencana,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'skema_id': skemaId,
        'tuk_id': tukId,
      };
      if (tanggalRencana != null) {
        payload['tanggal_rencana'] = tanggalRencana;
      }
      final response = await _dio.post(
        '/api/sertifikasi/daftar',
        data: payload,
      );
      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Error registering certification: $e');
      return null;
    }
  }

  /// 8. Status Pendaftaran (GET /api/sertifikasi/status)
  static Future<Map<String, dynamic>?> getSertifikasiStatus(int skemaId) async {
    try {
      final response = await _dio.get(
        '/api/sertifikasi/status',
        queryParameters: {'skema_id': skemaId},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting certification status: $e');
      return null;
    }
  }

  /// 9. Submit Pra-Asesmen (POST /api/pra-asesmen/skema/:id/submit)
  static Future<bool> submitPraAsesmen(int skemaId, List<Map<String, dynamic>> evaluasi) async {
    try {
      final response = await _dio.post(
        '/api/pra-asesmen/skema/$skemaId/submit',
        data: {
          'evaluasi': evaluasi,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error submitting pra-asesmen: $e');
      return false;
    }
  }

  /// 10. List Portofolio (GET /api/sertifikasi/:id/portofolio)
  static Future<List<Map<String, dynamic>>> getPortofolioList(int sertifikasiId) async {
    try {
      final response = await _dio.get('/api/sertifikasi/$sertifikasiId/portofolio');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data['data']?['documents'] ?? [];
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting portofolio list: $e');
      return [];
    }
  }

  /// 11. Upload Portofolio File (POST /api/sertifikasi/:id/portofolio/upload)
  static Future<Map<String, dynamic>?> uploadPortofolio(int sertifikasiId, String key, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'key': key,
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(
        '/api/sertifikasi/$sertifikasiId/portofolio/upload',
        data: formData,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading portofolio: $e');
      return null;
    }
  }
}
