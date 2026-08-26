// ============================================================================
// Model list & ringkasan asesi (untuk asesor).
// Diekstrak dari asesor_asesi_models.dart.
// ============================================================================

class AsesorAsesiItem {
  final int id;
  final String namaLengkap;
  final String nik;
  final String email;
  final String telp;
  final String jenisKelamin;
  final String tempatLahir;
  final String tglLahir;
  final String alamat;
  final String idSkema;
  final String skema;
  final int jadwalId;
  final String jadwalNama;
  final String jadwalTanggal;
  final int idTuk;
  final String tukNama;
  final String rekomendasiAsesor;
  final String isKompeten;
  final String? fotoProfil;
  final String? fotoProfilUrl;

  AsesorAsesiItem({
    required this.id,
    required this.namaLengkap,
    required this.nik,
    required this.email,
    required this.telp,
    required this.jenisKelamin,
    required this.tempatLahir,
    required this.tglLahir,
    required this.alamat,
    required this.idSkema,
    required this.skema,
    required this.jadwalId,
    required this.jadwalNama,
    required this.jadwalTanggal,
    required this.idTuk,
    required this.tukNama,
    required this.rekomendasiAsesor,
    required this.isKompeten,
    this.fotoProfil,
    this.fotoProfilUrl,
  });

  factory AsesorAsesiItem.fromJson(Map<String, dynamic> json) {
    return AsesorAsesiItem(
      id: json['id'] as int? ?? 0,
      namaLengkap: json['nama_lengkap'] as String? ?? '',
      nik: json['nik'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telp: json['telp'] as String? ?? '',
      jenisKelamin: json['jenis_kelamin'] as String? ?? '',
      tempatLahir: json['tempat_lahir'] as String? ?? '',
      tglLahir: json['tgl_lahir'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
      idSkema: json['id_skema']?.toString() ?? '',
      skema: json['skema'] as String? ?? '',
      jadwalId: json['jadwal_id'] as int? ?? 0,
      jadwalNama: json['jadwal_nama'] as String? ?? '',
      jadwalTanggal: json['jadwal_tanggal'] as String? ?? '',
      idTuk: json['id_tuk'] as int? ?? 0,
      tukNama: json['tuk_nama'] as String? ?? '',
      rekomendasiAsesor: json['rekomendasi_asesor'] as String? ?? 'Belum Rekomendasi',
      isKompeten: json['is_kompeten'] as String? ?? '',
      fotoProfil: json['foto_profil'] as String?,
      fotoProfilUrl: json['foto_profil_url'] as String?,
    );
  }
}

class AsesorAsesiSummary {
  final int totalAll;
  final int totalBelumDinilai;
  final int totalSudahDinilai;
  final int totalKompeten;
  final int totalBelumKompeten;

  AsesorAsesiSummary({
    required this.totalAll,
    required this.totalBelumDinilai,
    required this.totalSudahDinilai,
    required this.totalKompeten,
    required this.totalBelumKompeten,
  });

  factory AsesorAsesiSummary.fromJson(Map<String, dynamic> json) {
    return AsesorAsesiSummary(
      totalAll: json['total_all'] as int? ?? 0,
      totalBelumDinilai: json['total_belum_dinilai'] as int? ?? 0,
      totalSudahDinilai: json['total_sudah_dinilai'] as int? ?? 0,
      totalKompeten: json['total_kompeten'] as int? ?? 0,
      totalBelumKompeten: json['total_belum_kompeten'] as int? ?? 0,
    );
  }
}

class AsesorAsesiListResponse {
  final String status;
  final String message;
  final List<AsesorAsesiItem> data;
  final AsesorAsesiSummary? summary;
  final int total;
  final int page;
  final int perPage;
  final int totalPages;

  AsesorAsesiListResponse({
    required this.status,
    required this.message,
    required this.data,
    this.summary,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });

  factory AsesorAsesiListResponse.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    final summaryJson = json['summary'] as Map<String, dynamic>?;
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((item) => AsesorAsesiItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return AsesorAsesiListResponse(
      status: json['status'] as String? ?? 'success',
      message: json['message'] as String? ?? '',
      data: list,
      summary: summaryJson != null ? AsesorAsesiSummary.fromJson(summaryJson) : null,
      total: pagination['total'] as int? ?? list.length,
      page: pagination['page'] as int? ?? 1,
      perPage: pagination['per_page'] as int? ?? 20,
      totalPages: pagination['total_pages'] as int? ?? 1,
    );
  }
}
