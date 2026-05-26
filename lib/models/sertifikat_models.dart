// ============================================================================
// Sertifikat Models
// ============================================================================

class SertifikatItem {
  final int id;
  final String skema;
  final String pemegang;
  final String nomorSertifikat;
  final String tanggalTerbit;
  final String tanggalBerlaku;
  final String status; // 'aktif', 'kadaluarsa', 'akan_kadaluarsa'
  final String kategori; // 'Digital Marketing', 'Informatika', dll
  final String? institusi;

  const SertifikatItem({
    required this.id,
    required this.skema,
    required this.pemegang,
    required this.nomorSertifikat,
    required this.tanggalTerbit,
    required this.tanggalBerlaku,
    required this.status,
    required this.kategori,
    this.institusi,
  });

  factory SertifikatItem.fromJson(Map<String, dynamic> json) {
    return SertifikatItem(
      id: json['id'] ?? 0,
      skema: json['skema'] ?? '',
      pemegang: json['pemegang'] ?? '',
      nomorSertifikat: json['nomor_sertifikat'] ?? '',
      tanggalTerbit: json['tanggal_terbit'] ?? '',
      tanggalBerlaku: json['tanggal_berlaku'] ?? '',
      status: json['status'] ?? 'aktif',
      kategori: json['kategori'] ?? '',
      institusi: json['institusi'],
    );
  }
}

class SertifikatRingkasan {
  final int totalPemegangSertifikat;
  final double persentasePertumbuhan;
  final int totalSkema;
  final double persentaseSkema;
  final int totalSertifikatYangDiterbitkan;
  final double persentaseSertifikat;

  const SertifikatRingkasan({
    required this.totalPemegangSertifikat,
    required this.persentasePertumbuhan,
    required this.totalSkema,
    required this.persentaseSkema,
    required this.totalSertifikatYangDiterbitkan,
    required this.persentaseSertifikat,
  });

  factory SertifikatRingkasan.fallback() {
    return const SertifikatRingkasan(
      totalPemegangSertifikat: 3980,
      persentasePertumbuhan: 15.7,
      totalSkema: 2000,
      persentaseSkema: 16.8,
      totalSertifikatYangDiterbitkan: 8000,
      persentaseSertifikat: 18.7,
    );
  }
}

class SertifikatDistribusi {
  final String kategori;
  final int jumlah;
  final double persentase;
  final String color;

  const SertifikatDistribusi({
    required this.kategori,
    required this.jumlah,
    required this.persentase,
    required this.color,
  });
}
