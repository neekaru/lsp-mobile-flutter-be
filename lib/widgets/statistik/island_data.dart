import 'package:flutter/material.dart';

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
}

// Dummy Data representing regional assessment distribution
final Map<String, IslandData> islandDataMap = {
  'sumatera': IslandData(
    id: 'sumatera',
    name: 'Pulau Sumatera',
    assessments: 4850,
    percentage: 18.7,
    baseColor: const Color(0xFF3E82B3),
    competenceRate: 0.81,
    topProvinces: ['Sumatera Utara', 'Riau', 'Sumatera Selatan'],
    provinceAssessments: [2100, 1450, 1300],
  ),
  'jawa': IslandData(
    id: 'jawa',
    name: 'Pulau Jawa',
    assessments: 12850,
    percentage: 49.6,
    baseColor: const Color(0xFF2C6C9C), // High density - deep blue
    competenceRate: 0.86,
    topProvinces: ['DKI Jakarta', 'Jawa Barat', 'Jawa Timur'],
    provinceAssessments: [5120, 4380, 3350],
  ),
  'kalimantan': IslandData(
    id: 'kalimantan',
    name: 'Pulau Kalimantan',
    assessments: 2450,
    percentage: 9.5,
    baseColor: const Color(0xFF559AD4),
    competenceRate: 0.79,
    topProvinces: ['Kalimantan Timur', 'Kalimantan Barat', 'Kalimantan Selatan'],
    provinceAssessments: [1150, 750, 550],
  ),
  'sulawesi': IslandData(
    id: 'sulawesi',
    name: 'Pulau Sulawesi',
    assessments: 3120,
    percentage: 12.1,
    baseColor: const Color(0xFF4FA8E8),
    competenceRate: 0.83,
    topProvinces: ['Sulawesi Selatan', 'Sulawesi Utara', 'Sulawesi Tengah'],
    provinceAssessments: [1620, 850, 650],
  ),
  'bali_nusa': IslandData(
    id: 'bali_nusa',
    name: 'Bali & Nusa Tenggara',
    assessments: 1250,
    percentage: 4.8,
    baseColor: const Color(0xFF7CB8E6),
    competenceRate: 0.85,
    topProvinces: ['Bali', 'Nusa Tenggara Barat', 'Nusa Tenggara Timur'],
    provinceAssessments: [780, 290, 180],
  ),
  'maluku': IslandData(
    id: 'maluku',
    name: 'Kepulauan Maluku',
    assessments: 550,
    percentage: 2.1,
    baseColor: const Color(0xFFA1D0F5),
    competenceRate: 0.77,
    topProvinces: ['Maluku', 'Maluku Utara'],
    provinceAssessments: [350, 200],
  ),
  'papua': IslandData(
    id: 'papua',
    name: 'Pulau Papua',
    assessments: 820,
    percentage: 3.2,
    baseColor: const Color(0xFFBFE0FA),
    competenceRate: 0.80,
    topProvinces: ['Papua', 'Papua Barat', 'Papua Tengah'],
    provinceAssessments: [450, 250, 120],
  ),
};
