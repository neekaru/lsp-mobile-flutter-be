// ============================================================================
// Model laporan AK-05 & tinjauan AK-06 (jadwal asesmen).
// Diekstrak dari asesor_asesi_models.dart.
// ============================================================================

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
  String rekomendasiLabel; // "Kompeten", "Belum Kompeten", "Belum Dinilai"
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
