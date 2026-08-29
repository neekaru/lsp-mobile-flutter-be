import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/lead_model.dart';

class LeadSummaryStats {
  final int total;
  final int countLead;
  final int countProspek;
  final int countInterest;
  final int countSales;
  final int totalEstimasiSiswa;

  const LeadSummaryStats({
    this.total = 0,
    this.countLead = 0,
    this.countProspek = 0,
    this.countInterest = 0,
    this.countSales = 0,
    this.totalEstimasiSiswa = 0,
  });
}

class LeadStorageService {
  static const _storage = FlutterSecureStorage();
  static const String _keyPrefix = 'lsp_asesor_leads_';

  static Future<List<LeadModel>> getLeads(int idAsesor) async {
    try {
      final key = '$_keyPrefix$idAsesor';
      final jsonStr = await _storage.read(key: key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list
            .map((e) => LeadModel.fromJson(e as Map<String, dynamic>))
            .toList();
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
    final idx = list.indexWhere((e) => e.id == lead.id || (e.placeId.isNotEmpty && e.placeId == lead.placeId));
    if (idx >= 0) {
      list[idx] = lead.copyWith(updatedAt: DateTime.now());
    } else {
      list.insert(0, lead.copyWith(updatedAt: DateTime.now()));
    }
    await saveAllLeads(lead.idAsesor, list);
  }

  static Future<void> updateLeadStatus(
      int idAsesor, String leadId, String newStatus) async {
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

  static Future<void> updateLeadData(LeadModel updatedLead) async {
    final list = await getLeads(updatedLead.idAsesor);
    final idx = list.indexWhere((e) => e.id == updatedLead.id);
    if (idx >= 0) {
      list[idx] = updatedLead.copyWith(updatedAt: DateTime.now());
      await saveAllLeads(updatedLead.idAsesor, list);
    }
  }

  static Future<void> deleteLead(int idAsesor, String leadId) async {
    final list = await getLeads(idAsesor);
    list.removeWhere((e) => e.id == leadId);
    await saveAllLeads(idAsesor, list);
  }

  static Future<LeadSummaryStats> getSummaryStats(int idAsesor) async {
    final list = await getLeads(idAsesor);
    int cLead = 0;
    int cProspek = 0;
    int cInterest = 0;
    int cSales = 0;
    int totalSiswa = 0;

    for (final item in list) {
      totalSiswa += item.estimasiSiswa;
      switch (item.leadStatus.toLowerCase()) {
        case 'lead':
          cLead++;
          break;
        case 'prospek':
          cProspek++;
          break;
        case 'interest':
          cInterest++;
          break;
        case 'sales':
        case 'deal':
          cSales++;
          break;
      }
    }

    return LeadSummaryStats(
      total: list.length,
      countLead: cLead,
      countProspek: cProspek,
      countInterest: cInterest,
      countSales: cSales,
      totalEstimasiSiswa: totalSiswa,
    );
  }

  /// AI Potensi Generator Engine
  /// Menghasilkan analisis potensi jurusan, estimasi siswa per tahun, dan target skema uji LSP
  static Future<LeadModel> generateAiPotensi(LeadModel lead) async {
    await Future.delayed(const Duration(milliseconds: 600));

    int estimasi = lead.estimasiSiswa;
    List<String> jurusan = List.from(lead.jurusanList);
    String analisis = '';

    switch (lead.leadKategori) {
      case 'SMK':
        if (estimasi == 0) estimasi = 320;
        if (jurusan.isEmpty) {
          jurusan = [
            'Teknik Komputer & Jaringan (TKJ)',
            'Rekayasa Perangkat Lunak (RPL)',
            'Desain Komunikasi Visual (DKV)'
          ];
        }
        analisis =
            'Potensi ±$estimasi siswa kelas XII per tahun. Skema prioritas: Junior Network Administrator, Junior Web Developer, & Operator Komputer.';
        break;
      case 'Kampus':
        if (estimasi == 0) estimasi = 450;
        if (jurusan.isEmpty) {
          jurusan = [
            'Teknik Informatika (S1)',
            'Sistem Informasi (S1)',
            'Manajemen Informatika (D3)'
          ];
        }
        analisis =
            'Potensi ±$estimasi lulusan/mahasiswa tingkat akhir. Target utama: Sertifikasi SKPI skema Software Engineer, Database Admin, & Cyber Security.';
        break;
      case 'LPK':
      case 'LKP':
        if (estimasi == 0) estimasi = 160;
        if (jurusan.isEmpty) {
          jurusan = [
            'Digital Marketing Specialist',
            'Desain Grafis Komputer',
            'Office Automation'
          ];
        }
        analisis =
            'Potensi ±$estimasi peserta kursus/pelatihan per tahun. Minat tinggi pada sertifikasi keahlian digital terapan.';
        break;
      case 'BLK':
        if (estimasi == 0) estimasi = 240;
        if (jurusan.isEmpty) {
          jurusan = [
            'Kejuruan TIK',
            'Teknik Telekomunikasi',
            'Teknik Elektronika Industri'
          ];
        }
        analisis =
            'Potensi ±$estimasi peserta vokasi APBN/APBD per tahun. Peluang TUK Mandiri & Uji Kompetensi Massal bersubsidi.';
        break;
      case 'Dinas Pemda':
        if (estimasi == 0) estimasi = 85;
        if (jurusan.isEmpty) {
          jurusan = [
            'Aparatur Bidang TIK',
            'Pengelola Data SPBE',
            'Pranata Komputer'
          ];
        }
        analisis =
            'Potensi ±$estimasi ASN & staf dinas. Kebutuhan sertifikasi kompetensi ASN & pengelola sistem pemerintahan berbasis elektronik.';
        break;
      case 'Perusahaan Swasta':
      default:
        if (estimasi == 0) estimasi = 60;
        if (jurusan.isEmpty) {
          jurusan = [
            'IT Support & Network',
            'Software Developer',
            'Digital Marketing'
          ];
        }
        analisis =
            'Potensi ±$estimasi karyawan/teknisi industri. Kebutuhan uji kompetensi in-house & sertifikasi standar BNSP.';
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
        namaInstitusi: 'SMK Negeri 1 Kalasan',
        leadKategori: 'SMK',
        leadLocation:
            'Jl. Raya Solo - Yogyakarta KM 14, Glondong, Tirtomartani, Kalasan',
        kabupaten: 'Kabupaten Sleman',
        provinsi: 'DI Yogyakarta',
        latitude: -7.7719,
        longitude: 110.4691,
        leadDescription:
            'SMK Pusat Keunggulan dengan jurusan TKJ, RPL, dan Multimedia.',
        leadPotensi:
            'Potensi ±350 siswa/tahun. Skema prioritas: Junior Web Developer & Junior Network Admin.',
        estimasiSiswa: 350,
        jurusanList: [
          'Teknik Komputer & Jaringan',
          'Rekayasa Perangkat Lunak',
          'DKV'
        ],
        leadStatus: 'prospek',
        telepon: '0274-496180',
        email: 'info@smkn1kalasan.sch.id',
        picName: 'Drs. Budi Santoso (Wakasek Kurikulum)',
        rating: 4.8,
        userRatingsTotal: 142,
        isAiGenerated: true,
        updatedAt: now,
      ),
      LeadModel(
        id: 'lead-2',
        idAsesor: idAsesor,
        namaInstitusi: 'Universitas Ahmad Dahlan',
        leadKategori: 'Kampus',
        leadLocation:
            'Jl. Ringroad Selatan, Tamanan, Banguntapan, Bantul, DIY',
        kabupaten: 'Kabupaten Bantul',
        provinsi: 'DI Yogyakarta',
        latitude: -7.8333,
        longitude: 110.3831,
        leadDescription:
            'Perguruan Tinggi dengan Fakultas Teknologi Industri & Ilmu Komputer terkemuka.',
        leadPotensi:
            'Potensi ±480 mahasiswa/tahun untuk sertifikasi pendamping ijazah (SKPI).',
        estimasiSiswa: 480,
        jurusanList: [
          'Informatika (S1)',
          'Sistem Informasi (S1)',
          'Teknologi Informasi (S1)'
        ],
        leadStatus: 'interest',
        telepon: '0274-563515',
        email: 'fti@uad.ac.id',
        picName: 'Ir. Hendra Gunawan, M.T.',
        rating: 4.8,
        userRatingsTotal: 620,
        isAiGenerated: true,
        updatedAt: now,
      ),
      LeadModel(
        id: 'lead-3',
        idAsesor: idAsesor,
        namaInstitusi: 'BLK Kotawaringin Timur (Sampit)',
        leadKategori: 'BLK',
        leadLocation: 'Jl. Jenderal Sudirman KM. 6, Baamang, Sampit',
        kabupaten: 'Kotawaringin Timur',
        provinsi: 'Kalimantan Tengah',
        latitude: -2.5200,
        longitude: 112.9100,
        leadDescription:
            'Balai Latihan Kerja UPTD Pelatihan Kerja Dinas Tenaga Kerja Kotim.',
        leadPotensi:
            'Potensi ±220 peserta pelatihan per tahun bersertifikasi BNSP.',
        estimasiSiswa: 220,
        jurusanList: ['Pelatihan TIK', 'Desain Grafis', 'Teknik Komputer'],
        leadStatus: 'sales',
        telepon: '0531-23110',
        email: 'blk.kotim@gmail.com',
        picName: 'Ibu Ratna Dewi (Sie Pelatihan)',
        rating: 4.5,
        userRatingsTotal: 40,
        isAiGenerated: true,
        updatedAt: now,
      ),
      LeadModel(
        id: 'lead-4',
        idAsesor: idAsesor,
        namaInstitusi: 'SMK Negeri 1 Sampit',
        leadKategori: 'SMK',
        leadLocation: 'Jl. Walter Condrat No. 20, Baamang, Sampit',
        kabupaten: 'Kotawaringin Timur',
        provinsi: 'Kalimantan Tengah',
        latitude: -2.5312,
        longitude: 112.9510,
        leadDescription:
            'Sekolah Menengah Kejuruan Negeri favorit dengan program keahlian IT & Bisnis.',
        leadPotensi:
            'Potensi ±280 siswa kelas XII bidang komputer dan bisnis digital.',
        estimasiSiswa: 280,
        jurusanList: ['Teknik Komputer Jaringan', 'Bisnis Digital', 'Akuntansi'],
        leadStatus: 'lead',
        telepon: '0531-21345',
        email: 'smkn1sampit@gmail.com',
        picName: 'Pak Wahyudi (Kaprodi TKJ)',
        rating: 4.7,
        userRatingsTotal: 95,
        isAiGenerated: true,
        updatedAt: now,
      ),
    ];
  }
}
