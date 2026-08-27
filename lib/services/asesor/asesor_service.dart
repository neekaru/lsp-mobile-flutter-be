import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../api_client.dart';
import '../../utils/api_routes.dart';
import '../../models/dashboard_models.dart';
import '../../models/asesor_statistik_models.dart';
import '../../models/asesor_asesi_models.dart';
import '../../models/jadwal_models.dart';

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
          trendTotalAsesor: data['trend_total_asesor'] ??
                            trends?['total_asesor'] ??
                            '+0,0%',
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
            .map(
              (item) =>
                  SebaranSkemaAsesorItem.fromJson(item as Map<String, dynamic>),
            )
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
        ApiRoutes.withLimit(
          ApiRoutes.dashboardAsesorDistribution,
          DataLimit.five.value,
        ),
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

        return list;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Fetch Top 5 Partners (Mitra)
  static Future<List<TopMitra>> getTopMitras() async {
    try {
      final response = await _dio.get(
        ApiRoutes.withLimit(
          ApiRoutes.dashboardPenyebaranMitra,
          DataLimit.five.value,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        int totalMitra = response.data['meta']?['total_mitra'] ?? 1;

        List<TopMitra> list = [];
        for (var item in data) {
          int count = item['jumlah'] ?? 0;
          double percent = totalMitra > 0 ? (count / totalMitra * 100) : 0.0;
          final List<dynamic> mitras = item['mitra'] ?? [];
          String partnerName = mitras.isNotEmpty
              ? mitras[0]
              : item['kota'] ?? '';
          list.add(
            TopMitra(
              name: partnerName,
              value: count,
              percentage: '${percent.toStringAsFixed(1).replaceAll('.', ',')}%',
            ),
          );
        }

        return list;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Fetch Skema Statistics
  static Future<SkemaStats> getSkemaStats() async {
    try {
      final response = await _dio.get(
        ApiRoutes.withLimit(
          ApiRoutes.dashboardSertifikatPerSkema,
          DataLimit.thousand.value,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        int totalSkema = response.data['meta']?['total_skema'] ?? 0;

        return SkemaStats(
          totalSkema: totalSkema,
          provinsi: 0,
          skemaAktif: totalSkema,
          skemaNonaktif: 0,
        );
      }
      return SkemaStats.fallback();
    } catch (e) {
      return SkemaStats.fallback();
    }
  }

  /// 6. Daftar Laporan Tugas Asesor
  static Future<List<Map<String, dynamic>>> getLaporanList() async {
    try {
      final response = await _dio.get(ApiRoutes.asesorLaporan);
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
      final response = await _dio.get(ApiRoutes.asesorLaporanDetail(id));
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
      final response = await _dio.get(ApiRoutes.asesorSkemaTuk);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 9. Upload Lampiran Laporan (POST /api/asesor/laporan/upload-lampiran)
  static Future<Map<String, dynamic>?> uploadLampiran(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(
        ApiRoutes.asesorLaporanUploadLampiran,
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

  /// 9b. Upload Dokumentasi Tiket (POST /api/asesor/tiket/upload-dokumentasi)
  static Future<Map<String, dynamic>?> uploadTiketDokumentasi(
    String filePath,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(
        ApiRoutes.asesorTiketUploadDokumentasi,
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
        ApiRoutes.asesorLaporan,
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
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
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
      final response = await _dio.get(ApiRoutes.asesorProfile);
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

      final response = await _dio.put(ApiRoutes.asesorProfile, data: payload);
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 13. Daftar Honor Asesor (Berdasarkan Periode)
  /// If periode is null or empty, returns all honor.
  static Future<Map<String, dynamic>?> getHonorList([String? periode]) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (periode != null && periode.isNotEmpty) {
        queryParams['periode'] = periode;
      }
      final response = await _dio.get(
        ApiRoutes.asesorHonor,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 14. Daftar Tiket Bantuan Asesor
  static Future<List<Map<String, dynamic>>> getTiketList() async {
    try {
      final response = await _dio.get(ApiRoutes.asesorTiket);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching tiket list: $e');
      return [];
    }
  }

  /// 15. Detail Tiket Bantuan Asesor
  static Future<Map<String, dynamic>?> getTiketDetail(int id) async {
    try {
      final response = await _dio.get(ApiRoutes.asesorTiketDetail(id));
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching tiket detail: $e');
      return null;
    }
  }

  /// 16. Buat Tiket Baru
  static Future<Map<String, dynamic>?> createTiket({
    required String judul,
    required String pesan,
    String? namaLengkap,
    String? dokumentasiUrl,
  }) async {
    try {
      final response = await _dio.post(
        ApiRoutes.asesorTiket,
        data: {
          'judul': judul,
          'pesan': pesan,
          'nama_lengkap': ?namaLengkap,
          'dokumentasi_url': dokumentasiUrl ?? '',
        },
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error creating tiket: $e');
      return null;
    }
  }

  /// 17. Kirim Tanggapan / Reply Chat Tiket Bantuan
  static Future<Map<String, dynamic>?> replyTiket(int id, String text) async {
    try {
      final response = await _dio.post(
        ApiRoutes.asesorTiketReply(id),
        data: {'text': text},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error replying to tiket: $e');
      return null;
    }
  }


  // ============================================================================
  // Admin Honor Asesor APIs (what-be-say.md specifications)
  // ============================================================================

  /// 1. Fetch Admin Honor Asesor Summary List
  static Future<Map<String, dynamic>?> getAdminHonorAsesorList({
    String status = 'semua',
    String? bulan,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'status': status.toLowerCase(),
        'limit': limit,
        'offset': offset,
      };
      if (bulan != null && bulan.isNotEmpty) {
        queryParams['bulan'] = bulan;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _dio.get(
        ApiRoutes.adminHonorAsesor,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching admin honor asesor list: $e');
      return null;
    }
  }

  /// 2. Fetch Detail Tugas Asesor by asesorId
  static Future<Map<String, dynamic>?> getAdminHonorAsesorTugas(
    int asesorId, {
    String status = 'semua',
  }) async {
    try {
      final response = await _dio.get(
        ApiRoutes.adminHonorAsesorTugas(asesorId),
        queryParameters: {'status': status.toLowerCase()},
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching admin honor asesor tugas: $e');
      return null;
    }
  }

  /// 3. Fetch Detail Honor Tugas by tugasId
  static Future<Map<String, dynamic>?> getAdminHonorTugasDetail(
    int tugasId,
  ) async {
    try {
      final response = await _dio.get(
        ApiRoutes.adminHonorAsesorTugasDetail(tugasId),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching admin honor tugas detail: $e');
      return null;
    }
  }

  /// 4. Update Status & Link Bukti Pembayaran
  static Future<Map<String, dynamic>?> updateAdminHonorTugasStatus(
    int tugasId, {
    required String status, // "1" for Selesai, "0" for Menunggu
    String? linkBuktiPembayaran,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'status': status,
      };
      if (linkBuktiPembayaran != null && linkBuktiPembayaran.isNotEmpty) {
        body['link_bukti_pembayaran'] = linkBuktiPembayaran;
      }

      final response = await _dio.post(
        ApiRoutes.adminHonorAsesorTugasDetail(tugasId),
        data: body,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error updating admin honor tugas status: $e');
      return null;
    }
  }

  /// 18. Fetch Statistik Bulanan SPT & Asesi 2026 for logged-in Asesor
  /// GET /api/asesor/statistik-bulanan?tahun=2026
  static Future<AsesorStatistikData?> getAsesorStatistikBulanan({
    int tahun = 2026,
  }) async {
    try {
      final response = await _dio.get(
        ApiRoutes.asesorStatistikBulanan,
        queryParameters: {'tahun': tahun},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && data is Map<String, dynamic>) {
          return AsesorStatistikData.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching asesor statistik bulanan: $e');
      return null;
    }
  }

  /// 19. Fetch Asesi List tested by logged-in Asesor
  /// GET /api/asesor/asesi
  static Future<AsesorAsesiListResponse?> getAsesiList({
    String? search,
    String? status,
    String? filterDate,
    int? jadwalId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
        'per_page': perPage,
      };
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }
      if (status != null && status.isNotEmpty && status != 'all') {
        params['status'] = status;
      }
      if (filterDate != null && filterDate.isNotEmpty && filterDate != 'all') {
        params['filter_date'] = filterDate;
      }
      if (jadwalId != null && jadwalId > 0) {
        params['jadwal_id'] = jadwalId;
      }

      final response = await _dio.get(
        ApiRoutes.asesorAsesi,
        queryParameters: params,
      );

      if (response.statusCode == 200 && response.data != null) {
        return AsesorAsesiListResponse.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching asesor asesi list: $e');
      return null;
    }
  }

  /// 20. Fetch Asesi Detail tested by logged-in Asesor
  /// GET /api/asesor/asesi/:id
  static Future<AsesorAsesiDetailData?> getAsesiDetail(int id) async {
    try {
      final response = await _dio.get(ApiRoutes.asesorAsesiDetail(id));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && data is Map<String, dynamic>) {
          return AsesorAsesiDetailData.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching asesor asesi detail: $e');
      return null;
    }
  }

  /// 21. Update Asesi Recommendation
  /// PUT /api/asesor/asesi/:id/rekomendasi
  static Future<Map<String, dynamic>?> updateAsesiRekomendasi({
    required int asesiId,
    required String rekomendasiAsesor, // "1" (Kompeten), "2" (Belum Kompeten), "0" (Belum Dinilai)
    String? isKompeten,
    String? pesan,
    String? catatan,
    String? komentarObservasi,
    String? hasilObservasi,
    String? pencapaian,
    String? unitBk,
    String? saranTindakLanjut,
    String? peliharaKompetensi,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'rekomendasi_asesor': rekomendasiAsesor,
      };
      if (isKompeten != null) payload['is_kompeten'] = isKompeten;
      if (pesan != null && pesan.isNotEmpty) payload['pesan'] = pesan;
      if (catatan != null && catatan.isNotEmpty) payload['catatan'] = catatan;
      if (komentarObservasi != null && komentarObservasi.isNotEmpty) {
        payload['komentar_observasi'] = komentarObservasi;
      }
      if (hasilObservasi != null && hasilObservasi.isNotEmpty) {
        payload['hasil_observasi'] = hasilObservasi;
      }
      if (pencapaian != null) payload['pencapaian'] = pencapaian;
      if (unitBk != null) payload['unit_bk'] = unitBk;
      if (saranTindakLanjut != null && saranTindakLanjut.isNotEmpty) {
        payload['saran_tindak_lanjut'] = saranTindakLanjut;
      }
      if (peliharaKompetensi != null) payload['pelihara_kompetensi'] = peliharaKompetensi;

      final response = await _dio.put(
        ApiRoutes.asesorAsesiUpdateRekomendasi(asesiId),
        data: payload,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error updating asesi rekomendasi: $e');
      return null;
    }
  }

  /// Update Collective / Batch Recommendation for Schedule
  /// POST /api/asesor/jadwal/:id/rekomendasi-kolektif
  static Future<bool> updateRekomendasiKolektif({
    required int jadwalId,
    required List<Map<String, dynamic>> peserta,
  }) async {
    try {
      final response = await _dio.post(
        '/api/asesor/jadwal/$jadwalId/rekomendasi-kolektif',
        data: {
          'jadwal_id': jadwalId,
          'peserta': peserta,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('🔴 Error updating collective rekomendasi: $e');
      return false;
    }
  }

  /// 22. Update FR-APL.02 / Pra-Asesmen & MAPA Recommendation
  /// PUT /api/asesor/asesi/:id/apl02
  static Future<Map<String, dynamic>?> updateAPL02({
    required int asesiId,
    required String praAsesmen, // "1" (Asesmen Dilanjutkan), "2" (Tidak dapat dilanjutkan), "0"
    required String catatanRekomendasi,
    required String tanggal,
    required bool isApproved,
    required String kandidat,
    int? idMapa,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'pra_asesmen': praAsesmen,
        'catatan_rekomendasi': catatanRekomendasi,
        'tanggal': tanggal,
        'is_approved': isApproved,
        'kandidat': kandidat,
      };
      if (idMapa != null && idMapa > 0) {
        payload['id_mapa'] = idMapa;
      }

      final response = await _dio.put(
        ApiRoutes.asesorAsesiUpdateAPL02(asesiId),
        data: payload,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error updating APL-02: $e');
      return null;
    }
  }

  /// Get FR.IA.01 Ceklis Observasi
  /// GET /api/asesor/asesi/:id/ia01
  static Future<Map<String, dynamic>?> getIA01(int asesiId) async {
    try {
      final response = await _dio.get(ApiRoutes.asesorAsesiIA01(asesiId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching IA-01: $e');
      return null;
    }
  }

  /// Save FR.IA.01 Ceklis Observasi
  /// POST /api/asesor/asesi/:id/ia01
  static Future<Map<String, dynamic>?> saveIA01({
    required int asesiId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        ApiRoutes.asesorAsesiIA01(asesiId),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error saving IA-01: $e');
      return null;
    }
  }

  /// Get FR.IA.02 Tugas Praktik Demonstrasi
  /// GET /api/asesor/asesi/:id/ia02
  static Future<Map<String, dynamic>?> getIA02(int asesiId) async {
    try {
      final response = await _dio.get(ApiRoutes.asesorAsesiIA02(asesiId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching IA-02: $e');
      return null;
    }
  }

  /// Save FR.IA.02 Tugas Praktik Demonstrasi
  /// POST /api/asesor/asesi/:id/ia02
  static Future<Map<String, dynamic>?> saveIA02({
    required int asesiId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        ApiRoutes.asesorAsesiIA02(asesiId),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error saving IA-02: $e');
      return null;
    }
  }

  /// Get FR.IA.03 Pertanyaan Lisan Pendukung Observasi
  /// GET /api/asesor/asesi/:id/ia03
  static Future<Map<String, dynamic>?> getIA03(int asesiId) async {
    try {
      final response = await _dio.get(ApiRoutes.asesorAsesiIA03(asesiId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching IA-03: $e');
      return null;
    }
  }

  /// Save FR.IA.03 Pertanyaan Lisan Pendukung Observasi
  /// POST /api/asesor/asesi/:id/ia03
  static Future<Map<String, dynamic>?> saveIA03({
    required int asesiId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        ApiRoutes.asesorAsesiIA03(asesiId),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error saving IA-03: $e');
      return null;
    }
  }

  /// Get FR.IA.04A DIT – Daftar Instruksi Terstruktur
  /// GET /api/asesor/asesi/:id/ia04a
  static Future<Map<String, dynamic>?> getIA04A(int asesiId) async {
    try {
      final response = await _dio.get(ApiRoutes.asesorAsesiIA04A(asesiId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching IA-04A: $e');
      return null;
    }
  }

  /// Save FR.IA.04A DIT – Umpan Balik Asesor
  /// POST /api/asesor/asesi/:id/ia04a
  static Future<Map<String, dynamic>?> saveIA04A({
    required int asesiId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        ApiRoutes.asesorAsesiIA04A(asesiId),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error saving IA-04A: $e');
      return null;
    }
  }

  /// Get FR.IA.04B Penilaian Proyek Singkat / Kegiatan Terstruktur
  /// GET /api/asesor/asesi/:id/ia04b
  static Future<Map<String, dynamic>?> getIA04B(int asesiId) async {
    try {
      final response = await _dio.get(ApiRoutes.asesorAsesiIA04B(asesiId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching IA-04B: $e');
      return null;
    }
  }

  /// Save FR.IA.04B Penilaian Proyek Singkat / Kegiatan Terstruktur
  /// POST /api/asesor/asesi/:id/ia04b
  static Future<Map<String, dynamic>?> saveIA04B({
    required int asesiId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        ApiRoutes.asesorAsesiIA04B(asesiId),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error saving IA-04B: $e');
      return null;
    }
  }

  /// Get FR.IA.05 Pertanyaan Tertulis
  /// GET /api/asesor/asesi/:id/ia05
  static Future<Map<String, dynamic>?> getIA05(int asesiId) async {
    try {
      final response = await _dio.get(ApiRoutes.asesorAsesiIA05(asesiId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching IA-05: $e');
      return null;
    }
  }

  /// Save FR.IA.05 Pertanyaan Tertulis
  /// POST /api/asesor/asesi/:id/ia05
  static Future<Map<String, dynamic>?> saveIA05({
    required int asesiId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        ApiRoutes.asesorAsesiIA05(asesiId),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error saving IA-05: $e');
      return null;
    }
  }

  /// Get FR.AK.05 Laporan Asesmen Jadwal
  /// GET /api/asesor/jadwal/:id/ak05
  static Future<Map<String, dynamic>?> getJadwalAK05(int jadwalId) async {
    try {
      final response = await _dio.get(ApiRoutes.asesorJadwalAK05(jadwalId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching Jadwal AK-05: $e');
      return null;
    }
  }

  /// Save FR.AK.05 Laporan Asesmen Jadwal
  /// POST /api/asesor/jadwal/:id/ak05
  static Future<Map<String, dynamic>?> saveJadwalAK05({
    required int jadwalId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        ApiRoutes.asesorJadwalAK05(jadwalId),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error saving Jadwal AK-05: $e');
      return null;
    }
  }

  /// Get FR.AK.06 Meninjau Proses Asesmen Jadwal
  /// GET /api/asesor/jadwal/:id/ak06
  static Future<Map<String, dynamic>?> getJadwalAK06(int jadwalId) async {
    try {
      final response = await _dio.get(ApiRoutes.asesorJadwalAK06(jadwalId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching Jadwal AK-06: $e');
      return null;
    }
  }

  /// Save FR.AK.06 Meninjau Proses Asesmen Jadwal
  /// POST /api/asesor/jadwal/:id/ak06
  static Future<Map<String, dynamic>?> saveJadwalAK06({
    required int jadwalId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        ApiRoutes.asesorJadwalAK06(jadwalId),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error saving Jadwal AK-06: $e');
      return null;
    }
  }

  /// Get list of Jadwal Asesor filtered by Tahun and Bulan (e.g. from Rincian Bulanan Statistik)
  /// GET /api/asesor/jadwal?tahun=2026&bulan=1
  static Future<List<JadwalItem>> getAsesorJadwalBulanan({
    required int tahun,
    required int bulan,
  }) async {
    try {
      final response = await _dio.get(
        ApiRoutes.asesorJadwal,
        queryParameters: {
          'tahun': tahun,
          'bulan': bulan,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data
            .map((item) => JadwalItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching asesor jadwal bulanan ($tahun-$bulan): $e');
      return [];
    }
  }

  /// POST /api/asesor/ai/chat
  static Future<String> sendAiChat(String message) async {
    try {
      final response = await _dio.post(
        ApiRoutes.asesorAiChat,
        data: {
          'message': message,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 90),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && data['message'] != null) {
          return data['message'].toString();
        }
      }
      return 'Mohon maaf, asisten AI sedang tidak dapat merespons saat ini.';
    } catch (e) {
      debugPrint('🔴 Error sending AI chat: $e');
      return 'Terjadi kendala koneksi ke server asisten AI. Silakan coba lagi.';
    }
  }
}
