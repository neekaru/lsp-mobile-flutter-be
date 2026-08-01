import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

class PermohonanService {
  static Dio get _dio => ApiClient.dio;

  /// Fetch List Permohonan from API (GET /api/permohonan?search=)
  static Future<List<Map<String, String>>> getPermohonanList({String search = ''}) async {
    try {
      final response = await _dio.get('/api/permohonan', queryParameters: {
        if (search.isNotEmpty) 'search': search,
      });

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((e) {
          final item = e as Map<String, dynamic>;
          return {
            'id': item['id']?.toString() ?? '',
            'tanggal': item['tanggal']?.toString() ?? '',
            'jam': item['jam']?.toString() ?? '',
            'nama': item['nama']?.toString() ?? '',
            'skema': item['skema']?.toString() ?? '',
            'status': item['status']?.toString() ?? '',
          };
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting permohonan list: $e');
      return [];
    }
  }

  /// Fetch Detail Permohonan from API (GET /api/permohonan/:id)
  static Future<Map<String, String>?> getPermohonanDetail(int id) async {
    try {
      final response = await _dio.get('/api/permohonan/$id');
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data['data'] ?? {};
        return {
          'id': data['id']?.toString() ?? '',
          'nama': data['nama']?.toString() ?? '',
          'skema': data['skema']?.toString() ?? '',
          'no_ujk': data['no_ujk']?.toString() ?? '',
          'status': data['status']?.toString() ?? '',
          'tanggal': data['tanggal']?.toString() ?? '',
          'jam': data['jam']?.toString() ?? '',
          'asessor': data['asessor']?.toString() ?? '',
          'jadwal_uji_kompetensi': data['jadwal_uji_kompetensi']?.toString() ?? '',
          'tempat_uji_kompetensi': data['tempat_uji_kompetensi']?.toString() ?? '',
          'lembaga_perusahaan': data['lembaga_perusahaan']?.toString() ?? '',
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error getting permohonan detail for id $id: $e');
      return null;
    }
  }

  /// Fetch Step 1 Persyaratan Asesi from API (GET /api/permohonan/:id/step1)
  static Future<List<Map<String, String>>> getStep1Data(int id) async {
    try {
      final response = await _dio.get('/api/permohonan/$id/step1');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((e) {
          final item = e as Map<String, dynamic>;
          return {
            'title': item['title']?.toString() ?? '',
            'file': item['file']?.toString() ?? '',
            'status': item['status']?.toString() ?? '',
            'jenis': item['jenis']?.toString() ?? '',
          };
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting step 1 data: $e');
      return [];
    }
  }

  /// Fetch Step 2 Data Peserta from API (GET /api/permohonan/:id/step2)
  static Future<Map<String, String>?> getStep2Data(int id) async {
    try {
      final response = await _dio.get('/api/permohonan/$id/step2');
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data['data'] ?? {};
        return {
          'nama_pemohon': data['nama_pemohon']?.toString() ?? '',
          'skema_sertifikasi': data['skema_sertifikasi']?.toString() ?? '',
          'rekomendasi': data['rekomendasi']?.toString() ?? '',
          'catatan_pemohon': data['catatan_pemohon']?.toString() ?? '',
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error getting step 2 data: $e');
      return null;
    }
  }

  /// Fetch Step 3 Jadwal from API (GET /api/permohonan/:id/step3)
  static Future<List<Map<String, String>>> getStep3Data(int id) async {
    try {
      final response = await _dio.get('/api/permohonan/$id/step3');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((e) {
          final item = e as Map<String, dynamic>;
          return {
            'nama_jadwal': item['nama_jadwal']?.toString() ?? '',
            'tgl_pra': item['tgl_pra']?.toString() ?? '',
            'tgl_asesmen': item['tgl_asesmen']?.toString() ?? '',
            'tuk': item['tuk']?.toString() ?? '',
          };
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting step 3 data: $e');
      return [];
    }
  }

  /// Fetch Step 4 Biodata Peserta from API (GET /api/permohonan/:id/step4)
  static Future<Map<String, String>?> getStep4Data(int id) async {
    try {
      final response = await _dio.get('/api/permohonan/$id/step4');
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data['data'] ?? {};
        return {
          'id_peserta': data['id_peserta']?.toString() ?? '',
          'nik': data['nik']?.toString() ?? '',
          'nama_pemohon': data['nama_pemohon']?.toString() ?? '',
          'skema_sertifikasi': data['skema_sertifikasi']?.toString() ?? '',
          'jenis_kelamin': data['jenis_kelamin']?.toString() ?? '',
          'tempat_lahir': data['tempat_lahir']?.toString() ?? '',
          'tanggal_lahir': data['tanggal_lahir']?.toString() ?? '',
          'alamat': data['alamat']?.toString() ?? '',
          'provinsi': data['provinsi']?.toString() ?? '',
          'kabupaten': data['kabupaten']?.toString() ?? '',
          'kecamatan': data['kecamatan']?.toString() ?? '',
          'kontak': data['kontak']?.toString() ?? '',
          'email': data['email']?.toString() ?? '',
          'pendidikan_terakhir': data['pendidikan_terakhir']?.toString() ?? '',
          'nama_sekolah': data['nama_sekolah']?.toString() ?? '',
          'jurusan': data['jurusan']?.toString() ?? '',
          'pekerjaan': data['pekerjaan']?.toString() ?? '',
          'perusahaan': data['perusahaan']?.toString() ?? '',
          'jabatan': data['jabatan']?.toString() ?? '',
          'alamat_perusahaan': data['alamat_perusahaan']?.toString() ?? '',
          'no_kontak_perusahaan': data['no_kontak_perusahaan']?.toString() ?? '',
          'tuk': data['tuk']?.toString() ?? '',
          'pra_asesmen_checked': data['pra_asesmen_checked']?.toString() ?? '',
          'perangkat_asesmen': data['perangkat_asesmen']?.toString() ?? '',
          // Asesor info
          'asesor_short_name': data['asesor_short_name']?.toString() ?? '',
          'asesor_email': data['asesor_email']?.toString() ?? '',
          'asesor_user_category': data['asesor_user_category']?.toString() ?? '',
          // Perangkat asesmen info
          'nama_perangkat_asesmen': data['nama_perangkat_asesmen']?.toString() ?? '',
          'kode_perangkat_asesmen': data['kode_perangkat_asesmen']?.toString() ?? '',
          // Raw IDs for PUT-back
          'id_provinsi': data['id_provinsi']?.toString() ?? '',
          'id_kabupaten': data['id_kabupaten']?.toString() ?? '',
          'id_kecamatan': data['id_kecamatan']?.toString() ?? '',
          'id_pendidikan': data['id_pendidikan']?.toString() ?? '',
          'id_pekerjaan': data['id_pekerjaan']?.toString() ?? '',
          'id_perangkat': data['id_perangkat']?.toString() ?? '',
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error getting step 4 data: $e');
      return null;
    }
  }

  /// Update Permohonan (All Steps) - PUT /api/permohonan/:id
  static Future<Map<String, dynamic>?> updatePermohonan(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        '/api/permohonan/$id',
        data: data,
      );

      if (response.statusCode == 200 && response.data != null) {
        return {
          'status': response.data['status'] ?? 'success',
          'message': response.data['message'] ?? 'Data berhasil diperbarui',
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error updating permohonan: $e');
      if (e is DioException) {
        return {
          'status': 'error',
          'message': e.response?.data['message'] ?? 'Gagal memperbarui data',
        };
      }
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan saat memperbarui data',
      };
    }
  }

  /// GET /api/permohonan/master/skema
  static Future<List<Map<String, dynamic>>> getMasterSkema() async {
    try {
      final response = await _dio.get('/api/permohonan/master/skema');
      if (response.statusCode == 200 && response.data != null) {
        final List data = response.data['data'] ?? [];
        return data.map((e) => {'id': e['id'], 'skema': e['skema']?.toString() ?? ''}).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getMasterSkema: $e');
      return [];
    }
  }

  /// GET /api/permohonan/master/asesor
  static Future<List<Map<String, dynamic>>> getMasterAsesor() async {
    try {
      final response = await _dio.get('/api/permohonan/master/asesor');
      if (response.statusCode == 200 && response.data != null) {
        final List data = response.data['data'] ?? [];
        return data.map((e) => {
          'id': e['id'],
          'short_name': e['short_name']?.toString() ?? '',
          'email': e['email']?.toString() ?? '',
          'user_category': e['user_category']?.toString() ?? '',
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getMasterAsesor: $e');
      return [];
    }
  }

  /// GET /api/permohonan/master/perangkat
  static Future<List<Map<String, dynamic>>> getMasterPerangkat() async {
    try {
      final response = await _dio.get('/api/permohonan/master/perangkat');
      if (response.statusCode == 200 && response.data != null) {
        final List data = response.data['data'] ?? [];
        return data.map((e) => {
          'id': e['id'],
          'nama_perangkat': e['nama_perangkat']?.toString() ?? '',
          'no_perangkat': e['no_perangkat']?.toString() ?? '',
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getMasterPerangkat: $e');
      return [];
    }
  }
}
