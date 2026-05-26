// ============================================================================
// Jadwal Models
// ============================================================================

class JadwalItem {
  final int id;
  final String skema;
  final String tuk;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String status; // 'akan_berakhir', 'sedang_berjalan', 'selesai'
  final int jumlahAsesi;
  final String asesor;
  final int sisaHari; // untuk status akan_berakhir
  final String? catatan;

  const JadwalItem({
    required this.id,
    required this.skema,
    required this.tuk,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.status,
    required this.jumlahAsesi,
    required this.asesor,
    this.sisaHari = 0,
    this.catatan,
  });

  factory JadwalItem.fromJson(Map<String, dynamic> json) {
    return JadwalItem(
      id: json['id'] ?? 0,
      skema: json['skema'] ?? '',
      tuk: json['tuk'] ?? '',
      tanggalMulai: json['tanggal_mulai'] ?? '',
      tanggalSelesai: json['tanggal_selesai'] ?? '',
      status: json['status'] ?? 'sedang_berjalan',
      jumlahAsesi: json['jumlah_asesi'] ?? 0,
      asesor: json['asesor'] ?? '',
      sisaHari: json['sisa_hari'] ?? 0,
      catatan: json['catatan'],
    );
  }
}

class JadwalStatistik {
  final int totalJadwal;
  final int akanBerakhir;
  final int sedangBerjalan;
  final int selesai;
  final String trendPercentage;

  const JadwalStatistik({
    required this.totalJadwal,
    required this.akanBerakhir,
    required this.sedangBerjalan,
    required this.selesai,
    this.trendPercentage = '+5,2%',
  });

  factory JadwalStatistik.fallback() {
    return const JadwalStatistik(
      totalJadwal: 8645,
      akanBerakhir: 12,
      sedangBerjalan: 45,
      selesai: 8588,
      trendPercentage: '+5,2%',
    );
  }
}

class UserRole {
  final String role; // 'admin', 'asesor', 'viewer'
  final String name;
  final String email;

  const UserRole({
    required this.role,
    required this.name,
    required this.email,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get canEditSchedule => isAdmin;
}
