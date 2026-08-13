import 'package:dio/dio.dart';
import '../../models/admin_laporan_models.dart';
import '../api_client.dart';

class LaporanService {
  final Dio _dio = ApiClient.dio;

  // GET /api/admin/laporan - List reports, filtered/paginated at the server.
  // status: "Belum Lengkap" | "Lengkap" | "Draft" | "Terkonfirmasi" (omit for all)
  Future<AdminLaporanListResponse> getLaporanList({
    String? status,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/admin/laporan',
        queryParameters: {
          if (status != null && status.isNotEmpty) 'status': status,
          if (search != null && search.isNotEmpty) 'search': search,
          'limit': limit,
          'offset': offset,
        },
      );
      return AdminLaporanListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET /api/admin/laporan/:id - Get report detail
  Future<AdminLaporanDetailResponse> getLaporanDetail(int id) async {
    try {
      final response = await _dio.get('/api/admin/laporan/$id');
      return AdminLaporanDetailResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST /api/admin/laporan/:id/approve - Approve report
  Future<AdminLaporanActionResponse> approveLaporan(
    int id, {
    String? catatan,
  }) async {
    try {
      final response = await _dio.post(
        '/api/admin/laporan/$id/approve',
        data: AdminLaporanApproveRequest(catatan: catatan).toJson(),
      );
      return AdminLaporanActionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST /api/admin/laporan/:id/reject - Reject report
  Future<AdminLaporanActionResponse> rejectLaporan(
    int id, {
    required String alasan,
  }) async {
    try {
      final response = await _dio.post(
        '/api/admin/laporan/$id/reject',
        data: AdminLaporanRejectRequest(alasan: alasan).toJson(),
      );
      return AdminLaporanActionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'];
      }
      return 'Terjadi kesalahan: ${e.response!.statusCode}';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout, silakan coba lagi';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server';
    }
    return 'Terjadi kesalahan: ${e.message}';
  }
}
