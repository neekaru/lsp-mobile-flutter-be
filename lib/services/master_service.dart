import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';
import '../helpers/api_routes.dart';
import '../models/master_models.dart';

// ============================================================================
// Master Service
// ============================================================================

class MasterService {
  static Dio get _dio => ApiClient.dio;

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
}
