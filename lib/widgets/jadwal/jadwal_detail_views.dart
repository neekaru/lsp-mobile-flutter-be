import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/jadwal_models.dart';
import '../../services/api_service.dart';
import '../../screens/jadwal/profil_asesor_screen.dart';
import '../../screens/jadwal/asesi_list_screen.dart';
import 'detail_helpers.dart';

// ============================================================================
// View detail jadwal (Asesor / Asesi) + formatter tanggal.
//
// Diekstrak dari jadwal_detail_screen.dart agar file screen tetap ringkas.
// ============================================================================

String formatIndonesianDate(String yyyymmdd) {
    try {
      final parts = yyyymmdd.split('-');
      if (parts.length != 3) return yyyymmdd;
      final year = parts[0];
      final monthIndex = int.parse(parts[1]);
      final day = int.parse(parts[2]).toString();

      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final monthName = months[monthIndex - 1];
      return '$day $monthName $year';
    } catch (e) {
      return yyyymmdd;
    }
  }

String getDurationString(JadwalItem jadwal) {
    try {
      final start = DateTime.parse(jadwal.tanggalMulai);
      final end = DateTime.parse(jadwal.tanggalSelesai);
      final diff = end.difference(start).inDays + 1;
      return '$diff Hari';
    } catch (e) {
      return '7 Hari'; // Fallback matching the image
    }
  }

String statusLabelFor(JadwalItem jadwal, String status) {
    // Prefer label dari BE bila tersedia
    if (jadwal.statusLabel.trim().isNotEmpty &&
        status == jadwal.status) {
      return jadwal.displayStatusLabel;
    }
    switch (status) {
      case 'draft':
      case 'waiting':
        return 'Draft';
      case 'completed':
        return 'Completed';
      case 'canceled':
        return 'Canceled';
      case 'running':
        return 'Running';
      case 'pelaporan':
        return 'Pelaporan';
      default:
        return status;
    }
  }

String getDisplayAsesor(JadwalItem jadwal) {
    if (jadwal.asesor.isEmpty) {
      return 'Belum ditentukan';
    }
    return jadwal.asesor.first;
  }

String formatAsesiDateRange(JadwalItem jadwal) {
    try {
      final start = DateTime.tryParse(jadwal.tanggalMulai);
      final end = DateTime.tryParse(jadwal.tanggalSelesai);
      if (start == null || end == null) {
        return '${jadwal.tanggalMulai} - ${jadwal.tanggalSelesai}';
      }
      final days = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu',
      ];
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final startDay = days[start.weekday - 1];
      final monthName = months[start.month - 1];

      if (start.month == end.month && start.year == end.year) {
        if (start.day == end.day) {
          return '$startDay, ${start.day} $monthName ${start.year}';
        }
        return '$startDay, ${start.day}-${end.day} $monthName ${start.year}';
      } else {
        final endDay = days[end.weekday - 1];
        final endMonthName = months[end.month - 1];
        return '$startDay, ${start.day} $monthName ${start.year} - $endDay, ${end.day} $endMonthName ${end.year}';
      }
    } catch (e) {
      return '${jadwal.tanggalMulai} - ${jadwal.tanggalSelesai}';
    }
  }

class JadwalDetailAsesorView extends StatelessWidget {
  final JadwalItem jadwal;
  final JadwalAsesorDetailData? detailData;

  const JadwalDetailAsesorView({
    super.key,
    required this.jadwal,
    this.detailData,
  });

  @override
  Widget build(BuildContext context) {
    final String leadAsesor =
        (detailData != null && detailData!.asesor.isNotEmpty)
        ? detailData!.asesor.first.namaAsesor
        : (detailData?.leadAsesor != null &&
              detailData!.leadAsesor!.isNotEmpty)
        ? detailData!.leadAsesor!
        : getDisplayAsesor(jadwal);

    final String totalPeserta = (detailData?.jumlahPeserta != null)
        ? '${detailData!.jumlahPeserta} Peserta'
        : '${jadwal.jumlahAsesi} Peserta';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card 1: Main info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon, Title & Subtitle, Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F1FC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: Color(0xFF2C6C9C),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jadwal.skema,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            detailData?.tuk ?? jadwal.tuk,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AsesorStatusBadge(status: jadwal.status),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFECEFF1)),
                const SizedBox(height: 16),

                // Info rows
                AsesorDetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Tanggal Asesmen',
                  value: formatAsesiDateRange(jadwal),
                ),
                AsesorDetailRow(
                  icon: Icons.access_time_rounded,
                  label: 'Waktu Asesmen',
                  value:
                      (detailData?.waktuAsesmen != null &&
                          detailData!.waktuAsesmen!.isNotEmpty)
                      ? detailData!.waktuAsesmen!
                      : '09:00 - 11:00 WIB',
                ),
                AsesorDetailRow(
                  icon: Icons.location_on_rounded,
                  label: 'Lokasi Asesmen',
                  value:
                      detailData != null && detailData!.alamatTuk.isNotEmpty
                      ? detailData!.alamatTuk
                      : (jadwal.tuk.isNotEmpty ? jadwal.tuk : '-'),
                  iconColor: Colors.orange,
                ),
                AsesorDetailRow(
                  icon: Icons.people_outline_rounded,
                  label: 'Peserta',
                  value: totalPeserta,
                ),
                AsesorDetailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Lead Asesor',
                  value: leadAsesor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card 2: Lihat Surat Tugas
          ActionButtonCard(
            icon: Icons.description_rounded,
            title: 'Lihat Surat Tugas',
            onTap: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );
              try {
                final fileUrl = await ApiService.getSuratTugas(
                  jadwal.id,
                );
                if (context.mounted) {
                  Navigator.pop(context); // Dismiss loading dialog
                }
                if (fileUrl != null && fileUrl.isNotEmpty) {
                  final uri = Uri.parse(fileUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Tidak dapat membuka file PDF Surat Tugas.',
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                } else if (context.mounted) {
                  throw Exception('Surat tugas belum tersedia');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Dismiss loading dialog
                }
                final errorMsg = e.toString().replaceAll('Exception: ', '');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMsg),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 12),

          // Card 3: Lihat Peserta
          ActionButtonCard(
            icon: Icons.people_rounded,
            title: 'Lihat Peserta',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AsesiListScreen(
                    jadwalId: jadwal.id,
                    jadwalTitle: jadwal.skema,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class JadwalDetailAsesiView extends StatelessWidget {
  final JadwalItem jadwal;
  final JadwalAsesorDetailData? detailData;

  const JadwalDetailAsesiView({
    super.key,
    required this.jadwal,
    this.detailData,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Jadwal Terverifikasi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Jadwal Anda telah diverifikasi oleh pihak lsp',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Calendar Icon, Scheme, TUK
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F1FC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: Color(0xFF2C6C9C),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jadwal.skema,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            detailData?.tuk ?? jadwal.tuk,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Details List
                AsesiInfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Tanggal Asesmen',
                  value: formatAsesiDateRange(jadwal),
                ),
                AsesiInfoRow(
                  icon: Icons.access_time_rounded,
                  label: 'Waktu Asesmen',
                  value: '09:00 - 11:00 WIB',
                ),
                AsesiInfoRow(
                  icon: Icons.location_on_rounded,
                  label: 'Lokasi Asesmen',
                  value:
                      detailData != null && detailData!.alamatTuk.isNotEmpty
                      ? detailData!.alamatTuk
                      : (jadwal.tuk.isNotEmpty ? jadwal.tuk : '-'),
                  iconColor: Colors.orange,
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFECEFF1)),
                const SizedBox(height: 12),

                // Asesor Section
                const Text(
                  'Asesor',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                if (detailData != null && detailData!.asesor.isNotEmpty)
                  ...detailData!.asesor.map(
                    (asesorItem) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF5F5F5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      asesorItem.namaAsesor,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'No Reg: ${asesorItem.noReg}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD2E3F4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF6C8BB4),
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfilAsesorScreen(
                                        name: asesorItem.namaAsesor,
                                        skema: jadwal.skema,
                                        lokasi: asesorItem.kabupatenKota,
                                        asesorDetail: asesorItem,
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Lihat Profil Asesor',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C6C9C),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getDisplayAsesor(jadwal),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              jadwal.skema,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2E3F4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF6C8BB4),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilAsesorScreen(
                                name: getDisplayAsesor(jadwal),
                                skema: jadwal.skema,
                                lokasi: detailData != null && detailData!.alamatTuk.isNotEmpty
                                    ? detailData!.alamatTuk
                                    : (jadwal.tuk.isNotEmpty ? jadwal.tuk : '-'),
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Lihat Profil Asesor',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C6C9C),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFECEFF1)),
                const SizedBox(height: 12),

                // Checklist Section
                ChecklistItem(title: 'Portofolio Lengkap'),
                ChecklistItem(title: 'Bukti Kompetensi Valid'),
                ChecklistItem(title: 'Pra Asesmen Disetujui'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
