// ============================================================================
// API Service — Backward-compatible barrel / facade
// ============================================================================
// Seluruh implementasi API telah dipecah ke service masing-masing domain:
//
//   api_client.dart          → Shared Dio singleton + interceptors
//   dashboard_service.dart   → Dashboard, Statistik, Wilayah, Regional
//   jadwal_service.dart      → Jadwal + Notifikasi
//   asesor_service.dart      → Asesor, Skema, Mitra
//   sertifikat_service.dart  → Sertifikat validate/search/summary
//   master_service.dart      → Master Provinsi/Kabupaten/Kecamatan/Skema/Jadwal
//   misc_services.dart       → Sessions, Berita, Health checks
//
// File ini tetap dipertahankan agar semua screen yang sudah ada tidak perlu
// mengganti import. Setiap method mendelegasikan ke service yang sesuai.

export 'api_client.dart';
export 'dashboard_service.dart';
export 'jadwal_service.dart';
export 'asesor_service.dart';
export 'asesi_service.dart';
export 'sertifikat_service.dart';
export 'master_service.dart';
export 'misc_services.dart';

import 'package:dio/dio.dart';

import 'api_client.dart';
import 'dashboard_service.dart';
import 'jadwal_service.dart';
import 'asesor_service.dart';
import 'sertifikat_service.dart';
import 'master_service.dart';
import 'misc_services.dart';
import '../models/dashboard_models.dart';
import '../models/sertifikat_models.dart';
import '../models/jadwal_models.dart';
import '../models/master_models.dart';
import '../models/auth_models.dart';
import '../models/berita_model.dart';

// ignore: avoid_classes_with_only_static_members
class ApiService {
  // ── Dio access ─────────────────────────────────────────────────────────────
  static String get baseUrl => ApiClient.baseUrl;
  static Dio get dio => ApiClient.dio;

  // ── Health ──────────────────────────────────────────────────────────────────
  static Future<bool> healthCheck() => HealthService.healthCheck();
  static Future<bool> readyCheck() => HealthService.readyCheck();

  // ── Dashboard ───────────────────────────────────────────────────────────────
  static Future<DashboardSummary> getSummary() => DashboardService.getSummary();
  static Future<AsesiDashboardSummary> getAsesiSummary() =>
      DashboardService.getAsesiSummary();
  static Future<AsesorDashboardData> getAsesorDashboard({String? tanggal}) =>
      DashboardService.getAsesorDashboard(tanggal: tanggal);
  static Future<List<MonthlyAssessment>> getMonthlyAssessments() => DashboardService.getMonthlyAssessments();
  static Future<List<MonthlyAssessment>> getAssessmentGraph({int months = 12}) =>
      DashboardService.getAssessmentGraph(months: months);
  static Future<StatistikOverview> getStatistikOverview() => DashboardService.getStatistikOverview();
  static Future<List<SectorDistribution>> getSectorDistribution() => DashboardService.getSectorDistribution();
  static Future<List<RegionalDistribution>> getPenyebaranRegional() => DashboardService.getPenyebaranRegional();
  static Future<List<TUKKabupaten>> getTUKKabupaten(String provinceId) =>
      DashboardService.getTUKKabupaten(provinceId);

  // ── Jadwal ──────────────────────────────────────────────────────────────────
  static Future<List<JadwalBaru>> getJadwalBaru() => JadwalService.getJadwalBaru();
  static Future<List<JadwalOverdue>> getJadwalOutOfDate() => JadwalService.getJadwalOutOfDate();
  static Future<JadwalStatistik> getJadwalStatistics() =>
      JadwalService.getJadwalStatistics();
  static Future<List<JadwalItem>> getJadwalList({
    int limit = 20,
    int offset = 0,
    String? statusJadwal,
    int? idTuk,
    String? idLsp,
    String? sortBy,
    String? sortOrder,
    String? customRoutePath,
  }) =>
      JadwalService.getJadwalList(
        limit: limit,
        offset: offset,
        statusJadwal: statusJadwal,
        idTuk: idTuk,
        idLsp: idLsp,
        sortBy: sortBy,
        sortOrder: sortOrder,
        customRoutePath: customRoutePath,
      );
  static Future<Map<String, dynamic>> updateJadwalStatus({
    required int jadwalId,
    required String rule,
    String? catatan,
  }) =>
      JadwalService.updateJadwalStatus(jadwalId: jadwalId, rule: rule, catatan: catatan);
  static Future<AsesiListResponse> getAsesiList(int jadwalId) => JadwalService.getAsesiList(jadwalId);
  static Future<ParticipantDetailResponse?> getParticipantDetail(int jadwalId, int pesertaId) =>
      JadwalService.getParticipantDetail(jadwalId, pesertaId);
  static Future<JadwalAsesorDetailResponse?> getJadwalAsesorDetail(int jadwalId) =>
      JadwalService.getJadwalAsesorDetail(jadwalId);
  static Future<String?> getSuratTugas(int jadwalId) => JadwalService.getSuratTugas(jadwalId);
  static Future<int> getNotificationCount() => JadwalService.getNotificationCount();
  static Future<WaitingScheduleResponse> getWaitingSchedules({
    int limit = 20,
    String? idLsp,
    int? idTuk,
    String sortBy = 'tanggal',
    String sortOrder = 'desc',
  }) =>
      JadwalService.getWaitingSchedules(
        limit: limit,
        idLsp: idLsp,
        idTuk: idTuk,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

  // ── Asesor ──────────────────────────────────────────────────────────────────
  static Future<AsesorStats> getAsesorStats() => AsesorService.getAsesorStats();
  static Future<List<SebaranSkemaAsesorItem>> getSebaranSkemaAsesor() => AsesorService.getSebaranSkemaAsesor();
  static Future<List<TopProvinsi>> getTopProvinces() => AsesorService.getTopProvinces();
  static Future<List<TopMitra>> getTopMitras() => AsesorService.getTopMitras();
  static Future<SkemaStats> getSkemaStats() => AsesorService.getSkemaStats();
  static Future<List<AsesorHomebase>> getAsesorHomebase() => AsesorService.getAsesorHomebase();

  // ── Sertifikat ──────────────────────────────────────────────────────────────
  static Future<SertifikatValidationResult> validateSertifikat(String noDokumen) =>
      SertifikatService.validateSertifikat(noDokumen);
  static Future<SertifikatSummary> getSertifikatSummary() => SertifikatService.getSertifikatSummary();
  static Future<SertifikatApiResponse> getSertifikatPerSkema({
    int limit = 10,
    int? tahun,
    String sort = 'desc',
  }) =>
      SertifikatService.getSertifikatPerSkema(limit: limit, tahun: tahun, sort: sort);
  static Future<List<SertifikatItem>> searchSertifikat({
    required String query,
    String? skema,
    String? kategori,
    String? status,
    int limit = 20,
    int offset = 0,
  }) =>
      SertifikatService.searchSertifikat(
        query: query,
        skema: skema,
        kategori: kategori,
        status: status,
        limit: limit,
        offset: offset,
      );

  // ── Master ──────────────────────────────────────────────────────────────────
  static Future<List<MasterItem>> getProvinsiList() => MasterService.getProvinsiList();
  static Future<List<MasterItem>> getKabupatenList(String provinceId) =>
      MasterService.getKabupatenList(provinceId);
  static Future<List<MasterItem>> getKecamatanList(String kabupatenId) =>
      MasterService.getKecamatanList(kabupatenId);
  static Future<List<MasterSkema>> getMasterSkemaList() => MasterService.getMasterSkemaList();
  static Future<List<MasterJadwal>> getMasterJadwalList(int idSkema) =>
      MasterService.getMasterJadwalList(idSkema);
  static Future<List<MasterSumberAnggaran>> getMasterSumberAnggaranList() =>
      MasterService.getMasterSumberAnggaranList();
  static Future<List<MasterPemberiAnggaran>> getMasterPemberiAnggaranList({
    int? idSumberAnggaran,
  }) =>
      MasterService.getMasterPemberiAnggaranList(idSumberAnggaran: idSumberAnggaran);
  static Future<List<MasterPendidikan>> getMasterPendidikanList() =>
      MasterService.getMasterPendidikanList();
  static Future<List<MasterPekerjaan>> getMasterPekerjaanList() =>
      MasterService.getMasterPekerjaanList();

  // ── Sessions ─────────────────────────────────────────────────────────────────
  static Future<List<LoginSession>> getActiveSessions() => AuthSessionService.getActiveSessions();
  static Future<bool> deleteSession(int id) => AuthSessionService.deleteSession(id);

  // ── Berita ───────────────────────────────────────────────────────────────────
  static Future<List<BeritaItem>> getBerita({int page = 1, int size = 10}) =>
      BeritaService.getBerita(page: page, size: size);
  static Future<BeritaDetail?> getBeritaDetail(int id) => BeritaService.getBeritaDetail(id);
}
