import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

/// Singleton service untuk manage GeoJSON data dengan caching dan isolate parsing
/// untuk menghindari blocking UI thread dan re-render yang tidak perlu.
class GeoJsonManager {
  // Singleton instance
  static GeoJsonManager? _instance;
  static GeoJsonManager get instance => _instance ??= GeoJsonManager._internal();

  GeoJsonManager._internal();

  // Cache objects
  Uint8List? _geoJsonBytes;
  List<ProvinceModel>? _provinces;
  bool _isInitialized = false;
  bool _isInitializing = false;

  /// Check apakah sudah initialized
  bool get isInitialized => _isInitialized;

  /// Initialize GeoJSON data dengan parsing di isolate (background thread)
  /// untuk menghindari blocking UI thread
  Future<void> initialize(String geoJsonString) async {
    // Jika sudah initialized, skip
    if (_isInitialized) return;

    // Jika sedang initializing, tunggu sampai selesai
    if (_isInitializing) {
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return;
    }

    _isInitializing = true;

    try {
      // Parse GeoJSON di isolate (background thread)
      final result = await compute(_parseGeoJson, geoJsonString);

      _geoJsonBytes = result.bytes;
      _provinces = result.provinces;
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing GeoJSON: $e');
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  /// Get cached GeoJSON bytes
  /// Throws error jika belum initialized
  Uint8List get geoJsonBytes {
    if (!_isInitialized) {
      throw StateError('GeoJsonManager not initialized. Call initialize() first.');
    }
    return _geoJsonBytes!;
  }

  /// Get cached provinces list
  /// Throws error jika belum initialized
  List<ProvinceModel> get provinces {
    if (!_isInitialized) {
      throw StateError('GeoJsonManager not initialized. Call initialize() first.');
    }
    return _provinces!;
  }

  /// Create MapShapeSource dengan custom color mapping
  /// Reusable untuk menghindari re-create di setiap rebuild
  MapShapeSource createMapSource({
    required Map<String, int> provinceData,
    required Color Function(int) colorMapper,
  }) {
    if (!_isInitialized) {
      throw StateError('GeoJsonManager not initialized. Call initialize() first.');
    }

    // Selalu create fresh MapShapeSource untuk menghindari issue dengan caching
    // Syncfusion Maps memerlukan fresh instance untuk render yang konsisten
    return MapShapeSource.memory(
      _geoJsonBytes!,
      shapeDataField: 'id',
      dataCount: _provinces!.length,
      primaryValueMapper: (int index) {
        if (index < 0 || index >= _provinces!.length) return null;
        return _provinces![index].id;
      },
      shapeColorValueMapper: (int index) {
        if (index < 0 || index >= _provinces!.length) {
          return const Color(0xFFBFE0FA); // Default color
        }
        final province = _provinces![index];
        final count = provinceData[province.id] ?? 0;
        return colorMapper(count);
      },
    );
  }

  /// Reset cache (untuk testing atau reload)
  void reset() {
    _geoJsonBytes = null;
    _provinces = null;
    _isInitialized = false;
    _isInitializing = false;
  }
}

/// Model untuk province data
class ProvinceModel {
  final String id;
  final String name;
  final String islandId;

  ProvinceModel({
    required this.id,
    required this.name,
    required this.islandId,
  });

  @override
  String toString() => 'ProvinceModel(id: $id, name: $name, islandId: $islandId)';
}

/// Result dari parsing GeoJSON di isolate
class _ParseResult {
  final Uint8List bytes;
  final List<ProvinceModel> provinces;

  _ParseResult({
    required this.bytes,
    required this.provinces,
  });
}

/// Function yang dijalankan di isolate untuk parsing GeoJSON
/// Ini akan run di background thread sehingga tidak blocking UI
_ParseResult _parseGeoJson(String jsonString) {
  // Parse JSON
  final geoJson = json.decode(jsonString) as Map<String, dynamic>;

  // Convert ke bytes untuk Syncfusion Maps
  final bytes = Uint8List.fromList(utf8.encode(jsonString));

  // Extract provinces dari features
  final features = geoJson['features'] as List<dynamic>;
  final provinces = features.map((feature) {
    final props = feature['properties'] as Map<String, dynamic>;
    final id = props['id'] as String;
    final name = props['name'] as String;

    // Infer island_id dari province id jika tidak ada
    final islandId = _inferIslandId(id);

    return ProvinceModel(
      id: id,
      name: name,
      islandId: islandId,
    );
  }).toList();

  return _ParseResult(
    bytes: bytes,
    provinces: provinces,
  );
}

/// Mapping province ID ke island ID
/// Berdasarkan data dari indonesia_geojson.dart yang sudah ada
String _inferIslandId(String provinceId) {
  // Mapping berdasarkan province ID
  const provinceToIsland = {
    // Sumatera
    'IDAC': 'sumatera',
    'IDSU': 'sumatera',
    'IDSB': 'sumatera',
    'IDRI': 'sumatera',
    'IDJA': 'sumatera',
    'IDSS': 'sumatera',
    'IDBE': 'sumatera',
    'IDLA': 'sumatera',
    'IDBB': 'sumatera',
    'IDKR': 'sumatera',

    // Jawa
    'IDBT': 'jawa',
    'IDJK': 'jawa',
    'IDJB': 'jawa',
    'IDJT': 'jawa',
    'IDYO': 'jawa',
    'IDJI': 'jawa',

    // Kalimantan
    'IDKB': 'kalimantan',
    'IDKT': 'kalimantan',
    'IDKS': 'kalimantan',
    'IDKI': 'kalimantan',
    'IDKU': 'kalimantan',

    // Sulawesi
    'IDSA': 'sulawesi',
    'IDST': 'sulawesi',
    'IDSG': 'sulawesi',
    'IDSN': 'sulawesi',
    'IDGO': 'sulawesi',
    'IDSR': 'sulawesi',

    // Bali & Nusa Tenggara
    'IDBA': 'bali_nusa_tenggara',
    'IDNB': 'bali_nusa_tenggara',
    'IDNT': 'bali_nusa_tenggara',

    // Maluku
    'IDMA': 'maluku',
    'IDMU': 'maluku',

    // Papua
    'IDPA': 'papua',
    'IDPB': 'papua',
    'IDIT': 'papua',
  };

  return provinceToIsland[provinceId] ?? 'unknown';
}
