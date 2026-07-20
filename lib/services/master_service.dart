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

  // In-memory cache — avoids redundant network round-trips
  static List<MasterSkema>? _skemaCache;
  static final Map<int, List<MasterJadwal>> _jadwalCache = {};
  static List<MasterSumberAnggaran>? _sumberAnggaranCache;
  static final Map<String, List<MasterPemberiAnggaran>> _pemberiAnggaranCache = {};
  static List<MasterPendidikan>? _pendidikanCache;
  static List<MasterPekerjaan>? _pekerjaanCache;

  /// Fetch list of Provinsi
  static Future<List<MasterItem>> getProvinsiList() async {
    try {
      final response = await _dio.get(ApiRoutes.masterProvinsi);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return List<MasterItem>.generate(
          data.length,
          (i) => MasterItem.fromJson(data[i] as Map<String, dynamic>),
        );
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
        return List<MasterItem>.generate(
          data.length,
          (i) => MasterItem.fromJson(data[i] as Map<String, dynamic>),
        );
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
        return List<MasterItem>.generate(
          data.length,
          (i) => MasterItem.fromJson(data[i] as Map<String, dynamic>),
        );
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching kecamatan: $e');
      return [];
    }
  }

  /// Fetch list of Master Skema (cached in-memory)
  static Future<List<MasterSkema>> getMasterSkemaList() async {
    if (_skemaCache != null) return _skemaCache!;
    try {
      final response = await _dio.get(ApiRoutes.masterSkema);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        _skemaCache = List<MasterSkema>.generate(
          data.length,
          (i) => MasterSkema.fromJson(data[i] as Map<String, dynamic>),
        );
        return _skemaCache!;
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching master skema: $e');
      return [];
    }
  }

  /// Fetch list of Master Jadwal by skema ID (cached in-memory)
  static Future<List<MasterJadwal>> getMasterJadwalList(int idSkema) async {
    if (_jadwalCache.containsKey(idSkema)) return _jadwalCache[idSkema]!;
    try {
      final response = await _dio.get(
        ApiRoutes.masterJadwal,
        queryParameters: {'id_skema': idSkema},
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        _jadwalCache[idSkema] = List<MasterJadwal>.generate(
          data.length,
          (i) => MasterJadwal.fromJson(data[i] as Map<String, dynamic>),
        );
        return _jadwalCache[idSkema]!;
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching master jadwal: $e');
      return [];
    }
  }

  /// Fetch list of Sumber Anggaran (with cross-id pemberi_ids)
  static Future<List<MasterSumberAnggaran>> getMasterSumberAnggaranList() async {
    if (_sumberAnggaranCache != null) return _sumberAnggaranCache!;
    try {
      final response = await _dio.get(ApiRoutes.masterSumberAnggaran);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        _sumberAnggaranCache = List<MasterSumberAnggaran>.generate(
          data.length,
          (i) => MasterSumberAnggaran.fromJson(data[i] as Map<String, dynamic>),
        );
        return _sumberAnggaranCache!;
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching master sumber anggaran: $e');
      return [];
    }
  }

  /// Fetch list of Pemberi Anggaran.
  /// Pass [idSumberAnggaran] to filter by cross-id (pairs used with that sumber).
  static Future<List<MasterPemberiAnggaran>> getMasterPemberiAnggaranList({
    int? idSumberAnggaran,
  }) async {
    final cacheKey = idSumberAnggaran?.toString() ?? 'all';
    if (_pemberiAnggaranCache.containsKey(cacheKey)) {
      return _pemberiAnggaranCache[cacheKey]!;
    }
    try {
      final response = await _dio.get(
        ApiRoutes.masterPemberiAnggaran,
        queryParameters: idSumberAnggaran != null
            ? {'id_sumber_anggaran': idSumberAnggaran}
            : null,
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        _pemberiAnggaranCache[cacheKey] = List<MasterPemberiAnggaran>.generate(
          data.length,
          (i) => MasterPemberiAnggaran.fromJson(data[i] as Map<String, dynamic>),
        );
        return _pemberiAnggaranCache[cacheKey]!;
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching master pemberi anggaran: $e');
      return [];
    }
  }

  /// Fetch master pendidikan (cached)
  static Future<List<MasterPendidikan>> getMasterPendidikanList() async {
    if (_pendidikanCache != null) return _pendidikanCache!;
    try {
      final response = await _dio.get(ApiRoutes.masterPendidikan);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        _pendidikanCache = List<MasterPendidikan>.generate(
          data.length,
          (i) => MasterPendidikan.fromJson(data[i] as Map<String, dynamic>),
        );
        return _pendidikanCache!;
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching master pendidikan: $e');
      return [];
    }
  }

  /// Fetch master pekerjaan (cached)
  static Future<List<MasterPekerjaan>> getMasterPekerjaanList() async {
    if (_pekerjaanCache != null) return _pekerjaanCache!;
    try {
      final response = await _dio.get(ApiRoutes.masterPekerjaan);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        _pekerjaanCache = List<MasterPekerjaan>.generate(
          data.length,
          (i) => MasterPekerjaan.fromJson(data[i] as Map<String, dynamic>),
        );
        return _pekerjaanCache!;
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching master pekerjaan: $e');
      return [];
    }
  }

  /// Clear all cached master data (call on logout or pull-to-refresh)
  static void clearCache() {
    _skemaCache = null;
    _jadwalCache.clear();
    _sumberAnggaranCache = null;
    _pemberiAnggaranCache.clear();
    _pendidikanCache = null;
    _pekerjaanCache = null;
  }
}
