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
      tanggal: json['tanggal'] ?? '',
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
          return 'akan_berakhir';
        case '2':
          return 'sedang_berjalan';
        case '3':
          return 'selesai';
        case '4':
          return 'pelaporan';
        case '5':
        case '9':
          return 'cancelled';
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
