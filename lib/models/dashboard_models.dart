import 'jadwal_models.dart';

// ============================================================================
// Dashboard Data Models
// ============================================================================

class DashboardSummary {
  final int totalAsesmen;
  final int totalPemegangSertifikat;
  final int totalAsesor;
  final int totalTuk;
  final String trendAsesmen;
  final String trendPemegangSertifikat;
  final String trendAsesor;
  final String trendTuk;
  final bool isCurrentMonth;
  final String? note;
  
  // New fields - format "bulan_lalu > bulan_ini"
  final String jadwalAsesmen;
  final String sertifikatPerSkema;
  final String sebaranAsesor;
  final String tempatUjiKompetensi;

  // Real API fields for Admin summary grid 2x2
  final int totalAsesi;
  final int jadwalBelumTerkonfirmasi;
  final int suratTugasMenungguPengiriman;
  final int pendaftaranAsesiBaru;
  final int honorAsesorBelumDibayar;

  const DashboardSummary({
    required this.totalAsesmen,
    required this.totalPemegangSertifikat,
    required this.totalAsesor,
    required this.totalTuk,
    this.totalAsesi = 0,
    this.jadwalBelumTerkonfirmasi = 0,
    this.suratTugasMenungguPengiriman = 0,
    this.pendaftaranAsesiBaru = 0,
    this.honorAsesorBelumDibayar = 0,
    this.trendAsesmen = '+0%',
    this.trendPemegangSertifikat = '+0%',
    this.trendAsesor = '+0%',
    this.trendTuk = '+0%',
    this.isCurrentMonth = false,
    this.note,
    this.jadwalAsesmen = '0 > 0',
    this.sertifikatPerSkema = '0 > 0',
    this.sebaranAsesor = '0 > 0',
    this.tempatUjiKompetensi = '0 > 0',
  });

  /// Empty shell when API fails — zeros only, never demo numbers.
  factory DashboardSummary.fallback() {
    return const DashboardSummary(
      totalAsesmen: 0,
      totalPemegangSertifikat: 0,
      totalAsesor: 0,
      totalTuk: 0,
      totalAsesi: 0,
      jadwalBelumTerkonfirmasi: 0,
      suratTugasMenungguPengiriman: 0,
      pendaftaranAsesiBaru: 0,
      honorAsesorBelumDibayar: 0,
      trendAsesmen: '+0%',
      trendPemegangSertifikat: '+0%',
      trendAsesor: '+0%',
      trendTuk: '+0%',
      isCurrentMonth: false,
      jadwalAsesmen: '0 > 0',
      sertifikatPerSkema: '0 > 0',
      sebaranAsesor: '0 > 0',
      tempatUjiKompetensi: '0 > 0',
    );
  }
  
  // Helper method to parse "bulan_lalu > bulan_ini" format
  static Map<String, int> parseComparison(String value) {
    final parts = value.split('>');
    if (parts.length == 2) {
      return {
        'previous': int.tryParse(parts[0].trim()) ?? 0,
        'current': int.tryParse(parts[1].trim()) ?? 0,
      };
    }
    return {'previous': 0, 'current': 0};
  }
}

class MonthlyAssessment {
  final String label;
  final int total;
  final double heightPercentage;
  final int? kompeten;
  final int? belumKompeten;
  final bool isCurrentMonth;

  const MonthlyAssessment({
    required this.label,
    required this.total,
    required this.heightPercentage,
    this.kompeten,
    this.belumKompeten,
    this.isCurrentMonth = false,
  });
}

class JadwalOverdue {
  final int id;
  final String jadwal;
  final String tanggal;
  final String tuk;
  final int daysOverdue;
  final String statusLabel;

  const JadwalOverdue({
    required this.id,
    required this.jadwal,
    required this.tanggal,
    required this.tuk,
    required this.daysOverdue,
    required this.statusLabel,
  });

  factory JadwalOverdue.fromJson(Map<String, dynamic> json) {
    return JadwalOverdue(
      id: json['id'] ?? 0,
      jadwal: json['jadwal'] ?? 'Jadwal Asesmen',
      tanggal: json['tanggal'] ?? '',
      tuk: json['tuk'] ?? 'TUK Pusat',
      daysOverdue: json['days_overdue'] ?? 0,
      statusLabel: json['status_label'] ?? 'Terjadwal',
    );
  }
}

class AsesorStats {
  final int totalAsesor;
  final int asesorAktif;
  final int asesorInternal;
  final int asesorExternal;
  final int totalTuk;
  final int onlineAsesmen;
  final int offlineAsesmen;
  final int wilayahTercover;
  final String trendTotalAsesor;

  const AsesorStats({
    required this.totalAsesor,
    required this.asesorAktif,
    required this.asesorInternal,
    required this.asesorExternal,
    required this.totalTuk,
    required this.onlineAsesmen,
    required this.offlineAsesmen,
    required this.wilayahTercover,
    this.trendTotalAsesor = '+15,7%',
  });

  factory AsesorStats.fallback() {
    return const AsesorStats(
      totalAsesor: 0,
      asesorAktif: 0,
      asesorInternal: 0,
      asesorExternal: 0,
      totalTuk: 0,
      onlineAsesmen: 0,
      offlineAsesmen: 0,
      wilayahTercover: 0,
      trendTotalAsesor: '+0%',
    );
  }
}

class TopProvinsi {
  final String name;
  final int value;
  final String percentage;

  const TopProvinsi({
    required this.name,
    required this.value,
    required this.percentage,
  });
}

class SkemaStats {
  final int totalSkema;
  final int provinsi;
  final int skemaAktif;
  final int skemaNonaktif;

  const SkemaStats({
    required this.totalSkema,
    required this.provinsi,
    required this.skemaAktif,
    required this.skemaNonaktif,
  });

  factory SkemaStats.fallback() {
    return const SkemaStats(
      totalSkema: 0,
      provinsi: 0,
      skemaAktif: 0,
      skemaNonaktif: 0,
    );
  }
}

class TopMitra {
  final String name;
  final int value;
  final String percentage;

  const TopMitra({
    required this.name,
    required this.value,
    required this.percentage,
  });
}

class TUKKabupaten {
  final String kabupaten;
  final int jumlah;
  final List<String> detail;

  const TUKKabupaten({
    required this.kabupaten,
    required this.jumlah,
    this.detail = const [],
  });
}

// ============================================================================
// Statistik Overview Models
// ============================================================================

class StatistikOverview {
  final int totalAsesi;
  final int sertifikatTerbit;
  final int lspTerdaftar;
  final double tingkatKelulusan;
  final String trendTotalAsesi;
  final String trendSertifikatTerbit;
  final String trendLspTerdaftar;
  final String trendTingkatKelulusan;

  const StatistikOverview({
    required this.totalAsesi,
    required this.sertifikatTerbit,
    required this.lspTerdaftar,
    required this.tingkatKelulusan,
    this.trendTotalAsesi = '+0%',
    this.trendSertifikatTerbit = '+0%',
    this.trendLspTerdaftar = '+0%',
    this.trendTingkatKelulusan = '+0%',
  });

  factory StatistikOverview.fallback() {
    return const StatistikOverview(
      totalAsesi: 0,
      sertifikatTerbit: 0,
      lspTerdaftar: 0,
      tingkatKelulusan: 0,
      trendTotalAsesi: '+0%',
      trendSertifikatTerbit: '+0%',
      trendLspTerdaftar: '+0%',
      trendTingkatKelulusan: '+0%',
    );
  }
}

class SectorDistribution {
  final String sectorName;
  final int count;
  final double percentage;

  const SectorDistribution({
    required this.sectorName,
    required this.count,
    required this.percentage,
  });
}

// ============================================================================
// Regional/Island Distribution Models
// ============================================================================

class RegionalDistribution {
  final String islandId;
  final String islandName;
  final int totalAsesi;
  final double percentage;
  final double tingkatKompetensi;
  final List<TopProvinsiDetail> topProvinces;

  const RegionalDistribution({
    required this.islandId,
    required this.islandName,
    required this.totalAsesi,
    required this.percentage,
    required this.tingkatKompetensi,
    required this.topProvinces,
  });

  factory RegionalDistribution.fromJson(Map<String, dynamic> json) {
    final List<dynamic> provinces = json['top_provinces'] ?? [];
    return RegionalDistribution(
      islandId: json['island_id'] ?? '',
      islandName: json['island_name'] ?? '',
      totalAsesi: json['total_asesi'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      tingkatKompetensi: (json['tingkat_kompetensi'] ?? 0.0).toDouble(),
      topProvinces: provinces
          .map((p) => TopProvinsiDetail.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TopProvinsiDetail {
  final String name;
  final int count;

  const TopProvinsiDetail({
    required this.name,
    required this.count,
  });

  factory TopProvinsiDetail.fromJson(Map<String, dynamic> json) {
    return TopProvinsiDetail(
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class SkemaAsesorProvinsi {
  final String provinsiId;
  final String provinsiNama;
  final int jumlahAsesor;

  const SkemaAsesorProvinsi({
    required this.provinsiId,
    required this.provinsiNama,
    required this.jumlahAsesor,
  });

  factory SkemaAsesorProvinsi.fromJson(Map<String, dynamic> json) {
    return SkemaAsesorProvinsi(
      provinsiId: json['provinsi_id'] ?? '',
      provinsiNama: json['provinsi_nama'] ?? '',
      jumlahAsesor: json['jumlah_asesor'] ?? 0,
    );
  }
}

class SebaranSkemaAsesorItem {
  final int idSkema;
  final String kodeSkema;
  final String skema;
  final int jumlahAsesor;
  final String wilayahTerbanyak;
  final List<SkemaAsesorProvinsi> wilayahDetail;

  const SebaranSkemaAsesorItem({
    required this.idSkema,
    required this.kodeSkema,
    required this.skema,
    required this.jumlahAsesor,
    required this.wilayahTerbanyak,
    required this.wilayahDetail,
  });

  factory SebaranSkemaAsesorItem.fromJson(Map<String, dynamic> json) {
    final List<dynamic> details = json['wilayah_detail'] ?? [];
    return SebaranSkemaAsesorItem(
      idSkema: json['id_skema'] ?? 0,
      kodeSkema: json['kode_skema'] ?? '',
      skema: json['skema'] ?? '',
      jumlahAsesor: json['jumlah_asesor'] ?? 0,
      wilayahTerbanyak: json['wilayah_terbanyak'] ?? '',
      wilayahDetail: details
          .map((d) => SkemaAsesorProvinsi.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

class JadwalBaru {
  final int id;
  final String jadwal;
  final String tanggal;
  final int kuota;
  final String statusJadwal;
  final String tuk;

  const JadwalBaru({
    required this.id,
    required this.jadwal,
    required this.tanggal,
    required this.kuota,
    required this.statusJadwal,
    required this.tuk,
  });

  factory JadwalBaru.fromJson(Map<String, dynamic> json) {
    return JadwalBaru(
      id: json['id'] ?? 0,
      jadwal: json['jadwal'] ?? 'Jadwal Baru',
      tanggal: json['tanggal'] ?? json['tanggal_mulai'] ?? '',
      kuota: json['kuota'] ?? 0,
      statusJadwal: json['status_jadwal']?.toString() ?? '0',
      tuk: json['tuk'] ?? 'TUK Pusat',
    );
  }

  JadwalItem toJadwalItem() {
    return JadwalItem(
      id: id,
      skema: jadwal,
      tuk: tuk,
      tanggalMulai: tanggal,
      tanggalSelesai: tanggal,
      status: JadwalItem.mapStatusCode(statusJadwal),
      statusJadwal: statusJadwal,
      jumlahAsesi: kuota,
      asesor: const [],
      sisaHari: 0,
    );
  }
}

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

// ============================================================================
// Asesor Dashboard Model
// ============================================================================

class AsesorDashboardSummaryCount {
  final int menungguVerifikasi;
  final int asesmenBerlangsung;
  final int asesmenSelesai;
  final int menungguPenugasan;

  const AsesorDashboardSummaryCount({
    required this.menungguVerifikasi,
    required this.asesmenBerlangsung,
    required this.asesmenSelesai,
    required this.menungguPenugasan,
  });

  factory AsesorDashboardSummaryCount.fromJson(Map<String, dynamic> json) {
    return AsesorDashboardSummaryCount(
      menungguVerifikasi: json['menunggu_verifikasi'] ?? 0,
      asesmenBerlangsung: json['asesmen_berlangsung'] ?? 0,
      asesmenSelesai: json['asesmen_selesai'] ?? 0,
      menungguPenugasan: json['menunggu_penugasan'] ?? 0,
    );
  }

  factory AsesorDashboardSummaryCount.empty() {
    return const AsesorDashboardSummaryCount(
      menungguVerifikasi: 0,
      asesmenBerlangsung: 0,
      asesmenSelesai: 0,
      menungguPenugasan: 0,
    );
  }
}

class AsesorDashboardAlertBanner {
  final bool hasAlert;
  final String title;
  final String subtitle;

  const AsesorDashboardAlertBanner({
    required this.hasAlert,
    required this.title,
    required this.subtitle,
  });

  factory AsesorDashboardAlertBanner.fromJson(Map<String, dynamic> json) {
    return AsesorDashboardAlertBanner(
      hasAlert: json['has_alert'] ?? false,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
    );
  }

  factory AsesorDashboardAlertBanner.empty() {
    return const AsesorDashboardAlertBanner(
      hasAlert: false,
      title: '',
      subtitle: '',
    );
  }
}

class AsesorDashboardJadwal {
  final int idJadwal;
  final String skema;
  final String tanggal;
  final String waktu;
  final String tuk;
  final String status;

  const AsesorDashboardJadwal({
    required this.idJadwal,
    required this.skema,
    required this.tanggal,
    required this.waktu,
    required this.tuk,
    required this.status,
  });

  factory AsesorDashboardJadwal.fromJson(Map<String, dynamic> json) {
    return AsesorDashboardJadwal(
      idJadwal: json['id_jadwal'] ?? 0,
      skema: json['skema'] ?? '',
      tanggal: json['tanggal'] ?? '',
      waktu: json['waktu'] ?? '',
      tuk: json['tuk'] ?? '',
      status: json['status']?.toString() ?? '0',
    );
  }

  JadwalItem toJadwalItem() {
    return JadwalItem(
      id: idJadwal,
      skema: skema,
      tuk: tuk,
      tanggalMulai: tanggal,
      tanggalSelesai: tanggal,
      status: JadwalItem.mapStatusCode(status),
      statusJadwal: status,
      jumlahAsesi: 0,
      asesor: const [],
      sisaHari: 0,
    );
  }
}

class AsesorDashboardTugas {
  final int idTugas;
  final String title;
  final String subtitle;
  final String type;

  const AsesorDashboardTugas({
    required this.idTugas,
    required this.title,
    required this.subtitle,
    required this.type,
  });

  factory AsesorDashboardTugas.fromJson(Map<String, dynamic> json) {
    return AsesorDashboardTugas(
      idTugas: json['id_tugas'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class AsesorDashboardData {
  final AsesorDashboardSummaryCount summary;
  final AsesorDashboardAlertBanner alertBanner;
  final List<AsesorDashboardJadwal> jadwalHariIni;
  final List<AsesorDashboardTugas> tugasPrioritas;

  const AsesorDashboardData({
    required this.summary,
    required this.alertBanner,
    required this.jadwalHariIni,
    required this.tugasPrioritas,
  });

  factory AsesorDashboardData.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'] ?? {};
    final alertJson = json['alert_banner'] ?? {};
    final List<dynamic> jadwalList = json['jadwal_hari_ini'] ?? [];
    final List<dynamic> tugasList = json['tugas_prioritas'] ?? [];

    return AsesorDashboardData(
      summary: AsesorDashboardSummaryCount.fromJson(summaryJson),
      alertBanner: AsesorDashboardAlertBanner.fromJson(alertJson),
      jadwalHariIni:
          jadwalList.map((j) => AsesorDashboardJadwal.fromJson(j)).toList(),
      tugasPrioritas:
          tugasList.map((t) => AsesorDashboardTugas.fromJson(t)).toList(),
    );
  }

  /// Empty shell when API fails — no demo jadwal/tugas.
  factory AsesorDashboardData.empty() {
    return AsesorDashboardData(
      summary: AsesorDashboardSummaryCount.empty(),
      alertBanner: AsesorDashboardAlertBanner.empty(),
      jadwalHariIni: const [],
      tugasPrioritas: const [],
    );
  }
}

class AsesorHomebase {
  final String name;
  final String scheme;
  final String homebase;
  final int assessments;

  const AsesorHomebase({
    required this.name,
    required this.scheme,
    required this.homebase,
    required this.assessments,
  });

  factory AsesorHomebase.fromJson(Map<String, dynamic> json) {
    return AsesorHomebase(
      name: json['name'] ?? '',
      scheme: json['scheme'] ?? '',
      homebase: json['homebase'] ?? '',
      assessments: (json['assessments'] as num?)?.toInt() ?? 0,
    );
  }
}

// ============================================================================
// Detailed Admin Statistics Models (Items #1-5)
// ============================================================================

class AsesorDomisiliItem {
  final String id;
  final String namaAsesor;
  final String noMet;
  final String tipeAsesor;
  final String provinsi;
  final String kabupatenKota;
  final String email;
  final String noHp;
  final String skemaKeahlian;
  final String status;

  const AsesorDomisiliItem({
    required this.id,
    required this.namaAsesor,
    required this.noMet,
    required this.tipeAsesor,
    required this.provinsi,
    required this.kabupatenKota,
    required this.email,
    required this.noHp,
    required this.skemaKeahlian,
    required this.status,
  });

  factory AsesorDomisiliItem.fromJson(Map<String, dynamic> json) {
    return AsesorDomisiliItem(
      id: json['id']?.toString() ?? '',
      namaAsesor: json['nama_asesor']?.toString() ?? json['nama']?.toString() ?? '',
      noMet: json['no_met']?.toString() ?? json['no_reg']?.toString() ?? '-',
      tipeAsesor: json['tipe_asesor']?.toString() ?? json['tipe']?.toString() ?? 'Internal',
      provinsi: json['provinsi']?.toString() ?? '',
      kabupatenKota: json['kabupaten_kota']?.toString() ?? json['kota']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      noHp: json['no_hp']?.toString() ?? json['telepon']?.toString() ?? '',
      skemaKeahlian: json['skema_keahlian']?.toString() ?? json['skema']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Aktif',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_asesor': namaAsesor,
      'no_met': noMet,
      'tipe_asesor': tipeAsesor,
      'provinsi': provinsi,
      'kabupaten_kota': kabupatenKota,
      'email': email,
      'no_hp': noHp,
      'skema_keahlian': skemaKeahlian,
      'status': status,
    };
  }
}

class DomisiliAsesorDetailData {
  final String provinsiId;
  final String provinsiNama;
  final int totalAsesor;
  final int totalInternal;
  final int totalExternal;
  final List<AsesorDomisiliItem> asesorList;
  final int totalCount;
  final int filteredCount;

  const DomisiliAsesorDetailData({
    required this.provinsiId,
    required this.provinsiNama,
    required this.totalAsesor,
    required this.totalInternal,
    required this.totalExternal,
    required this.asesorList,
    required this.totalCount,
    required this.filteredCount,
  });

  factory DomisiliAsesorDetailData.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};
    final rawMeta = json['meta'];
    final meta = rawMeta is Map<String, dynamic> ? rawMeta : <String, dynamic>{};

    final list = (data['asesor_list'] as List?)
            ?.map((e) => AsesorDomisiliItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return DomisiliAsesorDetailData(
      provinsiId: data['provinsi_id']?.toString() ?? '',
      provinsiNama: data['provinsi_nama']?.toString() ?? '',
      totalAsesor: data['total_asesor'] ?? meta['total_count'] ?? 0,
      totalInternal: data['total_internal'] ?? 0,
      totalExternal: data['total_external'] ?? 0,
      asesorList: list,
      totalCount: meta['total_count'] ?? 0,
      filteredCount: meta['filtered_count'] ?? list.length,
    );
  }
}

class DomisiliAsesorProvinsiItem {
  final String provinsiId;
  final String provinsiKode;
  final String provinsiNama;
  final int totalAsesor;
  final int asesorInternal;
  final int asesorExternal;
  final double persentaseInternal;
  final List<AsesorDomisiliItem> daftarAsesor;

  const DomisiliAsesorProvinsiItem({
    required this.provinsiId,
    required this.provinsiKode,
    required this.provinsiNama,
    required this.totalAsesor,
    required this.asesorInternal,
    required this.asesorExternal,
    required this.persentaseInternal,
    this.daftarAsesor = const [],
  });

  factory DomisiliAsesorProvinsiItem.fromJson(Map<String, dynamic> json) {
    final rawAsesor = json['asesor_list'] ?? json['asesor'];
    final listAsesor = (rawAsesor is List)
        ? rawAsesor
            .map((e) => AsesorDomisiliItem.fromJson(e as Map<String, dynamic>))
            .toList()
        : <AsesorDomisiliItem>[];

    return DomisiliAsesorProvinsiItem(
      provinsiId: json['provinsi_id']?.toString() ?? '',
      provinsiKode: json['provinsi_kode']?.toString() ?? '',
      provinsiNama: json['provinsi_nama']?.toString() ?? 'Lainnya',
      totalAsesor: json['total_asesor'] ?? 0,
      asesorInternal: json['asesor_internal'] ?? 0,
      asesorExternal: json['asesor_external'] ?? 0,
      persentaseInternal:
          (json['persentase_internal'] as num?)?.toDouble() ?? 0.0,
      daftarAsesor: listAsesor,
    );
  }
}

class DomisiliAsesorData {
  final List<DomisiliAsesorProvinsiItem> items;
  final int totalAsesor;
  final int totalInternal;
  final int totalExternal;

  const DomisiliAsesorData({
    required this.items,
    required this.totalAsesor,
    required this.totalInternal,
    required this.totalExternal,
  });

  factory DomisiliAsesorData.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List?)
            ?.map((e) =>
                DomisiliAsesorProvinsiItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final meta = json['meta'] ?? {};
    return DomisiliAsesorData(
      items: list,
      totalAsesor: meta['total_asesor'] ?? 0,
      totalInternal: meta['total_internal'] ?? 0,
      totalExternal: meta['total_external'] ?? 0,
    );
  }
}

class KompetensiTeknisItem {
  final int skemaId;
  final String kodeSkema;
  final String namaSkema;
  final int jumlahAsesor;

  const KompetensiTeknisItem({
    required this.skemaId,
    required this.kodeSkema,
    required this.namaSkema,
    required this.jumlahAsesor,
  });

  factory KompetensiTeknisItem.fromJson(Map<String, dynamic> json) {
    return KompetensiTeknisItem(
      skemaId: json['skema_id'] ?? 0,
      kodeSkema: json['kode_skema']?.toString() ?? '',
      namaSkema: json['nama_skema']?.toString() ?? '',
      jumlahAsesor: json['jumlah_asesor'] ?? 0,
    );
  }
}

class KompetensiTeknisAsesorItem {
  final String id;
  final String namaAsesor;
  final String noMet;
  final String statusMasaBerlaku;
  final String tanggalExpired;
  final String provinsi;
  final String kabupatenKota;
  final String email;
  final String noHp;
  final String tipeAsesor;

  const KompetensiTeknisAsesorItem({
    required this.id,
    required this.namaAsesor,
    required this.noMet,
    required this.statusMasaBerlaku,
    required this.tanggalExpired,
    required this.provinsi,
    required this.kabupatenKota,
    required this.email,
    required this.noHp,
    required this.tipeAsesor,
  });

  factory KompetensiTeknisAsesorItem.fromJson(Map<String, dynamic> json) {
    return KompetensiTeknisAsesorItem(
      id: json['id']?.toString() ?? '',
      namaAsesor: json['nama_asesor']?.toString() ?? json['nama']?.toString() ?? '',
      noMet: json['no_met']?.toString() ?? json['no_reg']?.toString() ?? '-',
      statusMasaBerlaku: json['status_masa_berlaku']?.toString() ?? json['status']?.toString() ?? 'Aktif',
      tanggalExpired: json['tanggal_expired']?.toString() ?? '',
      provinsi: json['provinsi']?.toString() ?? '',
      kabupatenKota: json['kabupaten_kota']?.toString() ?? json['kota']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      noHp: json['no_hp']?.toString() ?? json['telepon']?.toString() ?? '',
      tipeAsesor: json['tipe_asesor']?.toString() ?? json['tipe']?.toString() ?? 'Internal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_asesor': namaAsesor,
      'no_met': noMet,
      'status_masa_berlaku': statusMasaBerlaku,
      'tanggal_expired': tanggalExpired,
      'provinsi': provinsi,
      'kabupaten_kota': kabupatenKota,
      'email': email,
      'no_hp': noHp,
      'tipe_asesor': tipeAsesor,
    };
  }
}

class KompetensiTeknisDetailData {
  final dynamic skemaId;
  final String kodeSkema;
  final String namaSkema;
  final int totalAsesor;
  final List<KompetensiTeknisAsesorItem> asesorList;
  final int totalCount;
  final int filteredCount;

  const KompetensiTeknisDetailData({
    required this.skemaId,
    required this.kodeSkema,
    required this.namaSkema,
    required this.totalAsesor,
    required this.asesorList,
    required this.totalCount,
    required this.filteredCount,
  });

  factory KompetensiTeknisDetailData.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};
    final rawMeta = json['meta'];
    final meta = rawMeta is Map<String, dynamic> ? rawMeta : <String, dynamic>{};

    final rawList = data['asesor_list'] ?? data['items'] ?? (json['data'] is List ? json['data'] : null);
    final list = (rawList is List)
        ? rawList
            .map((e) => KompetensiTeknisAsesorItem.fromJson(e as Map<String, dynamic>))
            .toList()
        : <KompetensiTeknisAsesorItem>[];

    return KompetensiTeknisDetailData(
      skemaId: data['skema_id'] ?? 0,
      kodeSkema: data['kode_skema']?.toString() ?? '',
      namaSkema: data['nama_skema']?.toString() ?? '',
      totalAsesor: data['total_asesor'] ?? meta['total_count'] ?? list.length,
      asesorList: list,
      totalCount: meta['total_count'] ?? data['total_count'] ?? list.length,
      filteredCount: meta['filtered_count'] ?? list.length,
    );
  }
}

class MasaBerlakuAsesorData {
  final int aktif;
  final int tenggang;
  final int expired;
  final int totalAsesor;

  const MasaBerlakuAsesorData({
    required this.aktif,
    required this.tenggang,
    required this.expired,
    required this.totalAsesor,
  });

  factory MasaBerlakuAsesorData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final meta = json['meta'] ?? {};
    return MasaBerlakuAsesorData(
      aktif: data['aktif'] ?? 0,
      tenggang: data['tenggang'] ?? 0,
      expired: data['expired'] ?? 0,
      totalAsesor: meta['total_asesor'] ?? 0,
    );
  }
}

class MasaBerlakuAsesorDetailItem {
  final String id;
  final String namaAsesor;
  final String noMet;
  final String statusMasaBerlaku;
  final String tanggalExpired;
  final int sisaHari;
  final String skemaKeahlian;
  final String provinsi;
  final String kabupatenKota;
  final String email;
  final String noHp;

  const MasaBerlakuAsesorDetailItem({
    required this.id,
    required this.namaAsesor,
    required this.noMet,
    required this.statusMasaBerlaku,
    required this.tanggalExpired,
    required this.sisaHari,
    required this.skemaKeahlian,
    required this.provinsi,
    required this.kabupatenKota,
    required this.email,
    required this.noHp,
  });

  factory MasaBerlakuAsesorDetailItem.fromJson(Map<String, dynamic> json) {
    return MasaBerlakuAsesorDetailItem(
      id: json['id']?.toString() ?? '',
      namaAsesor: json['nama_asesor']?.toString() ?? json['nama']?.toString() ?? '',
      noMet: json['no_met']?.toString() ?? json['no_reg']?.toString() ?? '-',
      statusMasaBerlaku: json['status_masa_berlaku']?.toString() ?? json['status']?.toString() ?? 'Tenggang',
      tanggalExpired: json['tanggal_expired']?.toString() ?? json['tgl_expired']?.toString() ?? '-',
      sisaHari: (json['sisa_hari'] as num?)?.toInt() ?? (json['days_remaining'] as num?)?.toInt() ?? 0,
      skemaKeahlian: json['skema_keahlian']?.toString() ?? json['skema']?.toString() ?? '-',
      provinsi: json['provinsi']?.toString() ?? '',
      kabupatenKota: json['kabupaten_kota']?.toString() ?? json['kota']?.toString() ?? '',
      email: json['email']?.toString() ?? '-',
      noHp: json['no_hp']?.toString() ?? json['telepon']?.toString() ?? '-',
    );
  }
}

class MasaBerlakuAsesorDetailData {
  final String statusFilter;
  final int totalCount;
  final List<MasaBerlakuAsesorDetailItem> asesorList;

  const MasaBerlakuAsesorDetailData({
    required this.statusFilter,
    required this.totalCount,
    required this.asesorList,
  });

  factory MasaBerlakuAsesorDetailData.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};
    final rawMeta = json['meta'];
    final meta = rawMeta is Map<String, dynamic> ? rawMeta : <String, dynamic>{};

    final rawList = data['asesor_list'] ?? data['items'] ?? (json['data'] is List ? json['data'] : null);
    final list = (rawList is List)
        ? rawList
            .map((e) => MasaBerlakuAsesorDetailItem.fromJson(e as Map<String, dynamic>))
            .toList()
        : <MasaBerlakuAsesorDetailItem>[];

    return MasaBerlakuAsesorDetailData(
      statusFilter: data['status_filter']?.toString() ?? '',
      totalCount: meta['total_count'] ?? data['total_count'] ?? list.length,
      asesorList: list,
    );
  }
}

class JenisSkemaItem {
  final String kategori;
  final int jumlahSkema;

  const JenisSkemaItem({
    required this.kategori,
    required this.jumlahSkema,
  });

  factory JenisSkemaItem.fromJson(Map<String, dynamic> json) {
    return JenisSkemaItem(
      kategori: json['kategori']?.toString() ?? 'Umum',
      jumlahSkema: json['jumlah_skema'] ?? 0,
    );
  }
}

class MUKDistribusiItem {
  final int skemaId;
  final String kodeSkema;
  final String namaSkema;
  final int jumlahMuk;

  const MUKDistribusiItem({
    required this.skemaId,
    required this.kodeSkema,
    required this.namaSkema,
    required this.jumlahMuk,
  });

  factory MUKDistribusiItem.fromJson(Map<String, dynamic> json) {
    return MUKDistribusiItem(
      skemaId: json['skema_id'] ?? 0,
      kodeSkema: json['kode_skema']?.toString() ?? '',
      namaSkema: json['nama_skema']?.toString() ?? '',
      jumlahMuk: json['jumlah_muk'] ?? 0,
    );
  }
}

class PerangkatMUKItem {
  final int id;
  final int skemaId;
  final String namaPerangkat;
  final String metode;
  final String penyusun;
  final String tanggalPembuatan;
  final int jumlahDigunakan;

  const PerangkatMUKItem({
    required this.id,
    required this.skemaId,
    required this.namaPerangkat,
    required this.metode,
    required this.penyusun,
    required this.tanggalPembuatan,
    required this.jumlahDigunakan,
  });

  factory PerangkatMUKItem.fromJson(Map<String, dynamic> json) {
    return PerangkatMUKItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      skemaId: json['skema_id'] is int ? json['skema_id'] : int.tryParse(json['skema_id'].toString()) ?? 0,
      namaPerangkat: json['nama_perangkat']?.toString() ?? 'MUK / MAPA',
      metode: json['metode']?.toString() ?? 'Observasi Langsung',
      penyusun: json['penyusun']?.toString() ?? 'Administrator',
      tanggalPembuatan: json['tanggal_pembuatan']?.toString() ?? '-',
      jumlahDigunakan: json['jumlah_digunakan'] is int
          ? json['jumlah_digunakan']
          : int.tryParse(json['jumlah_digunakan'].toString()) ?? 0,
    );
  }
}

class MUKDetailData {
  final int skemaId;
  final String kodeSkema;
  final String namaSkema;
  final int totalMuk;
  final List<PerangkatMUKItem> perangkatList;

  const MUKDetailData({
    required this.skemaId,
    required this.kodeSkema,
    required this.namaSkema,
    required this.totalMuk,
    required this.perangkatList,
  });

  factory MUKDetailData.fromJson(Map<String, dynamic> json) {
    return MUKDetailData(
      skemaId: json['skema_id'] is int ? json['skema_id'] : int.tryParse(json['skema_id'].toString()) ?? 0,
      kodeSkema: json['kode_skema']?.toString() ?? '',
      namaSkema: json['nama_skema']?.toString() ?? '',
      totalMuk: json['total_muk'] is int ? json['total_muk'] : int.tryParse(json['total_muk'].toString()) ?? 0,
      perangkatList: (json['perangkat_list'] as List<dynamic>?)
              ?.map((e) => PerangkatMUKItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <PerangkatMUKItem>[],
    );
  }
}

class SptAsesorItem {
  final String namaAsesor;
  final String tglExpired;
  final String statusMasaBerlaku;
  final int total;
  final Map<String, int> bulanan;

  const SptAsesorItem({
    required this.namaAsesor,
    required this.tglExpired,
    required this.statusMasaBerlaku,
    required this.total,
    required this.bulanan,
  });

  factory SptAsesorItem.fromJson(Map<String, dynamic> json) {
    final bulananRaw = json['bulanan'] as Map<String, dynamic>? ?? {};
    final mapBulanan = <String, int>{};
    bulananRaw.forEach((key, value) {
      mapBulanan[key] = (value as num?)?.toInt() ?? 0;
    });

    return SptAsesorItem(
      namaAsesor: json['nama_asesor']?.toString() ?? '',
      tglExpired: json['tgl_expired']?.toString() ?? '',
      statusMasaBerlaku: json['status_masa_berlaku']?.toString() ?? 'Tidak Diketahui',
      total: json['total'] ?? 0,
      bulanan: mapBulanan,
    );
  }
}

class SptAsesorData {
  final List<SptAsesorItem> items;
  final int totalAsesor;
  final int totalJadwal;
  final int tahun;

  const SptAsesorData({
    required this.items,
    required this.totalAsesor,
    required this.totalJadwal,
    required this.tahun,
  });

  factory SptAsesorData.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List?)
            ?.map((e) => SptAsesorItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final meta = json['meta'] ?? {};
    return SptAsesorData(
      items: list,
      totalAsesor: meta['total_asesor'] ?? list.length,
      totalJadwal: meta['total_jadwal'] ?? 0,
      tahun: meta['tahun'] ?? 2026,
    );
  }
}

class Asesi2026Item {
  final String namaAsesor;
  final String tglExpired;
  final String statusMasaBerlaku;
  final int totalAsesi;
  final int totalJadwal;
  final Map<String, int> bulanan;

  const Asesi2026Item({
    required this.namaAsesor,
    required this.tglExpired,
    required this.statusMasaBerlaku,
    required this.totalAsesi,
    required this.totalJadwal,
    required this.bulanan,
  });

  factory Asesi2026Item.fromJson(Map<String, dynamic> json) {
    final bulananRaw = json['bulanan'] as Map<String, dynamic>? ?? {};
    final mapBulanan = <String, int>{};
    bulananRaw.forEach((key, value) {
      mapBulanan[key] = (value as num?)?.toInt() ?? 0;
    });

    return Asesi2026Item(
      namaAsesor: json['nama_asesor']?.toString() ?? '',
      tglExpired: json['tgl_expired']?.toString() ?? '',
      statusMasaBerlaku: json['status_masa_berlaku']?.toString() ?? 'Tidak Diketahui',
      totalAsesi: (json['total_asesi'] as num?)?.toInt() ?? 0,
      totalJadwal: (json['total_jadwal'] as num?)?.toInt() ?? 0,
      bulanan: mapBulanan,
    );
  }
}

class Asesi2026Data {
  final List<Asesi2026Item> items;
  final int totalAsesor;
  final int totalAsesi;
  final int totalJadwal;
  final int tahun;

  const Asesi2026Data({
    required this.items,
    required this.totalAsesor,
    required this.totalAsesi,
    required this.totalJadwal,
    required this.tahun,
  });

  factory Asesi2026Data.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List?)
            ?.map((e) => Asesi2026Item.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final meta = json['meta'] ?? {};
    return Asesi2026Data(
      items: list,
      totalAsesor: (meta['total_asesor'] as num?)?.toInt() ?? list.length,
      totalAsesi: (meta['total_asesi'] as num?)?.toInt() ?? 0,
      totalJadwal: (meta['total_jadwal'] as num?)?.toInt() ?? 0,
      tahun: (meta['tahun'] as num?)?.toInt() ?? 2026,
    );
  }
}


