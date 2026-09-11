import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api_client.dart';
import '../../utils/api_routes.dart';
import '../../models/talenta_models.dart';

class TalentaService {
  static Dio get _dio => ApiClient.dio;

  /// Fetch talents / certificate holders with optional location, skema, and query filters.
  static Future<TalentaResponse> getTalenta({
    double? lat,
    double? lng,
    double? radiusKm,
    String? kabupatenId,
    String? provinsiId,
    int? skemaId,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (lat != null) queryParams['lat'] = lat;
      if (lng != null) queryParams['lng'] = lng;
      if (radiusKm != null && radiusKm > 0) queryParams['radius_km'] = radiusKm;
      if (kabupatenId != null && kabupatenId.isNotEmpty) {
        queryParams['kabupaten_id'] = kabupatenId;
      }
      if (provinsiId != null && provinsiId.isNotEmpty) {
        queryParams['provinsi_id'] = provinsiId;
      }
      if (skemaId != null && skemaId > 0) {
        queryParams['skema_id'] = skemaId;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['q'] = search.trim();
      }

      final response = await _dio.get(
        ApiRoutes.talenta,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return TalentaResponse.fromJson(response.data as Map<String, dynamic>);
      }
      return TalentaResponse.empty;
    } on DioException catch (e) {
      debugPrint('🔴 Error fetching talenta: $e');
      rethrow;
    } catch (e) {
      debugPrint('🔴 Error fetching talenta: $e');
      return TalentaResponse.empty;
    }
  }
}
