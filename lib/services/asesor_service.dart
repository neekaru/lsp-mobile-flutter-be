import 'package:dio/dio.dart';

import 'api_client.dart';
import '../helpers/api_routes.dart';
import '../models/dashboard_models.dart';

// ============================================================================
// Asesor Service
// ============================================================================

class AsesorService {
  static Dio get _dio => ApiClient.dio;

  /// Fetch Asesor Statistics
  static Future<AsesorStats> getAsesorStats() async {
    try {
      final response = await _dio.get(ApiRoutes.dashboardAsesorStats);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        final trends = data['trends'];

        return AsesorStats(
          totalAsesor: data['total_asesor'] ?? 0,
          asesorAktif: data['asesor_aktif'] ?? 0,
          asesorInternal: data['asesor_internal'] ?? 0,
          asesorExternal: data['asesor_external'] ?? 0,
          totalTuk: data['total_tuk'] ?? 0,
          onlineAsesmen: data['online_asesmen'] ?? 0,
          offlineAsesmen: data['offline_asesmen'] ?? 0,
          wilayahTercover: data['wilayah_tercover'] ?? 0,
          trendTotalAsesor: trends['total_asesor'] ?? '+0,0%',
        );
      }

      return AsesorStats.fallback();
    } catch (e) {
      return AsesorStats.fallback();
    }
  }

  /// Fetch Sebaran Skema Asesor
  static Future<List<SebaranSkemaAsesorItem>> getSebaranSkemaAsesor() async {
    try {
      final response = await _dio.get(ApiRoutes.dashboardSebaranSkemaAsesor);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data
            .map((item) => SebaranSkemaAsesorItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Fetch Top 5 Provinces by Assessors
  static Future<List<TopProvinsi>> getTopProvinces() async {
    try {
      final response = await _dio.get(
        ApiRoutes.withLimit(ApiRoutes.dashboardAsesorDistribution, DataLimit.five.value),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        int totalAsesor = response.data['total_asesor'] ?? 1;

        List<TopProvinsi> list = [];
        for (var item in data) {
          int count = item['total_asesor'] ?? 0;
          double percent = totalAsesor > 0 ? (count / totalAsesor * 100) : 0.0;
          list.add(
            TopProvinsi(
              name: item['provinsi'] ?? '',
              value: count,
              percentage: '${percent.toStringAsFixed(1).replaceAll('.', ',')}%',
            ),
          );
        }

        if (list.isEmpty) return _getFallbackProvinces();
        return list;
      }
      return _getFallbackProvinces();
    } catch (e) {
      return _getFallbackProvinces();
    }
  }

  /// Fetch Top 5 Partners (Mitra)
  static Future<List<TopMitra>> getTopMitras() async {
    try {
      final response = await _dio.get(
        ApiRoutes.withLimit(ApiRoutes.dashboardPenyebaranMitra, DataLimit.five.value),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        int totalMitra = response.data['meta']?['total_mitra'] ?? 1;

        List<TopMitra> list = [];
        for (var item in data) {
          int count = item['jumlah'] ?? 0;
          double percent = totalMitra > 0 ? (count / totalMitra * 100) : 0.0;
          final List<dynamic> mitras = item['mitra'] ?? [];
          String partnerName = mitras.isNotEmpty ? mitras[0] : item['kota'] ?? '';
          list.add(
            TopMitra(
              name: partnerName,
              value: count,
              percentage: '${percent.toStringAsFixed(1).replaceAll('.', ',')}%',
            ),
          );
        }

        if (list.isEmpty) return _getFallbackMitras();
        return list;
      }
      return _getFallbackMitras();
    } catch (e) {
      return _getFallbackMitras();
    }
  }

  /// Fetch Skema Statistics
  static Future<SkemaStats> getSkemaStats() async {
    try {
      final response = await _dio.get(
        ApiRoutes.withLimit(ApiRoutes.dashboardSertifikatPerSkema, DataLimit.thousand.value),
      );

      if (response.statusCode == 200 && response.data != null) {
        int totalSkema = response.data['meta']?['total_skema'] ?? 58;

        return SkemaStats(
          totalSkema: totalSkema,
          provinsi: 34,
          skemaAktif: totalSkema,
          skemaNonaktif: 0,
        );
      }
      return SkemaStats.fallback();
    } catch (e) {
      return SkemaStats.fallback();
    }
  }

  // ============================================================================
  // Private Fallback Data
  // ============================================================================

  static List<TopProvinsi> _getFallbackProvinces() {
    return const [
      TopProvinsi(name: 'Sampit, Kalimantan Tengah', value: 214, percentage: '17,2%'),
      TopProvinsi(name: 'Yogyakarta', value: 100, percentage: '15,9%'),
      TopProvinsi(name: 'Sumatra Utara', value: 62, percentage: '12,3%'),
      TopProvinsi(name: 'Semarang', value: 200, percentage: '11,4%'),
      TopProvinsi(name: 'Balikpapan', value: 97, percentage: '8,7%'),
    ];
  }

  static List<TopMitra> _getFallbackMitras() {
    return const [
      TopMitra(name: 'LKP Gen Komputer Sampit', value: 214, percentage: '17,2%'),
      TopMitra(name: 'LPP Enter Pangkalanbun', value: 100, percentage: '15,9%'),
      TopMitra(name: 'TUK Tanascom Lempuing', value: 62, percentage: '12,3%'),
      TopMitra(name: 'SMKN 2 Jakarta', value: 200, percentage: '11,4%'),
      TopMitra(name: 'SMK Muhammadiyah Malang', value: 97, percentage: '8,7%'),
    ];
  }

  /// 6. Daftar Laporan Tugas Asesor
  static Future<List<Map<String, dynamic>>> getLaporanList() async {
    try {
      final response = await _dio.get('/api/asesor/laporan');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 7. Detail Laporan Tugas Asesor
  static Future<Map<String, dynamic>?> getLaporanDetail(int id) async {
    try {
      final response = await _dio.get('/api/asesor/laporan/$id');
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 8. Daftar Skema & TUK (Dropdown)
  static Future<List<Map<String, dynamic>>> getSkemaTukDropdown() async {
    try {
      final response = await _dio.get('/api/asesor/skema-tuk');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 9. Upload Lampiran Pendukung
  static Future<Map<String, dynamic>?> uploadLampiran(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(
        '/api/asesor/laporan/upload-lampiran',
        data: formData,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 10. Kirim Laporan Tugas Baru (Submit Wizard)
  static Future<Map<String, dynamic>?> submitLaporan({
    required int jadwalId,
    required String namaAsesor,
    required int skemaId,
    required String tanggalPelaksanaan,
    required String suratTugasUrl,
    required String linkDokumentasi,
    required String catatan,
    required List<Map<String, dynamic>> daftarPeserta,
    required List<String> lampiranPendukung,
  }) async {
    try {
      final response = await _dio.post(
        '/api/asesor/laporan',
        data: {
          'jadwal_id': jadwalId,
          'nama_asesor': namaAsesor,
          'skema_id': skemaId,
          'tanggal_pelaksanaan': tanggalPelaksanaan,
          'surat_tugas_url': suratTugasUrl,
          'link_dokumentasi': linkDokumentasi,
          'catatan': catatan,
          'daftar_peserta': daftarPeserta,
          'lampiran_pendukung': lampiranPendukung,
        },
      );
      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 11. Profil Asesor (Data Diri)
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await _dio.get('/api/asesor/profile');
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 12. Update Profil Asesor
  static Future<Map<String, dynamic>?> updateProfile({
    String? noTelepon,
    String? alamat,
    String? instansi,
    String? fotoProfilUrl,
  }) async {
    try {
      final Map<String, dynamic> payload = {};
      if (noTelepon != null) payload['no_telepon'] = noTelepon;
      if (alamat != null) payload['alamat'] = alamat;
      if (instansi != null) payload['instansi'] = instansi;
      if (fotoProfilUrl != null) payload['foto_profil_url'] = fotoProfilUrl;

      final response = await _dio.put(
        '/api/asesor/profile',
        data: payload,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 13. Daftar Honor Asesor (Berdasarkan Periode)
  static Future<Map<String, dynamic>?> getHonorList(String periode) async {
    try {
      final response = await _dio.get(
        '/api/asesor/honor',
        queryParameters: {'periode': periode},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
