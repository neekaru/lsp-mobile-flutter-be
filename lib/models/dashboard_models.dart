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

  const DashboardSummary({
    required this.totalAsesmen,
    required this.totalPemegangSertifikat,
    required this.totalAsesor,
    required this.totalTuk,
    this.trendAsesmen = '+15,7%',
    this.trendPemegangSertifikat = '+12,3%',
    this.trendAsesor = '+8,1%',
    this.trendTuk = '+4,5%',
    this.isCurrentMonth = false,
    this.note,
    this.jadwalAsesmen = '0 > 0',
    this.sertifikatPerSkema = '0 > 0',
    this.sebaranAsesor = '0 > 0',
    this.tempatUjiKompetensi = '0 > 0',
  });

  factory DashboardSummary.fallback() {
    return const DashboardSummary(
      totalAsesmen: 2545,
      totalPemegangSertifikat: 3045,
      totalAsesor: 120,
      totalTuk: 45,
      trendAsesmen: '+15,7%',
      trendPemegangSertifikat: '+12,3%',
      trendAsesor: '+8,1%',
      trendTuk: '+4,5%',
      isCurrentMonth: false,
      jadwalAsesmen: '200 > 120',
      sertifikatPerSkema: '4 > 3',
      sebaranAsesor: '20 > 10',
      tempatUjiKompetensi: '10 > 5',
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
      totalAsesor: 1317,
      asesorAktif: 1200,
      asesorInternal: 1095,
      asesorExternal: 222,
      totalTuk: 45,
      onlineAsesmen: 1684,
      offlineAsesmen: 5894,
      wilayahTercover: 34,
      trendTotalAsesor: '+15,7%',
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
      totalSkema: 200,
      provinsi: 34,
      skemaAktif: 166,
      skemaNonaktif: 34,
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
    this.trendTotalAsesi = '+14,2%',
    this.trendSertifikatTerbit = '+11,8%',
    this.trendLspTerdaftar = '+4,5%',
    this.trendTingkatKelulusan = '+1,2%',
  });

  factory StatistikOverview.fallback() {
    return const StatistikOverview(
      totalAsesi: 25890,
      sertifikatTerbit: 21435,
      lspTerdaftar: 145,
      tingkatKelulusan: 82.8,
      trendTotalAsesi: '+14,2%',
      trendSertifikatTerbit: '+11,8%',
      trendLspTerdaftar: '+4,5%',
      trendTingkatKelulusan: '+1,2%',
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
    String mapStatus(String statusVal) {
      switch (statusVal) {
        case '0':
          return 'waiting';
        case '1':
          return 'completed';
        case '2':
          return 'canceled';
        case '3':
          return 'running';
        case '4':
          return 'pelaporan';
        default:
          return 'waiting';
      }
    }

    return JadwalItem(
      id: id,
      skema: jadwal,
      tuk: tuk,
      tanggalMulai: tanggal,
      tanggalSelesai: tanggal,
      status: mapStatus(statusJadwal),
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
  final bool hasAlert;
  final String alertTitle;
  final String alertSubtitle;

  const AsesiDashboardSummary({
    required this.totalJadwalDiikuti,
    required this.sertifikatDiterima,
    required this.tukTerdekat,
    required this.skemaPernahDijalani,
    this.hasAlert = false,
    this.alertTitle = '',
    this.alertSubtitle = '',
  });

  factory AsesiDashboardSummary.fromJson(Map<String, dynamic> json) {
    // Check if the json has a nested 'summary' key (from /api/asesi/dashboard)
    final Map<String, dynamic> summary = json['summary'] is Map<String, dynamic>
        ? json['summary']
        : json;
    final Map<String, dynamic> alert = json['alert_banner'] is Map<String, dynamic>
        ? json['alert_banner']
        : {};

    return AsesiDashboardSummary(
      totalJadwalDiikuti: summary['skema_diikuti'] ?? summary['total_jadwal_diikuti'] ?? 0,
      sertifikatDiterima: summary['sertifikat_aktif'] ?? summary['sertifikat_diterima'] ?? 0,
      tukTerdekat: json['tuk_terdekat'] ?? 0,
      skemaPernahDijalani: json['skema_pernah_dijalani'] ?? 0,
      hasAlert: alert['has_alert'] ?? false,
      alertTitle: alert['title'] ?? '',
      alertSubtitle: alert['subtitle'] ?? '',
    );
  }

  factory AsesiDashboardSummary.empty() {
    return const AsesiDashboardSummary(
      totalJadwalDiikuti: 0,
      sertifikatDiterima: 0,
      tukTerdekat: 0,
      skemaPernahDijalani: 0,
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

  factory AsesorDashboardSummaryCount.mock() {
    return const AsesorDashboardSummaryCount(
      menungguVerifikasi: 1,
      asesmenBerlangsung: 0,
      asesmenSelesai: 12,
      menungguPenugasan: 2,
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

  factory AsesorDashboardAlertBanner.mock() {
    return const AsesorDashboardAlertBanner(
      hasAlert: true,
      title: "Verifikasi laporan tertunda",
      subtitle: "Anda memiliki 1 laporan yang menunggu verifikasi",
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
    String mapStatus(String statusVal) {
      switch (statusVal) {
        case '0':
          return 'waiting';
        case '1':
          return 'completed';
        case '2':
          return 'canceled';
        case '3':
          return 'running';
        case '4':
          return 'pelaporan';
        default:
          return 'waiting';
      }
    }

    return JadwalItem(
      id: idJadwal,
      skema: skema,
      tuk: tuk,
      tanggalMulai: tanggal,
      tanggalSelesai: tanggal,
      status: mapStatus(status),
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

  factory AsesorDashboardData.mock() {
    return AsesorDashboardData(
      summary: AsesorDashboardSummaryCount.mock(),
      alertBanner: AsesorDashboardAlertBanner.mock(),
      jadwalHariIni: [
        const AsesorDashboardJadwal(
          idJadwal: 11152,
          skema: "Sertifikasi Junior Web Developer",
          tanggal: "2026-04-27",
          waktu: "08:00",
          tuk: "SMK Media Informatika",
          status: "1",
        ),
      ],
      tugasPrioritas: [
        const AsesorDashboardTugas(
          idTugas: 28054,
          title: "Laporan menunggu verifikasi",
          subtitle: "Sertifikasi Junior Web Developer - SMK Media Informatika",
          type: "menunggu_verifikasi",
        ),
        const AsesorDashboardTugas(
          idTugas: 28055,
          title: "Unggah Surat Tugas",
          subtitle: "Sertifikasi Junior Graphic Designer - Politeknik Sampit",
          type: "penugasan_baru",
        ),
        const AsesorDashboardTugas(
          idTugas: 28056,
          title: "Isi Catatan Asesmen",
          subtitle: "Sertifikasi Network Security Engineer - UI",
          type: "penugasan_baru",
        ),
        const AsesorDashboardTugas(
          idTugas: 28057,
          title: "Evaluasi Portofolio Mandiri",
          subtitle: "Sertifikasi Cloud Computing Admin - SMK Media Informatika",
          type: "asesmen_berlangsung",
        ),
        const AsesorDashboardTugas(
          idTugas: 28058,
          title: "Verifikasi Kehadiran Asesi",
          subtitle: "Sertifikasi Junior Web Developer - SMK Media Informatika",
          type: "asesmen_berlangsung",
        ),
        const AsesorDashboardTugas(
          idTugas: 28059,
          title: "Kirim Laporan Akhir",
          subtitle: "Sertifikasi Junior Graphic Designer - Politeknik Sampit",
          type: "asesmen_selesai",
        ),
      ],
    );
  }
}
