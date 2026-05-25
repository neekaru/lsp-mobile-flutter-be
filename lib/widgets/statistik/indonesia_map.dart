import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

import 'indonesia_geojson.dart';

class IndonesiaMap extends StatefulWidget {
  final ValueChanged<String> onIslandSelected;

  const IndonesiaMap({
    super.key,
    required this.onIslandSelected,
  });

  @override
  State<IndonesiaMap> createState() => _IndonesiaMapState();
}

class _IndonesiaMapState extends State<IndonesiaMap> {
  late List<ProvinceModel> _provincesList;

  // Realistically mapped advisor counts for all 32 provinces to reflect density exactly like the screenshots:
  // e.g. Kalimantan Tengah (Sampit) has 214, Yogyakarta has 100, Semarang has 200, Balikpapan (Kaltim) has 97, etc.
  final Map<String, int> provinceAdvisors = {
    'aceh': 12,
    'sumatera_utara': 62, // Medium Blue
    'sumatera_barat': 25,
    'riau': 30,
    'jambi': 15,
    'sumatera_selatan': 45,
    'bengkulu': 8,
    'lampung': 35,
    'kepulauan_bangka_belitung': 5,
    'kepulauan_riau': 18,
    'dki_jakarta': 200, // Dark Blue
    'jawa_barat': 150, // Dark Blue
    'jawa_tengah': 200, // Semarang / Jawa Tengah (Dark Blue)
    'di_yogyakarta': 100, // Yogyakarta (Dark Blue)
    'jawa_timur': 120, // Dark Blue
    'banten': 75, // Medium Blue
    'bali': 45,
    'nusa_tenggara_barat': 15,
    'nusa_tenggara_timur': 8,
    'kalimantan_barat': 25,
    'kalimantan_tengah': 214, // Sampit / Kalteng (Dark Blue)
    'kalimantan_selatan': 40,
    'kalimantan_timur': 97, // Balikpapan / Kaltim (Medium Blue)
    'kalimantan_utara': 6,
    'sulawesi_utara': 18,
    'sulawesi_tengah': 12,
    'sulawesi_selatan': 85, // Medium Blue
    'sulawesi_tenggara': 10,
    'gorontalo': 5,
    'sulawesi_barat': 4,
    'maluku': 6,
    'maluku_utara': 3,
    'papua_barat': 8,
    'papua': 12,
  };

  @override
  void initState() {
    super.initState();
    // Parse GeoJSON dynamically to generate province lists and guarantee 100% size synchronicity
    final Map<String, dynamic> geoJson = json.decode(indonesiaGeoJson);
    final List<dynamic> features = geoJson['features'];
    _provincesList = features.map((f) {
      final props = f['properties'] as Map<String, dynamic>;
      return ProvinceModel(
        id: props['id'] as String,
        name: props['name'] as String,
        islandId: props['island_id'] as String,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Standard MapShapeSource mapped to individual province IDs
    final MapShapeSource mapSource = MapShapeSource.memory(
      Uint8List.fromList(utf8.encode(indonesiaGeoJson)),
      shapeDataField: 'id',
      dataCount: _provincesList.length,
      primaryValueMapper: (int index) => _provincesList[index].id,
      shapeColorValueMapper: (int index) {
        final province = _provincesList[index];
        final count = provinceAdvisors[province.id] ?? 0;

        // Custom HSL density mapping corresponding to the screenshot legend:
        if (count > 100) {
          return const Color(0xFF0F4C81); // Dark Blue (> 100 Asesor)
        } else if (count >= 50) {
          return const Color(0xFF3E82B3); // Medium Blue (50 - 100 Asesor)
        } else if (count >= 10) {
          return const Color(0xFF7CB8E6); // Light Blue (10 - 50 Asesor)
        } else {
          return const Color(0xFFBFE0FA); // Very Light Blue (< 10 Asesor)
        }
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8), // Subtle rounded corners like the screenshots
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

            // Map and Legend Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Syncfusion Vektor Map (75% width)
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 180,
                    child: SfMaps(
                      layers: [
                        MapShapeLayer(
                          source: mapSource,
                          showDataLabels: false,
                          strokeColor: Colors.white,
                          strokeWidth: 0.8,
                          onSelectionChanged: (int index) {
                            final province = _provincesList[index];
                            widget.onIslandSelected(province.islandId);
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
            ),
          ],
        ),
      ),
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

class ProvinceModel {
  final String id;
  final String name;
  final String islandId;

  ProvinceModel({
    required this.id,
    required this.name,
    required this.islandId,
  });
}
