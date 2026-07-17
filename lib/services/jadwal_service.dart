import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'auth_repository.dart';
import '../helpers/api_routes.dart';
import '../models/jadwal_models.dart';
import '../models/dashboard_models.dart';

// ============================================================================
// Jadwal Service
// ============================================================================

class JadwalService {
  static Dio get _dio => ApiClient.dio;

  /// Fetch Jadwal Asesmen Baru
  static Future<List<JadwalBaru>> getJadwalBaru() async {
    try {
      final response = await _dio.get(
        ApiRoutes.withLimit(ApiRoutes.jadwalBaru, DataLimit.three.value),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data
            .map((item) => JadwalBaru.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      if (kDebugMode) return _getFallbackJadwalBaru();
      return [];
    } catch (e) {
      if (kDebugMode) return _getFallbackJadwalBaru();
      debugPrint('Error fetching jadwal baru: $e');
      return [];
    }
  }

  /// Fetch Jadwal Asesmen Mendekati / Overdue
  static Future<List<JadwalOverdue>> getJadwalOutOfDate() async {
    try {
      final response = await _dio.get(
        ApiRoutes.withLimit(ApiRoutes.jadwalOutOfDate, DataLimit.three.value),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data
            .map((item) => JadwalOverdue.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      if (kDebugMode) return _getFallbackJadwal();
      return [];
    } catch (e) {
      if (kDebugMode) return _getFallbackJadwal();
      debugPrint('Error fetching jadwal out of date: $e');
      return [];
    }
  }

  /// Fetch Jadwal List with filters (Used for JadwalScreen tabs)
  // Cache for running jadwal — avoids redundant network calls
  static List<JadwalItem>? _runningJadwalCache;
  static DateTime? _runningJadwalCacheTime;

  static Future<List<JadwalItem>> getJadwalList({
    int limit = 20,
    int offset = 0,
    String? statusJadwal,
    int? idTuk,
    String? idLsp,
    String? sortBy,
    String? sortOrder,
    String? customRoutePath,
    bool useCache = false,
  }) async {
    // Return cached running jadwal if fresh (< 2 minutes old)
    if (useCache && statusJadwal == '3' && _runningJadwalCache != null &&
        _runningJadwalCacheTime != null &&
        DateTime.now().difference(_runningJadwalCacheTime!).inMinutes < 2) {
      return _runningJadwalCache!;
    }

    try {
      String routePath = customRoutePath ?? ApiRoutes.jadwalOutOfDate;
      if (customRoutePath == null && statusJadwal != null) {
        if (statusJadwal == '3') {
          routePath = ApiRoutes.jadwalActive;
        } else if (statusJadwal.contains('1') || statusJadwal.contains('4')) {
          routePath = ApiRoutes.jadwalCompleted;
        }
      }

      final url = ApiRoutes.withJadwalFilters(
        routePath,
        limit: limit,
        offset: offset,
        statusJadwal: statusJadwal,
        idTuk: idTuk,
        idLsp: idLsp,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        final result = List<JadwalItem>.generate(
          data.length,
          (i) => JadwalItem.fromJson(data[i] as Map<String, dynamic>),
        );
        // Cache running schedules
        if (statusJadwal == '3') {
          _runningJadwalCache = result;
          _runningJadwalCacheTime = DateTime.now();
        }
        return result;
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching jadwal list: $e');
      return [];
    }
  }

  /// Update Status Jadwal
  static Future<Map<String, dynamic>> updateJadwalStatus({
    required int jadwalId,
    required String rule,
    String? catatan,
  }) async {
    try {
      final response = await _dio.post(
        ApiRoutes.jadwalUpdateStatusApply,
        data: {
          'jadwal_ids': [jadwalId],
          'rules': [rule],
          if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return {
          'success': true,
          'message': 'Status berhasil diperbarui',
          'data': response.data,
        };
      }
      return {'success': false, 'message': 'Gagal memperbarui status'};
    } catch (e) {
      debugPrint('🔴 Error updating jadwal status: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  /// Fetch list of Asesi for a specific schedule
  static Future<AsesiListResponse> getAsesiList(int jadwalId) async {
    try {
      final isAsesor = AuthRepository.currentUserInstance?.role == 'asesor';
      final path = isAsesor ? ApiRoutes.asesorJadwalPeserta(jadwalId) : ApiRoutes.jadwalAsesi(jadwalId);
      final response = await _dio.get(path);

      if (response.statusCode == 200 && response.data != null) {
        return AsesiListResponse.fromJson(response.data);
      }

      return AsesiListResponse(
        data: [],
        meta: AsesiMeta(
          jadwalId: jadwalId,
          totalAsesi: 0,
          jumlahKompeten: 0,
          jumlahBelumKompeten: 0,
          jumlahBelumDinilai: 0,
        ),
      );
    } catch (e) {
      debugPrint('🔴 Error fetching asesi list: $e');
      return AsesiListResponse(
        data: [],
        meta: AsesiMeta(
          jadwalId: jadwalId,
          totalAsesi: 0,
          jumlahKompeten: 0,
          jumlahBelumKompeten: 0,
          jumlahBelumDinilai: 0,
        ),
      );
    }
  }

  /// Fetch Participant Detail for a specific schedule and participant ID
  static Future<ParticipantDetailResponse?> getParticipantDetail(int jadwalId, int pesertaId) async {
    // Intercept dummy / mock calls
    if (jadwalId == 101 || jadwalId == 102 || jadwalId == 103 || jadwalId == 11152 || pesertaId == 101 || pesertaId == 102 || pesertaId == 103) {
      final name = pesertaId == 101 ? 'Andi Pratama' : (pesertaId == 102 ? 'Budi Santoso' : 'Citra Lestari');
      final rec = pesertaId == 101 ? 'K' : (pesertaId == 102 ? 'BK' : null);
      
      String tugasStatus = 'Belum Dinilai';
      if (rec == 'K') tugasStatus = 'Kompeten';
      if (rec == 'BK') tugasStatus = 'Belum Kompeten';

      return ParticipantDetailResponse(
        status: 'success',
        message: 'Participant detail retrieved successfully',
        data: ParticipantDetailData(
          pesertaId: pesertaId,
          noPeserta: 'PES-2026-0724-${pesertaId.toString().padLeft(3, '0')}',
          namaLengkap: name,
          nik: '6253748567382',
          tempatLahir: 'Yogyakarta',
          tanggalLahir: '1998-05-10',
          skemaSertifikat: 'UI/UX Design',
          institusi: 'LPP Jigja',
          email: '${name.toLowerCase().replaceAll(' ', '')}@gmail.com',
          noTelepon: '085678736521',
          statusKelengkapan: const StatusKelengkapan(
            portofolio: 'Lengkap',
            dokumenPendukung: 'Lengkap',
            persyaratan: 'Lengkap',
          ),
          statusAssessment: StatusAssessment(
            kehadiran: 'Hadir',
            tugasAsesmen: tugasStatus,
            laporan: 'Belum Dibuat',
            rekaman: 'Belum Diunggah',
          ),
        ),
      );
    }

    try {
      final response = await _dio.get(ApiRoutes.asesorJadwalPesertaDetail(jadwalId, pesertaId));
      if (response.statusCode == 200 && response.data != null) {
        return ParticipantDetailResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching participant detail: $e');
      return null;
    }
  }

  /// Fetch Assessor Detail for a specific schedule
  static Future<JadwalAsesorDetailResponse?> getJadwalAsesorDetail(int jadwalId) async {
    // Intercept dummy IDs for PenugasanScreen flow
    if (jadwalId == 101 || jadwalId == 102 || jadwalId == 103) {
      final is101 = jadwalId == 101;
      final is102 = jadwalId == 102;
      return JadwalAsesorDetailResponse(
        totalAsesor: 1,
        data: JadwalAsesorDetailData(
          id: jadwalId,
          jadwal: is101 ? 'UI/UX Design' : 'Digital Marketing',
          tanggal: '2026-07-20',
          tanggalAkhir: '2026-07-20',
          statusJadwal: is101 ? '0' : (is102 ? '1' : '2'), // 0: waiting, 1: completed, 2: canceled
          statusLabel: is101 ? 'Waiting' : (is102 ? 'Completed' : 'Canceled'),
          idTuk: 1,
          tuk: is101 ? 'LPP Cahaya Borneo' : 'LPP Jogja',
          alamatTuk: is101 ? 'Kalimantan Tengah' : 'Yogyakarta',
          jenisTuk: 'Sewaktu',
          asesor: [
            const AsesorDetailItem(
              idAsesor: 1,
              namaAsesor: 'Eko Setiabudi',
              noReg: 'MET.000.001928 2023',
              email: 'eko.setiabudi@lsp.com',
              hp: '08123456789',
              jenisAsesmen: 'Mandiri',
              statusSpt: 'Disetujui',
              isComplete: '1',
              masaBerlaku: '2028-12-31',
              kabupatenKota: 'Yogyakarta',
              provinsiId: '34',
              kabupatenId: '3471',
              totalAsesmen: 15,
            )
          ],
        ),
      );
    }

    try {
      final isAsesor = AuthRepository.currentUserInstance?.role == 'asesor';
      final path = isAsesor ? ApiRoutes.asesorJadwalDetail(jadwalId) : ApiRoutes.jadwalAsesorDetail(jadwalId);
      final response = await _dio.get(path);

      if (response.statusCode == 200 && response.data != null) {
        return JadwalAsesorDetailResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching jadwal asesor detail: $e');
      return null;
    }
  }

  /// Fetch Surat Tugas PDF URL for Asesor
  static Future<String?> getSuratTugas(int jadwalId) async {
    try {
      final response = await _dio.get(ApiRoutes.asesorJadwalSuratTugas(jadwalId));
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['status'] == 'success') {
          return response.data['data']?['file_url'] as String?;
        }
      }
      return null;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Surat tugas belum tersedia';
      throw Exception(message);
    } catch (e) {
      throw Exception('Gagal memuat Surat Tugas');
    }
  }

  /// Fetch Notification Count
  static Future<int> getNotificationCount() async {
    try {
      final response = await _dio.get(ApiRoutes.jadwalNotificationsCount);

      if (response.statusCode == 200 && response.data != null) {
        final count = NotificationCount.fromJson(response.data);
        return count.count;
      }
      return 0;
    } catch (e) {
      debugPrint('🔴 Error fetching notification count: $e');
      return 0;
    }
  }

  /// Fetch Waiting Schedules
  static Future<WaitingScheduleResponse> getWaitingSchedules({
    int limit = 20,
    String? idLsp,
    int? idTuk,
    String sortBy = 'tanggal',
    String sortOrder = 'desc',
  }) async {
    try {
      final params = <String>[];
      params.add('limit=$limit');
      if (idLsp != null) params.add('id_lsp=$idLsp');
      if (idTuk != null) params.add('id_tuk=$idTuk');
      params.add('sort_by=$sortBy');
      params.add('sort_order=$sortOrder');

      final url = '${ApiRoutes.jadwalWaiting}?${params.join('&')}';
      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        return WaitingScheduleResponse.fromJson(response.data);
      }

      return const WaitingScheduleResponse(
        data: [],
        meta: NotificationMeta(totalWaiting: 0, limit: 20, sortBy: 'tanggal', sortOrder: 'desc'),
      );
    } catch (e) {
      debugPrint('🔴 Error fetching waiting schedules: $e');
      return const WaitingScheduleResponse(
        data: [],
        meta: NotificationMeta(totalWaiting: 0, limit: 20, sortBy: 'tanggal', sortOrder: 'desc'),
      );
    }
  }

  // ============================================================================
  // Private Fallback Data
  // ============================================================================

  static List<JadwalOverdue> _getFallbackJadwal() {
    return const [
      JadwalOverdue(id: 1, jadwal: 'Sertifikasi Kompetensi TIK Bidang Programmer', tanggal: '2025-05-23', tuk: 'TUK Campus Digital', daysOverdue: 3, statusLabel: 'Terjadwal'),
      JadwalOverdue(id: 2, jadwal: 'Asesmen Ulang Klaster Cloud Computing', tanggal: '2025-05-24', tuk: 'TUK Sewaktu LSP', daysOverdue: 2, statusLabel: 'Sedang Berlangsung'),
      JadwalOverdue(id: 3, jadwal: 'Uji Kompetensi Jabatan Fungsional Sandiman', tanggal: '2025-05-25', tuk: 'TUK Mandiri Cyber', daysOverdue: 1, statusLabel: 'Terjadwal'),
    ];
  }

  static List<JadwalBaru> _getFallbackJadwalBaru() {
    return const [
      JadwalBaru(id: 9048, jadwal: 'Sertifikasi Borneo Engineer - Digital Marketing Batch 2', tanggal: '2025-04-30', kuota: 54, statusJadwal: '0', tuk: 'Borneo Engineer'),
      JadwalBaru(id: 9049, jadwal: 'Sertifikasi Campus Digital - Content Creator Batch 1', tanggal: '2025-05-15', kuota: 30, statusJadwal: '0', tuk: 'Campus Digital'),
      JadwalBaru(id: 9050, jadwal: 'Asesmen Mandiri Cyber - Ethical Hacker', tanggal: '2025-05-20', kuota: 25, statusJadwal: '0', tuk: 'Mandiri Cyber'),
    ];
  }
}
