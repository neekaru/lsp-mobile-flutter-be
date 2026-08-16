import 'dart:convert';

class BlankoListItem {
  final int id;
  final String nomorPermohonan;
  final String nomorKeputusan;
  final String tanggalPermohonan;
  final int jumlahKompeten;
  final int blankoTerkirim;
  final String statusTerkirim;
  final String blankoDiterima;
  final String noBlankoAwal;
  final String noBlankoAkhir;
  final String picPengajuan;
  final String? tanggalDiterima;
  final int isValidasi;

  const BlankoListItem({
    required this.id,
    required this.nomorPermohonan,
    required this.nomorKeputusan,
    required this.tanggalPermohonan,
    required this.jumlahKompeten,
    required this.blankoTerkirim,
    required this.statusTerkirim,
    required this.blankoDiterima,
    required this.noBlankoAwal,
    required this.noBlankoAkhir,
    required this.picPengajuan,
    this.tanggalDiterima,
    this.isValidasi = 0,
  });

  bool get isSudahTerkirim =>
      statusTerkirim.toLowerCase().contains('sudah') ||
      statusTerkirim.toLowerCase() == 'terkirim' ||
      blankoTerkirim > 0;

  factory BlankoListItem.fromJson(Map<String, dynamic> json) {
    return BlankoListItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nomorPermohonan: json['nomor_permohonan']?.toString() ?? '',
      nomorKeputusan: json['nomor_keputusan']?.toString() ?? '',
      tanggalPermohonan: json['tanggal_permohonan']?.toString() ?? '',
      jumlahKompeten: json['jumlah_kompeten'] is int
          ? json['jumlah_kompeten']
          : int.tryParse(json['jumlah_kompeten']?.toString() ?? '') ?? 0,
      blankoTerkirim: json['blanko_terkirim'] is int
          ? json['blanko_terkirim']
          : int.tryParse(json['blanko_terkirim']?.toString() ?? '') ?? 0,
      statusTerkirim: json['status_terkirim']?.toString() ?? 'Belum Terkirim',
      blankoDiterima: json['blanko_diterima']?.toString() ?? '',
      noBlankoAwal: json['no_blanko_awal']?.toString() ?? '0',
      noBlankoAkhir: json['no_blanko_akhir']?.toString() ?? '0',
      picPengajuan: json['pic_pengajuan']?.toString() ?? '-',
      tanggalDiterima: json['tanggal_diterima']?.toString(),
      isValidasi: json['is_validasi'] is int
          ? json['is_validasi']
          : int.tryParse(json['is_validasi']?.toString() ?? '') ?? 0,
    );
  }
}

class BlankoMeta {
  final int page;
  final int size;
  final int totalItem;
  final int totalPage;
  final int totalTerkirim;
  final int totalBelumTerkirim;

  const BlankoMeta({
    this.page = 1,
    this.size = 10,
    this.totalItem = 0,
    this.totalPage = 1,
    this.totalTerkirim = 0,
    this.totalBelumTerkirim = 0,
  });

  factory BlankoMeta.fromJson(Map<String, dynamic> json) {
    return BlankoMeta(
      page: json['page'] is int
          ? json['page']
          : int.tryParse(json['page']?.toString() ?? '') ?? 1,
      size: json['size'] is int
          ? json['size']
          : int.tryParse(json['size']?.toString() ?? '') ?? 10,
      totalItem: json['total_item'] is int
          ? json['total_item']
          : int.tryParse(json['total_item']?.toString() ?? '') ?? 0,
      totalPage: json['total_page'] is int
          ? json['total_page']
          : int.tryParse(json['total_page']?.toString() ?? '') ?? 1,
      totalTerkirim: json['total_terkirim'] is int
          ? json['total_terkirim']
          : int.tryParse(json['total_terkirim']?.toString() ?? '') ?? 0,
      totalBelumTerkirim: json['total_belum_terkirim'] is int
          ? json['total_belum_terkirim']
          : int.tryParse(json['total_belum_terkirim']?.toString() ?? '') ?? 0,
    );
  }
}

class BlankoListResponse {
  final List<BlankoListItem> data;
  final BlankoMeta meta;

  const BlankoListResponse({
    required this.data,
    required this.meta,
  });

  factory BlankoListResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    final items = rawList
        .map((e) => BlankoListItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = json['meta'] != null
        ? BlankoMeta.fromJson(json['meta'] as Map<String, dynamic>)
        : const BlankoMeta();

    return BlankoListResponse(data: items, meta: meta);
  }

  factory BlankoListResponse.empty() {
    return const BlankoListResponse(
      data: [],
      meta: BlankoMeta(),
    );
  }
}

class BlankoDetailModel {
  final int id;
  final String nomorPermohonan;
  final String nomorKeputusan;
  final String tanggalPermohonan;
  final String jadwalId;
  final List<String> jadwalIds;
  final String tanggalKeputusan;
  final int jumlahKompeten;
  final int blankoTerkirim;
  final String statusTerkirim;
  final String blankoDiterima;
  final String? tanggalDiterima;
  final String picPengajuan;
  final String rangeTanggalAsesmen;
  final String noBeritaAcara;
  final String skTimPleno;
  final String timPleno;
  final String ketuaTimPleno;
  final String tanggalPleno;
  final String noBlankoAwal;
  final String noBlankoAkhir;
  final String linkBast;
  final int isValidasi;

  const BlankoDetailModel({
    required this.id,
    required this.nomorPermohonan,
    required this.nomorKeputusan,
    required this.tanggalPermohonan,
    required this.jadwalId,
    required this.jadwalIds,
    required this.tanggalKeputusan,
    required this.jumlahKompeten,
    required this.blankoTerkirim,
    required this.statusTerkirim,
    required this.blankoDiterima,
    this.tanggalDiterima,
    required this.picPengajuan,
    required this.rangeTanggalAsesmen,
    required this.noBeritaAcara,
    required this.skTimPleno,
    required this.timPleno,
    required this.ketuaTimPleno,
    required this.tanggalPleno,
    required this.noBlankoAwal,
    required this.noBlankoAkhir,
    required this.linkBast,
    this.isValidasi = 0,
  });

  bool get isSudahTerkirim =>
      statusTerkirim.toLowerCase().contains('sudah') ||
      statusTerkirim.toLowerCase() == 'terkirim' ||
      blankoTerkirim > 0;

  factory BlankoDetailModel.fromJson(Map<String, dynamic> json) {
    return BlankoDetailModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nomorPermohonan: json['nomor_permohonan']?.toString() ?? '',
      nomorKeputusan: json['nomor_keputusan']?.toString() ?? '',
      tanggalPermohonan: json['tanggal_permohonan']?.toString() ?? '',
      jadwalId: json['jadwal_id']?.toString() ?? '',
      jadwalIds: json['jadwal_id'] != null
          ? (json['jadwal_id'] is List
              ? (json['jadwal_id'] as List)
                    .map((e) => e.toString())
                    .where((e) => e.trim().isNotEmpty)
                    .toList()
              : _parseJadwalIds(json['jadwal_id']))
          : const [],
      tanggalKeputusan: json['tanggal_keputusan']?.toString() ?? '',
      jumlahKompeten: json['jumlah_kompeten'] is int
          ? json['jumlah_kompeten']
          : int.tryParse(json['jumlah_kompeten']?.toString() ?? '') ?? 0,
      blankoTerkirim: json['blanko_terkirim'] is int
          ? json['blanko_terkirim']
          : int.tryParse(json['blanko_terkirim']?.toString() ?? '') ?? 0,
      statusTerkirim: json['status_terkirim']?.toString() ?? 'Belum Terkirim',
      blankoDiterima: json['blanko_diterima']?.toString() ?? '',
      tanggalDiterima: json['tanggal_diterima']?.toString(),
      picPengajuan: json['pic_pengajuan']?.toString() ?? '-',
      rangeTanggalAsesmen: json['range_tanggal_asesmen']?.toString() ?? '-',
      noBeritaAcara: json['no_berita_acara']?.toString() ?? '-',
      skTimPleno: json['sk_tim_pleno']?.toString() ?? '-',
      timPleno: json['tim_pleno']?.toString() ?? '-',
      ketuaTimPleno: json['ketua_tim_pleno']?.toString() ?? '-',
      tanggalPleno: json['tanggal_pleno']?.toString() ?? '-',
      noBlankoAwal: json['no_blanko_awal']?.toString() ?? '0',
      noBlankoAkhir: json['no_blanko_akhir']?.toString() ?? '0',
      linkBast: json['link_bast']?.toString() ?? '',
      isValidasi: json['is_validasi'] is int
          ? json['is_validasi']
          : int.tryParse(json['is_validasi']?.toString() ?? '') ?? 0,
    );
  }

  /// Parse jadwal_id string dari backend menjadi ID yang siap ditampilkan.
  static List<String> _parseJadwalIds(dynamic raw) {
    final value = raw.toString().trim();
    if (value.isEmpty) return const [];
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded
            .map((item) => item.toString())
            .where((item) => item.trim().isNotEmpty)
            .toList();
      }
    } catch (_) {
      // Fallback di bawah menangani format comma-separated.
    }
    return value
        .replaceAll(RegExp(r'[\[\]"]'), '')
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}