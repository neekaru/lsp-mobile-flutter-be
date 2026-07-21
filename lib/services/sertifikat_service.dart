import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';
import '../helpers/api_routes.dart';
import '../models/sertifikat_models.dart';
import '../models/jadwal_models.dart';
import 'token_storage.dart';

// ============================================================================
// Sertifikat Service
// ============================================================================

class SertifikatService {
  static Dio get _dio => ApiClient.dio;

  /// Validate Certificate by certificate, registration, or serial number.
  static Future<SertifikatValidationResult> validateSertifikat(
    String noDokumen,
  ) async {
    try {
      final response = await _dio.post(
        ApiRoutes.sertifikatValidate,
        data: {'no_dokumen': noDokumen},
      );

      if (response.data != null) {
        return SertifikatValidationResult.fromJson(response.data);
      }
      return const SertifikatValidationResult(
        valid: false,
        message: 'Format response tidak valid.',
      );
    } on DioException catch (e) {
      debugPrint('🔴 Error validating certificate: $e');
      if (e.response != null &&
          e.response!.data != null &&
          e.response!.data is Map) {
        return SertifikatValidationResult.fromJson(e.response!.data);
      }
      return SertifikatValidationResult(
        valid: false,
        message:
            e.response?.data?['message'] ??
            e.message ??
            'Terjadi kesalahan pada server.',
      );
    } catch (e) {
      debugPrint('🔴 Error validating certificate: $e');
      return SertifikatValidationResult(
        valid: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

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
      if (tahun != null) url += '&tahun=$tahun';
      if (sort != 'desc') url += '&sort=$sort';

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
      final params = <String>[];
      params.add('q=$query');
      if (skema != null && skema.isNotEmpty) params.add('skema=$skema');
      if (kategori != null && kategori.isNotEmpty)
        params.add('kategori=$kategori');
      if (status != null && status.isNotEmpty) params.add('status=$status');
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
  // Skema Sertifikasi (Protected, role=asesi)
  // ============================================================================

  /// Fetch paginated list of skema sertifikasi.
  static Future<SkemaSertifikatListResponse> getSkemaList({
    String? search,
    String? kategori,
    String? jenjang,
    String? bidang,
    String? sort,
    int page = 1,
    int limit = 6,
  }) async {
    try {
      final params = <String>[];
      if (search != null && search.isNotEmpty) params.add('search=$search');
      if (kategori != null && kategori.isNotEmpty)
        params.add('kategori=$kategori');
      if (jenjang != null && jenjang.isNotEmpty) params.add('jenjang=$jenjang');
      if (bidang != null && bidang.isNotEmpty) params.add('bidang=$bidang');
      if (sort != null && sort.isNotEmpty) params.add('sort=$sort');
      params.add('page=$page');
      params.add('limit=$limit');

      final url = '${ApiRoutes.sertifikatSkema}?${params.join('&')}';
      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        return SkemaSertifikatListResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return const SkemaSertifikatListResponse(
        data: [],
        meta: SkemaSertifikatMeta(total: 0, page: 1, lastPage: 1, perPage: 6),
      );
    } on DioException catch (e) {
      debugPrint('🔴 Error fetching skema list: ${e.message}');
      rethrow;
    }
  }

  /// Fetch the list of available bidang values for filter chips.
  /// Called once per screen lifecycle — cached client-side.
  static Future<List<SkemaBidangItem>> getBidangList() async {
    try {
      final response = await _dio.get(ApiRoutes.sertifikatSkemaBidang);
      if (response.statusCode == 200 && response.data != null) {
        return SkemaBidangListResponse.fromJson(
          response.data as Map<String, dynamic>,
        ).data;
      }
      return const <SkemaBidangItem>[];
    } on DioException catch (e) {
      debugPrint('🔴 Error fetching bidang list: ${e.message}');
      return const <SkemaBidangItem>[];
    }
  }

  /// Fetch detail of a single skema sertifikasi by id (includes unit competence + persyaratan).
  static Future<SkemaSertifikatDetailResponse> getSkemaDetail(int id) async {
    try {
      final response = await _dio.get(ApiRoutes.sertifikatSkemaDetail(id));

      if (response.statusCode == 200 && response.data != null) {
        return SkemaSertifikatDetailResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw Exception(
        'Failed to load skema detail (status ${response.statusCode})',
      );
    } on DioException catch (e) {
      debugPrint('🔴 Error fetching skema detail: ${e.message}');
      rethrow;
    }
  }

  /// Fetch list of recommended assessors for a specific skema.
  static Future<List<AsesorDetailItem>> getAsesorBySkema(int skemaId) async {
    try {
      final token = await TokenStorage.instance.getAccessToken();
      final response = await _dio.get(
        ApiRoutes.sertifikatSkemaAsesor(skemaId),
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list
            .map(
              (item) => AsesorDetailItem.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching assessors by skema: $e');
      return [];
    }
  }

  /// Fetch Pra-Asesmen Info for a specific skema.
  static Future<PraAsesmenInfo> getPraAsesmenInfo(
    int skemaId,
    String fallbackTitle,
    String fallbackKode,
  ) async {
    try {
      final token = await TokenStorage.instance.getAccessToken();
      final response = await _dio.get(
        ApiRoutes.praAsesmenSkemaInfo(skemaId),
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['data'] != null) {
        return PraAsesmenInfo.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      return PraAsesmenInfo.fallback(skemaId, fallbackTitle, fallbackKode);
    } catch (e) {
      debugPrint('🔴 Error fetching pra-asesmen info (using fallback): $e');
      return PraAsesmenInfo.fallback(skemaId, fallbackTitle, fallbackKode);
    }
  }

  /// Fetch Pra-Asesmen Kompetensi for a specific skema.
  /// Returns null on hard failure so callers can retry / show error.
  /// Empty unit list is a valid 200 response (skema without detail).
  static Future<PraAsesmenKompetensi?> getPraAsesmenKompetensi(
    int skemaId,
    String fallbackTitle,
  ) async {
    try {
      final response = await _dio.get(
        ApiRoutes.praAsesmenSkemaKompetensi(skemaId),
        options: Options(
          headers: {'Accept': 'application/json'},
        ),
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['data'] != null) {
        final raw = response.data['data'];
        final map = raw is Map<String, dynamic>
            ? raw
            : Map<String, dynamic>.from(raw as Map);
        final parsed = PraAsesmenKompetensi.fromJson(map);
        if (parsed.namaSkema.isEmpty && fallbackTitle.isNotEmpty) {
          return PraAsesmenKompetensi(
            skemaId: parsed.skemaId == 0 ? skemaId : parsed.skemaId,
            namaSkema: fallbackTitle,
            unitKompetensi: parsed.unitKompetensi,
          );
        }
        return parsed;
      }
      debugPrint(
        '🔴 pra-asesmen kompetensi unexpected response for skema $skemaId',
      );
      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching pra-asesmen kompetensi: $e');
      return null;
    }
  }

  /// Submit Pra-Asesmen responses
  static Future<bool> submitPraAsesmen(
    int skemaId,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await TokenStorage.instance.getAccessToken();
      final response = await _dio.post(
        ApiRoutes.praAsesmenSkemaSubmit(skemaId),
        data: body,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('🔴 Error submitting pra-asesmen: $e');
      return false;
    }
  }

  // ============================================================================
  // Private Fallback Data
  // ============================================================================

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
}
