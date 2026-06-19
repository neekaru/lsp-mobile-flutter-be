import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';
import '../helpers/api_routes.dart';
import '../models/dashboard_models.dart';
import '../helpers/bps_code_helper.dart';

// ============================================================================
// Dashboard Service
// ============================================================================

class DashboardService {
  static Dio get _dio => ApiClient.dio;

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

  /// Fetch Monthly Assessments for Chart
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

        List<MonthlyAssessment> list = [];
        int maxTotal = 1;

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

        if (list.isEmpty) return _getFallbackMonthlyAssessments();
        return list;
      }
      return _getFallbackMonthlyAssessments();
    } catch (e) {
      return _getFallbackMonthlyAssessments();
    }
  }

  /// Fetch Assessment Graph with Filters
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
        int maxTotal = 1;

        for (var item in data) {
          int total = (item['jumlah_asesmen'] as num?)?.toInt() ??
                     (item['total'] as num?)?.toInt() ?? 0;
          if (total > maxTotal) maxTotal = total;
        }

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

        if (list.isEmpty) return _getFallbackMonthlyAssessments();
        return list;
      }
      return _getFallbackMonthlyAssessments();
    } catch (e) {
      debugPrint('Error fetching assessment graph: $e');
      return _getFallbackMonthlyAssessments();
    }
  }

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

  /// Fetch Penyebaran Regional (By Island)
  static Future<List<RegionalDistribution>> getPenyebaranRegional() async {
    try {
      final response = await _dio.get(ApiRoutes.dashboardPenyebaranRegional);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic>? data = response.data['data'];

        if (data != null && data.isNotEmpty) {
          return data
              .map((item) => RegionalDistribution.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

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
  // Private Fallback Data
  // ============================================================================

  static List<MonthlyAssessment> _getFallbackMonthlyAssessments() {
    return const [
      MonthlyAssessment(label: 'Mei 2026', total: 1050, heightPercentage: 0.42),
      MonthlyAssessment(label: 'Jun 2026', total: 1550, heightPercentage: 0.62),
      MonthlyAssessment(label: 'Jul 2026', total: 2050, heightPercentage: 0.82),
      MonthlyAssessment(label: 'Agu 2026', total: 2545, heightPercentage: 1.0),
    ];
  }

  static List<SectorDistribution> _getFallbackSectorDistribution() {
    return const [
      SectorDistribution(sectorName: 'Teknologi Informasi & Komunikasi', count: 9060, percentage: 0.35),
      SectorDistribution(sectorName: 'Manufaktur & Teknik Industri', count: 5695, percentage: 0.22),
      SectorDistribution(sectorName: 'Pariwisata & Perhotelan', count: 4660, percentage: 0.18),
      SectorDistribution(sectorName: 'Bisnis & Keuangan Administrasi', count: 3880, percentage: 0.15),
      SectorDistribution(sectorName: 'Kesehatan & Farmasi', count: 2595, percentage: 0.10),
    ];
  }
}
