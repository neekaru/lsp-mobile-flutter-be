// ============================================================================
// Jadwal Models
// ============================================================================

List<String> _parseAsesor(dynamic jsonVal) {
  if (jsonVal == null) {
    return [];
  }
  if (jsonVal is List) {
    return jsonVal.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
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
  });

  factory JadwalItem.fromJson(Map<String, dynamic> json) {
    // Map status_jadwal dari API ke status internal
    String mapStatus(String statusJadwal, int daysOverdue) {
      switch (statusJadwal) {
        case '0': // Waiting
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

    return JadwalItem(
      id: json['id'] ?? 0,
      skema: json['jadwal'] ?? '', // API uses 'jadwal' field
      tuk: json['tuk'] ?? '',
      tanggalMulai: json['tanggal'] ?? '',
      tanggalSelesai: json['tanggal_akhir'] ?? '',
      status: mapStatus(statusJadwal, daysOverdue),
      jumlahAsesi: json['jumlah_asesi'] ?? 0,
      asesor: _parseAsesor(json['asesor']),
      sisaHari: daysOverdue, // days_overdue from API
      daysLate: daysLate, // days_late from API (only for status "2")
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

// ============================================================================
// Notification Models
// ============================================================================

class NotificationCount {
  final int count;

  const NotificationCount({required this.count});

  factory NotificationCount.fromJson(Map<String, dynamic> json) {
    return NotificationCount(
      count: json['count'] ?? 0,
    );
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
  });

  factory WaitingSchedule.fromJson(Map<String, dynamic> json) {
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
      jumlahAsesi: json['jumlah_asesi'] ?? 0,
      asesor: _parseAsesor(json['asesor']),
    );
  }
}

class WaitingScheduleResponse {
  final List<WaitingSchedule> data;
  final NotificationMeta meta;

  const WaitingScheduleResponse({
    required this.data,
    required this.meta,
  });

  factory WaitingScheduleResponse.fromJson(Map<String, dynamic> json) {
    return WaitingScheduleResponse(
      data: (json['data'] as List<dynamic>?)
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
