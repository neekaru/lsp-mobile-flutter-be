// ============================================================================
// Model formulir AK-01 .. AK-04 (asesi).
// Diekstrak dari asesor_asesi_models.dart.
// ============================================================================

class BuktiAK01Item {
  final String nama;
  final bool checked;

  BuktiAK01Item({
    required this.nama,
    required this.checked,
  });

  factory BuktiAK01Item.fromJson(Map<String, dynamic> json) {
    return BuktiAK01Item(
      nama: json['nama'] as String? ?? '',
      checked: json['checked'] as bool? ?? false,
    );
  }
}

class AK01Data {
  final String status;
  final String judulSkema;
  final String nomorSkema;
  final String tuk;
  final String namaAsesor;
  final String namaAsesi;
  final List<BuktiAK01Item> buktiDikumpulkan;
  final String hariTanggal;
  final String waktu;
  final String persetujuan;
  final String persetujuanBanding;
  final String persetujuanKerahasiaan;
  final String persetujuanAsesi;
  final String tglAsesmen;
  final bool tandaTanganAsesi;
  final bool tandaTanganAsesor;
  final bool tandaTangan;

  AK01Data({
    required this.status,
    this.judulSkema = '',
    this.nomorSkema = '',
    required this.tuk,
    this.namaAsesor = '',
    this.namaAsesi = '',
    this.buktiDikumpulkan = const [],
    this.hariTanggal = '',
    this.waktu = '08:00 WIB',
    required this.persetujuan,
    this.persetujuanBanding = 'Bahwa Saya Sudah Mendapatkan Penjelasan Hak dan Prosedur Banding Oleh Asesor.',
    this.persetujuanKerahasiaan = 'Menyatakan tidak akan membuka hasil pekerjaan yang saya peroleh karena penugasan saya sebagai asesor dalam pekerjaan Asesmen kepada siapapun atau organisasi apapun selain kepada pihak yang berwenang sehubungan dengan kewajiban saya sebagai Asesor yang ditugaskan oleh LSP.\n\nMenyatakan setuju untuk melaksanakan asesmen jarak jauh sesuai dengan prosedur yang ditentukan.',
    this.persetujuanAsesi = 'Saya setuju mengikuti asesmen tatap muka / asesmen jarak jauh dengan pemahaman bahwa informasi yang dikumpulkan hanya digunakan untuk pengembangan profesional dan hanya dapat diakses oleh orang tertentu saja.',
    required this.tglAsesmen,
    this.tandaTanganAsesi = true,
    this.tandaTanganAsesor = true,
    required this.tandaTangan,
  });

  factory AK01Data.fromJson(Map<String, dynamic> json) {
    final buktiList = (json['bukti_dikumpulkan'] as List<dynamic>? ?? [])
        .map((e) => BuktiAK01Item.fromJson(e as Map<String, dynamic>))
        .toList();

    return AK01Data(
      status: json['status'] as String? ?? 'Disetujui',
      judulSkema: json['judul_skema'] as String? ?? '',
      nomorSkema: json['nomor_skema'] as String? ?? '',
      tuk: json['tuk'] as String? ?? '',
      namaAsesor: json['nama_asesor'] as String? ?? '',
      namaAsesi: json['nama_asesi'] as String? ?? '',
      buktiDikumpulkan: buktiList,
      hariTanggal: json['hari_tanggal'] as String? ?? json['tgl_asesmen'] as String? ?? '',
      waktu: _normalizeWaktu(json['waktu']),
      persetujuan: json['persetujuan'] as String? ?? 'Asesi Menyetujui Seluruh Proses dan Tata Tertib Asesmen',
      persetujuanBanding: json['persetujuan_banding'] as String? ??
          'Bahwa Saya Sudah Mendapatkan Penjelasan Hak dan Prosedur Banding Oleh Asesor.',
      persetujuanKerahasiaan: json['persetujuan_kerahasiaan'] as String? ??
          'Menyatakan tidak akan membuka hasil pekerjaan yang saya peroleh karena penugasan saya sebagai asesor dalam pekerjaan Asesmen kepada siapapun atau organisasi apapun selain kepada pihak yang berwenang sehubungan dengan kewajiban saya sebagai Asesor yang ditugaskan oleh LSP.\n\nMenyatakan setuju untuk melaksanakan asesmen jarak jauh sesuai dengan prosedur yang ditentukan.',
      persetujuanAsesi: json['persetujuan_asesi'] as String? ??
          'Saya setuju mengikuti asesmen tatap muka / asesmen jarak jauh dengan pemahaman bahwa informasi yang dikumpulkan hanya digunakan untuk pengembangan profesional dan hanya dapat diakses oleh orang tertentu saja.',
      tglAsesmen: json['tgl_asesmen'] as String? ?? '',
      tandaTanganAsesi: json['tanda_tangan_asesi'] as bool? ?? true,
      tandaTanganAsesor: json['tanda_tangan_asesor'] as bool? ?? true,
      tandaTangan: json['tanda_tangan'] as bool? ?? true,
    );
  }

  static String _normalizeWaktu(dynamic raw) {
    final str = raw?.toString().trim() ?? '';
    if (str.isEmpty || str == '0' || str == '00:00:00' || str == '00:00' || str == '-') {
      return '08:00 WIB';
    }
    if (!str.toLowerCase().contains('wib') && !str.toLowerCase().contains('wita') && !str.toLowerCase().contains('wit')) {
      return '$str WIB';
    }
    return str;
  }
}

class AK02Data {
  final String status;
  final String hasilObservasi;
  final String hasilPraktik;
  final String hasilLisan;
  final String hasilEsai;
  final String hasilPortofolio;
  final String komentarObservasi;
  final String rekomendasiAsesor;
  final String rekomendasi;
  final String rekomendasiLabel;
  final String pesan;
  final String catatan;
  final String saranTindakLanjut;

  AK02Data({
    required this.status,
    required this.hasilObservasi,
    required this.hasilPraktik,
    required this.hasilLisan,
    required this.hasilEsai,
    this.hasilPortofolio = 'Kompeten',
    required this.komentarObservasi,
    this.rekomendasiAsesor = '0',
    this.rekomendasi = 'Belum Rekomendasi',
    this.rekomendasiLabel = 'Belum Rekomendasi',
    this.pesan = '',
    this.catatan = '',
    this.saranTindakLanjut = '',
  });

  factory AK02Data.fromJson(Map<String, dynamic> json) {
    final rawRekom = json['rekomendasi'] as String? ??
        json['rekomendasi_label'] as String? ??
        'Belum Rekomendasi';
    final rawCode = json['rekomendasi_asesor']?.toString() ??
        (rawRekom == 'Kompeten' ? '1' : (rawRekom == 'Belum Kompeten' ? '2' : '0'));
    final pesanText = json['pesan'] as String? ??
        json['catatan'] as String? ??
        json['komentar_observasi'] as String? ??
        json['saran_tindak_lanjut'] as String? ??
        '';

    final obs = json['hasil_observasi'] as String? ?? 'Kompeten';
    final porto = json['hasil_portofolio'] as String? ?? obs;

    return AK02Data(
      status: json['status'] as String? ?? 'Selesai',
      hasilObservasi: obs,
      hasilPraktik: json['hasil_praktik'] as String? ?? 'Kompeten',
      hasilLisan: json['hasil_lisan'] as String? ?? 'Kompeten',
      hasilEsai: json['hasil_esai'] as String? ?? 'Kompeten',
      hasilPortofolio: porto,
      komentarObservasi: json['komentar_observasi'] as String? ?? '',
      rekomendasiAsesor: rawCode,
      rekomendasi: rawRekom,
      rekomendasiLabel: json['rekomendasi_label'] as String? ?? rawRekom,
      pesan: pesanText,
      catatan: json['catatan'] as String? ?? pesanText,
      saranTindakLanjut: json['saran_tindak_lanjut'] as String? ?? pesanText,
    );
  }
}

class AK03Item {
  final int no;
  final String komponen;
  final String hasil; // "Ya", "Tidak", or "-"
  final String catatanKomentar;

  AK03Item({
    required this.no,
    required this.komponen,
    this.hasil = 'Ya',
    this.catatanKomentar = '',
  });

  factory AK03Item.fromJson(Map<String, dynamic> json) {
    return AK03Item(
      no: json['no'] as int? ?? 0,
      komponen: json['komponen'] as String? ?? '',
      hasil: json['hasil'] as String? ?? 'Ya',
      catatanKomentar: json['catatan_komentar'] as String? ?? '',
    );
  }
}

class AK03Data {
  final String status;
  final String namaAsesi;
  final String tanggalMulai;
  final String tanggalSelesai;
  final List<AK03Item> items;
  final String umpanBalik;
  final String catatan;
  final bool isSudahDiisi;

  AK03Data({
    required this.status,
    this.namaAsesi = '',
    this.tanggalMulai = '',
    this.tanggalSelesai = '',
    this.items = const [],
    required this.umpanBalik,
    required this.catatan,
    this.isSudahDiisi = false,
  });

  factory AK03Data.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? [])
        .map((e) => AK03Item.fromJson(e as Map<String, dynamic>))
        .toList();

    return AK03Data(
      status: json['status'] as String? ?? 'Telah Diisi',
      namaAsesi: json['nama_asesi'] as String? ?? '',
      tanggalMulai: json['tanggal_mulai'] as String? ?? '',
      tanggalSelesai: json['tanggal_selesai'] as String? ?? '',
      items: rawItems,
      umpanBalik: json['umpan_balik'] as String? ?? 'Proses asesmen berjalan baik dan sesuai prosedur',
      catatan: json['catatan'] as String? ?? '',
      isSudahDiisi: json['is_sudah_diisi'] as bool? ?? (rawItems.isNotEmpty),
    );
  }
}

class AK04PertanyaanItem {
  final int no;
  final String pertanyaan;
  final String? jawaban; // 'Ya', 'Tidak', or null

  AK04PertanyaanItem({
    required this.no,
    required this.pertanyaan,
    this.jawaban,
  });

  factory AK04PertanyaanItem.fromJson(Map<String, dynamic> json) {
    return AK04PertanyaanItem(
      no: json['no'] as int? ?? 1,
      pertanyaan: json['pertanyaan'] as String? ?? '',
      jawaban: json['jawaban'] as String?,
    );
  }
}

class AK04Data {
  final String status;
  final bool adaBanding;
  final String namaAsesi;
  final String namaAsesor;
  final String tanggalAsesmen;
  final String skema;
  final String noSkema;
  final List<AK04PertanyaanItem> pertanyaan;
  final String alasanBanding;

  AK04Data({
    required this.status,
    required this.adaBanding,
    this.namaAsesi = '',
    this.namaAsesor = '',
    this.tanggalAsesmen = '',
    this.skema = '',
    this.noSkema = '',
    this.pertanyaan = const [],
    required this.alasanBanding,
  });

  factory AK04Data.fromJson(Map<String, dynamic> json) {
    final rawList = json['pertanyaan'];
    List<AK04PertanyaanItem> items = [];
    if (rawList is List) {
      items = rawList.map((e) => AK04PertanyaanItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    return AK04Data(
      status: json['status'] as String? ?? 'Tidak Ada Permohonan Banding',
      adaBanding: json['ada_banding'] as bool? ?? false,
      namaAsesi: json['nama_asesi'] as String? ?? '',
      namaAsesor: json['nama_asesor'] as String? ?? '',
      tanggalAsesmen: json['tanggal_asesmen'] as String? ?? '',
      skema: json['skema'] as String? ?? '',
      noSkema: json['no_skema'] as String? ?? '',
      pertanyaan: items,
      alasanBanding: json['alasan_banding'] as String? ?? '',
    );
  }
}
