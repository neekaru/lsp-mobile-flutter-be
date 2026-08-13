// Admin Laporan Models

class AdminLaporanListResponse {
  final String status;
  final String message;
  final List<AdminLaporanListItem> data;
  final AdminLaporanPagination pagination;

  AdminLaporanListResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory AdminLaporanListResponse.fromJson(Map<String, dynamic> json) {
    return AdminLaporanListResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => AdminLaporanListItem.fromJson(item))
              .toList() ??
          [],
      pagination: AdminLaporanPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class AdminLaporanPagination {
  final int total;
  final int limit;
  final int offset;

  AdminLaporanPagination({
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory AdminLaporanPagination.fromJson(Map<String, dynamic> json) {
    return AdminLaporanPagination(
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 20,
      offset: json['offset'] ?? 0,
    );
  }
}

class AdminLaporanListItem {
  final int id;
  final String kodeLaporan;
  final String skemaSertifikasi;
  final String tanggalPelaksanaan;
  final String tuk;
  final String namaAsesor;
  final String status;
  final String statusPermohonanBlanko;

  AdminLaporanListItem({
    required this.id,
    required this.kodeLaporan,
    required this.skemaSertifikasi,
    required this.tanggalPelaksanaan,
    required this.tuk,
    required this.namaAsesor,
    required this.status,
    required this.statusPermohonanBlanko,
  });

  factory AdminLaporanListItem.fromJson(Map<String, dynamic> json) {
    return AdminLaporanListItem(
      id: json['id'] ?? 0,
      kodeLaporan: json['kode_laporan'] ?? '',
      skemaSertifikasi: json['skema_sertifikasi'] ?? '',
      tanggalPelaksanaan: json['tanggal_pelaksanaan'] ?? '',
      tuk: json['tuk'] ?? '',
      namaAsesor: json['nama_asesor'] ?? '',
      status: json['status'] ?? '',
      statusPermohonanBlanko: json['status_permohonan_blanko']?.toString() ?? '0',
    );
  }
}

class AdminLaporanDetailResponse {
  final String status;
  final String message;
  final AdminLaporanDetailData data;

  AdminLaporanDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AdminLaporanDetailResponse.fromJson(Map<String, dynamic> json) {
    return AdminLaporanDetailResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: AdminLaporanDetailData.fromJson(json['data'] ?? {}),
    );
  }
}

class AdminLaporanAsesorItem {
  final int id;
  final String namaAsesor;
  final String isComplete; // '0' or '1'
  final String linkRekaman;

  AdminLaporanAsesorItem({
    required this.id,
    required this.namaAsesor,
    required this.isComplete,
    required this.linkRekaman,
  });

  factory AdminLaporanAsesorItem.fromJson(Map<String, dynamic> json) {
    return AdminLaporanAsesorItem(
      id: json['id'] ?? 0,
      namaAsesor: json['nama_asesor'] ?? '',
      isComplete: json['is_complete']?.toString() ?? '0',
      linkRekaman: json['link_rekaman'] ?? '',
    );
  }
}

class AdminLaporanDetailData {
  final int id;
  final String kodeLaporan;
  final String status;
  final String namaAsesor;
  final String skemaSertifikasi;
  final String tanggalPelaksanaan;
  final String tuk;
  final String jenisAsesmen;
  final String linkDokumentasi;
  final String catatan;
  final AdminLaporanRingkasan ringkasan;
  final AdminLaporanDokumen dokumen;
  final List<AdminLaporanAsesiItem> daftarAsesiDinilai;
  final List<AdminLaporanLampiranItem> lampiranPendukung;
  final List<AdminLaporanAsesorItem> daftarAsesor;

  AdminLaporanDetailData({
    required this.id,
    required this.kodeLaporan,
    required this.status,
    required this.namaAsesor,
    required this.skemaSertifikasi,
    required this.tanggalPelaksanaan,
    required this.tuk,
    required this.jenisAsesmen,
    required this.linkDokumentasi,
    required this.catatan,
    required this.ringkasan,
    required this.dokumen,
    required this.daftarAsesiDinilai,
    required this.lampiranPendukung,
    required this.daftarAsesor,
  });

  factory AdminLaporanDetailData.fromJson(Map<String, dynamic> json) {
    return AdminLaporanDetailData(
      id: json['id'] ?? 0,
      kodeLaporan: json['kode_laporan'] ?? '',
      status: json['status'] ?? '',
      namaAsesor: json['nama_asesor'] ?? '',
      skemaSertifikasi: json['skema_sertifikasi'] ?? '',
      tanggalPelaksanaan: json['tanggal_pelaksanaan'] ?? '',
      tuk: json['tuk'] ?? json['nama_tuk'] ?? '',
      jenisAsesmen: json['jenis_asesmen'] ?? 'Offline',
      linkDokumentasi: json['link_dokumentasi'] ?? '',
      catatan: json['catatan'] ?? '',
      ringkasan: AdminLaporanRingkasan.fromJson(json['ringkasan'] ?? {}),
      dokumen: AdminLaporanDokumen.fromJson(json['dokumen'] ?? {}),
      daftarAsesiDinilai: (json['daftar_asesi_dinilai'] as List<dynamic>?)
              ?.map((item) => AdminLaporanAsesiItem.fromJson(item))
              .toList() ??
          [],
      lampiranPendukung: (json['lampiran_pendukung'] as List<dynamic>?)
              ?.map((item) => AdminLaporanLampiranItem.fromJson(item))
              .toList() ??
          [],
      daftarAsesor: (json['daftar_asesor'] as List<dynamic>?)
              ?.map((item) => AdminLaporanAsesorItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class AdminLaporanRingkasan {
  final int totalPeserta;
  final int hadir;
  final int absen;
  final int kompeten;
  final int belumKompeten;

  AdminLaporanRingkasan({
    required this.totalPeserta,
    required this.hadir,
    required this.absen,
    required this.kompeten,
    required this.belumKompeten,
  });

  factory AdminLaporanRingkasan.fromJson(Map<String, dynamic> json) {
    return AdminLaporanRingkasan(
      totalPeserta: json['total_peserta'] ?? 0,
      hadir: json['hadir'] ?? 0,
      absen: json['absen'] ?? 0,
      kompeten: json['kompeten'] ?? 0,
      belumKompeten: json['belum_kompeten'] ?? 0,
    );
  }
}

class AdminLaporanDokumen {
  final String suratTugasName;
  final String suratTugasUrl;

  AdminLaporanDokumen({
    required this.suratTugasName,
    required this.suratTugasUrl,
  });

  factory AdminLaporanDokumen.fromJson(Map<String, dynamic> json) {
    return AdminLaporanDokumen(
      suratTugasName: json['surat_tugas_name'] ?? '',
      suratTugasUrl: json['surat_tugas_url'] ?? '',
    );
  }
}

class AdminLaporanAsesiItem {
  final String nama;
  final String nim;
  final String kehadiran;
  final String penilaian;

  AdminLaporanAsesiItem({
    required this.nama,
    required this.nim,
    required this.kehadiran,
    required this.penilaian,
  });

  factory AdminLaporanAsesiItem.fromJson(Map<String, dynamic> json) {
    return AdminLaporanAsesiItem(
      nama: json['nama'] ?? '',
      nim: json['nim'] ?? '',
      kehadiran: json['kehadiran'] ?? '',
      penilaian: json['penilaian'] ?? '',
    );
  }
}

class AdminLaporanLampiranItem {
  final String title;
  final String fileName;
  final String fileUrl;
  final String fileSize;
  final bool isValid;

  AdminLaporanLampiranItem({
    required this.title,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.isValid,
  });

  factory AdminLaporanLampiranItem.fromJson(Map<String, dynamic> json) {
    return AdminLaporanLampiranItem(
      title: json['title'] ?? json['file_name'] ?? '',
      fileName: json['file_name'] ?? '',
      fileUrl: json['file_url'] ?? '',
      fileSize: json['file_size'] ?? '136KB',
      isValid: json['is_valid'] ?? (json['status'] == 'valid' || json['status'] == null),
    );
  }
}

class AdminLaporanApproveRequest {
  final String? catatan;

  AdminLaporanApproveRequest({this.catatan});

  Map<String, dynamic> toJson() {
    return {
      'catatan': catatan ?? '',
    };
  }
}

class AdminLaporanRejectRequest {
  final String alasan;

  AdminLaporanRejectRequest({required this.alasan});

  Map<String, dynamic> toJson() {
    return {
      'alasan': alasan,
    };
  }
}

class AdminLaporanActionResponse {
  final String status;
  final String message;
  final AdminLaporanActionData data;

  AdminLaporanActionResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AdminLaporanActionResponse.fromJson(Map<String, dynamic> json) {
    return AdminLaporanActionResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: AdminLaporanActionData.fromJson(json['data'] ?? {}),
    );
  }
}

class AdminLaporanActionData {
  final int id;
  final String status;

  AdminLaporanActionData({
    required this.id,
    required this.status,
  });

  factory AdminLaporanActionData.fromJson(Map<String, dynamic> json) {
    return AdminLaporanActionData(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}
