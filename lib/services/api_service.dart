// ============================================================================
// API Service — Backward-compatible barrel / facade
// ============================================================================
// Seluruh implementasi API telah dipecah ke service masing-masing domain:
//
//   api_client.dart                  → Shared Dio singleton + interceptors
//   auth/session_service.dart        → Sessions login aktif
//   dashboard/dashboard_service.dart → Dashboard, Statistik, Wilayah, Regional
//   dashboard/berita_service.dart    → Berita
//   jadwal/jadwal_service.dart       → Jadwal + Notifikasi
//   asesor/asesor_service.dart       → Asesor, Skema, Mitra
//   asesi/asesi_service.dart         → Asesi (Instansi, Sertifikat, Pendaftaran)
//   sertifikat/sertifikat_service.dart → Sertifikat validate/search/summary
//   common/master_service.dart       → Master Provinsi/Kabupaten/Kecamatan/Skema/Jadwal
//   common/health_service.dart       → Health checks
//
// File ini tetap dipertahankan agar semua screen yang sudah ada tidak perlu
// mengganti import. Setiap method mendelegasikan ke service yang sesuai.

export 'api_client.dart';
export 'dashboard/dashboard_service.dart';
export 'dashboard/berita_service.dart';
export 'jadwal/jadwal_service.dart';
export 'asesor/asesor_service.dart';
export 'asesi/asesi_service.dart';
export 'sertifikat/sertifikat_service.dart';
export 'common/master_service.dart';
export 'common/file_service.dart';
export 'common/health_service.dart';
export 'auth/session_service.dart';
export 'admin/blanko_service.dart';
export '../models/asesor_statistik_models.dart';

import 'package:dio/dio.dart';

import 'api_client.dart';
import 'dashboard/dashboard_service.dart';
import 'dashboard/berita_service.dart';
import 'jadwal/jadwal_service.dart';
import 'asesor/asesor_service.dart';
import 'sertifikat/sertifikat_service.dart';
import 'common/master_service.dart';
import 'common/file_service.dart';
import 'common/health_service.dart';
import 'auth/session_service.dart';
import 'auth/auth_repository.dart';
import '../utils/api_routes.dart';
import '../models/dashboard_models.dart';
import '../models/asesor_statistik_models.dart';
import '../models/sertifikat_models.dart';
import '../models/jadwal_models.dart';
import '../models/master_models.dart';
import '../models/auth_models.dart';
import '../models/berita_models.dart';

// ignore: avoid_classes_with_only_static_members
class ApiService {
  // ── Dio access ─────────────────────────────────────────────────────────────
  static String get baseUrl => ApiClient.baseUrl;
  static Dio get dio => ApiClient.dio;

  // ── Profile Photo Upload ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> uploadProfilePhoto(String filePath) async {
    try {
      final fileName = filePath.split(RegExp(r'[\\/]')).last;
      final formData = FormData.fromMap({
        'foto': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await dio.post(
        ApiRoutes.uploadFotoProfil,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>?;
        if (data != null) {
          final fotoProfil = data['foto_profil']?.toString() ?? '';
          final fotoProfilUrl = data['foto_profil_url']?.toString() ?? '';
          await AuthRepository.updateCurrentUserPhoto(
            fotoProfil: fotoProfil,
            fotoProfilUrl: fotoProfilUrl,
          );
        }
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ── Health ──────────────────────────────────────────────────────────────────
  static Future<bool> healthCheck() => HealthService.healthCheck();
  static Future<bool> readyCheck() => HealthService.readyCheck();

  // ── Dashboard ───────────────────────────────────────────────────────────────
  static Future<DashboardSummary> getSummary() => DashboardService.getSummary();
  static Future<AsesiDashboardSummary> getAsesiSummary() =>
      DashboardService.getAsesiSummary();
  static Future<AsesorDashboardData> getAsesorDashboard({String? tanggal}) =>
      DashboardService.getAsesorDashboard(tanggal: tanggal);
  static Future<List<MonthlyAssessment>> getMonthlyAssessments() =>
      DashboardService.getMonthlyAssessments();
  static Future<List<MonthlyAssessment>> getAssessmentGraph({
    int months = 12,
  }) => DashboardService.getAssessmentGraph(months: months);
  static Future<StatistikOverview> getStatistikOverview() =>
      DashboardService.getStatistikOverview();
  static Future<List<SectorDistribution>> getSectorDistribution() =>
      DashboardService.getSectorDistribution();
  static Future<List<RegionalDistribution>> getPenyebaranRegional() =>
      DashboardService.getPenyebaranRegional();
  static Future<List<TUKKabupaten>> getTUKKabupaten(String provinceId) =>
      DashboardService.getTUKKabupaten(provinceId);
  static Future<PenyebaranWilayahDetail?> getPenyebaranWilayahDetail(
    String provinceId,
    String provinceName,
  ) =>
      DashboardService.getPenyebaranWilayahDetail(provinceId, provinceName);
  static Future<DomisiliAsesorData?> getDomisiliAsesor() =>
      DashboardService.getDomisiliAsesor();
  static Future<DomisiliAsesorDetailData?> getDomisiliAsesorDetail({
    required String provinsiId,
    String? search,
    String? tipe,
    int limit = 50,
    int offset = 0,
  }) =>
      DashboardService.getDomisiliAsesorDetail(
        provinsiId: provinsiId,
        search: search,
        tipe: tipe,
        limit: limit,
        offset: offset,
      );
  static Future<List<KompetensiTeknisItem>> getKompetensiTeknis() =>
      DashboardService.getKompetensiTeknis();
  static Future<KompetensiTeknisDetailData?> getKompetensiTeknisDetail({
    required dynamic skemaId,
    String? search,
    String? status,
    int limit = 50,
    int offset = 0,
  }) =>
      DashboardService.getKompetensiTeknisDetail(
        skemaId: skemaId,
        search: search,
        status: status,
        limit: limit,
        offset: offset,
      );
  static Future<MasaBerlakuAsesorData?> getMasaBerlakuAsesor() =>
      DashboardService.getMasaBerlakuAsesor();
  static Future<MasaTenggangSertifikatData?> getMasaTenggangSertifikat() =>
      DashboardService.getMasaTenggangSertifikat();
  static Future<MasaBerlakuAsesorDetailData?> getMasaBerlakuAsesorDetail({
    required String status,
    String? search,
    int limit = 50,
    int offset = 0,
  }) =>
      DashboardService.getMasaBerlakuAsesorDetail(
        status: status,
        search: search,
        limit: limit,
        offset: offset,
      );
  static Future<List<JenisSkemaItem>> getJenisSkema() =>
      DashboardService.getJenisSkema();
  static Future<List<MUKDistribusiItem>> getMUKDistribusi() =>
      DashboardService.getMUKDistribusi();
  static Future<MUKDetailData?> getMUKDistribusiDetail({
    required dynamic skemaId,
    String? search,
  }) =>
      DashboardService.getMUKDistribusiDetail(
        skemaId: skemaId,
        search: search,
      );
  static Future<SptAsesorData?> getSptAsesor2026({int tahun = 2026}) =>
      DashboardService.getSptAsesor2026(tahun: tahun);
  static Future<Asesi2026Data?> getAsesi2026({int tahun = 2026}) =>
      DashboardService.getAsesi2026(tahun: tahun);
  static Future<AsesorStatistikData?> getAsesorStatistikBulanan({int tahun = 2026}) =>
      AsesorService.getAsesorStatistikBulanan(tahun: tahun);


  // ── Jadwal ──────────────────────────────────────────────────────────────────
  static Future<List<JadwalBaru>> getJadwalBaru() =>
      JadwalService.getJadwalBaru();
  static Future<List<JadwalOverdue>> getJadwalOutOfDate() =>
      JadwalService.getJadwalOutOfDate();
  static Future<JadwalStatistik> getJadwalStatistics() =>
      JadwalService.getJadwalStatistics();
  static Future<List<JadwalItem>> getJadwalList({
    int limit = 20,
    int offset = 0,
    String? statusJadwal,
    int? idTuk,
    String? idLsp,
    String? search,
    String? tanggalAsesmen,
    String? tuk,
    String? sortBy,
    String? sortOrder,
    String? customRoutePath,
  }) => JadwalService.getJadwalList(
    limit: limit,
    offset: offset,
    statusJadwal: statusJadwal,
    idTuk: idTuk,
    idLsp: idLsp,
    search: search,
    tanggalAsesmen: tanggalAsesmen,
    tuk: tuk,
    sortBy: sortBy,
    sortOrder: sortOrder,
    customRoutePath: customRoutePath,
  );
  static Future<Map<String, dynamic>> updateJadwalStatus({
    required int jadwalId,
    required String rule,
    String? catatan,
  }) => JadwalService.updateJadwalStatus(
    jadwalId: jadwalId,
    rule: rule,
    catatan: catatan,
  );
  static Future<AsesiListResponse> getAsesiList(int jadwalId) =>
      JadwalService.getAsesiList(jadwalId);
  static Future<ParticipantDetailResponse?> getParticipantDetail(
    int jadwalId,
    int pesertaId,
  ) => JadwalService.getParticipantDetail(jadwalId, pesertaId);
  static Future<JadwalAsesorDetailResponse?> getJadwalAsesorDetail(
    int jadwalId,
  ) => JadwalService.getJadwalAsesorDetail(jadwalId);
  static Future<String?> getSuratTugas(int jadwalId) =>
      JadwalService.getSuratTugas(jadwalId);
  static Future<int> getNotificationCount() =>
      JadwalService.getNotificationCount();
  static Future<WaitingScheduleResponse> getWaitingSchedules({
    int limit = 20,
    String? idLsp,
    int? idTuk,
    String sortBy = 'tanggal',
    String sortOrder = 'desc',
  }) => JadwalService.getWaitingSchedules(
    limit: limit,
    idLsp: idLsp,
    idTuk: idTuk,
    sortBy: sortBy,
    sortOrder: sortOrder,
  );

  // ── Asesor ──────────────────────────────────────────────────────────────────
  static Future<AsesorStats> getAsesorStats() => AsesorService.getAsesorStats();
  static Future<List<SebaranSkemaAsesorItem>> getSebaranSkemaAsesor() =>
      AsesorService.getSebaranSkemaAsesor();
  static Future<List<TopProvinsi>> getTopProvinces() =>
      AsesorService.getTopProvinces();
  static Future<List<TopMitra>> getTopMitras() => AsesorService.getTopMitras();
  static Future<SkemaStats> getSkemaStats() => AsesorService.getSkemaStats();


  // ── Sertifikat ──────────────────────────────────────────────────────────────
  static Future<SertifikatValidationResult> validateSertifikat(
    String noDokumen,
  ) => SertifikatService.validateSertifikat(noDokumen);
  static Future<SertifikatSummary> getSertifikatSummary() =>
      SertifikatService.getSertifikatSummary();
  static Future<SertifikatApiResponse> getSertifikatPerSkema({
    int limit = 10,
    int? tahun,
    String sort = 'desc',
  }) => SertifikatService.getSertifikatPerSkema(
    limit: limit,
    tahun: tahun,
    sort: sort,
  );
  static Future<List<SertifikatItem>> searchSertifikat({
    String? query,
    String? skema,
    String? kategori,
    String? status,
    String? tanggalAsesmen,
    String? tuk,
    int limit = 20,
    int offset = 0,
  }) => SertifikatService.searchSertifikat(
    query: query,
    skema: skema,
    kategori: kategori,
    status: status,
    tanggalAsesmen: tanggalAsesmen,
    tuk: tuk,
    limit: limit,
    offset: offset,
  );

  // ── Master ──────────────────────────────────────────────────────────────────
  static Future<List<MasterItem>> getProvinsiList() =>
      MasterService.getProvinsiList();
  static Future<List<MasterItem>> getKabupatenList(String provinceId) =>
      MasterService.getKabupatenList(provinceId);
  static Future<List<MasterItem>> getKecamatanList(String kabupatenId) =>
      MasterService.getKecamatanList(kabupatenId);
  static Future<List<MasterSkema>> getMasterSkemaList() =>
      MasterService.getMasterSkemaList();
  static Future<List<MasterJadwal>> getMasterJadwalList(int idSkema) =>
      MasterService.getMasterJadwalList(idSkema);
  static Future<List<MasterSumberAnggaran>> getMasterSumberAnggaranList() =>
      MasterService.getMasterSumberAnggaranList();
  static Future<List<MasterPemberiAnggaran>> getMasterPemberiAnggaranList({
    int? idSumberAnggaran,
  }) => MasterService.getMasterPemberiAnggaranList(
    idSumberAnggaran: idSumberAnggaran,
  );
  static Future<List<MasterPendidikan>> getMasterPendidikanList() =>
      MasterService.getMasterPendidikanList();
  static Future<List<MasterPekerjaan>> getMasterPekerjaanList() =>
      MasterService.getMasterPekerjaanList();
  static Future<SkemaUnitPersyaratan?> getSkemaUnitPersyaratan(int idSkema) =>
      MasterService.getSkemaUnitPersyaratan(idSkema);

  // ── Sessions ─────────────────────────────────────────────────────────────────
  static Future<List<LoginSession>> getActiveSessions() =>
      AuthSessionService.getActiveSessions();
  static Future<bool> deleteSession(int id) =>
      AuthSessionService.deleteSession(id);

  // ── Berita ───────────────────────────────────────────────────────────────────
  static Future<List<BeritaItem>> getBerita({int page = 1, int size = 10}) =>
      BeritaService.getBerita(page: page, size: size);
  static Future<BeritaDetail?> getBeritaDetail(int id) =>
      BeritaService.getBeritaDetail(id);
  static Future<Map<String, dynamic>?> uploadBeritaFoto(String filePath) =>
      BeritaService.uploadBeritaFoto(filePath);
  static Future<Map<String, dynamic>?> getSignedUrl(String filePath) =>
      FileService.getSignedUrl(filePath);
  static Future<Map<String, dynamic>?> createAdminBerita({
    required String judul,
    required String headline,
    required String isi,
    required int idKategori,
    String? foto,
    String showImage = '1',
  }) =>
      BeritaService.createAdminBerita(
        judul: judul,
        headline: headline,
        isi: isi,
        idKategori: idKategori,
        foto: foto,
        showImage: showImage,
      );
  static Future<Map<String, dynamic>?> updateAdminBerita(
    int id, {
    String? judul,
    String? headline,
    String? isi,
    int? idKategori,
    String? foto,
    String? showImage,
  }) =>
      BeritaService.updateAdminBerita(
        id,
        judul: judul,
        headline: headline,
        isi: isi,
        idKategori: idKategori,
        foto: foto,
        showImage: showImage,
      );
  static Future<bool> deleteAdminBerita(int id) =>
      BeritaService.deleteAdminBerita(id);
}
