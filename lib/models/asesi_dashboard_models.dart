// ============================================================================
// Asesi Dashboard Summary Model
// ============================================================================

class AsesiDashboardSummary {
  final int totalJadwalDiikuti;
  final int sertifikatDiterima;
  final int tukTerdekat;
  final int skemaPernahDijalani;
  /// Profile ringkasan fields
  final int sertifikatAktif;
  final int skemaKompetensi;
  final int sertifikatKadaluarsa;
  final int totalUjiKompetensi;
  final bool hasAlert;
  final String alertTitle;
  final String alertSubtitle;

  const AsesiDashboardSummary({
    required this.totalJadwalDiikuti,
    required this.sertifikatDiterima,
    required this.tukTerdekat,
    required this.skemaPernahDijalani,
    this.sertifikatAktif = 0,
    this.skemaKompetensi = 0,
    this.sertifikatKadaluarsa = 0,
    this.totalUjiKompetensi = 0,
    this.hasAlert = false,
    this.alertTitle = '',
    this.alertSubtitle = '',
  });

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  factory AsesiDashboardSummary.fromJson(Map<String, dynamic> json) {
    // Check if the json has a nested 'summary' key (from /api/asesi/dashboard)
    final Map<String, dynamic> summary = json['summary'] is Map<String, dynamic>
        ? json['summary']
        : json;
    final Map<String, dynamic> alert = json['alert_banner'] is Map<String, dynamic>
        ? json['alert_banner']
        : {};

    final skemaDiikuti = _asInt(
      summary['skema_diikuti'] ?? summary['total_jadwal_diikuti'],
    );
    final sertAktif = _asInt(
      summary['sertifikat_aktif'] ?? summary['sertifikat_diterima'],
    );
    final skemaKomp = _asInt(
      summary['skema_kompetensi'] ?? summary['hasil_asesmen'],
    );
    final sertKadal = _asInt(summary['sertifikat_kadaluarsa']);
    final tuk = _asInt(summary['tuk_terdekat'] ?? json['tuk_terdekat']);
    final hasil = _asInt(
      summary['hasil_asesmen'] ?? summary['skema_pernah_dijalani'],
    );

    return AsesiDashboardSummary(
      totalJadwalDiikuti: skemaDiikuti,
      sertifikatDiterima: sertAktif,
      tukTerdekat: tuk,
      skemaPernahDijalani: hasil,
      sertifikatAktif: sertAktif,
      skemaKompetensi: skemaKomp,
      sertifikatKadaluarsa: sertKadal,
      totalUjiKompetensi: skemaDiikuti,
      hasAlert: alert['has_alert'] == true,
      alertTitle: alert['title']?.toString() ?? '',
      alertSubtitle: alert['subtitle']?.toString() ?? '',
    );
  }

  factory AsesiDashboardSummary.empty() {
    return const AsesiDashboardSummary(
      totalJadwalDiikuti: 0,
      sertifikatDiterima: 0,
      tukTerdekat: 0,
      skemaPernahDijalani: 0,
      sertifikatAktif: 0,
      skemaKompetensi: 0,
      sertifikatKadaluarsa: 0,
      totalUjiKompetensi: 0,
      hasAlert: false,
      alertTitle: '',
      alertSubtitle: '',
    );
  }
}
