import '../utils/json_helper.dart';

import 'jadwal_models.dart';
import 'asesor_statistik_models.dart';

// ============================================================================
// Asesor Dashboard Model
// ============================================================================

class AsesorDashboardSummaryCount {
  final int jumlahSpt2026;
  final int jumlahMuk2026;
  final int jumlahMitra;
  final int menungguVerifikasi;
  final int asesmenBerlangsung;
  final int asesmenSelesai;
  final int menungguPenugasan;

  const AsesorDashboardSummaryCount({
    this.jumlahSpt2026 = 0,
    this.jumlahMuk2026 = 0,
    this.jumlahMitra = 0,
    required this.menungguVerifikasi,
    required this.asesmenBerlangsung,
    required this.asesmenSelesai,
    required this.menungguPenugasan,
  });

  factory AsesorDashboardSummaryCount.fromJson(Map<String, dynamic> json) {
    return AsesorDashboardSummaryCount(
      jumlahSpt2026: json['jumlah_spt_2026'] ?? json['total_spt'] ?? 0,
      jumlahMuk2026: json['jumlah_muk_2026'] ?? json['jumlah_muk'] ?? 0,
      jumlahMitra: json['jumlah_mitra'] ?? 0,
      menungguVerifikasi: json['menunggu_verifikasi'] ?? 0,
      asesmenBerlangsung: json['asesmen_berlangsung'] ?? 0,
      asesmenSelesai: json['asesmen_selesai'] ?? 0,
      menungguPenugasan: json['menunggu_penugasan'] ?? 0,
    );
  }

  factory AsesorDashboardSummaryCount.empty() {
    return const AsesorDashboardSummaryCount(
      jumlahSpt2026: 0,
      jumlahMuk2026: 0,
      jumlahMitra: 0,
      menungguVerifikasi: 0,
      asesmenBerlangsung: 0,
      asesmenSelesai: 0,
      menungguPenugasan: 0,
    );
  }
}

class AsesorDashboardAlertBanner {
  final bool hasAlert;
  final String title;
  final String subtitle;

  const AsesorDashboardAlertBanner({
    required this.hasAlert,
    required this.title,
    required this.subtitle,
  });

  factory AsesorDashboardAlertBanner.fromJson(Map<String, dynamic> json) {
    return AsesorDashboardAlertBanner(
      hasAlert: json['has_alert'] ?? false,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
    );
  }

  factory AsesorDashboardAlertBanner.empty() {
    return const AsesorDashboardAlertBanner(
      hasAlert: false,
      title: '',
      subtitle: '',
    );
  }
}

class AsesorDashboardJadwal {
  final int idJadwal;
  final String namaJadwal;
  final String skema;
  final String tanggal;
  final String waktu;
  final String tuk;
  final String status;
  final String? jenisUji;
  final bool? isAjj;
  final int kuota;
  final int totalAsesi;

  const AsesorDashboardJadwal({
    required this.idJadwal,
    this.namaJadwal = '',
    required this.skema,
    required this.tanggal,
    required this.waktu,
    required this.tuk,
    required this.status,
    this.jenisUji,
    this.isAjj,
    this.kuota = 0,
    this.totalAsesi = 0,
  });
  String get statusLabel {
    switch (status.toLowerCase().trim()) {
      case '0':
      case 'draft':
      case 'waiting':
        return 'Menunggu';
      case '1':
      case 'completed':
      case 'selesai':
        return 'Selesai';
      case '2':
      case 'canceled':
      case 'dibatalkan':
        return 'Dibatalkan';
      case '3':
      case 'running':
      case 'berlangsung':
        return 'Berlangsung';
      case '4':
      case 'pelaporan':
        return 'Pelaporan';
      default:
        return status;
    }
  }

  bool get isAJJ => isSjj;
  bool get isSjj {
    if (isAjj == true) return true;
    if (jenisUji?.trim() == '1' ||
        jenisUji?.trim().toUpperCase() == 'AJJ' ||
        jenisUji?.trim().toLowerCase() == 'online') {
      return true;
    }
    final s = '$namaJadwal $skema'.toUpperCase();
    final t = tuk.toUpperCase();
    return s.contains('AJJ') ||
        s.contains('JARAK JAUH') ||
        s.contains('ONLINE') ||
        t.contains('AJJ') ||
        t.contains('JARAK JAUH') ||
        t.contains('ONLINE');
  }

  factory AsesorDashboardJadwal.fromJson(Map<String, dynamic> json) {
    final isAjj = JsonHelper.asBool(json['is_ajj']);
    final kuotaVal = JsonHelper.asInt(json['kuota']);
    final totalAsesiVal = JsonHelper.asInt(json['total_asesi']);

    return AsesorDashboardJadwal(
      idJadwal: json['id_jadwal'] ?? 0,
      namaJadwal: json['nama_jadwal'] ?? json['jadwal'] ?? json['jadual'] ?? '',
      skema: json['skema'] ?? '',
      tanggal: json['tanggal'] ?? '',
      waktu: json['waktu'] ?? '',
      tuk: (json['tuk'] != null && json['tuk'].toString().trim().isNotEmpty)
          ? json['tuk'].toString()
          : (json['lokasi_tuk']?.toString() ?? ''),
      status: json['status']?.toString() ?? '0',
      jenisUji: json['jenis_uji']?.toString(),
      isAjj: isAjj,
      kuota: kuotaVal,
      totalAsesi: totalAsesiVal,
    );
  }

  JadwalItem toJadwalItem() {
    return JadwalItem(
      id: idJadwal,
      skema: skema.isNotEmpty
          ? skema
          : (namaJadwal.isNotEmpty ? namaJadwal : 'Jadwal Asesmen'),
      tuk: tuk,
      tanggalMulai: tanggal,
      tanggalSelesai: tanggal,
      status: JadwalItem.mapStatusCode(status),
      statusJadwal: status,
      statusLabel: statusLabel,
      jumlahAsesi: totalAsesi > 0 ? totalAsesi : kuota,
      totalAsesi: totalAsesi,
      kuota: kuota,
      asesor: const [],
      sisaHari: 0,
      jenisUji: jenisUji,
      isAjj: isAjj,
    );
  }
}

class AsesorDashboardTugas {
  final int idTugas;
  final int idJadwal;
  final String title;
  final String subtitle;
  final String type;
  final String? jenisUji;
  final bool? isAjj;

  const AsesorDashboardTugas({
    required this.idTugas,
    required this.idJadwal,
    required this.title,
    required this.subtitle,
    required this.type,
    this.jenisUji,
    this.isAjj,
  });

  bool get isAJJ => isSjj;
  bool get isSjj {
    if (isAjj == true) return true;
    if (jenisUji?.trim() == '1' ||
        jenisUji?.trim().toUpperCase() == 'AJJ' ||
        jenisUji?.trim().toLowerCase() == 'online') {
      return true;
    }
    final s = subtitle.toUpperCase();
    final t = title.toUpperCase();
    return s.contains('AJJ') ||
        s.contains('JARAK JAUH') ||
        s.contains('ONLINE') ||
        t.contains('AJJ') ||
        t.contains('JARAK JAUH') ||
        t.contains('ONLINE');
  }

  factory AsesorDashboardTugas.fromJson(Map<String, dynamic> json) {
    final rawIdTugas = json['id_tugas'];
    final parsedIdTugas = rawIdTugas is int
        ? rawIdTugas
        : int.tryParse(rawIdTugas?.toString() ?? '0') ?? 0;

    final rawIdJadwal = json['id_jadwal'];
    final parsedIdJadwal = rawIdJadwal != null
        ? (rawIdJadwal is int
              ? rawIdJadwal
              : int.tryParse(rawIdJadwal.toString()) ?? 0)
        : parsedIdTugas;

    final rawIsAjj = json['is_ajj'];
    final isAjj =
        rawIsAjj == true ||
        rawIsAjj == 1 ||
        rawIsAjj == '1' ||
        rawIsAjj == 'true';

    return AsesorDashboardTugas(
      idTugas: parsedIdTugas,
      idJadwal: parsedIdJadwal,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      jenisUji: json['jenis_uji']?.toString(),
      isAjj: isAjj,
    );
  }

  JadwalItem toJadwalItem() {
    final effectiveId = idJadwal > 0 ? idJadwal : idTugas;
    return JadwalItem(
      id: effectiveId,
      skema: subtitle,
      tuk: '',
      tanggalMulai: '',
      tanggalSelesai: '',
      status: type == 'asesmen_berlangsung' ? 'running' : 'pelaporan',
      statusJadwal: type == 'asesmen_berlangsung' ? '3' : '4',
      jumlahAsesi: 0,
      asesor: const [],
      sisaHari: 0,
      jenisUji: jenisUji,
      isAjj: isAjj,
    );
  }
}

class AsesorDashboardData {
  final AsesorDashboardSummaryCount summary;
  final AsesorDashboardAlertBanner alertBanner;
  final List<AsesorDashboardJadwal> jadwalHariIni;
  final List<AsesorDashboardTugas> jadwalBelumLengkap;
  final List<AsesorMitra> mitra;
  final AsesorStatistikData? statistikBulanan;

  List<AsesorDashboardTugas> get tugasPrioritas => jadwalBelumLengkap;

  const AsesorDashboardData({
    required this.summary,
    required this.alertBanner,
    required this.jadwalHariIni,
    required this.jadwalBelumLengkap,
    this.mitra = const [],
    this.statistikBulanan,
  });

  factory AsesorDashboardData.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'] ?? {};
    final alertJson = json['alert_banner'] ?? {};
    final List<dynamic> jadwalList = json['jadwal_hari_ini'] ?? [];
    final List<dynamic> tugasList = json['jadwal_belum_lengkap'] ?? json['tugas_prioritas'] ?? [];
    final List<dynamic> mitraList = json['mitra'] ?? [];
    final statJson = json['statistik_bulanan'];

    return AsesorDashboardData(
      summary: AsesorDashboardSummaryCount.fromJson(summaryJson),
      alertBanner: AsesorDashboardAlertBanner.fromJson(alertJson),
      jadwalHariIni: jadwalList.map((j) => AsesorDashboardJadwal.fromJson(j)).toList(),
      jadwalBelumLengkap: tugasList.map((t) => AsesorDashboardTugas.fromJson(t)).toList(),
      mitra: mitraList.map((m) => AsesorMitra.fromJson(m as Map<String, dynamic>)).toList(),
      statistikBulanan: statJson is Map<String, dynamic> ? AsesorStatistikData.fromJson(statJson) : null,
    );
  }

  factory AsesorDashboardData.empty() {
    return AsesorDashboardData(
      summary: AsesorDashboardSummaryCount.empty(),
      alertBanner: AsesorDashboardAlertBanner.empty(),
      jadwalHariIni: const [],
      jadwalBelumLengkap: const [],
    );
  }
}

class AsesorMitra {
  final int id;
  final int idAsesor;
  final String tanggalBermitra;
  final int idTuk;
  final String namaTuk;
  final String kota;
  final String alamat;
  final String deskripsiMitra;
  final String proyeksiMitra;
  final String linkMouMitra;
  final double? latitude;
  final double? longitude;
  final int statusMitra;

  const AsesorMitra({
    required this.id,
    required this.idAsesor,
    required this.tanggalBermitra,
    required this.idTuk,
    this.namaTuk = '',
    this.kota = '',
    this.alamat = '',
    this.deskripsiMitra = '',
    this.proyeksiMitra = '',
    this.linkMouMitra = '',
    this.latitude,
    this.longitude,
    this.statusMitra = 0,
  });

  bool get hasCoordinates => latitude != null && longitude != null;
  bool get isAktif => statusMitra == 1;
  bool get hasMou => linkMouMitra.trim().isNotEmpty;

  String get statusLabel {
    switch (statusMitra) {
      case 1:
        return 'Aktif';
      case 2:
        return 'Selesai';
      case 0:
      default:
        return 'Menunggu';
    }
  }

  factory AsesorMitra.fromJson(Map<String, dynamic> json) {
    final lat = (json['latitude'] as num?)?.toDouble();
    final lng = (json['longitude'] as num?)?.toDouble();
    final validCoordinates = lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
    return AsesorMitra(
      id: (json['id'] as num?)?.toInt() ?? 0,
      idAsesor: (json['id_asesor'] as num?)?.toInt() ?? 0,
      tanggalBermitra: json['tanggal_bermitra']?.toString() ?? '',
      idTuk: (json['id_tuk'] as num?)?.toInt() ?? 0,
      namaTuk: json['nama_tuk']?.toString() ?? '',
      kota: json['kota']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
      deskripsiMitra: json['deskripsi_mitra']?.toString() ?? '',
      proyeksiMitra: json['proyeksi_mitra']?.toString() ?? '',
      linkMouMitra: json['link_mou_mitra']?.toString() ?? '',
      latitude: validCoordinates ? lat : null,
      longitude: validCoordinates ? lng : null,
      statusMitra: (json['status_mitra'] as num?)?.toInt() ?? 0,
    );
  }
}


class AsesorMUKItem {
  final int id;
  final String namaMapa;
  final String tanggalPembuatan;
  final String validator;
  final String status;
  final String linkMukManual;

  const AsesorMUKItem({
    required this.id,
    required this.namaMapa,
    required this.tanggalPembuatan,
    required this.validator,
    required this.status,
    this.linkMukManual = '',
  });

  bool get hasDownloadLink => linkMukManual.trim().isNotEmpty;

  factory AsesorMUKItem.fromJson(Map<String, dynamic> json) {
    return AsesorMUKItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      namaMapa: json['nama_mapa']?.toString() ?? 'MUK / MAPA',
      tanggalPembuatan: json['tanggal_pembuatan']?.toString() ?? '-',
      validator: json['validator']?.toString() ?? '-',
      status: json['status']?.toString() ?? 'Menunggu Verifikasi',
      linkMukManual: json['link_muk_manual']?.toString() ??
          json['link_mapa_manual']?.toString() ??
          '',
    );
  }
}
