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
      return [];
    } catch (e) {
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
      return [];
    } catch (e) {
      debugPrint('Error fetching jadwal out of date: $e');
      return [];
    }
  }

  /// Invalidate running list cache (call after ACC / status change)
  static void clearRunningJadwalCache() {
    _runningJadwalCache = null;
    _runningJadwalCacheTime = null;
  }

  /// Fetch ringkasan hitungan jadwal admin
  static Future<JadwalStatistik> getJadwalStatistics() async {
    try {
      final response = await _dio.get(ApiRoutes.jadwalStatistics);
      if (response.statusCode == 200 && response.data != null) {
        return JadwalStatistik.fromJson(
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : <String, dynamic>{},
        );
      }
      return JadwalStatistik.fallback();
    } catch (e) {
      debugPrint('🔴 Error fetching jadwal statistics: $e');
      return JadwalStatistik.fallback();
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
    if (useCache &&
        statusJadwal == '3' &&
        _runningJadwalCache != null &&
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
      clearRunningJadwalCache();
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
      final path = isAsesor
          ? ApiRoutes.asesorJadwalPeserta(jadwalId)
          : ApiRoutes.jadwalAsesi(jadwalId);
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
  static Future<ParticipantDetailResponse?> getParticipantDetail(
    int jadwalId,
    int pesertaId,
  ) async {
    try {
      final response = await _dio.get(
        ApiRoutes.asesorJadwalPesertaDetail(jadwalId, pesertaId),
      );
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
  static Future<JadwalAsesorDetailResponse?> getJadwalAsesorDetail(
    int jadwalId,
  ) async {
    try {
      final isAsesor = AuthRepository.currentUserInstance?.role == 'asesor';
      final path = isAsesor
          ? ApiRoutes.asesorJadwalDetail(jadwalId)
          : ApiRoutes.jadwalAsesorDetail(jadwalId);
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
      final response = await _dio.get(
        ApiRoutes.asesorJadwalSuratTugas(jadwalId),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['status'] == 'success') {
          return response.data['data']?['file_url'] as String?;
        }
      }
      return null;
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Surat tugas belum tersedia';
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
        meta: NotificationMeta(
          totalWaiting: 0,
          limit: 20,
          sortBy: 'tanggal',
          sortOrder: 'desc',
        ),
      );
    } catch (e) {
      debugPrint('🔴 Error fetching waiting schedules: $e');
      return const WaitingScheduleResponse(
        data: [],
        meta: NotificationMeta(
          totalWaiting: 0,
          limit: 20,
          sortBy: 'tanggal',
          sortOrder: 'desc',
        ),
      );
    }
  }

}
