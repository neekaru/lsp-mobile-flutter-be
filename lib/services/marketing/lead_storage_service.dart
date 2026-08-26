import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/lead_model.dart';

class LeadStorageService {
  static const _storage = FlutterSecureStorage();
  static const String _keyPrefix = 'lsp_asesor_leads_';

  static Future<List<LeadModel>> getLeads(int idAsesor) async {
    try {
      final key = '$_keyPrefix$idAsesor';
      final jsonStr = await _storage.read(key: key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((e) => LeadModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    // Seed default realistic dummy leads if storage is empty
    final initialLeads = _getDefaultSeedLeads(idAsesor);
    await saveAllLeads(idAsesor, initialLeads);
    return initialLeads;
  }

  static Future<void> saveAllLeads(int idAsesor, List<LeadModel> leads) async {
    final key = '$_keyPrefix$idAsesor';
    final jsonStr = jsonEncode(leads.map((e) => e.toJson()).toList());
    await _storage.write(key: key, value: jsonStr);
  }

  static Future<void> saveLead(LeadModel lead) async {
    final list = await getLeads(lead.idAsesor);
    final idx = list.indexWhere((e) => e.id == lead.id);
    if (idx >= 0) {
      list[idx] = lead.copyWith(updatedAt: DateTime.now());
    } else {
      list.insert(0, lead.copyWith(updatedAt: DateTime.now()));
    }
    await saveAllLeads(lead.idAsesor, list);
  }

  static Future<void> updateLeadStatus(int idAsesor, String leadId, String newStatus) async {
    final list = await getLeads(idAsesor);
    final idx = list.indexWhere((e) => e.id == leadId);
    if (idx >= 0) {
      list[idx] = list[idx].copyWith(
        leadStatus: newStatus,
        updatedAt: DateTime.now(),
      );
      await saveAllLeads(idAsesor, list);
    }
  }

  static Future<void> deleteLead(int idAsesor, String leadId) async {
    final list = await getLeads(idAsesor);
    list.removeWhere((e) => e.id == leadId);
    await saveAllLeads(idAsesor, list);
  }

  /// AI Potensi Generator Engine
  /// Menghasilkan analisis potensi jurusan, estimasi siswa per tahun, dan target skema uji LSP
  static Future<LeadModel> generateAiPotensi(LeadModel lead) async {
    await Future.delayed(const Duration(milliseconds: 900));

    int estimasi = lead.estimasiSiswa;
    List<String> jurusan = List.from(lead.jurusanList);
    String analisis = '';

    switch (lead.leadKategori) {
      case 'SMK':
        if (estimasi == 0) estimasi = 320;
        if (jurusan.isEmpty) {
          jurusan = ['Teknik Komputer & Jaringan', 'Rekayasa Perangkat Lunak', 'Multimedia / DKV'];
        }
        analisis = 'Potensi ±$estimasi siswa kelas XII per tahun. Sangat prospektif untuk skema Junior Network Administrator, Web Developer Pratama, dan Desain Grafis.';
        break;
      case 'Kampus':
        if (estimasi == 0) estimasi = 450;
        if (jurusan.isEmpty) {
          jurusan = ['Teknik Informatika', 'Sistem Informasi', 'Manajemen Informatika'];
        }
        analisis = 'Potensi ±$estimasi lulusan/mahasiswa tingkat akhir. Target utama: Sertifikasi SKPI (Surat Keterangan Pendamping Ijazah) skema Programmer & Network Admin.';
        break;
      case 'LPK':
      case 'LKP':
        if (estimasi == 0) estimasi = 160;
        if (jurusan.isEmpty) {
          jurusan = ['Digital Marketing', 'Desain Grafis Komputer', 'Office Application'];
        }
        analisis = 'Potensi ±$estimasi peserta pelatihan/batch per tahun. Minat tinggi pada skema Digital Marketing Specialist & Pengelola Administrasi Perkantoran.';
        break;
      case 'BLK':
        if (estimasi == 0) estimasi = 240;
        if (jurusan.isEmpty) {
          jurusan = ['TIK / Komputer', 'Teknik Telekomunikasi', 'Teknik Elektronika'];
        }
        analisis = 'Potensi ±$estimasi peserta pelatihan vokasi bersumber dana APBN/APBD. Peluang TUK Mandiri & Uji Kompetensi Massal.';
        break;
      case 'Dinas Pemda':
        if (estimasi == 0) estimasi = 85;
        if (jurusan.isEmpty) {
          jurusan = ['Aparatur Bidang TIK', 'Pengelola Data & Informasi', 'Pranata Komputer'];
        }
        analisis = 'Potensi ±$estimasi ASN & staf dinas terkait. Kebutuhan sertifikasi peningkatan kompetensi ASN & pengelola sistem pemerintahan berbasis elektronik (SPBE).';
        break;
      case 'Perusahaan Swasta':
      default:
        if (estimasi == 0) estimasi = 60;
        if (jurusan.isEmpty) {
          jurusan = ['IT Support & Network', 'Content Creator & Marketing'];
        }
        analisis = 'Potensi ±$estimasi karyawan/teknisi industri. Kebutuhan uji kompetensi in-house & sertifikasi standar BNSP.';
        break;
    }

    return lead.copyWith(
      estimasiSiswa: estimasi,
      jurusanList: jurusan,
      leadPotensi: analisis,
      isAiGenerated: true,
      updatedAt: DateTime.now(),
    );
  }

  static List<LeadModel> _getDefaultSeedLeads(int idAsesor) {
    final now = DateTime.now();
    return [
      LeadModel(
        id: 'lead-1',
        idAsesor: idAsesor,
        namaInstitusi: 'SMK Negeri 1 Surabaya',
        leadKategori: 'SMK',
        leadLocation: 'Jl. SMEA No.4, Wonokromo, Surabaya',
        kabupaten: 'Kota Surabaya',
        provinsi: 'Jawa Timur',
        latitude: -7.3012,
        longitude: 112.7383,
        leadDescription: 'Sekolah Menengah Kejuruan Pusat Keunggulan dengan konsentrasi bidang TIK dan Bisnis Manajemen.',
        leadPotensi: 'Potensi ±350 siswa per tahun. Jurusan TKJ & RPL. Target skema Junior Network Admin & Web Dev.',
        estimasiSiswa: 350,
        jurusanList: ['Teknik Komputer & Jaringan', 'Rekayasa Perangkat Lunak', 'DKV'],
        leadStatus: 'prospek',
        telepon: '031-8292038',
        email: 'info@smkn1-sby.sch.id',
        picName: 'Drs. Budi Santoso (Kaprodi TKJ)',
        isAiGenerated: true,
        updatedAt: now,
      ),
      LeadModel(
        id: 'lead-2',
        idAsesor: idAsesor,
        namaInstitusi: 'Politeknik Negeri Malang',
        leadKategori: 'Kampus',
        leadLocation: 'Jl. Soekarno Hatta No.9, Jatimulyo, Lowokwaru, Malang',
        kabupaten: 'Kota Malang',
        provinsi: 'Jawa Timur',
        latitude: -7.9467,
        longitude: 112.6156,
        leadDescription: 'Perguruan Tinggi Vokasi terkemuka dengan program Diploma & Sarjana Terapan Teknologi Informasi.',
        leadPotensi: 'Potensi ±280 mahasiswa tingkat akhir per tahun. Minat skema Web Developer & Database Administrator.',
        estimasiSiswa: 280,
        jurusanList: ['D4 Teknik Informatika', 'D3 Manajemen Informatika', 'D4 Sistem Informasi Bisnis'],
        leadStatus: 'interest',
        telepon: '0341-404424',
        email: 'ti@polinema.ac.id',
        picName: 'Ir. Hendra Gunawan, M.T.',
        isAiGenerated: true,
        updatedAt: now,
      ),
      LeadModel(
        id: 'lead-3',
        idAsesor: idAsesor,
        namaInstitusi: 'BLK (Balai Latihan Kerja) Surabaya',
        leadKategori: 'BLK',
        leadLocation: 'Jl. Dukuh Menanggal III No.29, Gayungan, Surabaya',
        kabupaten: 'Kota Surabaya',
        provinsi: 'Jawa Timur',
        latitude: -7.3385,
        longitude: 112.7231,
        leadDescription: 'UPTD Pelatihan Kerja Dinas Tenaga Kerja & Transmigrasi Provinsi Jawa Timur.',
        leadPotensi: 'Potensi ±220 peserta pelatihan per tahun bersertifikasi BNSP. Kerjasama aktif uji kompetensi 2026.',
        estimasiSiswa: 220,
        jurusanList: ['Pelatihan TIK', 'Desain Grafis', 'Teknik Komputer'],
        leadStatus: 'sales',
        telepon: '031-8280254',
        email: 'uptblk.surabaya@gmail.com',
        picName: 'Ibu Ratna Dewi (Sie Pelatihan)',
        isAiGenerated: true,
        updatedAt: now,
      ),
      LeadModel(
        id: 'lead-4',
        idAsesor: idAsesor,
        namaInstitusi: 'LPK Mitra Buana Digital Edu',
        leadKategori: 'LPK',
        leadLocation: 'Jl. Raya Mojoagung No. 12, Jombang',
        kabupaten: 'Kabupaten Jombang',
        provinsi: 'Jawa Timur',
        latitude: -7.5645,
        longitude: 112.3482,
        leadDescription: 'Lembaga Pelatihan Kerja swasta fokus pada vokasi digital marketing dan pemrograman.',
        leadPotensi: 'Potensi ±140 peserta kursus per tahun. Skema Digital Marketing & Junior Web Developer.',
        estimasiSiswa: 140,
        jurusanList: ['Digital Marketing', 'Pemrograman Web', 'Desain Komunikasi Visual'],
        leadStatus: 'lead',
        telepon: '0853-2948-9247',
        email: 'mitrabuana.edu@gmail.com',
        picName: 'Roy Buana (Direktur)',
        isAiGenerated: true,
        updatedAt: now,
      ),
      LeadModel(
        id: 'lead-5',
        idAsesor: idAsesor,
        namaInstitusi: 'Dinas Komunikasi & Informatika',
        leadKategori: 'Dinas Pemda',
        leadLocation: 'Jl. Ahmad Yani No. 50, Surabaya',
        kabupaten: 'Kota Surabaya',
        provinsi: 'Jawa Timur',
        latitude: -7.3190,
        longitude: 112.7335,
        leadDescription: 'Instansi Pemerintah Daerah Pengelola Sistem Informasi, Jaringan Komunikasi, dan Keamanan Siber.',
        leadPotensi: 'Potensi ±75 staf ASN & Non-ASN untuk peningkatan sertifikasi kompetensi SPBE & Cyber Security.',
        estimasiSiswa: 75,
        jurusanList: ['Pranata Komputer', 'Pengelola Jaringan', 'Keamanan Informasi'],
        leadStatus: 'prospek',
        telepon: '031-8291777',
        email: 'diskominfo@jatimprov.go.id',
        picName: 'Pak Wahyu (Kabid TIK)',
        isAiGenerated: true,
        updatedAt: now,
      ),
      LeadModel(
        id: 'lead-6',
        idAsesor: idAsesor,
        namaInstitusi: 'PT. Solusi Digital Mandiri',
        leadKategori: 'Perusahaan Swasta',
        leadLocation: 'Kawasan Industri Rungkut Megah Raya, Surabaya',
        kabupaten: 'Kota Surabaya',
        provinsi: 'Jawa Timur',
        latitude: -7.3255,
        longitude: 112.7680,
        leadDescription: 'Software house & IT infrastructure vendor dengan puluhan software engineer dan network engineer.',
        leadPotensi: 'Potensi ±50 engineer untuk sertifikasi kompetensi profesi dan standar sertifikasi tender proyek.',
        estimasiSiswa: 50,
        jurusanList: ['Software Engineering', 'Cloud Infrastructure', 'Network Security'],
        leadStatus: 'interest',
        telepon: '031-8782991',
        email: 'hrd@solusidigital.co.id',
        picName: 'Agus Pratama (HR Lead)',
        isAiGenerated: true,
        updatedAt: now,
      ),
    ];
  }
}

