// ============================================================================
// Penyebaran Wilayah Detail (Inline Expansion) Models
// ============================================================================

class BidangBreakdownItem {
  final String bidangId;
  final String namaBidang;
  final int jumlah;

  const BidangBreakdownItem({
    required this.bidangId,
    required this.namaBidang,
    required this.jumlah,
  });

  factory BidangBreakdownItem.fromJson(Map<String, dynamic> json, String countKey) {
    return BidangBreakdownItem(
      bidangId: json['bidang_id']?.toString() ?? '',
      namaBidang: json['nama_bidang']?.toString() ?? json['bidang_id']?.toString() ?? 'Lainnya',
      jumlah: json[countKey] is int
          ? json[countKey]
          : int.tryParse(json[countKey]?.toString() ?? '0') ?? (json['jumlah'] is int ? json['jumlah'] : 0),
    );
  }
}

class TUKKabupatenItem {
  final String kabupatenId;
  final String namaKabupaten;
  final int jumlahTuk;

  const TUKKabupatenItem({
    required this.kabupatenId,
    required this.namaKabupaten,
    required this.jumlahTuk,
  });

  factory TUKKabupatenItem.fromJson(Map<String, dynamic> json) {
    return TUKKabupatenItem(
      kabupatenId: json['kabupaten_id']?.toString() ?? '',
      namaKabupaten: json['nama_kabupaten']?.toString() ?? json['kabupaten']?.toString() ?? 'Kabupaten/Kota',
      jumlahTuk: json['jumlah_tuk'] is int
          ? json['jumlah_tuk']
          : int.tryParse(json['jumlah_tuk']?.toString() ?? '0') ?? (json['jumlah'] is int ? json['jumlah'] : 0),
    );
  }
}

class PenyebaranWilayahDetail {
  final String provinsiId;
  final String namaProvinsi;
  final int totalAsesor;
  final int totalTuk;
  final int totalAsesi;
  final List<BidangBreakdownItem> asesorByBidang;
  final List<TUKKabupatenItem> tukByKabupaten;
  final List<BidangBreakdownItem> asesiByBidang;

  const PenyebaranWilayahDetail({
    required this.provinsiId,
    required this.namaProvinsi,
    required this.totalAsesor,
    required this.totalTuk,
    required this.totalAsesi,
    required this.asesorByBidang,
    required this.tukByKabupaten,
    required this.asesiByBidang,
  });

  factory PenyebaranWilayahDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final summary = data['summary'] as Map<String, dynamic>? ?? {};
    final asesor = data['asesor'] as Map<String, dynamic>? ?? {};
    final tuk = data['tuk'] as Map<String, dynamic>? ?? {};
    final asesi = data['asesi'] as Map<String, dynamic>? ?? {};

    final asesorList = (asesor['by_bidang'] as List? ?? [])
        .map((e) => BidangBreakdownItem.fromJson(e as Map<String, dynamic>, 'jumlah_asesor'))
        .toList();

    final tukList = (tuk['by_kabupaten'] as List? ?? [])
        .map((e) => TUKKabupatenItem.fromJson(e as Map<String, dynamic>))
        .toList();

    final asesiList = (asesi['by_bidang'] as List? ?? [])
        .map((e) => BidangBreakdownItem.fromJson(e as Map<String, dynamic>, 'jumlah_asesi'))
        .toList();

    return PenyebaranWilayahDetail(
      provinsiId: data['provinsi_id']?.toString() ?? '0',
      namaProvinsi: data['nama_provinsi']?.toString() ?? '',
      totalAsesor: summary['total_asesor'] ?? asesor['total'] ?? 0,
      totalTuk: summary['total_tuk'] ?? tuk['total'] ?? 0,
      totalAsesi: summary['total_asesi'] ?? asesi['total'] ?? 0,
      asesorByBidang: asesorList,
      tukByKabupaten: tukList,
      asesiByBidang: asesiList,
    );
  }
}



