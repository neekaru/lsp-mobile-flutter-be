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
  static const String jadwalBaru = '/api/jadwal/baru';
  static const String jadwalActive = '/api/jadwal/active';
  static const String jadwalCompleted = '/api/jadwal/completed';
  static const String jadwalUpdateStatus = '/api/jadwal/update-status';
  static const String jadwalUpdateStatusApply = '/api/jadwal/update-status/apply';
  static const String jadwalNotificationsCount =
      '/api/jadwal/notifications/count';
  static const String jadwalWaiting = '/api/jadwal/waiting';
  static const String jadwalDraft = '/api/jadwal/draft';
  static String jadwalAsesi(int jadwalId) => '/api/jadwal/$jadwalId/asesi';
  static String jadwalAsesorDetail(int jadwalId) =>
      '/api/jadwal/$jadwalId/asesor-detail';

  // ============================================================================
  // Sertifikat Routes
  // ============================================================================

  static const String sertifikatSearch = '/api/sertifikat/search';
  static const String sertifikatValidate = '/api/sertifikat/validate';

  // Skema Sertifikasi (protected, role=asesi)
  static const String sertifikatSkema = '/api/sertifikat/skema';
  static const String sertifikatSkemaBidang = '/api/sertifikat/skema/bidang';
  static String sertifikatSkemaDetail(int id) => '/api/sertifikat/skema/$id';
  static String sertifikatSkemaAsesor(int skemaId) =>
      '/api/sertifikat/skema/$skemaId/asesor';

  // ============================================================================
  // Pra-Asesmen Routes
  // ============================================================================

  static String praAsesmenSkemaInfo(int skemaId) =>
      '/api/pra-asesmen/skema/$skemaId/info';
  static String praAsesmenSkemaKompetensi(int skemaId) =>
      '/api/pra-asesmen/skema/$skemaId/kompetensi';
  static String praAsesmenSkemaSubmit(int skemaId) =>
      '/api/pra-asesmen/skema/$skemaId/submit';

  // ============================================================================
  // Sertifikasi Routes
  // ============================================================================

  static const String sertifikasiDaftar = '/api/sertifikasi/daftar';
  static const String sertifikasiStatus = '/api/sertifikasi/status';
  static String sertifikasiPortofolio(int sertifikasiId) =>
      '/api/sertifikasi/$sertifikasiId/portofolio';
  static String sertifikasiPortofolioUpload(int sertifikasiId) =>
      '/api/sertifikasi/$sertifikasiId/portofolio/upload';

  // ============================================================================
  // Auth Routes
  // ============================================================================

  static const String authLogin = '/api/auth/login';
  static const String authCurrent = '/api/auth/current';
  static const String authLogout = '/api/auth/logout';
  static const String authRefresh = '/api/auth/refresh';

  // ============================================================================
  // Notifications Routes
  // ============================================================================

  static const String notificationsRegister = '/api/notifications/register';

  // ============================================================================
  // Asesi Routes
  // ============================================================================

  static const String asesiDashboard = '/api/asesi/dashboard';
  static const String asesiInstansi = '/api/asesi/instansi';
  static const String asesiSertifikat = '/api/asesi/sertifikat';
  static const String asesiJadwal = '/api/asesi/jadwal';
  static String asesiSertifikatDetail(int id) => '/api/asesi/sertifikat/$id';
  static String asesiSertifikatUploadTtd(int id) =>
      '/api/asesi/sertifikat/$id/upload-ttd';
  static String asesiSertifikatDownload(int id) =>
      '/api/asesi/sertifikat/$id/download';

  // ============================================================================
  // Asesor Routes
  // ============================================================================

  static const String asesorDashboard = '/api/asesor/dashboard';
  static const String asesorJadwal = '/api/asesor/jadwal';
  static const String asesorLaporan = '/api/asesor/laporan';
  static const String asesorLaporanUploadLampiran =
      '/api/asesor/laporan/upload-lampiran';
  static const String asesorSkemaTuk = '/api/asesor/skema-tuk';
  static const String asesorProfile = '/api/asesor/profile';
  static const String asesorHonor = '/api/asesor/honor';
  static const String asesorTiket = '/api/asesor/tiket';
  static String asesorLaporanDetail(int id) => '/api/asesor/laporan/$id';
  static String asesorJadwalPeserta(int jadwalId) =>
      '/api/asesor/jadwal/$jadwalId/peserta';
  static String asesorJadwalPesertaDetail(int jadwalId, int pesertaId) =>
      '/api/asesor/jadwal/$jadwalId/peserta/$pesertaId';
  static String asesorJadwalDetail(int jadwalId) =>
      '/api/asesor/jadwal/$jadwalId/detail';
  static String asesorJadwalSuratTugas(int jadwalId) =>
      '/api/asesor/jadwal/$jadwalId/surat-tugas';
  static String asesorTiketDetail(int id) => '/api/asesor/tiket/$id';
  static String asesorTiketReply(int id) => '/api/asesor/tiket/$id/reply';

  // ============================================================================
  // Admin Tiket Routes
  // ============================================================================

  static const String adminTiket = '/api/admin/tiket';
  static String adminTiketDetail(int id) => '/api/admin/tiket/$id';
  static String adminTiketReply(int id) => '/api/admin/tiket/$id/reply';
  static String adminTiketStatus(int id) => '/api/admin/tiket/$id/status';

  // ============================================================================
  // Pengumuman Routes
  // ============================================================================

  static const String pengumuman = '/api/pengumuman';
  static const String adminPengumuman = '/api/admin/pengumuman';
  static String adminPengumumanDetail(int id) => '/api/admin/pengumuman/$id';

  // ============================================================================
  // Session Routes
  // ============================================================================

  static const String sessions = '/api/sessions';

  // ============================================================================
  // Berita Routes
  // ============================================================================

  static const String berita = '/api/berita';
  static String beritaDetail(int id) => '/api/berita/$id';

  // ============================================================================
  // Health Routes
  // ============================================================================

  static const String health = '/api/health';
  static const String ready = '/api/ready';

  // ============================================================================
  // Wilayah/Master Routes
  // ============================================================================

  static const String wilayahTukPerKabupaten = '/api/wilayah/tuk-per-kabupaten';
  static const String masterProvinsi = '/api/master/provinsi';
  static const String masterKabupaten = '/api/master/kabupaten';
  static const String masterKecamatan = '/api/master/kecamatan';
  static const String masterSkema = '/api/master/skema';
  static const String masterJadwal = '/api/master/jadwal';

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
    int? offset,
    String? statusJadwal,
    int? idTuk,
    String? idLsp,
    String? sortBy,
    String? sortOrder,
  }) {
    final params = <String>[];
    if (limit != null) params.add('limit=$limit');
    if (offset != null) params.add('offset=$offset');
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
