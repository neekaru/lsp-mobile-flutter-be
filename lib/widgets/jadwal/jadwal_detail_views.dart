import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/jadwal_models.dart';
import '../../services/jadwal/jadwal_service.dart';
import '../../screens/jadwal/profil_asesor_screen.dart';
import '../../screens/jadwal/asesi_list_screen.dart';
import '../../screens/jadwal/jadwal_ak05_screen.dart';
import '../../screens/jadwal/jadwal_ak06_screen.dart';
import '../../screens/asesi/asesi_ak03_form_screen.dart';
import '../../utils/date_format_helper.dart';
import 'detail_helpers.dart';

// ============================================================================
// View detail jadwal (Asesor / Asesi) + formatter tanggal.
//
// Diekstrak dari jadwal_detail_screen.dart agar file screen tetap ringkas.
// ============================================================================

String formatIndonesianDate(String yyyymmdd) {
  return DateFormatHelper.formatToIndonesian(yyyymmdd);
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

String getDisplayAsesor(JadwalItem jadwal) {
  if (jadwal.asesor.isEmpty) {
    return 'Belum ditentukan';
  }
  return jadwal.asesor.first;
}

String formatAsesiDateRange(JadwalItem jadwal, [JadwalAsesorDetailData? detailData]) {
  final startStr = jadwal.tanggalMulai.isNotEmpty
      ? jadwal.tanggalMulai
      : (detailData != null && detailData.tanggal.isNotEmpty ? detailData.tanggal : '');
  final endStr = jadwal.tanggalSelesai.isNotEmpty
      ? jadwal.tanggalSelesai
      : (detailData != null && detailData.tanggalAkhir.isNotEmpty ? detailData.tanggalAkhir : startStr);

  if (startStr.isEmpty) return '-';
  if (endStr.isEmpty || startStr == endStr) {
    return DateFormatHelper.formatToLong(startStr);
  }
  return '${DateFormatHelper.formatToLong(startStr)} - ${DateFormatHelper.formatToLong(endStr)}';
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
    final bool isAJJ = detailData?.isAJJ ?? jadwal.isAJJ;

    final String namaAsesor = (detailData != null && detailData!.asesor.isNotEmpty)
        ? detailData!.asesor.map((a) => a.namaAsesor).where((n) => n.isNotEmpty).join(', ')
        : (detailData?.leadAsesor != null && detailData!.leadAsesor!.isNotEmpty)
            ? detailData!.leadAsesor!
            : getDisplayAsesor(jadwal);

    final String totalPeserta = (detailData?.jumlahPeserta != null)
        ? '${detailData!.jumlahPeserta} Peserta'
        : '${jadwal.jumlahAsesi} Peserta';

    final String lokasiAsesmen = isAJJ
        ? 'Daring'
        : (detailData != null && detailData!.alamatTuk.isNotEmpty
            ? detailData!.alamatTuk
            : (jadwal.tuk.isNotEmpty ? jadwal.tuk : '-'));

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
                        color: isAJJ
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFE5F1FC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        color: isAJJ
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF2C6C9C),
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
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  detailData?.tuk ?? jadwal.tuk,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              if (isAJJ) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: const Color(0xFFBFDBFE),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Text(
                                    'AJJ',
                                    style: TextStyle(
                                      color: Color(0xFF1D4ED8),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
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
                  value: formatAsesiDateRange(jadwal, detailData),
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
                  value: lokasiAsesmen,
                  iconColor: Colors.orange,
                ),
                AsesorDetailRow(
                  icon: Icons.people_outline_rounded,
                  label: 'Peserta',
                  value: totalPeserta,
                ),
                AsesorDetailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Asesor',
                  value: namaAsesor.isNotEmpty ? namaAsesor : '-',
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
              try {
                final fileUrl = await JadwalService.getSuratTugas(jadwal.id);
                final targetUrl = (fileUrl != null && fileUrl.isNotEmpty)
                    ? fileUrl
                    : 'https://sertifikasi.lspdigital.id/mobile/spt_asesor/${jadwal.id}';
                final uri = Uri.tryParse(targetUrl);
                if (uri != null) {
                  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                    await launchUrl(uri, mode: LaunchMode.platformDefault);
                  }
                }
              } catch (_) {
                final fallbackUrl = 'https://sertifikasi.lspdigital.id/mobile/spt_asesor/${jadwal.id}';
                final uri = Uri.tryParse(fallbackUrl);
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
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
                    tanggal: jadwal.tanggalMulai,
                    tuk: jadwal.tuk,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Card 4: FR-AK.05 Laporan Asesmen
          Builder(
            builder: (context) {
              final isAK05Locked = detailData != null && !detailData!.isAK05Unlocked;
              return ActionButtonCard(
                icon: Icons.assignment_turned_in_rounded,
                title: 'FR-AK.05 Laporan Asesmen',
                subtitle: isAK05Locked ? 'Terkunci: Selesaikan FR-AK.01 terlebih dahulu' : null,
                isLocked: isAK05Locked,
                onTap: () {
                  if (isAK05Locked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(detailData?.lockReasonAK05 ?? 'Selesaikan dan setujui formulir FR-AK.01 terlebih dahulu.'),
                        backgroundColor: const Color(0xFFDC2626),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JadwalAK05Screen(
                        jadwalId: jadwal.id,
                        jadwalTitle: jadwal.skema,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),

          // Card 5: FR-AK.06 Meninjau Proses Asesmen
          Builder(
            builder: (context) {
              final isAK06Locked = detailData != null && !detailData!.isAK06Unlocked;
              return ActionButtonCard(
                icon: Icons.rate_review_rounded,
                title: 'FR-AK.06 Meninjau Proses Asesmen',
                subtitle: isAK06Locked ? 'Terkunci: Selesaikan FR-AK.01 & AK.05 terlebih dahulu' : null,
                isLocked: isAK06Locked,
                onTap: () {
                  if (isAK06Locked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(detailData?.lockReasonAK06 ?? 'Selesaikan FR-AK.01 dan FR-AK.05 terlebih dahulu.'),
                        backgroundColor: const Color(0xFFDC2626),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JadwalAK06Screen(
                        jadwalId: jadwal.id,
                        jadwalTitle: jadwal.skema,
                      ),
                    ),
                  );
                },
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

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFECEFF1)),
                const SizedBox(height: 14),

                // FR-AK.03 Umpan Balik Asesi Action Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF93C5FD),
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
                            builder: (context) => AsesiAK03FormScreen(
                              jadwal: jadwal,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2F80ED),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.rate_review_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'FR-AK.03 Umpan Balik Asesmen',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E40AF),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Klik untuk mengisi evaluasi & umpan balik',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF3B82F6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Color(0xFF2F80ED),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
