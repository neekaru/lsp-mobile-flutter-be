// ============================================================================
// API Routes Constants
// ============================================================================
// Konstanta untuk semua API routes yang digunakan dalam aplikasi

class ApiRoutes {
  // ============================================================================
  // Dashboard Routes (Enhanced)
  // ============================================================================

  static const String dashboardSummary = '/api/dashboard/summary';
  static const String dashboardStatistikOverview =
      '/api/dashboard/statistik-overview';
  static const String dashboardDistribusiSektor =
      '/api/dashboard/distribusi-sektor';
  static const String dashboardAsesorStats = '/api/dashboard/asesor-stats';
  static const String dashboardLspCount = '/api/dashboard/lsp-count';
  static const String dashboardMonthlyAssessments =
      '/api/dashboard/monthly-assessments';
  static const String dashboardAssessmentGraph =
      '/api/dashboard/assesmen-graph';
  static const String dashboardPenyebaranRegional =
      '/api/dashboard/penyebaran-regional';
  static const String dashboardTrends = '/api/dashboard/trends';
  static const String dashboardSertifikatPerSkema =
      '/api/dashboard/sertifikat-per-skema';
  static const String dashboardSertifikatSummary =
      '/api/dashboard/sertifikat-summary';
  static const String dashboardAsesorDistribution =
      '/api/dashboard/asesor-distribution';
  static const String dashboardPenyebaranTuk = '/api/dashboard/penyebaran-tuk';
  static const String dashboardPenyebaranMitra =
      '/api/dashboard/penyebaran-mitra';
  static const String dashboardSebaranSkemaAsesor =
      '/api/dashboard/sebaran-skema-asesor';

  // ============================================================================
  // Jadwal Routes
  // ============================================================================

  static const String jadwalOutOfDate = '/api/jadwal/out-of-date';
  static const String jadwalUpdateStatus = '/api/jadwal/update-status';
  static const String jadwalNotificationsCount = '/api/jadwal/notifications/count';
  static const String jadwalWaiting = '/api/jadwal/waiting';

  // ============================================================================
  // Sertifikat Routes
  // ============================================================================

  static const String sertifikatSearch = '/api/sertifikat/search';

  // ============================================================================
  // Wilayah Routes
  // ============================================================================

  static const String wilayahTukPerKabupaten = '/api/wilayah/tuk-per-kabupaten';

  // ============================================================================
  // Helper Methods untuk build URL dengan query parameters
  // ============================================================================

  /// Build URL dengan period parameter
  static String withPeriod(String route, String period) {
    return '$route?period=$period';
  }

  /// Build URL dengan months parameter
  static String withMonths(String route, int months) {
    return '$route?months=$months';
  }

  /// Build URL dengan limit parameter
  static String withLimit(String route, int limit) {
    return '$route?limit=$limit';
  }

  /// Build URL dengan limit dan include_invalid parameters
  static String withLimitAndIncludeInvalid(
    String route,
    int limit,
    bool includeInvalid,
  ) {
    return '$route?limit=$limit&include_invalid=$includeInvalid';
  }

  /// Build URL dengan provinsi_id parameter
  static String withProvinsiId(String route, int provinsiId) {
    return '$route?provinsi_id=$provinsiId';
  }

  /// Build URL dengan metric dan compare_period parameters
  static String withTrendsParams(
    String route,
    String metric,
    String comparePeriod,
  ) {
    return '$route?metric=$metric&compare_period=$comparePeriod';
  }

  /// Build URL dengan multiple filters untuk monthly assessments
  static String withMonthlyAssessmentsFilters(
    String route, {
    int? months,
    int? provinsiId,
    String? sektor,
    int? idLsp,
    int? idTuk,
  }) {
    final params = <String>[];
    if (months != null) params.add('months=$months');
    if (provinsiId != null) params.add('provinsi_id=$provinsiId');
    if (sektor != null) params.add('sektor=$sektor');
    if (idLsp != null) params.add('id_lsp=$idLsp');
    if (idTuk != null) params.add('id_tuk=$idTuk');

    return params.isEmpty ? route : '$route?${params.join('&')}';
  }

  /// Build URL dengan multiple filters untuk jadwal
  static String withJadwalFilters(
    String route, {
    int? limit,
    String? statusJadwal,
    int? idTuk,
    String? idLsp,
    String? sortBy,
    String? sortOrder,
  }) {
    final params = <String>[];
    if (limit != null) params.add('limit=$limit');
    if (statusJadwal != null) params.add('status_jadwal=$statusJadwal');
    if (idTuk != null) params.add('id_tuk=$idTuk');
    if (idLsp != null) params.add('id_lsp=$idLsp');
    if (sortBy != null) params.add('sort_by=$sortBy');
    if (sortOrder != null) params.add('sort_order=$sortOrder');

    return params.isEmpty ? route : '$route?${params.join('&')}';
  }
}

// ============================================================================
// API Query Parameters Enums
// ============================================================================

/// Enum untuk period parameter
enum PeriodRange {
  currentMonth('current_month'),
  currentYear('current_year');

  final String value;
  const PeriodRange(this.value);
}

/// Enum untuk months parameter pada monthly assessments
enum MonthsRange {
  threeMonths(3),
  fourMonths(4),
  sixMonths(6),
  twelveMonths(12),
  thirtySixMonths(36);

  final int value;
  const MonthsRange(this.value);
}

/// Enum untuk limit parameter
enum DataLimit {
  one(1),
  three(3),
  five(5),
  ten(10),
  hundred(100),
  thousand(1000);

  final int value;
  const DataLimit(this.value);
}

/// Enum untuk metric parameter pada trends
enum TrendMetric {
  all('all'),
  asesmen('asesmen'),
  asesor('asesor'),
  pemegangSertifikat('pemegang_sertifikat'),
  tuk('tuk');

  final String value;
  const TrendMetric(this.value);
}

/// Enum untuk compare_period parameter pada trends
enum ComparePeriod {
  previousMonth('previous_month'),
  previousYear('previous_year');

  final String value;
  const ComparePeriod(this.value);
}
