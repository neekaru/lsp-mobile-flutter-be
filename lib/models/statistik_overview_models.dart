import 'jadwal_models.dart';

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
