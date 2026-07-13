// ============================================================================
// Jadwal Models
// ============================================================================

List<String> _parseAsesor(dynamic jsonVal) {
  if (jsonVal == null) {
    return [];
  }
  if (jsonVal is List) {
    return jsonVal
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  if (jsonVal is String) {
    final trimmed = jsonVal.trim();
    if (trimmed.isEmpty || trimmed == '-') {
      return [];
    }
    return [trimmed];
  }
  return [];
}

class JadwalItem {
  final int id;
  final String skema;
  final String tuk;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String status; // 'akan_berakhir', 'sedang_berjalan', 'selesai'
  final int jumlahAsesi;
  final List<String> asesor;
  final int sisaHari; // untuk status akan_berakhir
  final int? daysLate; // untuk status sedang_berjalan (status_jadwal = "2")
  final String? catatan;
  final int totalAsesi;
  final int jumlahKompeten;
  final int jumlahBelumKompeten;
  final bool needsAcc;

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
    this.daysLate,
    this.catatan,
    this.totalAsesi = 0,
    this.jumlahKompeten = 0,
    this.jumlahBelumKompeten = 0,
    this.needsAcc = false,
  });

  factory JadwalItem.fromJson(Map<String, dynamic> json) {
    // Map status_jadwal dari API ke status internal
    String mapStatus(String statusJadwal, int daysOverdue) {
      switch (statusJadwal) {
        case '0': // Waiting / Draft
          return 'waiting';
        case '1': // Completed
          return 'completed';
        case '2': // Canceled
          return 'canceled';
        case '3': // Running
          return 'running';
        case '4': // Pelaporan
          return 'pelaporan';
        default:
          return 'waiting';
      }
    }

    final statusJadwal = json['status_jadwal']?.toString() ?? '1';
    final daysOverdue = json['days_overdue'] ?? 0;
    final daysLate = json['days_late']; // Nullable, hanya untuk status "2"

    final totalAsesi = json['total_asesi'] ?? json['jumlah_asesi'] ?? 0;
    final jumlahKompeten = json['jumlah_kompeten'] ?? 0;
    final jumlahBelumKompeten = json['jumlah_belum_kompeten'] ?? 0;
    final needsAcc = json['needs_acc'] ?? false;

    return JadwalItem(
      id: json['id'] ?? 0,
      skema: json['jadwal'] ?? '', // API uses 'jadwal' field
      tuk: json['tuk'] ?? '',
      tanggalMulai: json['tanggal'] ?? json['tanggal_mulai'] ?? '',
      tanggalSelesai: json['tanggal_akhir'] ?? json['tanggal_selesai'] ?? '',
      status: mapStatus(statusJadwal, daysOverdue),
      jumlahAsesi: totalAsesi,
      asesor: _parseAsesor(json['asesor']),
      sisaHari: daysOverdue, // days_overdue from API
      daysLate: daysLate, // days_late from API (only for status "2")
      catatan: json['catatan'],
      totalAsesi: totalAsesi,
      jumlahKompeten: jumlahKompeten,
      jumlahBelumKompeten: jumlahBelumKompeten,
      needsAcc: needsAcc,
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

  const UserRole({required this.role, required this.name, required this.email});

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get canEditSchedule => isAdmin;
}

// ============================================================================
// Notification Models
// ============================================================================

class NotificationCount {
  final int count;

  const NotificationCount({required this.count});

  factory NotificationCount.fromJson(Map<String, dynamic> json) {
    return NotificationCount(count: json['count'] ?? 0);
  }
}

class WaitingSchedule {
  final int id;
  final String jadwal;
  final String tanggal;
  final String? tanggalAkhir;
  final String statusJadwal;
  final String statusLabel;
  final String? idLsp;
  final int idTuk;
  final String tuk;
  final int jumlahAsesi;
  final List<String> asesor;
  final int totalAsesi;
  final int jumlahKompeten;
  final int jumlahBelumKompeten;

  const WaitingSchedule({
    required this.id,
    required this.jadwal,
    required this.tanggal,
    this.tanggalAkhir,
    required this.statusJadwal,
    required this.statusLabel,
    this.idLsp,
    required this.idTuk,
    required this.tuk,
    required this.jumlahAsesi,
    required this.asesor,
    this.totalAsesi = 0,
    this.jumlahKompeten = 0,
    this.jumlahBelumKompeten = 0,
  });

  factory WaitingSchedule.fromJson(Map<String, dynamic> json) {
    final totalAsesi = json['total_asesi'] ?? json['jumlah_asesi'] ?? 0;
    final jumlahKompeten = json['jumlah_kompeten'] ?? 0;
    final jumlahBelumKompeten = json['jumlah_belum_kompeten'] ?? 0;

    return WaitingSchedule(
      id: json['id'] ?? 0,
      jadwal: json['jadwal'] ?? '',
      tanggal: json['tanggal'] ?? '',
      tanggalAkhir: json['tanggal_akhir'],
      statusJadwal: json['status_jadwal']?.toString() ?? '0',
      statusLabel: json['status_label'] ?? 'Draft/Baru',
      idLsp: json['id_lsp'],
      idTuk: json['id_tuk'] ?? 0,
      tuk: json['tuk'] ?? '',
      jumlahAsesi: totalAsesi,
      asesor: _parseAsesor(json['asesor']),
      totalAsesi: totalAsesi,
      jumlahKompeten: jumlahKompeten,
      jumlahBelumKompeten: jumlahBelumKompeten,
    );
  }
}

class WaitingScheduleResponse {
  final List<WaitingSchedule> data;
  final NotificationMeta meta;

  const WaitingScheduleResponse({required this.data, required this.meta});

  factory WaitingScheduleResponse.fromJson(Map<String, dynamic> json) {
    return WaitingScheduleResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => WaitingSchedule.fromJson(item))
              .toList() ??
          [],
      meta: NotificationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class NotificationMeta {
  final int totalWaiting;
  final int limit;
  final String sortBy;
  final String sortOrder;

  const NotificationMeta({
    required this.totalWaiting,
    required this.limit,
    required this.sortBy,
    required this.sortOrder,
  });

  factory NotificationMeta.fromJson(Map<String, dynamic> json) {
    return NotificationMeta(
      totalWaiting: json['total_waiting'] ?? 0,
      limit: json['limit'] ?? 20,
      sortBy: json['sort_by'] ?? 'tanggal',
      sortOrder: json['sort_order'] ?? 'desc',
    );
  }
}

// ============================================================================
// Asesi List Models
// ============================================================================

class AsesiItem {
  final int id;
  final String namaLengkap;
  final String? hasilRekomendasi; // 'K', 'BK', or null

  const AsesiItem({
    required this.id,
    required this.namaLengkap,
    this.hasilRekomendasi,
  });

  factory AsesiItem.fromJson(Map<String, dynamic> json) {
    return AsesiItem(
      id: json['id'] ?? 0,
      namaLengkap: json['nama_lengkap'] ?? '',
      hasilRekomendasi: json['hasil_rekomendasi'],
    );
  }
}

class AsesiMeta {
  final int jadwalId;
  final int totalAsesi;
  final int jumlahKompeten;
  final int jumlahBelumKompeten;
  final int jumlahBelumDinilai;

  const AsesiMeta({
    required this.jadwalId,
    required this.totalAsesi,
    required this.jumlahKompeten,
    required this.jumlahBelumKompeten,
    required this.jumlahBelumDinilai,
  });

  factory AsesiMeta.fromJson(Map<String, dynamic> json) {
    return AsesiMeta(
      jadwalId: json['jadwal_id'] ?? 0,
      totalAsesi: json['total_asesi'] ?? 0,
      jumlahKompeten: json['jumlah_kompeten'] ?? 0,
      jumlahBelumKompeten: json['jumlah_belum_kompeten'] ?? 0,
      jumlahBelumDinilai: json['jumlah_belum_dinilai'] ?? 0,
    );
  }
}

class AsesiListResponse {
  final List<AsesiItem> data;
  final AsesiMeta meta;

  const AsesiListResponse({required this.data, required this.meta});

  factory AsesiListResponse.fromJson(Map<String, dynamic> json) {
    return AsesiListResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => AsesiItem.fromJson(item))
              .toList() ??
          [],
      meta: AsesiMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class JadwalAsesorDetailResponse {
  final JadwalAsesorDetailData data;
  final int totalAsesor;

  const JadwalAsesorDetailResponse({
    required this.data,
    required this.totalAsesor,
  });

  factory JadwalAsesorDetailResponse.fromJson(Map<String, dynamic> json) {
    return JadwalAsesorDetailResponse(
      data: JadwalAsesorDetailData.fromJson(json['data'] ?? {}),
      totalAsesor: json['meta']?['total_asesor'] ?? 0,
    );
  }
}

class JadwalAsesorDetailData {
  final int id;
  final String jadwal;
  final String tanggal;
  final String tanggalAkhir;
  final String statusJadwal;
  final String statusLabel;
  final int idTuk;
  final String tuk;
  final String alamatTuk;
  final String jenisTuk;
  final List<AsesorDetailItem> asesor;
  final String? waktuAsesmen;
  final String? leadAsesor;
  final int? jumlahPeserta;

  const JadwalAsesorDetailData({
    required this.id,
    required this.jadwal,
    required this.tanggal,
    required this.tanggalAkhir,
    required this.statusJadwal,
    required this.statusLabel,
    required this.idTuk,
    required this.tuk,
    required this.alamatTuk,
    required this.jenisTuk,
    required this.asesor,
    this.waktuAsesmen,
    this.leadAsesor,
    this.jumlahPeserta,
  });

  factory JadwalAsesorDetailData.fromJson(Map<String, dynamic> json) {
    return JadwalAsesorDetailData(
      id: json['id'] ?? 0,
      jadwal: json['jadwal'] ?? json['nama_jadwal'] ?? '',
      tanggal: json['tanggal'] ?? json['tanggal_asesmen'] ?? '',
      tanggalAkhir: json['tanggal_akhir'] ?? json['tanggal_asesmen'] ?? '',
      statusJadwal: json['status_jadwal']?.toString() ?? '',
      statusLabel: json['status_label'] ?? '',
      idTuk: json['id_tuk'] ?? 0,
      tuk: json['tuk'] ?? '',
      alamatTuk: json['alamat_tuk'] ?? json['lokasi_asesmen'] ?? '',
      jenisTuk: json['jenis_tuk'] ?? '',
      waktuAsesmen: json['waktu_asesmen'],
      leadAsesor: json['lead_asesor'],
      jumlahPeserta: json['jumlah_peserta'],
      asesor:
          (json['asesor'] as List<dynamic>?)
              ?.map(
                (item) =>
                    AsesorDetailItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class AsesorDetailItem {
  final int idAsesor;
  final String namaAsesor;
  final String noReg;
  final String email;
  final String hp;
  final String jenisAsesmen;
  final String statusSpt;
  final String isComplete;
  final String? sertifikatAsesor;
  final String? sertifikatTeknis;
  final String masaBerlaku;
  final String kabupatenKota;
  final String provinsiId;
  final String kabupatenId;
  final int totalAsesmen;

  const AsesorDetailItem({
    required this.idAsesor,
    required this.namaAsesor,
    required this.noReg,
    required this.email,
    required this.hp,
    required this.jenisAsesmen,
    required this.statusSpt,
    required this.isComplete,
    this.sertifikatAsesor,
    this.sertifikatTeknis,
    required this.masaBerlaku,
    required this.kabupatenKota,
    required this.provinsiId,
    required this.kabupatenId,
    this.totalAsesmen = 0,
  });

  factory AsesorDetailItem.fromJson(Map<String, dynamic> json) {
    return AsesorDetailItem(
      idAsesor: json['id_asesor'] ?? 0,
      namaAsesor: json['nama_asesor'] ?? '',
      noReg: json['no_reg'] ?? '',
      email: json['email'] ?? '',
      hp: json['hp'] ?? '',
      jenisAsesmen: json['jenis_asesmen']?.toString() ?? '',
      statusSpt: json['status_spt']?.toString() ?? '',
      isComplete: json['is_complete']?.toString() ?? '',
      sertifikatAsesor: json['sertifikat_asesor'],
      sertifikatTeknis: json['sertifikat_teknis'],
      masaBerlaku: json['masa_berlaku'] ?? '',
      kabupatenKota: json['kabupaten_kota'] ?? '',
      provinsiId: json['provinsi_id']?.toString() ?? '',
      kabupatenId: json['kabupaten_id']?.toString() ?? '',
      totalAsesmen: json['total_asesmen'] ?? 0,
    );
  }
}

class ParticipantDetailResponse {
  final String status;
  final String message;
  final ParticipantDetailData data;

  const ParticipantDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ParticipantDetailResponse.fromJson(Map<String, dynamic> json) {
    return ParticipantDetailResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: ParticipantDetailData.fromJson(json['data'] ?? {}),
    );
  }
}

class ParticipantDetailData {
  final int pesertaId;
  final String noPeserta;
  final String namaLengkap;
  final String nik;
  final String tempatLahir;
  final String tanggalLahir;
  final String skemaSertifikat;
  final String institusi;
  final String email;
  final String noTelepon;
  final StatusKelengkapan statusKelengkapan;
  final StatusAssessment statusAssessment;

  const ParticipantDetailData({
    required this.pesertaId,
    required this.noPeserta,
    required this.namaLengkap,
    required this.nik,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.skemaSertifikat,
    required this.institusi,
    required this.email,
    required this.noTelepon,
    required this.statusKelengkapan,
    required this.statusAssessment,
  });

  factory ParticipantDetailData.fromJson(Map<String, dynamic> json) {
    return ParticipantDetailData(
      pesertaId: json['peserta_id'] ?? 0,
      noPeserta: json['no_peserta'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      nik: json['nik'] ?? '',
      tempatLahir: json['tempat_lahir'] ?? '',
      tanggalLahir: json['tanggal_lahir'] ?? '',
      skemaSertifikat: json['skema_sertifikat'] ?? '',
      institusi: json['institusi'] ?? '',
      email: json['email'] ?? '',
      noTelepon: json['no_telepon'] ?? '',
      statusKelengkapan: StatusKelengkapan.fromJson(json['status_kelengkapan'] ?? {}),
      statusAssessment: StatusAssessment.fromJson(json['status_assessment'] ?? {}),
    );
  }
}

class StatusKelengkapan {
  final String portofolio;
  final String dokumenPendukung;
  final String persyaratan;

  const StatusKelengkapan({
    required this.portofolio,
    required this.dokumenPendukung,
    required this.persyaratan,
  });

  factory StatusKelengkapan.fromJson(Map<String, dynamic> json) {
    return StatusKelengkapan(
      portofolio: json['portofolio'] ?? '',
      dokumenPendukung: json['dokumen_pendukung'] ?? '',
      persyaratan: json['persyaratan'] ?? '',
    );
  }
}

class StatusAssessment {
  final String kehadiran;
  final String tugasAsesmen;
  final String laporan;
  final String rekaman;

  const StatusAssessment({
    required this.kehadiran,
    required this.tugasAsesmen,
    required this.laporan,
    required this.rekaman,
  });

  factory StatusAssessment.fromJson(Map<String, dynamic> json) {
    return StatusAssessment(
      kehadiran: json['kehadiran'] ?? '',
      tugasAsesmen: json['tugas_asesmen'] ?? '',
      laporan: json['laporan'] ?? '',
      rekaman: json['rekaman'] ?? '',
    );
  }
}
