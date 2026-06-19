import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'token_storage.dart';
import 'auth_repository.dart';
import '../models/dashboard_models.dart';
import '../models/sertifikat_models.dart';
import '../models/jadwal_models.dart';
import '../helpers/bps_code_helper.dart';
import '../helpers/api_routes.dart';
import '../models/master_models.dart';
import '../models/auth_models.dart';
import '../models/berita_model.dart';

// ============================================================================
// API Service
// ============================================================================
// Service untuk handle semua API calls ke backend LSP Digital

class ApiService {
  // ============================================================================
  // Configuration — Lazy Initialization
  // ============================================================================

  static String get baseUrl {
    final url = dotenv.env['BASE_URL'] ?? "";
    return url;
  }

  // Expose the Dio instance publicly for use by other repositories
  static Dio get dio => _dio;

  // Lazy Dio: only created on first API call, not at class load time.
  // This avoids triggering dotenv lookup + interceptor setup during startup.
  static Dio? _dioInstance;
  static bool _isRefreshing = false;
  static Dio get _dio {
    return _dioInstance ??=
        Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 20),
            ),
          )
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) async {
                if (kDebugMode) {
                  debugPrint(
                    '🔵 API Request: ${options.method} ${options.uri}',
                  );
                }
                final token = await TokenStorage.instance.getAccessToken();
                if (token != null && token.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
                return handler.next(options);
              },
              onResponse: (response, handler) {
                if (kDebugMode) {
                  debugPrint(
                    '🟢 API Response: ${response.statusCode} ${response.requestOptions.uri}',
                  );
                }
                return handler.next(response);
              },
              onError: (error, handler) async {
                if (kDebugMode) {
                  debugPrint('🔴 API Error: ${error.message}');
                  debugPrint('🔴 URL: ${error.requestOptions.uri}');
                }
                
                if (error.response?.statusCode == 401 && !_isRefreshing) {
                  _isRefreshing = true;
                  try {
                    final refreshToken = await TokenStorage.instance.getRefreshToken();
                    if (refreshToken != null && refreshToken.isNotEmpty) {
                      final refreshResponse = await Dio(BaseOptions(baseUrl: baseUrl))
                          .post(
                        '/api/auth/refresh',
                        data: {'refresh_token': refreshToken},
                      );

                      if (refreshResponse.statusCode == 200) {
                        final newAccessToken = refreshResponse.data['data']['access_token'];
                        await TokenStorage.instance.saveTokens(
                          accessToken: newAccessToken,
                          refreshToken: refreshToken,
                        );

                        error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                        _isRefreshing = false;
                        
                        if (kDebugMode) {
                          debugPrint('🔄 Token refreshed successfully, retrying request');
                        }
                        return handler.resolve(await _dioInstance!.fetch(error.requestOptions));
                      }
                    }
                  } catch (e) {
                    if (kDebugMode) {
                      debugPrint('🔴 Token refresh failed: $e');
                    }
                    await TokenStorage.instance.clear();
                    AuthRepository.notifyTokenExpired();
                  } finally {
                    _isRefreshing = false;
                  }
                }
                
                return handler.next(error);
              },
            ),
          );
  }

  // ============================================================================
  // Health Check API
  // ============================================================================

  /// Health check endpoint - verifies server is up (no auth required)
  /// Backend added: 2026-06-09
  static Future<bool> healthCheck() async {
    try {
      final response = await _dio.get(
        '/api/health',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      final isHealthy = response.statusCode == 200 && 
                        response.data?['status'] == 'ok';
      if (kDebugMode) {
        debugPrint('🏥 Health check: ${isHealthy ? "✅ OK" : "❌ FAILED"} (${response.statusCode})');
      }
      return isHealthy;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔴 Health check failed: $e');
      }
      return false;
    }
  }

  /// Readiness check endpoint - verifies server + DB connection (no auth required)
  /// Backend added: 2026-06-09
  static Future<bool> readyCheck() async {
    try {
      final response = await _dio.get(
        '/api/ready',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      final isReady = response.statusCode == 200 && 
                      response.data?['status'] == 'ready';
      if (kDebugMode) {
        debugPrint('🔌 Ready check: ${isReady ? "✅ READY" : "❌ NOT READY"} (${response.statusCode})');
      }
      return isReady;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔴 Ready check failed: $e');
      }
      return false;
    }
  }

  // ============================================================================
  // Dashboard APIs
  // ============================================================================

  /// Fetch Dashboard Summary (Rangkuman Utama)
  static Future<DashboardSummary> getSummary() async {
    try {
      final response = await _dio.get(ApiRoutes.dashboardSummary);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        final trends = data['trends'];
        final meta = response.data['meta'];

        return DashboardSummary(
          totalAsesmen: data['total_asesmen'] ?? 0,
          totalPemegangSertifikat: data['total_pemegang_sertifikat'] ?? 0,
          totalAsesor: data['total_asesor'] ?? 0,
          totalTuk: data['total_tuk'] ?? 0,
          trendAsesmen: trends['asesmen']?['formatted'] ?? '+0,0%',
          trendPemegangSertifikat:
              trends['pemegang_sertifikat']?['formatted'] ?? '+0,0%',
          trendAsesor: trends['asesor']?['formatted'] ?? '+0,0%',
          trendTuk: trends['tuk']?['formatted'] ?? '+0,0%',
          isCurrentMonth: meta?['is_current_month'] ?? false,
          note: meta?['note'],
          // New fields - format "bulan_lalu > bulan_ini"
          jadwalAsesmen: data['jadwal_asesmen'] ?? '0 > 0',
          sertifikatPerSkema: data['sertifikat_per_skema'] ?? '0 > 0',
          sebaranAsesor: data['sebaran_asesor'] ?? '0 > 0',
          tempatUjiKompetensi: data['tempat_uji_kompetensi'] ?? '0 > 0',
        );
      }

      return DashboardSummary.fallback();
    } catch (e) {
      return DashboardSummary.fallback();
    }
  }

  /// Fetch Monthly Assessments for Chart (Tren Asesmen Bulanan)
  static Future<List<MonthlyAssessment>> getMonthlyAssessments() async {
    try {
      final response = await _dio.get(
        ApiRoutes.withMonths(
          ApiRoutes.dashboardMonthlyAssessments,
          MonthsRange.fourMonths.value,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        // Meta data tersedia jika diperlukan: response.data['meta']

        List<MonthlyAssessment> list = [];
        int maxTotal = 1; // Prevent division by zero

        for (var item in data) {
          int total = (item['total'] as num).toInt();
          if (total > maxTotal) maxTotal = total;
        }

        for (var item in data) {
          int total = (item['total'] as num).toInt();
          list.add(
            MonthlyAssessment(
              label: item['label'] ?? '',
              total: total,
              heightPercentage: total / maxTotal,
              kompeten: item['kompeten'],
              belumKompeten: item['belum_kompeten'],
              isCurrentMonth: item['is_current_month'] ?? false,
            ),
          );
        }

        if (list.isEmpty) {
          return _getFallbackMonthlyAssessments();
        }

        return list;
      } else {
        return _getFallbackMonthlyAssessments();
      }
    } catch (e) {
      return _getFallbackMonthlyAssessments();
    }
  }

  /// Fetch Assessment Graph with Filters (NEW)
  /// Default: 12 months, Options: 6, 12, 18, 24 months
  static Future<List<MonthlyAssessment>> getAssessmentGraph({
    int months = 12,
  }) async {
    try {
      final url = months == 12
          ? ApiRoutes.dashboardAssessmentGraph
          : '${ApiRoutes.dashboardAssessmentGraph}?months=$months';

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];

        List<MonthlyAssessment> list = [];
        int maxTotal = 1; // Prevent division by zero

        // Find max value first
        for (var item in data) {
          int total = (item['jumlah_asesmen'] as num?)?.toInt() ?? 
                     (item['total'] as num?)?.toInt() ?? 0;
          if (total > maxTotal) maxTotal = total;
        }

        // Build list with proper field mapping
        for (var item in data) {
          int total = (item['jumlah_asesmen'] as num?)?.toInt() ?? 
                     (item['total'] as num?)?.toInt() ?? 0;
          list.add(
            MonthlyAssessment(
              label: item['label'] ?? '',
              total: total,
              heightPercentage: total / maxTotal,
              kompeten: item['kompeten'],
              belumKompeten: item['belum_kompeten'],
              isCurrentMonth: item['is_current_month'] ?? false,
            ),
          );
        }

        if (list.isEmpty) {
          return _getFallbackMonthlyAssessments();
        }

        return list;
      } else {
        return _getFallbackMonthlyAssessments();
      }
    } catch (e) {
      debugPrint('Error fetching assessment graph: $e');
      return _getFallbackMonthlyAssessments();
    }
  }

  // ============================================================================
  // Private Helper Methods - Fallback Data
  // ============================================================================

  static List<MonthlyAssessment> _getFallbackMonthlyAssessments() {
    return const [
      MonthlyAssessment(label: 'Mei 2026', total: 1050, heightPercentage: 0.42),
      MonthlyAssessment(label: 'Jun 2026', total: 1550, heightPercentage: 0.62),
      MonthlyAssessment(label: 'Jul 2026', total: 2050, heightPercentage: 0.82),
      MonthlyAssessment(label: 'Agu 2026', total: 2545, heightPercentage: 1.0),
    ];
  }

  static List<JadwalOverdue> _getFallbackJadwal() {
    return const [
      JadwalOverdue(
        id: 1,
        jadwal: 'Sertifikasi Kompetensi TIK Bidang Programmer',
        tanggal: '2025-05-23',
        tuk: 'TUK Campus Digital',
        daysOverdue: 3,
        statusLabel: 'Terjadwal',
      ),
      JadwalOverdue(
        id: 2,
        jadwal: 'Asesmen Ulang Klaster Cloud Computing',
        tanggal: '2025-05-24',
        tuk: 'TUK Sewaktu LSP',
        daysOverdue: 2,
        statusLabel: 'Sedang Berlangsung',
      ),
      JadwalOverdue(
        id: 3,
        jadwal: 'Uji Kompetensi Jabatan Fungsional Sandiman',
        tanggal: '2025-05-25',
        tuk: 'TUK Mandiri Cyber',
        daysOverdue: 1,
        statusLabel: 'Terjadwal',
      ),
    ];
  }

  static List<JadwalBaru> _getFallbackJadwalBaru() {
    return const [
      JadwalBaru(
        id: 9048,
        jadwal: 'Sertifikasi Borneo Engineer - Digital Marketing Batch 2',
        tanggal: '2025-04-30',
        kuota: 54,
        statusJadwal: '0',
        tuk: 'Borneo Engineer',
      ),
      JadwalBaru(
        id: 9049,
        jadwal: 'Sertifikasi Campus Digital - Content Creator Batch 1',
        tanggal: '2025-05-15',
        kuota: 30,
        statusJadwal: '0',
        tuk: 'Campus Digital',
      ),
      JadwalBaru(
        id: 9050,
        jadwal: 'Asesmen Mandiri Cyber - Ethical Hacker',
        tanggal: '2025-05-20',
        kuota: 25,
        statusJadwal: '0',
        tuk: 'Mandiri Cyber',
      ),
    ];
  }

  static List<TopProvinsi> _getFallbackProvinces() {
    return const [
      TopProvinsi(
        name: 'Sampit, Kalimantan Tengah',
        value: 214,
        percentage: '17,2%',
      ),
      TopProvinsi(name: 'Yogyakarta', value: 100, percentage: '15,9%'),
      TopProvinsi(name: 'Sumatra Utara', value: 62, percentage: '12,3%'),
      TopProvinsi(name: 'Semarang', value: 200, percentage: '11,4%'),
      TopProvinsi(name: 'Balikpapan', value: 97, percentage: '8,7%'),
    ];
  }

  static List<TopMitra> _getFallbackMitras() {
    return const [
      TopMitra(
        name: 'LKP Gen Komputer Sampit',
        value: 214,
        percentage: '17,2%',
      ),
      TopMitra(name: 'LPP Enter Pangkalanbun', value: 100, percentage: '15,9%'),
      TopMitra(name: 'TUK Tanascom Lempuing', value: 62, percentage: '12,3%'),
      TopMitra(name: 'SMKN 2 Jakarta', value: 200, percentage: '11,4%'),
      TopMitra(name: 'SMK Muhammadiyah Malang', value: 97, percentage: '8,7%'),
    ];
  }

  // ============================================================================
  // Jadwal APIs
  // ============================================================================

  /// Fetch Jadwal Asesmen Baru
  static Future<List<JadwalBaru>> getJadwalBaru() async {
    try {
      final response = await _dio.get(
        ApiRoutes.withLimit(ApiRoutes.jadwalBaru, DataLimit.three.value),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        List<JadwalBaru> list = data
            .map((item) => JadwalBaru.fromJson(item as Map<String, dynamic>))
            .toList();

        return list;
      } else {
        if (kDebugMode) return _getFallbackJadwalBaru();
        return [];
      }
    } catch (e) {
      if (kDebugMode) return _getFallbackJadwalBaru();
      debugPrint('Error fetching jadwal baru: $e');
      return [];
    }
  }

  /// Fetch Jadwal Asesmen Mendekati Baru
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

  /// Fetch Jadwal List with filters
  /// Used for JadwalScreen tabs
  static Future<List<JadwalItem>> getJadwalList({
    int limit = 20,
    int offset = 0,
    String? statusJadwal,
    int? idTuk,
    String? idLsp,
    String? sortBy,
    String? sortOrder,
    String? customRoutePath,
  }) async {
    try {
      // Determine the correct route path based on customRoutePath or statusJadwal
      String routePath = customRoutePath ?? ApiRoutes.jadwalOutOfDate;
      if (customRoutePath == null && statusJadwal != null) {
        if (statusJadwal == '3') {
          // Status Running -> use /api/jadwal/active
          routePath = '/api/jadwal/active';
        } else if (statusJadwal.contains('1') || statusJadwal.contains('4')) {
          // Status Completed/Pelaporan -> use /api/jadwal/completed
          routePath = '/api/jadwal/completed';
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
        List<JadwalItem> list = data
            .map((item) => JadwalItem.fromJson(item as Map<String, dynamic>))
            .toList();

        return list;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('🔴 Error fetching jadwal list: $e');
      return [];
    }
  }

  /// Update Status Jadwal
  /// Used for updating specific jadwal status
  static Future<Map<String, dynamic>> updateJadwalStatus({
    required int jadwalId,
    required String rule,
    String? catatan,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiRoutes.jadwalUpdateStatus}/apply',
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
      } else {
        return {'success': false, 'message': 'Gagal memperbarui status'};
      }
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
      final response = await _dio.get('/api/jadwal/$jadwalId/asesi');

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

  // ============================================================================
  // Notification APIs
  // ============================================================================

  /// Fetch Notification Count
  /// Get count of waiting schedules for notification badge
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
  /// Get list of schedules with status "Waiting" (status_jadwal = "0")
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

  // ============================================================================
  // Asesor APIs
  // ============================================================================

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

        if (list.isEmpty) return _getFallbackProvinces();
        return list;
      }
      return _getFallbackProvinces();
    } catch (e) {
      return _getFallbackProvinces();
    }
  }

  // ============================================================================
  // Skema APIs
  // ============================================================================

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
        int totalSkema = response.data['meta']?['total_skema'] ?? 58;

        // In the real database, all schemas are active (status_aktif = '1')
        int active = totalSkema;
        int inactive = 0;

        return SkemaStats(
          totalSkema: totalSkema,
          provinsi: 34, // Nationwide coverage
          skemaAktif: active,
          skemaNonaktif: inactive,
        );
      }
      return SkemaStats.fallback();
    } catch (e) {
      return SkemaStats.fallback();
    }
  }

  // ============================================================================
  // Mitra APIs
  // ============================================================================

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

        if (list.isEmpty) return _getFallbackMitras();
        return list;
      }
      return _getFallbackMitras();
    } catch (e) {
      return _getFallbackMitras();
    }
  }

  // ============================================================================
  // Wilayah APIs
  // ============================================================================

  /// Fetch TUK Kabupaten distribution by Province ID
  static Future<List<TUKKabupaten>> getTUKKabupaten(String provinceId) async {
    try {
      int bpsCode = BpsCodeHelper.getBpsCode(provinceId);
      final response = await _dio.get(
        ApiRoutes.withProvinsiId(ApiRoutes.wilayahTukPerKabupaten, bpsCode),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> provList = response.data['data'] ?? [];
        if (provList.isNotEmpty) {
          final List<dynamic> kabs = provList[0]['kabupaten'] ?? [];
          return kabs
              .map(
                (item) => TUKKabupaten(
                  kabupaten: item['kabupaten'] ?? 'Kabupaten/Kota',
                  jumlah: item['jumlah'] ?? 0,
                  detail: List<String>.from(item['detail'] ?? []),
                ),
              )
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ============================================================================
  // Statistik APIs
  // ============================================================================

  /// Fetch Statistik Overview
  static Future<StatistikOverview> getStatistikOverview() async {
    try {
      final response = await _dio.get(ApiRoutes.dashboardStatistikOverview);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        final trends = data['trends'];

        return StatistikOverview(
          totalAsesi: data['total_asesi'] ?? 0,
          sertifikatTerbit: data['sertifikat_terbit'] ?? 0,
          lspTerdaftar: data['lsp_terdaftar'] ?? 0,
          tingkatKelulusan: (data['tingkat_kelulusan'] ?? 0.0).toDouble(),
          trendTotalAsesi: trends['total_asesi'] ?? '+0,0%',
          trendSertifikatTerbit: trends['sertifikat_terbit'] ?? '+0,0%',
          trendLspTerdaftar: trends['lsp_terdaftar'] ?? '+0,0%',
          trendTingkatKelulusan: trends['tingkat_kelulusan'] ?? '+0,0%',
        );
      }

      return StatistikOverview.fallback();
    } catch (e) {
      return StatistikOverview.fallback();
    }
  }

  /// Fetch Sector Distribution
  static Future<List<SectorDistribution>> getSectorDistribution() async {
    try {
      final response = await _dio.get(
        ApiRoutes.withLimit(
          ApiRoutes.dashboardDistribusiSektor,
          DataLimit.five.value,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic>? data = response.data['data'];

        if (data != null && data.isNotEmpty) {
          return data
              .map(
                (item) => SectorDistribution(
                  sectorName: item['sector_name'] ?? '',
                  count: item['count'] ?? 0,
                  percentage: (item['percentage'] ?? 0.0).toDouble() / 100,
                ),
              )
              .toList();
        }
      }

      return _getFallbackSectorDistribution();
    } catch (e) {
      return _getFallbackSectorDistribution();
    }
  }

  static List<SectorDistribution> _getFallbackSectorDistribution() {
    return const [
      SectorDistribution(
        sectorName: 'Teknologi Informasi & Komunikasi',
        count: 9060,
        percentage: 0.35,
      ),
      SectorDistribution(
        sectorName: 'Manufaktur & Teknik Industri',
        count: 5695,
        percentage: 0.22,
      ),
      SectorDistribution(
        sectorName: 'Pariwisata & Perhotelan',
        count: 4660,
        percentage: 0.18,
      ),
      SectorDistribution(
        sectorName: 'Bisnis & Keuangan Administrasi',
        count: 3880,
        percentage: 0.15,
      ),
      SectorDistribution(
        sectorName: 'Kesehatan & Farmasi',
        count: 2595,
        percentage: 0.10,
      ),
    ];
  }

  // ============================================================================
  // Regional/Island APIs
  // ============================================================================

  /// Fetch Penyebaran Regional (By Island)
  static Future<List<RegionalDistribution>> getPenyebaranRegional() async {
    try {
      final response = await _dio.get(ApiRoutes.dashboardPenyebaranRegional);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic>? data = response.data['data'];

        if (data != null && data.isNotEmpty) {
          return data
              .map(
                (item) =>
                    RegionalDistribution.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // ============================================================================
  // Sertifikat APIs
  // ============================================================================

  /// Fetch Sertifikat Summary
  static Future<SertifikatSummary> getSertifikatSummary() async {
    try {
      final response = await _dio.get(ApiRoutes.dashboardSertifikatSummary);

      if (response.statusCode == 200 && response.data != null) {
        return SertifikatSummary.fromJson(response.data);
      }

      return SertifikatSummary.fallback();
    } catch (e) {
      debugPrint('🔴 Error fetching sertifikat summary: $e');
      return SertifikatSummary.fallback();
    }
  }

  /// Fetch Sertifikat Per Skema
  static Future<SertifikatApiResponse> getSertifikatPerSkema({
    int limit = 10,
    int? tahun,
    String sort = 'desc',
  }) async {
    try {
      String url = ApiRoutes.withLimit(
        ApiRoutes.dashboardSertifikatPerSkema,
        limit,
      );

      if (tahun != null) {
        url += '&tahun=$tahun';
      }

      if (sort != 'desc') {
        url += '&sort=$sort';
      }

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        return SertifikatApiResponse.fromJson(response.data);
      }

      return _getFallbackSertifikatResponse();
    } catch (e) {
      debugPrint('🔴 Error fetching sertifikat per skema: $e');
      return _getFallbackSertifikatResponse();
    }
  }

  static SertifikatApiResponse _getFallbackSertifikatResponse() {
    return const SertifikatApiResponse(
      data: [],
      meta: SertifikatMeta(
        totalSkema: 0,
        totalPemegangSertifikat: 0,
        limit: 10,
      ),
    );
  }

  /// Search Sertifikat by query
  static Future<List<SertifikatItem>> searchSertifikat({
    required String query,
    String? skema,
    String? kategori,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Build query parameters
      final params = <String>[];
      params.add('q=$query');
      if (skema != null && skema.isNotEmpty) {
        params.add('skema=$skema');
      }
      if (kategori != null && kategori.isNotEmpty) {
        params.add('kategori=$kategori');
      }
      if (status != null && status.isNotEmpty) {
        params.add('status=$status');
      }
      params.add('limit=$limit');
      params.add('offset=$offset');

      final url = '${ApiRoutes.sertifikatSearch}?${params.join('&')}';
      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => SertifikatItem.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      debugPrint('🔴 Error searching sertifikat: $e');
      return [];
    }
  }

  // ============================================================================
  // Master APIs
  // ============================================================================

  /// Fetch list of Provinsi
  static Future<List<MasterItem>> getProvinsiList() async {
    try {
      final response = await _dio.get(ApiRoutes.masterProvinsi);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => MasterItem.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching provinsi: $e');
      return [];
    }
  }

  /// Fetch list of Kabupaten/Kota by province ID
  static Future<List<MasterItem>> getKabupatenList(String provinceId) async {
    try {
      final response = await _dio.get(
        ApiRoutes.masterKabupaten,
        queryParameters: {'province_id': provinceId},
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => MasterItem.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching kabupaten: $e');
      return [];
    }
  }

  /// Fetch list of Kecamatan by kabupaten ID
  static Future<List<MasterItem>> getKecamatanList(String kabupatenId) async {
    try {
      final response = await _dio.get(
        ApiRoutes.masterKecamatan,
        queryParameters: {'kabupaten_id': kabupatenId},
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => MasterItem.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching kecamatan: $e');
      return [];
    }
  }

  /// Fetch list of Master Skema
  static Future<List<MasterSkema>> getMasterSkemaList() async {
    try {
      final response = await _dio.get(ApiRoutes.masterSkema);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => MasterSkema.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching master skema: $e');
      return [];
    }
  }

  /// Fetch list of Master Jadwal by skema ID
  static Future<List<MasterJadwal>> getMasterJadwalList(int idSkema) async {
    try {
      final response = await _dio.get(
        ApiRoutes.masterJadwal,
        queryParameters: {'id_skema': idSkema},
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => MasterJadwal.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching master jadwal: $e');
      return [];
    }
  }

  // ============================================================================
  // Session APIs
  // ============================================================================

  /// Fetch active login sessions
  static Future<List<LoginSession>> getActiveSessions() async {
    try {
      final response = await _dio.get('/api/sessions');
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
        '/api/sessions',
        data: {'id': id},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('🔴 Error deleting session: $e');
      return false;
    }
  }

  // ============================================================================
  // Berita APIs
  // ============================================================================

  /// Fetch Paginated News List
  static Future<List<BeritaItem>> getBerita({int page = 1, int size = 10}) async {
    try {
      final response = await _dio.get(
        '/api/berita',
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
      final response = await _dio.get('/api/berita/$id');
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
}
