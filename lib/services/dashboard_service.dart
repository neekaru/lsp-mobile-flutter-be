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
          totalAsesi: data['total_asesi'] ?? 0,
          jadwalBelumTerkonfirmasi: data['jadwal_belum_terkonfirmasi'] ?? 0,
          suratTugasMenungguPengiriman: data['surat_tugas_menunggu_pengiriman'] ?? 0,
          pendaftaranAsesiBaru: data['pendaftaran_asesi_baru'] ?? 0,
          honorAsesorBelumDibayar: data['honor_asesor_belum_dibayar'] ?? 0,
          trendAsesmen: trends?['asesmen']?['formatted'] ?? '+0,0%',
          trendPemegangSertifikat:
              trends?['pemegang_sertifikat']?['formatted'] ?? '+0,0%',
          trendAsesor: trends?['asesor']?['formatted'] ?? '+0,0%',
          trendTuk: trends?['tuk']?['formatted'] ?? '+0,0%',
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

  /// Fetch Asesi Dashboard Summary
  static Future<AsesiDashboardSummary> getAsesiSummary() async {
    try {
      final response = await _dio.get(ApiRoutes.asesiDashboard);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        debugPrint('🟢 [AsesiDashboard] raw data: $data');
        return AsesiDashboardSummary.fromJson(data);
      }

      debugPrint('🔴 [AsesiDashboard] non-200 status: ${response.statusCode}');
      return AsesiDashboardSummary.empty();
    } catch (e) {
      debugPrint('🔴 [AsesiDashboard] error: $e');
      return AsesiDashboardSummary.empty();
    }
  }

  /// Fetch Asesor Dashboard Data
  static Future<AsesorDashboardData> getAsesorDashboard({String? tanggal}) async {
    try {
      final url = tanggal != null
          ? '${ApiRoutes.asesorDashboard}?tanggal=$tanggal'
          : ApiRoutes.asesorDashboard;

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        return AsesorDashboardData.fromJson(data);
      }

      return AsesorDashboardData.empty();
    } catch (e) {
      debugPrint('Error fetching asesor dashboard: $e');
      return AsesorDashboardData.empty();
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
          int total = (item['total'] as num?)?.toInt() ??
                      (item['jumlah_asesmen'] as num?)?.toInt() ?? 0;
          if (total > maxTotal) maxTotal = total;
        }

        for (var item in data) {
          int total = (item['total'] as num?)?.toInt() ??
                      (item['jumlah_asesmen'] as num?)?.toInt() ?? 0;
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

        return list;
      }
      return [];
    } catch (e) {
      return [];
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

        return list;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching assessment graph: $e');
      return [];
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

      return [];
    } catch (e) {
      return [];
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

  /// Fetch Domisili Asesor (Internal vs External per Provinsi)
  static Future<DomisiliAsesorData?> getDomisiliAsesor() async {
    try {
      final response = await _dio.get(ApiRoutes.dashboardDomisiliAsesor);
      if (response.statusCode == 200 && response.data != null) {
        return DomisiliAsesorData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching domisili asesor: $e');
      return null;
    }
  }

  /// Fetch detail list of assessors for a specific provinsi domisili from Backend API
  static Future<DomisiliAsesorDetailData?> getDomisiliAsesorDetail({
    required String provinsiId,
    String? search,
    String? tipe,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (tipe != null &&
          tipe.trim().isNotEmpty &&
          tipe.trim().toLowerCase() != 'semua') {
        queryParams['tipe'] = tipe.trim().toLowerCase();
      }

      final response = await _dio.get(
        ApiRoutes.dashboardDomisiliAsesorDetail(provinsiId),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return DomisiliAsesorDetailData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching detail domisili asesor: $e');
      return null;
    }
  }

  /// Fetch Kompetensi Teknis Asesor list by Skema ID
  static Future<List<KompetensiTeknisItem>> getKompetensiTeknis() async {
    try {
      final response = await _dio.get(ApiRoutes.dashboardKompetensiTeknis);
      if (response.statusCode == 200 && response.data != null) {
        final List list = response.data['data'] ?? [];
        return list.map((e) => KompetensiTeknisItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching kompetensi teknis: $e');
      return [];
    }
  }

  /// Fetch detail list of assessors for a specific Kompetensi Teknis Skema
  static Future<KompetensiTeknisDetailData?> getKompetensiTeknisDetail({
    required dynamic skemaId,
    String? search,
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (status != null && status.trim().isNotEmpty && status.trim().toLowerCase() != 'semua') {
        queryParams['status'] = status.trim().toLowerCase();
      }

      final response = await _dio.get(
        ApiRoutes.dashboardKompetensiTeknisDetail(skemaId),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return KompetensiTeknisDetailData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching detail kompetensi teknis asesor: $e');
      return null;
    }
  }

  /// Fetch Masa Berlaku Asesor (Aktif, Tenggang, Expired)
  static Future<MasaBerlakuAsesorData?> getMasaBerlakuAsesor() async {
    try {
      final response = await _dio.get(ApiRoutes.dashboardMasaBerlakuAsesor);
      if (response.statusCode == 200 && response.data != null) {
        return MasaBerlakuAsesorData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching masa berlaku asesor: $e');
      return null;
    }
  }

  /// Fetch detail list of assessors by status masa berlaku (tenggang or expired)
  static Future<MasaBerlakuAsesorDetailData?> getMasaBerlakuAsesorDetail({
    required String status,
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'status': status.trim().toLowerCase(),
        'limit': limit,
        'offset': offset,
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _dio.get(
        ApiRoutes.dashboardMasaBerlakuAsesorDetail,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return MasaBerlakuAsesorDetailData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching detail masa berlaku asesor: $e');
      return null;
    }
  }

  /// Fetch Jenis Skema by Category
  static Future<List<JenisSkemaItem>> getJenisSkema() async {
    try {
      final response = await _dio.get(ApiRoutes.dashboardJenisSkema);
      if (response.statusCode == 200 && response.data != null) {
        final List list = response.data['data'] ?? [];
        return list.map((e) => JenisSkemaItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching jenis skema: $e');
      return [];
    }
  }

  /// Fetch MUK/MAPA Distribution by Skema
  static Future<List<MUKDistribusiItem>> getMUKDistribusi() async {
    try {
      final response = await _dio.get(ApiRoutes.dashboardMukDistribusi);
      if (response.statusCode == 200 && response.data != null) {
        final List list = response.data['data'] ?? [];
        return list.map((e) => MUKDistribusiItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching MUK distribusi: $e');
      return [];
    }
  }

  /// Fetch detail list of MUK/MAPA perangkat for a specific Skema ID
  static Future<MUKDetailData?> getMUKDistribusiDetail({
    required dynamic skemaId,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _dio.get(
        ApiRoutes.dashboardMukDistribusiDetail(skemaId),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return MUKDetailData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching MUK distribusi detail: $e');
      return null;
    }
  }

  /// Fetch Surat Tugas / SPT Asesor 2026
  static Future<SptAsesorData?> getSptAsesor2026({int tahun = 2026}) async {
    try {
      final response = await _dio.get('${ApiRoutes.dashboardSptAsesor2026}?tahun=$tahun');
      if (response.statusCode == 200 && response.data != null) {
        return SptAsesorData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching SPT Asesor 2026: $e');
      return null;
    }
  }
}
