import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Future<void>? _initFuture;

  /// Check apakah sudah initialized
  bool get isInitialized => _isInitialized;

  /// Initialize GeoJSON data dari asset dengan parsing di isolate (background thread)
  /// untuk menghindari blocking UI thread.
  Future<void> initialize() {
    if (_isInitialized) return Future.value();
    return _initFuture ??= _runInitialize();
  }

  Future<void> _runInitialize() async {
    try {
      // Load raw bytes directly — avoids decode-then-re-encode cycle
      final byteData = await rootBundle.load('assets/indonesia.geojson');
      _geoJsonBytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

      // Parse JSON in background isolate — only extract provinces, not bytes
      final jsonString = utf8.decode(_geoJsonBytes!);
      _provinces = await compute(_parseProvinces, jsonString);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing GeoJSON: $e');
      _initFuture = null;
      rethrow;
    }
  }

  @Deprecated('Use initialize() instead - GeoJSON now loaded from asset')
  Future<void> initializeWithString(String geoJsonString) {
    if (_isInitialized) return Future.value();
    return _initFuture ??= _runInitializeWithString(geoJsonString);
  }

  Future<void> _runInitializeWithString(String geoJsonString) async {
    try {
      _geoJsonBytes = Uint8List.fromList(utf8.encode(geoJsonString));
      _provinces = await compute(_parseProvinces, geoJsonString);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing GeoJSON: $e');
      _initFuture = null;
      rethrow;
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
        if (index < 0 || index >= _provinces!.length) return '';
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
    _initFuture = null;
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

/// Function yang dijalankan di isolate untuk parsing GeoJSON
/// Hanya extract provinces — bytes sudah di-set di main thread
List<ProvinceModel> _parseProvinces(String jsonString) {
  final geoJson = json.decode(jsonString) as Map<String, dynamic>;
  final features = geoJson['features'] as List<dynamic>;
  return features.map<ProvinceModel>((feature) {
    final props = feature['properties'] as Map<String, dynamic>;
    final id = props['id'] as String;
    final name = props['name'] as String;
    final islandId = _inferIslandId(id);
    return ProvinceModel(id: id, name: name, islandId: islandId);
  }).toList();
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
