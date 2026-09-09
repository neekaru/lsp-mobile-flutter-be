import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/jadwal_models.dart';
import '../../services/jadwal/jadwal_service.dart';
import '../../screens/jadwal/asesi_list_screen.dart';
import '../../screens/jadwal/jadwal_ak05_screen.dart';
import '../../screens/jadwal/jadwal_ak06_screen.dart';
import 'detail_helpers.dart';
import 'jadwal_detail_format.dart';

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

    final double bottomInset = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 32),
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
                    AsesorStatusBadge(
                      status: (detailData != null && detailData!.statusLabel.isNotEmpty)
                          ? detailData!.statusLabel
                          : (detailData != null && detailData!.statusJadwal.isNotEmpty
                              ? detailData!.statusJadwal
                              : (jadwal.statusLabel.isNotEmpty ? jadwal.statusLabel : jadwal.status)),
                      label: (detailData != null && detailData!.statusLabel.isNotEmpty)
                          ? detailData!.statusLabel
                          : (jadwal.statusLabel.isNotEmpty ? jadwal.statusLabel : null),
                    ),
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
                    statusJadwal: jadwal.statusJadwal,
                    isSelesai: jadwal.status == 'completed' || jadwal.statusJadwal == '1',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Card 3.5: Materi Uji Kompetensi (MUK / MAPA)
          ActionButtonCard(
            icon: Icons.menu_book_rounded,
            title: 'Materi Uji Kompetensi (MUK)',
            onTap: () {
              final mukList = detailData?.materiUji ?? [];
              final primaryLink = detailData?.linkMukManual ?? '';

              if (mukList.isEmpty && primaryLink.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Materi Uji Kompetensi (MUK) belum tersedia untuk skema ini.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (modalCtx) {
                  return Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(modalCtx).size.height * 0.85,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.menu_book_rounded,
                                        color: Color(0xFF2563EB),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Materi Uji Kompetensi (MUK)',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Dokumen MAPA & materi yang diujikan',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(height: 1),
                              ],
                            ),
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (mukList.isNotEmpty)
                                    ...mukList.map((m) {
                                      final hasLink = m.hasDownloadLink;
                                      return Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              m.namaMapa,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            if (m.penyusun.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                'Penyusun: ${m.penyusun}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                            if (m.validator.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                'Validator: ${m.validator}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 12),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                onPressed: hasLink
                                                    ? () async {
                                                        final uri = Uri.tryParse(m.linkMukManual);
                                                        if (uri != null) {
                                                          try {
                                                            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                                              await launchUrl(uri, mode: LaunchMode.platformDefault);
                                                            }
                                                          } catch (_) {
                                                            try {
                                                              await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                                                            } catch (_) {}
                                                          }
                                                        }
                                                      }
                                                    : null,
                                                icon: Icon(
                                                  hasLink
                                                      ? Icons.open_in_new_rounded
                                                      : Icons.link_off_rounded,
                                                  size: 16,
                                                ),
                                                label: Text(
                                                  hasLink
                                                      ? 'Buka Link MUK Manual'
                                                      : 'Link MUK Belum Tersedia',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF2563EB),
                                                  foregroundColor: Colors.white,
                                                  disabledBackgroundColor: const Color(0xFFF1F5F9),
                                                  disabledForegroundColor: const Color(0xFF94A3B8),
                                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    side: hasLink
                                                        ? BorderSide.none
                                                        : const BorderSide(color: Color(0xFFE2E8F0)),
                                                  ),
                                                  elevation: 0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    })
                                  else if (primaryLink.isNotEmpty)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Materi Uji Kompetensi (MUK)',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                final uri = Uri.tryParse(primaryLink);
                                                if (uri != null) {
                                                  try {
                                                    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                                      await launchUrl(uri, mode: LaunchMode.platformDefault);
                                                    }
                                                  } catch (_) {
                                                    try {
                                                      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                                                    } catch (_) {}
                                                  }
                                                }
                                              },
                                              icon: const Icon(Icons.open_in_new_rounded, size: 16),
                                              label: const Text(
                                                'Buka Link MUK Manual',
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF2563EB),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 10),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                elevation: 0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
