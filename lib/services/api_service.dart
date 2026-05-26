import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DashboardSummary {
  final int totalAsesmen;
  final int totalPemegangSertifikat;
  final int totalAsesor;
  final int totalTuk;

  DashboardSummary({
    required this.totalAsesmen,
    required this.totalPemegangSertifikat,
    required this.totalAsesor,
    required this.totalTuk,
  });

  factory DashboardSummary.fallback() {
    return DashboardSummary(
      totalAsesmen: 2545,
      totalPemegangSertifikat: 3045,
      totalAsesor: 120,
      totalTuk: 45,
    );
  }
}

class MonthlyAssessment {
  final String label;
  final int total;
  final double heightPercentage;

  MonthlyAssessment({
    required this.label,
    required this.total,
    required this.heightPercentage,
  });
}

class JadwalOverdue {
  final int id;
  final String jadwal;
  final String tanggal;
  final String tuk;
  final int daysOverdue;
  final String statusLabel;

  JadwalOverdue({
    required this.id,
    required this.jadwal,
    required this.tanggal,
    required this.tuk,
    required this.daysOverdue,
    required this.statusLabel,
  });

  factory JadwalOverdue.fromJson(Map<String, dynamic> json) {
    return JadwalOverdue(
      id: json['id'] ?? 0,
      jadwal: json['jadwal'] ?? 'Jadwal Asesmen',
      tanggal: json['tanggal'] ?? '',
      tuk: json['tuk'] ?? 'TUK Pusat',
      daysOverdue: json['days_overdue'] ?? 0,
      statusLabel: json['status_label'] ?? 'Terjadwal',
    );
  }
}

class ApiService {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? "";

  // Instantiate Dio with custom, strict, and snappy socket timeouts
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(
        milliseconds: 1000,
      ), // Socket connect timeout
      receiveTimeout: const Duration(
        milliseconds: 1500,
      ), // Response transfer timeout
    ),
  );

  // 1. Fetch Dashboard Summary (Rangkuman Utama)
  static Future<DashboardSummary> getSummary() async {
    try {
      final responses = await Future.wait([
        _dio.get('/api/dashboard/monthly-assessments?months=36'),
        _dio.get('/api/dashboard/sertifikat-per-skema?limit=1'),
        _dio.get('/api/dashboard/asesor-distribution?limit=1'),
        _dio.get('/api/dashboard/penyebaran-tuk?limit=1'),
      ]);

      int totalAsesmen = 0;
      if (responses[0].statusCode == 200 && responses[0].data != null) {
        final List<dynamic> data = responses[0].data['data'] ?? [];
        for (var item in data) {
          totalAsesmen += (item['total'] as num).toInt();
        }
      }

      int totalPemegangSertifikat = 0;
      if (responses[1].statusCode == 200 && responses[1].data != null) {
        totalPemegangSertifikat =
            responses[1].data['meta']?['total_pemegang_sertifikat'] ?? 0;
      }

      int totalAsesor = 0;
      if (responses[2].statusCode == 200 && responses[2].data != null) {
        totalAsesor = responses[2].data['total_asesor'] ?? 0;
      }

      int totalTuk = 0;
      if (responses[3].statusCode == 200 && responses[3].data != null) {
        totalTuk = responses[3].data['meta']?['total_tuk'] ?? 0;
      }

      // If all are zero, it might mean empty DB, return fallback
      if (totalAsesmen == 0 &&
          totalPemegangSertifikat == 0 &&
          totalAsesor == 0 &&
          totalTuk == 0) {
        return DashboardSummary.fallback();
      }

      return DashboardSummary(
        totalAsesmen: totalAsesmen,
        totalPemegangSertifikat: totalPemegangSertifikat,
        totalAsesor: totalAsesor,
        totalTuk: totalTuk,
      );
    } catch (e) {
      // Instantly return fallback data on timeout or connection error
      return DashboardSummary.fallback();
    }
  }

  // 2. Fetch Monthly Assessments for Chart (Tren Asesmen Bulanan)
  static Future<List<MonthlyAssessment>> getMonthlyAssessments() async {
    try {
      final response = await _dio.get(
        '/api/dashboard/monthly-assessments?months=4',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];

        List<MonthlyAssessment> list = [];
        int maxTotal = 1; // Prevent division by zero

        for (var item in data) {
          int total = (item['total'] as num).toInt();
          if (total > maxTotal) maxTotal = total;
        }

        for (var item in data) {
          int total = (item['total'] as num).toInt();
          list.add(
            MonthlyAssessment(
              label: item['label'] ?? '',
              total: total,
              heightPercentage: total / maxTotal,
            ),
          );
        }

        if (list.isEmpty) {
          return _getFallbackMonthlyAssessments();
        }

        return list;
      } else {
        return _getFallbackMonthlyAssessments();
      }
    } catch (e) {
      return _getFallbackMonthlyAssessments();
    }
  }

  static List<MonthlyAssessment> _getFallbackMonthlyAssessments() {
    return [
      MonthlyAssessment(label: 'Mei 2026', total: 1050, heightPercentage: 0.42),
      MonthlyAssessment(label: 'Jun 2026', total: 1550, heightPercentage: 0.62),
      MonthlyAssessment(label: 'Jul 2026', total: 2050, heightPercentage: 0.82),
      MonthlyAssessment(label: 'Agu 2026', total: 2545, heightPercentage: 1.0),
    ];
  }

  // 3. Fetch Jadwal Asesmen Mendekati Akhir (Out of Date Schedules)
  static Future<List<JadwalOverdue>> getJadwalOutOfDate() async {
    try {
      final response = await _dio.get('/api/jadwal/out-of-date?limit=3');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];

        List<JadwalOverdue> list = data
            .map((item) => JadwalOverdue.fromJson(item as Map<String, dynamic>))
            .toList();

        if (list.isEmpty) {
          return _getFallbackJadwal();
        }

        return list;
      } else {
        return _getFallbackJadwal();
      }
    } catch (e) {
      return _getFallbackJadwal();
    }
  }

  static List<JadwalOverdue> _getFallbackJadwal() {
    return [
      JadwalOverdue(
        id: 1,
        jadwal: 'Sertifikasi Kompetensi TIK Bidang Programmer',
        tanggal: '2025-05-23',
        tuk: 'TUK Campus Digital',
        daysOverdue: 3,
        statusLabel: 'Terjadwal',
      ),
      JadwalOverdue(
        id: 2,
        jadwal: 'Asesmen Ulang Klaster Cloud Computing',
        tanggal: '2025-05-24',
        tuk: 'TUK Sewaktu LSP',
        daysOverdue: 2,
        statusLabel: 'Sedang Berlangsung',
      ),
      JadwalOverdue(
        id: 3,
        jadwal: 'Uji Kompetensi Jabatan Fungsional Sandiman',
        tanggal: '2025-05-25',
        tuk: 'TUK Mandiri Cyber',
        daysOverdue: 1,
        statusLabel: 'Terjadwal',
      ),
    ];
  }
}
