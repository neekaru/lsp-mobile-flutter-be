class AsesorStatistikResponse {
  final String status;
  final String message;
  final AsesorStatistikData data;

  const AsesorStatistikResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AsesorStatistikResponse.fromJson(Map<String, dynamic> json) {
    return AsesorStatistikResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: AsesorStatistikData.fromJson(
        (json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : {},
      ),
    );
  }
}

class AsesorStatistikData {
  final int tahun;
  final int asesorId;
  final String namaAsesor;
  final String statusMasaBerlaku;
  final String? tglExpired;
  final int totalSpt;
  final int totalAsesi;
  final List<AsesorStatistikBulanItem> bulanan;

  const AsesorStatistikData({
    required this.tahun,
    required this.asesorId,
    required this.namaAsesor,
    required this.statusMasaBerlaku,
    this.tglExpired,
    required this.totalSpt,
    required this.totalAsesi,
    required this.bulanan,
  });

  factory AsesorStatistikData.fromJson(Map<String, dynamic> json) {
    final rawList = json['bulanan'] as List<dynamic>? ?? [];
    return AsesorStatistikData(
      tahun: json['tahun'] is int
          ? json['tahun']
          : int.tryParse(json['tahun']?.toString() ?? '') ?? 2026,
      asesorId: json['asesor_id'] is int
          ? json['asesor_id']
          : int.tryParse(json['asesor_id']?.toString() ?? '') ?? 0,
      namaAsesor: json['nama_asesor']?.toString() ?? '',
      statusMasaBerlaku: json['status_masa_berlaku']?.toString() ?? 'Aktif',
      tglExpired: json['tgl_expired']?.toString(),
      totalSpt: json['total_spt'] is int
          ? json['total_spt']
          : int.tryParse(json['total_spt']?.toString() ?? '') ?? 0,
      totalAsesi: json['total_asesi'] is int
          ? json['total_asesi']
          : int.tryParse(json['total_asesi']?.toString() ?? '') ?? 0,
      bulanan: rawList
          .map((e) =>
              AsesorStatistikBulanItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory AsesorStatistikData.empty({int tahun = 2026}) {
    return AsesorStatistikData(
      tahun: tahun,
      asesorId: 0,
      namaAsesor: '',
      statusMasaBerlaku: 'Aktif',
      tglExpired: null,
      totalSpt: 0,
      totalAsesi: 0,
      bulanan: [],
    );
  }
}

class AsesorStatistikBulanItem {
  final int month;
  final String bulan;
  final int jumlahSpt;
  final int jumlahAsesi;

  const AsesorStatistikBulanItem({
    required this.month,
    required this.bulan,
    required this.jumlahSpt,
    required this.jumlahAsesi,
  });

  factory AsesorStatistikBulanItem.fromJson(Map<String, dynamic> json) {
    return AsesorStatistikBulanItem(
      month: json['month'] is int
          ? json['month']
          : int.tryParse(json['month']?.toString() ?? '') ?? 0,
      bulan: json['bulan']?.toString() ?? '',
      jumlahSpt: json['jumlah_spt'] is int
          ? json['jumlah_spt']
          : int.tryParse(json['jumlah_spt']?.toString() ?? '') ?? 0,
      jumlahAsesi: json['jumlah_asesi'] is int
          ? json['jumlah_asesi']
          : int.tryParse(json['jumlah_asesi']?.toString() ?? '') ?? 0,
    );
  }
}
