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
      rekomendasiAsesor: json['rekomendasi_asesor'] as String? ?? 'Belum Dinilai',
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
  final String isKompeten;
  final String? fotoProfilUrl;
  final APL01Data apl01;
  final APL02Data apl02;
  final AK01Data ak01;
  final AK02Data ak02;
  final AK03Data ak03;
  final AK04Data ak04;
  final AK05Data ak05;

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
    required this.isKompeten,
    this.fotoProfilUrl,
    required this.apl01,
    required this.apl02,
    required this.ak01,
    required this.ak02,
    required this.ak03,
    required this.ak04,
    required this.ak05,
  });

  factory AsesorAsesiDetailData.fromJson(Map<String, dynamic> json) {
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
      rekomendasiAsesor: json['rekomendasi_asesor'] as String? ?? 'Belum Dinilai',
      isKompeten: json['is_kompeten'] as String? ?? '',
      fotoProfilUrl: json['foto_profil_url'] as String?,
      apl01: APL01Data.fromJson(json['apl01'] as Map<String, dynamic>? ?? {}),
      apl02: APL02Data.fromJson(json['apl02'] as Map<String, dynamic>? ?? {}),
      ak01: AK01Data.fromJson(json['ak01'] as Map<String, dynamic>? ?? {}),
      ak02: AK02Data.fromJson(json['ak02'] as Map<String, dynamic>? ?? {}),
      ak03: AK03Data.fromJson(json['ak03'] as Map<String, dynamic>? ?? {}),
      ak04: AK04Data.fromJson(json['ak04'] as Map<String, dynamic>? ?? {}),
      ak05: AK05Data.fromJson(json['ak05'] as Map<String, dynamic>? ?? {}),
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

class APL02Data {
  final String status;
  final int totalUnit;
  final int totalK;
  final int totalBK;
  final List<APL02UnitItem> units;

  APL02Data({
    required this.status,
    required this.totalUnit,
    required this.totalK,
    required this.totalBK,
    required this.units,
  });

  factory APL02Data.fromJson(Map<String, dynamic> json) {
    return APL02Data(
      status: json['status'] as String? ?? 'Lengkap',
      totalUnit: json['total_unit'] as int? ?? 0,
      totalK: json['total_k'] as int? ?? 0,
      totalBK: json['total_bk'] as int? ?? 0,
      units: (json['units'] as List<dynamic>? ?? [])
          .map((e) => APL02UnitItem.fromJson(e as Map<String, dynamic>))
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

class AK01Data {
  final String status;
  final String persetujuan;
  final String tglAsesmen;
  final String tuk;
  final bool tandaTangan;

  AK01Data({
    required this.status,
    required this.persetujuan,
    required this.tglAsesmen,
    required this.tuk,
    required this.tandaTangan,
  });

  factory AK01Data.fromJson(Map<String, dynamic> json) {
    return AK01Data(
      status: json['status'] as String? ?? 'Disetujui',
      persetujuan: json['persetujuan'] as String? ?? 'Asesi Menyetujui Seluruh Proses dan Tata Tertib Asesmen',
      tglAsesmen: json['tgl_asesmen'] as String? ?? '',
      tuk: json['tuk'] as String? ?? '',
      tandaTangan: json['tanda_tangan'] as bool? ?? true,
    );
  }
}

class AK02Data {
  final String status;
  final String hasilObservasi;
  final String hasilPraktik;
  final String hasilLisan;
  final String hasilEsai;
  final String komentarObservasi;

  AK02Data({
    required this.status,
    required this.hasilObservasi,
    required this.hasilPraktik,
    required this.hasilLisan,
    required this.hasilEsai,
    required this.komentarObservasi,
  });

  factory AK02Data.fromJson(Map<String, dynamic> json) {
    return AK02Data(
      status: json['status'] as String? ?? 'Selesai',
      hasilObservasi: json['hasil_observasi'] as String? ?? 'Kompeten',
      hasilPraktik: json['hasil_praktik'] as String? ?? 'Kompeten',
      hasilLisan: json['hasil_lisan'] as String? ?? 'Kompeten',
      hasilEsai: json['hasil_esai'] as String? ?? 'Kompeten',
      komentarObservasi: json['komentar_observasi'] as String? ?? '',
    );
  }
}

class AK03Data {
  final String status;
  final String umpanBalik;
  final String catatan;

  AK03Data({
    required this.status,
    required this.umpanBalik,
    required this.catatan,
  });

  factory AK03Data.fromJson(Map<String, dynamic> json) {
    return AK03Data(
      status: json['status'] as String? ?? 'Telah Diisi',
      umpanBalik: json['umpan_balik'] as String? ?? 'Proses asesmen berjalan baik dan sesuai prosedur',
      catatan: json['catatan'] as String? ?? '',
    );
  }
}

class AK04Data {
  final String status;
  final bool adaBanding;
  final String alasanBanding;

  AK04Data({
    required this.status,
    required this.adaBanding,
    required this.alasanBanding,
  });

  factory AK04Data.fromJson(Map<String, dynamic> json) {
    return AK04Data(
      status: json['status'] as String? ?? 'Tidak Ada Permohonan Banding',
      adaBanding: json['ada_banding'] as bool? ?? false,
      alasanBanding: json['alasan_banding'] as String? ?? '-',
    );
  }
}

class AK05Data {
  final String status;
  final String rekomendasi;
  final String tanggalRekomendasi;
  final String pencapaian;
  final String unitBk;
  final String saranTindakLanjut;
  final String peliharaKompetensi;

  AK05Data({
    required this.status,
    required this.rekomendasi,
    required this.tanggalRekomendasi,
    required this.pencapaian,
    required this.unitBk,
    required this.saranTindakLanjut,
    required this.peliharaKompetensi,
  });

  factory AK05Data.fromJson(Map<String, dynamic> json) {
    return AK05Data(
      status: json['status'] as String? ?? 'Selesai',
      rekomendasi: json['rekomendasi'] as String? ?? 'Kompeten',
      tanggalRekomendasi: json['tanggal_rekomendasi'] as String? ?? '',
      pencapaian: json['pencapaian'] as String? ?? 'Semua unit kompetensi telah tercapai dengan baik',
      unitBk: json['unit_bk'] as String? ?? '-',
      saranTindakLanjut: json['saran_tindak_lanjut'] as String? ?? 'Pertahankan dan terus kembangkan kompetensi',
      peliharaKompetensi: json['pelihara_kompetensi'] as String? ?? 'Mengikuti pelatihan berkelanjutan',
    );
  }
}
