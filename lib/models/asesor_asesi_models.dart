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

class AsesorAsesiDetailData {
  final int id;
  final String noPeserta;
  final String namaLengkap;
  final String nik;
  final String tempatLahir;
  final String tanggalLahir;
  final String jenisKelamin;
  final String alamat;
  final String noTelepon;
  final String email;
  final String institusi;
  final String pendidikan;
  final String jurusan;
  final String pekerjaan;
  final String organisasi;
  final String jabatan;
  final String alamatCompany;
  final String telpCompany;
  final String emailCompany;
  final String kodePosCompany;
  final String skemaSertifikat;
  final String idSkema;
  final int jadwalId;
  final String jadwalNama;
  final String jadwalTanggal;
  final String tukNama;
  final String rekomendasiAsesor;
  final String rekomendasiAsesorCode;
  final String rekomendasiAsesorLabel;
  final String isKompeten;
  final String pesanAsesor;
  final String catatanAsesor;
  final String saranTindakLanjut;
  final String? fotoProfilUrl;
  final APL01Data apl01;
  final APL02Data apl02;
  final AK01Data ak01;
  final AK02Data ak02;
  final AK03Data ak03;
  final AK04Data ak04;

  AsesorAsesiDetailData({
    required this.id,
    required this.noPeserta,
    required this.namaLengkap,
    required this.nik,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.alamat,
    required this.noTelepon,
    required this.email,
    required this.institusi,
    required this.pendidikan,
    this.jurusan = '',
    required this.pekerjaan,
    required this.organisasi,
    required this.jabatan,
    this.alamatCompany = '',
    this.telpCompany = '',
    this.emailCompany = '',
    this.kodePosCompany = '',
    required this.skemaSertifikat,
    required this.idSkema,
    required this.jadwalId,
    required this.jadwalNama,
    required this.jadwalTanggal,
    required this.tukNama,
    required this.rekomendasiAsesor,
    this.rekomendasiAsesorCode = '0',
    this.rekomendasiAsesorLabel = 'Belum Rekomendasi',
    required this.isKompeten,
    this.pesanAsesor = '',
    this.catatanAsesor = '',
    this.saranTindakLanjut = '',
    this.fotoProfilUrl,
    required this.apl01,
    required this.apl02,
    required this.ak01,
    required this.ak02,
    required this.ak03,
    required this.ak04,
  });

  String get kandidat => apl02.kandidat;

  factory AsesorAsesiDetailData.fromJson(Map<String, dynamic> json) {
    final rawRekom = json['rekomendasi_asesor'] as String? ?? 'Belum Rekomendasi';
    final rekomCode = json['rekomendasi_asesor_code']?.toString() ??
        (rawRekom == 'Kompeten' ? '1' : (rawRekom == 'Belum Kompeten' ? '2' : '0'));
    final rekomLabel = json['rekomendasi_asesor_label'] as String? ?? rawRekom;
    final pesan = json['pesan_asesor'] as String? ??
        json['saran_tindak_lanjut'] as String? ??
        json['catatan_asesor'] as String? ??
        '';

    return AsesorAsesiDetailData(
      id: json['id'] as int? ?? 0,
      noPeserta: json['no_peserta'] as String? ?? '',
      namaLengkap: json['nama_lengkap'] as String? ?? '',
      nik: json['nik'] as String? ?? '',
      tempatLahir: json['tempat_lahir'] as String? ?? '',
      tanggalLahir: json['tanggal_lahir'] as String? ?? '',
      jenisKelamin: json['jenis_kelamin'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
      noTelepon: json['no_telepon'] as String? ?? '',
      email: json['email'] as String? ?? '',
      institusi: json['institusi'] as String? ?? '',
      pendidikan: json['pendidikan'] as String? ?? '',
      jurusan: json['jurusan'] as String? ?? '',
      pekerjaan: json['pekerjaan'] as String? ?? '',
      organisasi: json['organisasi'] as String? ?? '',
      jabatan: json['jabatan'] as String? ?? '',
      alamatCompany: json['alamat_company'] as String? ?? '',
      telpCompany: json['telp_company'] as String? ?? '',
      emailCompany: json['email_company'] as String? ?? '',
      kodePosCompany: json['kode_pos_company'] as String? ?? '',
      skemaSertifikat: json['skema_sertifikat'] as String? ?? '',
      idSkema: json['id_skema']?.toString() ?? '',
      jadwalId: json['jadwal_id'] as int? ?? 0,
      jadwalNama: json['jadwal_nama'] as String? ?? '',
      jadwalTanggal: json['jadwal_tanggal'] as String? ?? '',
      tukNama: json['tuk_nama'] as String? ?? '',
      rekomendasiAsesor: rawRekom,
      rekomendasiAsesorCode: rekomCode,
      rekomendasiAsesorLabel: rekomLabel,
      isKompeten: json['is_kompeten'] as String? ?? '',
      pesanAsesor: pesan,
      catatanAsesor: json['catatan_asesor'] as String? ?? pesan,
      saranTindakLanjut: json['saran_tindak_lanjut'] as String? ?? pesan,
      fotoProfilUrl: json['foto_profil_url'] as String?,
      apl01: APL01Data.fromJson(json['apl01'] as Map<String, dynamic>? ?? {}),
      apl02: APL02Data.fromJson(json['apl02'] as Map<String, dynamic>? ?? {}),
      ak01: AK01Data.fromJson(json['ak01'] as Map<String, dynamic>? ?? {}),
      ak02: AK02Data.fromJson(json['ak02'] as Map<String, dynamic>? ?? {}),
      ak03: AK03Data.fromJson(json['ak03'] as Map<String, dynamic>? ?? {}),
      ak04: AK04Data.fromJson(json['ak04'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class APL01Data {
  final String status;
  final String rekomendasi;
  final String catatan;
  final String tanggalValidasi;
  final List<BuktiDokumenItem> persyaratanDasar;
  final List<BuktiDokumenItem> persyaratanAdministratif;
  final List<BuktiDokumenItem> buktiDokumen;

  APL01Data({
    required this.status,
    required this.rekomendasi,
    required this.catatan,
    required this.tanggalValidasi,
    this.persyaratanDasar = const [],
    this.persyaratanAdministratif = const [],
    required this.buktiDokumen,
  });

  factory APL01Data.fromJson(Map<String, dynamic> json) {
    String rawRekom = json['rekomendasi'] as String? ?? '';
    if (rawRekom.isEmpty || rawRekom == '0' || rawRekom == '1') {
      rawRekom = 'Diterima Sebagai Peserta Asesmen';
    } else if (rawRekom == '2') {
      rawRekom = 'Tidak Diterima Sebagai Peserta Asesmen';
    } else if (rawRekom == '3') {
      rawRekom = 'Perlu Perbaikan Dokumen';
    }

    final dasarList = (json['persyaratan_dasar'] as List<dynamic>? ?? [])
        .map((e) => BuktiDokumenItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final adminList = (json['persyaratan_administratif'] as List<dynamic>? ?? [])
        .map((e) => BuktiDokumenItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final buktiList = (json['bukti_dokumen'] as List<dynamic>? ?? [])
        .map((e) => BuktiDokumenItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return APL01Data(
      status: json['status'] as String? ?? 'Terverifikasi',
      rekomendasi: rawRekom,
      catatan: json['catatan'] as String? ?? '',
      tanggalValidasi: json['tanggal_validasi'] as String? ?? '',
      persyaratanDasar: dasarList,
      persyaratanAdministratif: adminList,
      buktiDokumen: buktiList,
    );
  }
}

class BuktiDokumenItem {
  final String nama;
  final String jenis;
  final String? jenisBukti;
  final bool ada;
  final String? fileName;
  final String? url;

  BuktiDokumenItem({
    required this.nama,
    required this.jenis,
    this.jenisBukti,
    required this.ada,
    this.fileName,
    this.url,
  });

  factory BuktiDokumenItem.fromJson(Map<String, dynamic> json) {
    return BuktiDokumenItem(
      nama: json['nama'] as String? ?? '',
      jenis: json['jenis'] as String? ?? 'Wajib',
      jenisBukti: json['jenis_bukti'] as String?,
      ada: json['ada'] as bool? ?? true,
      fileName: json['file_name'] as String?,
      url: json['url'] as String?,
    );
  }
}

class MapaOption {
  final int id;
  final String namaMapa;
  final String displayText;
  final String metode;
  final String insClo;
  final String insPraktik;
  final String insObservasi;
  final String insPortofolio;
  final String insPg;
  final String insEsai;
  final String insLisan;
  final String insVPortofolio;
  final String insWawancara;
  final List<String> instrumen;
  final bool hasIA01;
  final bool hasIA02;
  final bool hasIA03;
  final bool hasIA05;
  final bool hasIA06;
  final bool hasIA11;

  MapaOption({
    required this.id,
    required this.namaMapa,
    required this.displayText,
    this.metode = 'observasi',
    this.insClo = '0',
    this.insPraktik = '0',
    this.insObservasi = '0',
    this.insPortofolio = '0',
    this.insPg = '0',
    this.insEsai = '0',
    this.insLisan = '0',
    this.insVPortofolio = '0',
    this.insWawancara = '0',
    this.instrumen = const [],
    this.hasIA01 = true,
    this.hasIA02 = true,
    this.hasIA03 = true,
    this.hasIA05 = true,
    this.hasIA06 = false,
    this.hasIA11 = false,
  });

  bool get isPortofolio =>
      metode == 'portofolio' ||
      namaMapa.toUpperCase().contains('PORTOFOLIO') ||
      insPortofolio != '0' ||
      insVPortofolio != '0';

  bool isInstrumentActive(String formId, String selectedKandidat) {
    if (selectedKandidat == '3' || isPortofolio) {
      if (formId == 'IA11' || formId == 'IA08' || formId == 'IA09') return true;
      if (formId == 'IA03') return hasIA03;
      return false;
    }
    // Observasi / Terstruktur (Kandidat 1, 2, 4)
    switch (formId) {
      case 'IA01':
        return hasIA01 && (insClo == selectedKandidat || insClo == '1' || insClo == '0');
      case 'IA02':
        return hasIA02 && (insPraktik == selectedKandidat || insPraktik == '1' || insPraktik == '0');
      case 'IA03':
        return hasIA03;
      case 'IA05':
        return hasIA05 && (insPg == selectedKandidat || insPg == '1' || insPg == '0');
      case 'IA06':
        return hasIA06 && (insEsai == selectedKandidat || insEsai == '1' || insEsai == '0');
      default:
        return false;
    }
  }

  factory MapaOption.fromJson(Map<String, dynamic> json) {
    final rawNama = json['nama_mapa'] as String? ?? '';
    final isPortofolio = rawNama.toUpperCase().contains('PORTOFOLIO') ||
        (json['ins_portofolio'] != null && json['ins_portofolio'] != '0') ||
        (json['ins_vportofolio'] != null && json['ins_vportofolio'] != '0');
    final rawInstrumen = (json['instrumen'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return MapaOption(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      namaMapa: rawNama,
      displayText: json['display_text'] as String? ?? '',
      metode: json['metode'] as String? ?? (isPortofolio ? 'portofolio' : 'observasi'),
      insClo: json['ins_clo']?.toString() ?? '0',
      insPraktik: json['ins_praktik']?.toString() ?? '0',
      insObservasi: json['ins_observasi']?.toString() ?? '0',
      insPortofolio: json['ins_portofolio']?.toString() ?? '0',
      insPg: json['ins_pg']?.toString() ?? '0',
      insEsai: json['ins_esai']?.toString() ?? '0',
      insLisan: json['ins_lisan']?.toString() ?? '0',
      insVPortofolio: json['ins_vportofolio']?.toString() ?? '0',
      insWawancara: json['ins_wawancara']?.toString() ?? '0',
      instrumen: rawInstrumen,
      hasIA01: json['has_ia01'] ?? !isPortofolio,
      hasIA02: json['has_ia02'] ?? !isPortofolio,
      hasIA03: json['has_ia03'] ?? true,
      hasIA05: json['has_ia05'] ?? !isPortofolio,
      hasIA06: json['has_ia06'] ?? false,
      hasIA11: json['has_ia11'] ?? isPortofolio,
    );
  }
}

class KandidatOption {
  final String id;
  final String label;

  KandidatOption({
    required this.id,
    required this.label,
  });

  factory KandidatOption.fromJson(Map<String, dynamic> json) {
    return KandidatOption(
      id: json['id']?.toString() ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

class APL02Data {
  final String status;
  final int totalUnit;
  final int totalK;
  final int totalBK;
  final List<APL02UnitItem> units;
  final String praAsesmen;
  final String rekomendasi;
  final String catatanRekomendasi;
  final String tanggal;
  final bool isApproved;
  final String kandidat;
  final String kandidatLabel;
  final int? idMapa;
  final String namaMapa;
  final String qrCodeData;
  final List<MapaOption> mapaOptions;
  final List<KandidatOption> kandidatOptions;

  APL02Data({
    required this.status,
    required this.totalUnit,
    required this.totalK,
    required this.totalBK,
    required this.units,
    this.praAsesmen = '0',
    this.rekomendasi = 'Belum Diverifikasi',
    this.catatanRekomendasi = 'Di rekomendasi menjadi peserta uji kompetensi',
    this.tanggal = '',
    this.isApproved = false,
    this.kandidat = '1',
    this.kandidatLabel = '',
    this.idMapa,
    this.namaMapa = '',
    this.qrCodeData = '',
    this.mapaOptions = const [],
    this.kandidatOptions = const [],
  });

  factory APL02Data.fromJson(Map<String, dynamic> json) {
    return APL02Data(
      status: json['status'] as String? ?? 'Lengkap',
      totalUnit: int.tryParse(json['total_unit']?.toString() ?? '') ?? 0,
      totalK: int.tryParse(json['total_k']?.toString() ?? '') ?? 0,
      totalBK: int.tryParse(json['total_bk']?.toString() ?? '') ?? 0,
      units: (json['units'] as List<dynamic>? ?? [])
          .map((e) => APL02UnitItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      praAsesmen: json['pra_asesmen']?.toString() ?? '0',
      rekomendasi: json['rekomendasi'] as String? ?? 'Belum Diverifikasi',
      catatanRekomendasi: json['catatan_rekomendasi'] as String? ?? 'Di rekomendasi menjadi peserta uji kompetensi',
      tanggal: json['tanggal'] as String? ?? '',
      isApproved: json['is_approved'] as bool? ?? false,
      kandidat: json['kandidat']?.toString() ?? '1',
      kandidatLabel: json['kandidat_label'] as String? ?? '',
      idMapa: json['id_mapa'] != null ? int.tryParse(json['id_mapa'].toString()) : null,
      namaMapa: json['nama_mapa'] as String? ?? '',
      qrCodeData: json['qr_code_data'] as String? ?? '',
      mapaOptions: (json['mapa_options'] as List<dynamic>? ?? [])
          .map((e) => MapaOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      kandidatOptions: (json['kandidat_options'] as List<dynamic>? ?? [])
          .map((e) => KandidatOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class APL02UnitItem {
  final String idUnit;
  final String kodeUnit;
  final String judulUnit;
  final String statusKompeten;
  final String jenisBukti;

  APL02UnitItem({
    required this.idUnit,
    required this.kodeUnit,
    required this.judulUnit,
    required this.statusKompeten,
    required this.jenisBukti,
  });

  factory APL02UnitItem.fromJson(Map<String, dynamic> json) {
    return APL02UnitItem(
      idUnit: json['id_unit']?.toString() ?? '',
      kodeUnit: json['kode_unit'] as String? ?? '',
      judulUnit: json['judul_unit'] as String? ?? '',
      statusKompeten: json['status_kompeten'] as String? ?? 'K',
      jenisBukti: json['jenis_bukti'] as String? ?? 'Portofolio',
    );
  }
}

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

class AK06AspectItem {
  final String aspect;
  final String kesesuaian;
  final String catatan;

  AK06AspectItem({
    required this.aspect,
    required this.kesesuaian,
    this.catatan = '',
  });

  factory AK06AspectItem.fromJson(Map<String, dynamic> json) {
    return AK06AspectItem(
      aspect: json['aspect'] as String? ?? '',
      kesesuaian: json['kesesuaian'] as String? ?? 'Ya',
      catatan: json['catatan'] as String? ?? '',
    );
  }
}

class JadwalAK05PesertaItem {
  final int id;
  final String noPeserta;
  final String namaLengkap;
  final String nik;
  String rekomendasiAsesor; // "1", "2", "0"
  String rekomendasiLabel;  // "Kompeten", "Belum Kompeten", "Belum Dinilai"
  String unitBk;

  JadwalAK05PesertaItem({
    required this.id,
    required this.noPeserta,
    required this.namaLengkap,
    required this.nik,
    required this.rekomendasiAsesor,
    required this.rekomendasiLabel,
    this.unitBk = '',
  });

  factory JadwalAK05PesertaItem.fromJson(Map<String, dynamic> json) {
    final rawCode = json['rekomendasi_asesor']?.toString() ?? '0';
    var label = json['rekomendasi_label']?.toString() ?? '';
    if (label.isEmpty) {
      if (rawCode == '1') {
        label = 'Kompeten';
      } else if (rawCode == '2') {
        label = 'Belum Kompeten';
      } else {
        label = 'Belum Rekomendasi';
      }
    }
    return JadwalAK05PesertaItem(
      id: json['id'] as int? ?? 0,
      noPeserta: json['no_peserta'] as String? ?? '',
      namaLengkap: json['nama_lengkap'] as String? ?? '',
      nik: json['nik'] as String? ?? '',
      rekomendasiAsesor: rawCode,
      rekomendasiLabel: label,
      unitBk: json['unit_bk'] as String? ?? '',
    );
  }
}

class JadwalAK05AsesorItem {
  final int idMapping;
  final int idJadwal;
  final int idAsesor;
  final String namaAsesor;
  final String noReg;
  final String masaAktif;
  final String linkRekaman;
  final int totalK;
  final int totalBk;
  final int totalBelum;

  JadwalAK05AsesorItem({
    required this.idMapping,
    required this.idJadwal,
    required this.idAsesor,
    required this.namaAsesor,
    required this.noReg,
    required this.masaAktif,
    required this.linkRekaman,
    required this.totalK,
    required this.totalBk,
    required this.totalBelum,
  });

  factory JadwalAK05AsesorItem.fromJson(Map<String, dynamic> json) {
    return JadwalAK05AsesorItem(
      idMapping: json['id_mapping'] as int? ?? 0,
      idJadwal: json['id_jadwal'] as int? ?? 0,
      idAsesor: json['id_asesor'] as int? ?? 0,
      namaAsesor: json['nama_asesor'] as String? ?? '',
      noReg: json['no_reg'] as String? ?? '-',
      masaAktif: json['masa_aktif'] as String? ?? '-',
      linkRekaman: json['link_rekaman'] as String? ?? '',
      totalK: json['total_k'] as int? ?? 0,
      totalBk: json['total_bk'] as int? ?? 0,
      totalBelum: json['total_belum'] as int? ?? 0,
    );
  }
}

class JadwalAK05DetailData {
  final int jadwalId;
  final String namaJadwal;
  final String skema;
  final String kodeSkema;
  final String tuk;
  final String tanggal;
  final String kuota;
  final String skVerifikasiTuk;
  final String linkFolderRekaman;
  final String linkRekamanAsesor;
  final String linkVertuk;
  final String namaAsesor;
  final int totalPeserta;
  final int totalKompeten;
  final int totalBelumKompeten;
  final int totalBelumDinilai;
  final List<JadwalAK05AsesorItem> daftarAsesor;
  final List<JadwalAK05PesertaItem> peserta;
  final String pencapaian;
  final String unitBk;
  final String saranTindakLanjut;
  final String peliharaKompetensi;
  final String catatan;
  final String statusLaporan;

  JadwalAK05DetailData({
    required this.jadwalId,
    required this.namaJadwal,
    required this.skema,
    required this.kodeSkema,
    required this.tuk,
    required this.tanggal,
    required this.kuota,
    required this.skVerifikasiTuk,
    required this.linkFolderRekaman,
    required this.linkRekamanAsesor,
    required this.linkVertuk,
    required this.namaAsesor,
    required this.totalPeserta,
    required this.totalKompeten,
    required this.totalBelumKompeten,
    required this.totalBelumDinilai,
    required this.daftarAsesor,
    required this.peserta,
    required this.pencapaian,
    required this.unitBk,
    required this.saranTindakLanjut,
    required this.peliharaKompetensi,
    required this.catatan,
    required this.statusLaporan,
  });

  factory JadwalAK05DetailData.fromJson(Map<String, dynamic> json) {
    final rawPeserta = json['peserta'];
    List<JadwalAK05PesertaItem> pesertaList = [];
    if (rawPeserta is List) {
      pesertaList = rawPeserta
          .map((e) => JadwalAK05PesertaItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final rawAsesor = json['daftar_asesor'];
    List<JadwalAK05AsesorItem> asesorList = [];
    if (rawAsesor is List) {
      asesorList = rawAsesor
          .map((e) => JadwalAK05AsesorItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return JadwalAK05DetailData(
      jadwalId: json['jadwal_id'] as int? ?? 0,
      namaJadwal: json['nama_jadwal'] as String? ?? '',
      skema: json['skema'] as String? ?? '',
      kodeSkema: json['kode_skema'] as String? ?? '',
      tuk: json['tuk'] as String? ?? '',
      tanggal: json['tanggal'] as String? ?? '',
      kuota: json['kuota'] as String? ?? '20 Peserta',
      skVerifikasiTuk: json['sk_verifikasi_tuk'] as String? ?? '-',
      linkFolderRekaman: json['link_folder_rekaman'] as String? ?? '',
      linkRekamanAsesor: json['link_rekaman_asesor'] as String? ?? '',
      linkVertuk: json['link_vertuk'] as String? ?? '',
      namaAsesor: json['nama_asesor'] as String? ?? '',
      totalPeserta: json['total_peserta'] as int? ?? pesertaList.length,
      totalKompeten: json['total_kompeten'] as int? ?? 0,
      totalBelumKompeten: json['total_belum_kompeten'] as int? ?? 0,
      totalBelumDinilai: json['total_belum_dinilai'] as int? ?? 0,
      daftarAsesor: asesorList,
      peserta: pesertaList,
      pencapaian: json['pencapaian'] as String? ?? '',
      unitBk: json['unit_bk'] as String? ?? '',
      saranTindakLanjut: json['saran_tindak_lanjut'] as String? ?? '',
      peliharaKompetensi: json['pelihara_kompetensi'] as String? ?? '',
      catatan: json['catatan'] as String? ?? '',
      statusLaporan: json['status_laporan'] as String? ?? 'Draft',
    );
  }
}

class AK06PrinsipItem {
  final String prosedur;
  bool valid;
  bool reliable;
  bool flexible;
  bool fair;

  AK06PrinsipItem({
    required this.prosedur,
    this.valid = true,
    this.reliable = true,
    this.flexible = true,
    this.fair = true,
  });

  factory AK06PrinsipItem.fromJson(Map<String, dynamic> json) {
    return AK06PrinsipItem(
      prosedur: json['prosedur'] as String? ?? '',
      valid: json['valid'] as bool? ?? true,
      reliable: json['reliable'] as bool? ?? true,
      flexible: json['flexible'] as bool? ?? false,
      fair: json['fair'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prosedur': prosedur,
      'valid': valid,
      'reliable': reliable,
      'flexible': flexible,
      'fair': fair,
    };
  }
}



class JadwalAK06DetailData {
  final int jadwalId;
  final String namaJadwal;
  final String skema;
  final String tuk;
  final String tanggal;
  final String namaAsesor;
  final String penjelasanAsesmen;
  final List<AK06PrinsipItem> prinsipAsesmen;
  final List<AK06AspectItem> dimensiKompetensi;
  final String rekomendasi;
  final String catatan;
  final String statusTinjauan;

  JadwalAK06DetailData({
    required this.jadwalId,
    required this.namaJadwal,
    required this.skema,
    required this.tuk,
    required this.tanggal,
    required this.namaAsesor,
    required this.penjelasanAsesmen,
    required this.prinsipAsesmen,
    required this.dimensiKompetensi,
    required this.rekomendasi,
    required this.catatan,
    required this.statusTinjauan,
  });

  factory JadwalAK06DetailData.fromJson(Map<String, dynamic> json) {
    final rawPrinsip = json['prinsip_asesmen'];
    List<AK06PrinsipItem> prinsipList = [];
    if (rawPrinsip is List) {
      prinsipList = rawPrinsip
          .map((e) => AK06PrinsipItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (prinsipList.isEmpty) {
      prinsipList = [
        AK06PrinsipItem(
            prosedur: 'Rencana asesmen',
            valid: true,
            reliable: true,
            flexible: true,
            fair: true),
        AK06PrinsipItem(
            prosedur: 'Persiapan asesmen',
            valid: true,
            reliable: true,
            flexible: true,
            fair: true),
        AK06PrinsipItem(
            prosedur: 'Implementasi asesmen',
            valid: true,
            reliable: true,
            flexible: true,
            fair: true),
        AK06PrinsipItem(
            prosedur: 'Keputusan asesmen',
            valid: true,
            reliable: true,
            flexible: false,
            fair: true),
        AK06PrinsipItem(
            prosedur: 'Umpan balik asesmen',
            valid: true,
            reliable: true,
            flexible: false,
            fair: true),
      ];
    }

    final rawDimensi = json['dimensi_kompetensi'];
    List<AK06AspectItem> dimensiList = [];
    if (rawDimensi is List) {
      dimensiList = rawDimensi
          .map((e) => AK06AspectItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (dimensiList.isEmpty) {
      dimensiList = [
        AK06AspectItem(
            aspect: 'Task Skills', kesesuaian: 'Ya', catatan: 'L (IA.01, IA.02)'),
        AK06AspectItem(
            aspect: 'Task Management Skills',
            kesesuaian: 'Ya',
            catatan: 'L (IA.01, IA.02)'),
        AK06AspectItem(
            aspect: 'Contingency Management Skills',
            kesesuaian: 'Ya',
            catatan: 'L (IA.01, IA.02)'),
        AK06AspectItem(
            aspect: 'Job Role / Environment Skills',
            kesesuaian: 'Ya',
            catatan: 'L (IA.01, IA.02)'),
        AK06AspectItem(
            aspect: 'Transfer Skills',
            kesesuaian: 'Ya',
            catatan: 'L (IA.01, IA.02)'),
      ];
    }

    return JadwalAK06DetailData(
      jadwalId: json['jadwal_id'] as int? ?? 0,
      namaJadwal: json['nama_jadwal'] as String? ?? '',
      skema: json['skema'] as String? ?? '',
      tuk: json['tuk'] as String? ?? '',
      tanggal: json['tanggal'] as String? ?? '',
      namaAsesor: json['nama_asesor'] as String? ?? '',
      penjelasanAsesmen: json['penjelasan_asesmen'] as String? ?? '',
      prinsipAsesmen: prinsipList,
      dimensiKompetensi: dimensiList,
      rekomendasi: json['rekomendasi'] as String? ?? '',
      catatan: json['catatan'] as String? ?? '',
      statusTinjauan: json['status_tinjauan'] as String? ?? 'Selesai',
    );
  }
}
