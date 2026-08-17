// ============================================================================
// Sertifikat Summary Models
// ============================================================================

class SertifikatSummary {
  final int totalPemegangSertifikat;
  final int totalSkema;
  final TopSkema? topSkema;
  final SertifikatTrends? trends;
  final String periode;
  final String comparisonPeriod;
  final String tanggalUpdate;

  const SertifikatSummary({
    required this.totalPemegangSertifikat,
    required this.totalSkema,
    this.topSkema,
    this.trends,
    required this.periode,
    required this.comparisonPeriod,
    required this.tanggalUpdate,
  });

  factory SertifikatSummary.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];

    // Check if top_skema has meaningful data
    final topSkemaData = data['top_skema'];
    final hasTopSkema =
        topSkemaData != null &&
        topSkemaData is Map &&
        topSkemaData.isNotEmpty &&
        (topSkemaData['id_skema'] != null || topSkemaData['skema'] != null);

    // Check if trends has meaningful data
    final trendsData = data['trends'];
    final hasTrends =
        trendsData != null && trendsData is Map && trendsData.isNotEmpty;

    return SertifikatSummary(
      totalPemegangSertifikat: data['total_pemegang_sertifikat'] ?? 0,
      totalSkema: data['total_skema'] ?? 0,
      topSkema: hasTopSkema
          ? TopSkema.fromJson(Map<String, dynamic>.from(topSkemaData))
          : null,
      trends: hasTrends
          ? SertifikatTrends.fromJson(Map<String, dynamic>.from(trendsData))
          : null,
      periode: meta['periode'] ?? '',
      comparisonPeriod: meta['comparison_period'] ?? '',
      tanggalUpdate: meta['tanggal_update'] ?? '',
    );
  }

  factory SertifikatSummary.fallback() {
    return const SertifikatSummary(
      totalPemegangSertifikat: 0,
      totalSkema: 0,
      topSkema: null,
      trends: null,
      periode: 'N/A',
      comparisonPeriod: 'N/A',
      tanggalUpdate: '',
    );
  }
}

class TopSkema {
  final int idSkema;
  final String skema;
  final int totalPemegang;

  const TopSkema({
    required this.idSkema,
    required this.skema,
    required this.totalPemegang,
  });

  factory TopSkema.fromJson(Map<String, dynamic> json) {
    return TopSkema(
      idSkema: json['id_skema'] ?? 0,
      skema: json['skema'] ?? '',
      totalPemegang: json['total_pemegang'] ?? 0,
    );
  }

  factory TopSkema.fallback() {
    return const TopSkema(idSkema: 0, skema: 'N/A', totalPemegang: 0);
  }
}

class SertifikatTrends {
  final TrendData pemegangSertifikat;
  final TrendData skema;

  const SertifikatTrends({
    required this.pemegangSertifikat,
    required this.skema,
  });

  factory SertifikatTrends.fromJson(Map<String, dynamic> json) {
    return SertifikatTrends(
      pemegangSertifikat: TrendData.fromJson(json['pemegang_sertifikat'] ?? {}),
      skema: TrendData.fromJson(json['skema'] ?? {}),
    );
  }

  factory SertifikatTrends.fallback() {
    return SertifikatTrends(
      pemegangSertifikat: TrendData.fallback(),
      skema: TrendData.fallback(),
    );
  }
}

class TrendData {
  final double percentage;
  final String direction;
  final String formatted;

  const TrendData({
    required this.percentage,
    required this.direction,
    required this.formatted,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      direction: json['direction'] ?? 'stable',
      formatted: json['formatted'] ?? '+0.0%',
    );
  }

  factory TrendData.fallback() {
    return const TrendData(
      percentage: 0.0,
      direction: 'stable',
      formatted: '+0.0%',
    );
  }
}
