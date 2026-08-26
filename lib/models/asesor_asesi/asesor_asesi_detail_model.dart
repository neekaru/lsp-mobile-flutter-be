// ============================================================================
// Model detail asesi (untuk asesor).
// Diekstrak dari asesor_asesi_models.dart.
// ============================================================================

import 'apl_models.dart';
import 'ak_models.dart';

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
