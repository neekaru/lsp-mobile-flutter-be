import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../helpers/api_routes.dart';
import 'api_client.dart';

class AsesiService {
  static Dio get _dio => ApiClient.dio;

  /// 1. Get Instansi Profile (GET /api/asesi/instansi)
  static Future<Map<String, dynamic>?> getInstansi() async {
    try {
      final response = await _dio.get(ApiRoutes.asesiInstansi);
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
        ApiRoutes.asesiInstansi,
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
      final response = await _dio.get(ApiRoutes.asesiSertifikat);
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
      final response = await _dio.get(ApiRoutes.asesiSertifikatDetail(id));
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
        ApiRoutes.asesiSertifikatUploadTtd(id),
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
      final response = await _dio.get(ApiRoutes.asesiSertifikatDownload(id));
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data']?['download_url'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error downloading sertifikat: $e');
      return null;
    }
  }

  /// 7. Daftar Sertifikasi (POST /api/sertifikasi/daftar) — **public**
  /// BE: without JWT auto-creates asesi (NIK + password 123456) and may return
  /// `access_token` / `refresh_token` / `user` in data for FE to persist session.
  static Future<Map<String, dynamic>?> daftarSertifikasi({
    required int skemaId,
    int? tukId,
    int? jadwalId,
    String? tanggalRencana,
    Map<String, dynamic>? dataPribadi,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'skema_id': skemaId,
      };
      if (jadwalId != null && jadwalId > 0) {
        payload['jadwal_id'] = jadwalId;
      }
      if (tukId != null && tukId > 0) {
        payload['tuk_id'] = tukId;
      }
      if (tanggalRencana != null) {
        payload['tanggal_rencana'] = tanggalRencana;
      }
      if (dataPribadi != null) {
        payload.addAll(dataPribadi);
      }
      final response = await _dio.post(
        ApiRoutes.sertifikasiDaftar,
        data: payload,
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) return data;
        if (data is Map) return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error registering certification: $e');
      return null;
    }
  }

  /// GET /api/asesi/profile — FR.APL.01 data pribadi
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await _dio.get(ApiRoutes.asesiProfile);
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting asesi profile: $e');
      return null;
    }
  }

  /// PUT /api/asesi/profile — update FR.APL.01 data pribadi
  static Future<bool> updateProfile(Map<String, dynamic> body) async {
    try {
      final response = await _dio.put(ApiRoutes.asesiProfile, data: body);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating asesi profile: $e');
      return false;
    }
  }

  /// Map FE jenis kelamin label → DB enum "1"/"2"
  static String mapJenisKelamin(String label) {
    final v = label.toLowerCase();
    if (v == '1' || v.contains('laki')) return '1';
    if (v == '2' || v.contains('perempuan')) return '2';
    return label;
  }

  /// Normalize date to YYYY-MM-DD (accepts dd/mm/yyyy, dd-mm-yyyy, yyyy-mm-dd)
  static String normalizeTglLahir(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return v;
    if (v.length == 10 && v[4] == '-') return v;
    final sep = v.contains('/') ? '/' : '-';
    final parts = v.split(sep);
    if (parts.length == 3 && parts[2].length == 4) {
      final d = parts[0].padLeft(2, '0');
      final m = parts[1].padLeft(2, '0');
      return '${parts[2]}-$m-$d';
    }
    return v;
  }

  /// 8. Status Pendaftaran (GET /api/sertifikasi/status)
  static Future<Map<String, dynamic>?> getSertifikasiStatus(int skemaId) async {
    try {
      final response = await _dio.get(
        ApiRoutes.sertifikasiStatus,
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
        ApiRoutes.praAsesmenSkemaSubmit(skemaId),
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
      final response = await _dio.get(ApiRoutes.sertifikasiPortofolio(sertifikasiId));
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
        ApiRoutes.sertifikasiPortofolioUpload(sertifikasiId),
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
