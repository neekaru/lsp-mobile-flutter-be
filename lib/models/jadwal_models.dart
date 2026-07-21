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

  /// Canonical internal status:
  /// draft(0) | completed(1) | canceled(2) | running(3) | pelaporan(4)
  final String status;

  /// Raw DB code: 0/1/2/3/4
  final String statusJadwal;

  /// Label dari BE (`status_label`), mis. Draft / Running
  final String statusLabel;
  final int jumlahAsesi;
  final List<String> asesor;
  final int sisaHari;
  final int?
  daysLate; // days_late — relevan untuk running (status_jadwal = "3")
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
    this.statusJadwal = '0',
    this.statusLabel = '',
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

  bool get isDraft =>
      status == 'draft' || status == 'waiting' || statusJadwal == '0';
  bool get isRunning => status == 'running' || statusJadwal == '3';

  /// Label tampilan: prioritaskan status_label BE
  String get displayStatusLabel {
    if (statusLabel.trim().isNotEmpty) return statusLabel.trim();
    switch (status) {
      case 'draft':
      case 'waiting':
        return 'Draft';
      case 'completed':
        return 'Completed';
      case 'canceled':
        return 'Canceled';
      case 'running':
        return 'Running';
      case 'pelaporan':
        return 'Pelaporan';
      default:
        return status;
    }
  }

  /// Canonical map: 0=Draft, 1=Completed, 2=Canceled, 3=Running, 4=Pelaporan
  static String mapStatusCode(String statusJadwal) {
    switch (statusJadwal) {
      case '0':
        return 'draft';
      case '1':
        return 'completed';
      case '2':
        return 'canceled';
      case '3':
        return 'running';
      case '4':
        return 'pelaporan';
      default:
        return 'draft';
    }
  }

  factory JadwalItem.fromJson(Map<String, dynamic> json) {
    final statusJadwal = json['status_jadwal']?.toString() ?? '0';
    final daysOverdue = json['days_overdue'] ?? 0;
    final daysLate = json['days_late'];
    final statusLabel = (json['status_label'] ?? '').toString();

    final totalAsesi = json['total_asesi'] ?? json['jumlah_asesi'] ?? 0;
    final jumlahKompeten = json['jumlah_kompeten'] ?? 0;
    final jumlahBelumKompeten = json['jumlah_belum_kompeten'] ?? 0;
    final needsAcc = json['needs_acc'] == true || json['needs_acc'] == 1;

    return JadwalItem(
      id: json['id'] ?? 0,
      skema: json['jadwal'] ?? json['nama_jadwal'] ?? '',
      tuk: json['tuk'] ?? '',
      tanggalMulai: json['tanggal'] ?? json['tanggal_mulai'] ?? '',
      tanggalSelesai: json['tanggal_akhir'] ?? json['tanggal_selesai'] ?? '',
      status: mapStatusCode(statusJadwal),
      statusJadwal: statusJadwal,
      statusLabel: statusLabel,
      jumlahAsesi: totalAsesi,
      asesor: _parseAsesor(json['asesor']),
      sisaHari: daysOverdue is int
          ? daysOverdue
          : int.tryParse('$daysOverdue') ?? 0,
      daysLate: daysLate == null
          ? null
          : (daysLate is int ? daysLate : int.tryParse('$daysLate')),
      catatan: json['catatan'],
      totalAsesi: totalAsesi is int
          ? totalAsesi
          : int.tryParse('$totalAsesi') ?? 0,
      jumlahKompeten: jumlahKompeten is int
          ? jumlahKompeten
          : int.tryParse('$jumlahKompeten') ?? 0,
      jumlahBelumKompeten: jumlahBelumKompeten is int
          ? jumlahBelumKompeten
          : int.tryParse('$jumlahBelumKompeten') ?? 0,
      needsAcc: needsAcc,
    );
  }
}

class JadwalStatistik {
  final int totalJadwal;
  final int draft;
  final int akanBerakhir;
  final int sedangBerjalan;
  final int selesai;
  final int terlambat;
  final String trendPercentage;

  const JadwalStatistik({
    required this.totalJadwal,
    this.draft = 0,
    required this.akanBerakhir,
    required this.sedangBerjalan,
    required this.selesai,
    this.terlambat = 0,
    this.trendPercentage = '+0%',
  });

  factory JadwalStatistik.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final meta = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : <String, dynamic>{};

    int readInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('$v') ?? 0;
    }

    return JadwalStatistik(
      totalJadwal: readInt(data['total_jadwal']),
      draft: readInt(data['draft']),
      akanBerakhir: readInt(data['akan_berakhir']),
      sedangBerjalan: readInt(data['sedang_berjalan']),
      selesai: readInt(data['selesai']),
      terlambat: readInt(data['terlambat']),
      trendPercentage: _normalizeTrend(
        meta['trend_percentage']?.toString() ??
            data['trend_percentage']?.toString(),
      ),
    );
  }

  static String _normalizeTrend(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return '+0%';
    final upper = v.toUpperCase();
    if (upper == 'N/A' || upper == 'NA' || upper == '-' || upper == 'NULL') {
      return '+0%';
    }
    return v;
  }

  factory JadwalStatistik.fallback() {
    return const JadwalStatistik(
      totalJadwal: 0,
      draft: 0,
      akanBerakhir: 0,
      sedangBerjalan: 0,
      selesai: 0,
      terlambat: 0,
      trendPercentage: '+0%',
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
      statusKelengkapan: StatusKelengkapan.fromJson(
        json['status_kelengkapan'] ?? {},
      ),
      statusAssessment: StatusAssessment.fromJson(
        json['status_assessment'] ?? {},
      ),
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
