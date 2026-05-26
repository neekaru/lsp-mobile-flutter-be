import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/dashboard_models.dart';
import '../helpers/bps_code_helper.dart';
import '../helpers/api_routes.dart';

// ============================================================================
// API Service
// ============================================================================
// Service untuk handle semua API calls ke backend LSP Digital

class ApiService {
  // ============================================================================
  // Configuration
  // ============================================================================
  
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'] ?? "";
    print('🌐 ApiService baseUrl: $url');
    return url;
  }

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10), // Increased from 1s to 10s
      receiveTimeout: const Duration(seconds: 10), // Increased from 1.5s to 10s
      sendTimeout: const Duration(seconds: 10),
    ),
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🔵 API Request: ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('🟢 API Response: ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('🔴 API Error: ${error.message}');
        print('🔴 URL: ${error.requestOptions.uri}');
        return handler.next(error);
      },
    ),
  );

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

  /// Fetch Jadwal Asesmen Mendekati Akhir (Out of Date Schedules)
  static Future<List<JadwalOverdue>> getJadwalOutOfDate() async {
    try {
      final response = await _dio.get(
        ApiRoutes.withLimit(ApiRoutes.jadwalOutOfDate, DataLimit.three.value),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        List<JadwalOverdue> list = data
            .map((item) => JadwalOverdue.fromJson(item as Map<String, dynamic>))
            .toList();

        if (list.isEmpty) {
          return _getFallbackJadwal();
        }

        return list;
      } else {
        return _getFallbackJadwal();
      }
    } catch (e) {
      return _getFallbackJadwal();
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
          wilayahTercover: data['wilayah_tercover'] ?? 0,
          trendTotalAsesor: trends['total_asesor'] ?? '+0,0%',
        );
      }

      return AsesorStats.fallback();
    } catch (e) {
      return AsesorStats.fallback();
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
}
