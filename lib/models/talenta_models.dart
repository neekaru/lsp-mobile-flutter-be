class TalentaItem {
  final int id;
  final String pemegang;
  final int skemaId;
  final String skema;
  final String kategori;
  final String nomorSertifikat;
  final String nomorRegistrasi;
  final String tanggalTerbit;
  final String tanggalBerlaku;
  final String status;
  final String kabupaten;
  final String provinsi;
  final String lokasi;
  final double? latitude;
  final double? longitude;
  final double? jarakKm;
  final String jarakLabel;
  final String telp;
  final String email;
  final int statusPencariKerja;
  final String statusPencariKerjaLabel;

  const TalentaItem({
    required this.id,
    required this.pemegang,
    required this.skemaId,
    required this.skema,
    required this.kategori,
    required this.nomorSertifikat,
    required this.nomorRegistrasi,
    required this.tanggalTerbit,
    required this.tanggalBerlaku,
    required this.status,
    required this.kabupaten,
    required this.provinsi,
    required this.lokasi,
    this.latitude,
    this.longitude,
    this.jarakKm,
    this.jarakLabel = '',
    this.telp = '',
    this.email = '',
    this.statusPencariKerja = 0,
    this.statusPencariKerjaLabel = '',
  });

  factory TalentaItem.fromJson(Map<String, dynamic> json) {
    return TalentaItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      pemegang: json['pemegang'] as String? ?? '-',
      skemaId: (json['skema_id'] as num?)?.toInt() ?? 0,
      skema: json['skema'] as String? ?? '',
      kategori: json['kategori'] as String? ?? '',
      nomorSertifikat: json['nomor_sertifikat'] as String? ?? '',
      nomorRegistrasi: json['nomor_registrasi'] as String? ?? '',
      tanggalTerbit: json['tanggal_terbit'] as String? ?? '',
      tanggalBerlaku: json['tanggal_berlaku'] as String? ?? '',
      status: json['status'] as String? ?? 'tidak_aktif',
      kabupaten: json['kabupaten'] as String? ?? '',
      provinsi: json['provinsi'] as String? ?? '',
      lokasi: json['lokasi'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      jarakKm: (json['jarak_km'] as num?)?.toDouble(),
      jarakLabel: json['jarak_label'] as String? ?? '',
      telp: json['telp'] as String? ?? '',
      email: json['email'] as String? ?? '',
      statusPencariKerja: (json['status_pencari_kerja'] as num?)?.toInt() ?? 0,
      statusPencariKerjaLabel: json['status_pencari_kerja_label'] as String? ?? '',
    );
  }

  bool get isAktif => status == 'aktif';
  bool get hasCoordinates => latitude != null && longitude != null;
  bool get hasKontak => telp.isNotEmpty || email.isNotEmpty;
  bool get isPencariKerjaAktif => statusPencariKerja == 1;
  bool get isBekerjaMencariPeluang => statusPencariKerja == 2;
}

class TalentaMeta {
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;
  final String? kabupatenId;
  final String? provinsiId;
  final int? skemaId;
  final int? statusPencariKerja;

  const TalentaMeta({
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
    this.kabupatenId,
    this.provinsiId,
    this.skemaId,
    this.statusPencariKerja,
  });

  factory TalentaMeta.fromJson(Map<String, dynamic> json) {
    return TalentaMeta(
      total: (json['total'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      hasMore: json['has_more'] as bool? ?? false,
      kabupatenId: json['kabupaten_id'] as String?,
      provinsiId: json['provinsi_id'] as String?,
      skemaId: (json['skema_id'] as num?)?.toInt(),
      statusPencariKerja: (json['status_pencari_kerja'] as num?)?.toInt(),
    );
  }
}

class TalentaResponse {
  final List<TalentaItem> data;
  final TalentaMeta meta;

  const TalentaResponse({
    required this.data,
    required this.meta,
  });

  factory TalentaResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => TalentaItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return TalentaResponse(
      data: list,
      meta: TalentaMeta.fromJson(json['meta'] as Map<String, dynamic>? ?? {}),
    );
  }

  static const empty = TalentaResponse(
    data: [],
    meta: TalentaMeta(total: 0, limit: 20, offset: 0, hasMore: false),
  );
}
