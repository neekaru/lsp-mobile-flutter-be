import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

import '../../services/geojson_manager.dart';

class IndonesiaMap extends StatefulWidget {
  final ValueChanged<String> onIslandSelected;
  final ValueChanged<ProvinceModel>? onProvinceSelected;
  final Map<String, int>? provinceData;
  final bool isAdminDashboard;

  const IndonesiaMap({
    super.key,
    required this.onIslandSelected,
    this.onProvinceSelected,
    this.provinceData,
    this.isAdminDashboard = false,
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
    'IDKT': 4, // Kalimantan Tengah
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
    // Compare by CONTENT, not reference. Reference equality flips true on every
    // parent rebuild -> recreates MapShapeSource -> Syncfusion re-parses async
    // every frame (flicker / intermittent stuck render).
    if (!mapEquals(widget.provinceData, oldWidget.provinceData)) {
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
      await GeoJsonManager.instance
          .initialize()
          .timeout(const Duration(seconds: 30));

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
    } on TimeoutException {
      debugPrint('Map init timed out');
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Peta membutuhkan waktu untuk dimuat. Silakan buka ulang halaman.';
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

  /// Get color based on advisor count according to custom rules:
  /// >= 20: Green (Hijau)
  /// >= 5: Orange (Oranye)
  /// >= 1: Yellow (Kuning)
  /// 0: Red (Merah)
  Color _getColorForCount(int count) {
    if (count >= 20) {
      return const Color(0xFF22C55E); // Hijau (>= 20 Asesor)
    } else if (count >= 5) {
      return const Color(0xFFF97316); // Orange (>= 5 Asesor)
    } else if (count >= 1) {
      return const Color(0xFFEAB308); // Kuning (>= 1 Asesor)
    } else {
      return const Color(0xFFEF4444); // Merah (0 / Gak Ada)
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cachedMapSource = null; // release Syncfusion source + GeoJSON bytes ref
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    final double horizontalPadding = widget.isAdminDashboard ? 0.0 : 16.0;
    final double cardPadding = widget.isAdminDashboard ? 16.0 : 12.0;

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8.0),
        child: Container(
          width: double.infinity,
          decoration: widget.isAdminDashboard
              ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x03000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                )
              : BoxDecoration(
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
          padding: EdgeInsets.all(cardPadding),
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

  /// Map content dengan legend di bawah (membuat peta penuh 100% lebar & lebih besar)
  Widget _buildMapContent() {
    final MapShapeSource? mapSource = _cachedMapSource;

    if (mapSource == null) {
      if (GeoJsonManager.instance.isInitialized && !_isDisposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed && mounted) {
            setState(() {
              _cachedMapSource = GeoJsonManager.instance.createMapSource(
                provinceData: widget.provinceData ?? provinceAdvisors,
                colorMapper: _getColorForCount,
              );
            });
          }
        });
      }
      return _buildLoadingState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Syncfusion Vector Map (100% width, height 230)
        SizedBox(
          height: 230,
          width: double.infinity,
          child: SfMaps(
            layers: [
              MapShapeLayer(
                source: mapSource,
                showDataLabels: false,
                strokeColor: Colors.white,
                strokeWidth: 0.8,
                onSelectionChanged: (int index) {
                  final provinces = GeoJsonManager.instance.provinces;
                  if (index >= 0 && index < provinces.length) {
                    final province = provinces[index];
                    widget.onIslandSelected(province.islandId);
                    widget.onProvinceSelected?.call(province);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Horizontal Legend Row di bagian bawah peta
        _buildHorizontalLegendRow(),
      ],
    );
  }

  Widget _buildHorizontalLegendRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendChip('> 20 Asesor', const Color(0xFF22C55E)),
          _buildLegendChip('5 - 20 Asesor', const Color(0xFFF97316)),
          _buildLegendChip('1 - 5 Asesor', const Color(0xFFEAB308)),
          _buildLegendChip('Gak Ada (0)', const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildLegendChip(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}
