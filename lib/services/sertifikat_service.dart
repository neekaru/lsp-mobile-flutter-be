import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';
import '../helpers/api_routes.dart';
import '../models/sertifikat_models.dart';

// ============================================================================
// Sertifikat Service
// ============================================================================

class SertifikatService {
  static Dio get _dio => ApiClient.dio;

  /// Validate Certificate by No. Sertifikat or No. Registrasi
  static Future<SertifikatValidationResult> validateSertifikat(String noDokumen) async {
    try {
      final response = await _dio.post(
        ApiRoutes.sertifikatValidate,
        data: {'no_dokumen': noDokumen},
      );

      if (response.data != null) {
        return SertifikatValidationResult.fromJson(response.data);
      }
      return const SertifikatValidationResult(valid: false, message: 'Format response tidak valid.');
    } on DioException catch (e) {
      debugPrint('🔴 Error validating certificate: $e');
      if (e.response != null && e.response!.data != null && e.response!.data is Map) {
        return SertifikatValidationResult.fromJson(e.response!.data);
      }
      return SertifikatValidationResult(
        valid: false,
        message: e.response?.data?['message'] ?? e.message ?? 'Terjadi kesalahan pada server.',
      );
    } catch (e) {
      debugPrint('🔴 Error validating certificate: $e');
      return SertifikatValidationResult(valid: false, message: 'Terjadi kesalahan: ${e.toString()}');
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
      String url = ApiRoutes.withLimit(ApiRoutes.dashboardSertifikatPerSkema, limit);
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
      if (kategori != null && kategori.isNotEmpty) params.add('kategori=$kategori');
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
  // Private Fallback Data
  // ============================================================================

  static SertifikatApiResponse _getFallbackSertifikatResponse() {
    return const SertifikatApiResponse(
      data: [],
      meta: SertifikatMeta(totalSkema: 0, totalPemegangSertifikat: 0, limit: 10),
    );
  }
}
