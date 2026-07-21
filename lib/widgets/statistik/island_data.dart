import 'package:flutter/material.dart';

import '../../models/dashboard_models.dart';

// Model to represent statistical data for each island group
class IslandData {
  final String id;
  final String name;
  final int assessments;
  final double percentage;
  final Color baseColor;
  final List<String> topProvinces;
  final List<int> provinceAssessments;
  final double competenceRate; // e.g. 0.85 for 85%

  IslandData({
    required this.id,
    required this.name,
    required this.assessments,
    required this.percentage,
    required this.baseColor,
    required this.topProvinces,
    required this.provinceAssessments,
    required this.competenceRate,
  });

  /// Map API regional distribution → UI model (no dummy numbers).
  factory IslandData.fromRegional(RegionalDistribution r, {Color? color}) {
    final sorted = List<TopProvinsiDetail>.from(r.topProvinces)
      ..sort((a, b) => b.count.compareTo(a.count));
    final rate = r.tingkatKompetensi > 1
        ? r.tingkatKompetensi / 100.0
        : r.tingkatKompetensi;
    return IslandData(
      id: r.islandId,
      name: r.islandName,
      assessments: r.totalAsesi,
      percentage: r.percentage,
      baseColor: color ?? _colorForIsland(r.islandId),
      topProvinces: sorted.map((p) => p.name).toList(),
      provinceAssessments: sorted.map((p) => p.count).toList(),
      competenceRate: rate.clamp(0.0, 1.0),
    );
  }

  static Color _colorForIsland(String id) {
    switch (id.toLowerCase()) {
      case 'jawa':
        return const Color(0xFF2C6C9C);
      case 'sumatera':
        return const Color(0xFF3E82B3);
      case 'kalimantan':
        return const Color(0xFF559AD4);
      case 'sulawesi':
        return const Color(0xFF4FA8E8);
      case 'bali_nusa_tenggara':
      case 'bali_nusa':
      case 'bali':
        return const Color(0xFF7CB8E6);
      case 'maluku_papua':
      case 'maluku':
      case 'papua':
        return const Color(0xFFA1D0F5);
      default:
        return const Color(0xFF3E82B3);
    }
  }
}

/// Build island map from API list. Empty if API returns nothing.
Map<String, IslandData> islandDataFromApi(List<RegionalDistribution> rows) {
  final map = <String, IslandData>{};
  for (final r in rows) {
    if (r.islandId.isEmpty) continue;
    map[r.islandId] = IslandData.fromRegional(r);
  }
  return map;
}

/// No static dummy regional stats — load via [islandDataFromApi] / API only.
final Map<String, IslandData> islandDataMap = {};
