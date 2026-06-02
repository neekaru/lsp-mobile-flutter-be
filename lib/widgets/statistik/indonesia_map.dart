import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

import '../../services/geojson_manager.dart';
import 'indonesia_geojson_optimized.dart';

class IndonesiaMap extends StatefulWidget {
  final ValueChanged<String> onIslandSelected;
  final ValueChanged<ProvinceModel>? onProvinceSelected;
  final Map<String, int>? provinceData;

  const IndonesiaMap({
    super.key,
    required this.onIslandSelected,
    this.onProvinceSelected,
    this.provinceData,
  });

  @override
  State<IndonesiaMap> createState() => _IndonesiaMapState();
}

class _IndonesiaMapState extends State<IndonesiaMap>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  MapShapeSource? _cachedMapSource;
  String? _errorMessage;
  bool _isDisposed = false;

  @override
  bool get wantKeepAlive => true;

  // Realistically mapped advisor counts for all provinces
  // Mapping menggunakan ID dari GeoJSON (format: IDXX)
  final Map<String, int> provinceAdvisors = {
    'IDAC': 12, // Aceh
    'IDSU': 62, // Sumatera Utara
    'IDSB': 25, // Sumatera Barat
    'IDRI': 30, // Riau
    'IDJA': 15, // Jambi
    'IDSS': 45, // Sumatera Selatan
    'IDBE': 8, // Bengkulu
    'IDLA': 35, // Lampung
    'IDBB': 5, // Bangka Belitung
    'IDKR': 18, // Kepulauan Riau
    'IDJK': 200, // Jakarta (Dark Blue)
    'IDJB': 150, // Jawa Barat (Dark Blue)
    'IDJT': 200, // Jawa Tengah (Dark Blue)
    'IDYO': 100, // Yogyakarta (Dark Blue)
    'IDJI': 120, // Jawa Timur (Dark Blue)
    'IDBT': 75, // Banten (Medium Blue)
    'IDBA': 45, // Bali
    'IDNB': 15, // Nusa Tenggara Barat
    'IDNT': 8, // Nusa Tenggara Timur
    'IDKB': 25, // Kalimantan Barat
    'IDKT': 214, // Kalimantan Tengah (Dark Blue)
    'IDKS': 40, // Kalimantan Selatan
    'IDKI': 97, // Kalimantan Timur (Medium Blue)
    'IDKU': 6, // Kalimantan Utara
    'IDSA': 18, // Sulawesi Utara
    'IDST': 12, // Sulawesi Tengah
    'IDSG': 85, // Sulawesi Selatan (Medium Blue)
    'IDSN': 10, // Sulawesi Tenggara
    'IDGO': 5, // Gorontalo
    'IDSR': 4, // Sulawesi Barat
    'IDMA': 6, // Maluku
    'IDMU': 3, // Maluku Utara
    'IDPB': 8, // Papua Barat
    'IDPA': 12, // Papua
  };

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void didUpdateWidget(covariant IndonesiaMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.provinceData != oldWidget.provinceData) {
      if (GeoJsonManager.instance.isInitialized) {
        setState(() {
          _cachedMapSource = GeoJsonManager.instance.createMapSource(
            provinceData: widget.provinceData ?? provinceAdvisors,
            colorMapper: _getColorForCount,
          );
        });
      }
    }
  }

  /// Initialize map dengan async loading dan isolate parsing
  Future<void> _initializeMap() async {
    if (_isDisposed) return;
    
    try {
      // Initialize GeoJsonManager dengan data optimized
      await GeoJsonManager.instance.initialize(indonesiaGeoJsonOptimized);

      // Create MapShapeSource sekali saja (cached)
      final mapSource = GeoJsonManager.instance.createMapSource(
        provinceData: widget.provinceData ?? provinceAdvisors,
        colorMapper: _getColorForCount,
      );

      if (!_isDisposed && mounted) {
        setState(() {
          _cachedMapSource = mapSource;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing map: $e');
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat peta: $e';
        });
      }
    }
  }

  /// Get color based on advisor count
  Color _getColorForCount(int count) {
    if (count > 100) {
      return const Color(0xFF0F4C81); // Dark Blue (> 100 Asesor)
    } else if (count >= 50) {
      return const Color(0xFF3E82B3); // Medium Blue (50 - 100 Asesor)
    } else if (count >= 10) {
      return const Color(0xFF7CB8E6); // Light Blue (10 - 50 Asesor)
    } else {
      return const Color(0xFFBFE0FA); // Very Light Blue (< 10 Asesor)
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    
    // Jika map source hilang tapi sudah pernah initialized, re-create
    if (!_isLoading && _cachedMapSource == null && GeoJsonManager.instance.isInitialized) {
      _cachedMapSource = GeoJsonManager.instance.createMapSource(
        provinceData: widget.provinceData ?? provinceAdvisors,
        colorMapper: _getColorForCount,
      );
    }
    
    return RepaintBoundary(
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map header
            const Text(
              'Penyebaran Asesor di Indonesia',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5F6E7D),
              ),
            ),
            const SizedBox(height: 12),

            // Content: Loading, Error, atau Map
            if (_isLoading)
              _buildLoadingState()
            else if (_errorMessage != null)
              _buildErrorState()
            else
              _buildMapContent(),
          ],
        ),
      ),
    ),
    );
  }

  /// Loading state dengan spinner
  Widget _buildLoadingState() {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F4C81)),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Memuat peta...',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF5F6E7D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Error state
  Widget _buildErrorState() {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFE53E3E),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF5F6E7D),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Map content dengan legend
  Widget _buildMapContent() {
    // Safety check: jika _cachedMapSource null, coba re-create
    if (_cachedMapSource == null) {
      if (GeoJsonManager.instance.isInitialized) {
        _cachedMapSource = GeoJsonManager.instance.createMapSource(
          provinceData: widget.provinceData ?? provinceAdvisors,
          colorMapper: _getColorForCount,
        );
      } else {
        // Jika belum initialized, tampilkan loading
        return _buildLoadingState();
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Syncfusion Vector Map (75% width)
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 180,
            child: SfMaps(
              layers: [
                MapShapeLayer(
                  source: _cachedMapSource!,
                  showDataLabels: false,
                  strokeColor: Colors.white,
                  strokeWidth: 0.8,
                  onSelectionChanged: (int index) {
                    final provinces = GeoJsonManager.instance.provinces;
                    if (index >= 0 && index < provinces.length) {
                      final province = provinces[index];
                      
                      // Callback dengan island_id (untuk backward compatibility)
                      widget.onIslandSelected(province.islandId);
                      
                      // Callback dengan province lengkap (optional, untuk data detail)
                      widget.onProvinceSelected?.call(province);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // 2. Vertical Legend Column (25% width)
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVerticalLegendItem('> 100 Asesor', const Color(0xFF0F4C81)),
              const SizedBox(height: 6),
              _buildVerticalLegendItem('50 - 100 Asesor', const Color(0xFF3E82B3)),
              const SizedBox(height: 6),
              _buildVerticalLegendItem('10 - 50 Asesor', const Color(0xFF7CB8E6)),
              const SizedBox(height: 6),
              _buildVerticalLegendItem('< 10 Asesor', const Color(0xFFBFE0FA)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLegendItem(String label, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5F6E7D),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
