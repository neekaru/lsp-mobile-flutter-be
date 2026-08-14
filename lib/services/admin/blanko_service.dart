import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/blanko_models.dart';
import '../../utils/api_routes.dart';
import '../api_client.dart';

class BlankoService {
  static Dio get _dio => ApiClient.dio;

  /// Fetch list of blanko submissions from Admin API
  /// GET /api/admin/blanko?page=1&size=10&search=&status=
  static Future<BlankoListResponse> getBlankoList({
    int page = 1,
    int size = 10,
    String? search,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
      };

      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
        queryParams['q'] = search.trim();
      }

      if (status != null &&
          status.trim().isNotEmpty &&
          status.trim().toLowerCase() != 'semua') {
        queryParams['status'] = status.trim().toLowerCase();
      }

      final response = await _dio.get(
        ApiRoutes.adminBlanko,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return BlankoListResponse.fromJson(response.data);
      }

      return BlankoListResponse.empty();
    } on DioException catch (e) {
      debugPrint('🔴 [BlankoService] DioException getBlankoList: ${e.message}');
      return BlankoListResponse.empty();
    } catch (e) {
      debugPrint('🔴 [BlankoService] Error getBlankoList: $e');
      return BlankoListResponse.empty();
    }
  }

  /// Fetch detail of a specific blanko submission by ID
  /// GET /api/admin/blanko/:id
  static Future<BlankoDetailModel?> getBlankoDetail(int id) async {
    try {
      final response = await _dio.get(ApiRoutes.adminBlankoDetail(id));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && data is Map<String, dynamic>) {
          return BlankoDetailModel.fromJson(data);
        }
      }

      return null;
    } on DioException catch (e) {
      debugPrint('🔴 [BlankoService] DioException getBlankoDetail($id): ${e.message}');
      return null;
    } catch (e) {
      debugPrint('🔴 [BlankoService] Error getBlankoDetail($id): $e');
      return null;
    }
  }
}
