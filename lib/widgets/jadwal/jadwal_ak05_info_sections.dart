import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../models/asesor_asesi_models.dart';
import '../asesi/asesi_form_common.dart';
import 'jadwal_ak05_peserta_sections.dart';

Widget buildAk05LockBanner({
  required JadwalAK05DetailData data,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFFCA5A5)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lock_outline_rounded, color: Color(0xFFDC2626), size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Formulir FR-AK.05 Terkunci',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF991B1B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.lockReason.isNotEmpty
                    ? data.lockReason
                    : 'Selesaikan dan setujui formulir FR-AK.01 terlebih dahulu sebelum mengisi formulir Laporan Asesmen.',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFFB91C1C),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildAk05InfoCard({
  required BuildContext context,
  required JadwalAK05DetailData data,
  required String jadwalTitle,
  required TextEditingController linkController,
  required Future<void> Function() onPasteLink,
  required ValueChanged<String> onLaunchUrl,
}) {
  final isSubmitted = data.statusLaporan == 'Sudah Diserahkan';

  return FormSectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSectionHeader(
          title: 'Informasi Pelaksanaan Asesmen',
          status: data.statusLaporan,
          statusColor: isSubmitted ? const Color(0xFF16A34A) : const Color(0xFFEAB308),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        const SizedBox(height: 12),
        AsesiDetailRow('Skema Sertifikasi', data.skema.isNotEmpty ? data.skema : '-'),
        if (data.kodeSkema.isNotEmpty)
          AsesiDetailRow('Kode Skema', data.kodeSkema),
        AsesiDetailRow('Nama Jadwal', data.namaJadwal.isNotEmpty ? data.namaJadwal : jadwalTitle),
        AsesiDetailRow('TUK', data.tuk.isNotEmpty ? data.tuk : '-'),
        AsesiDetailRow('Kuota & Tanggal', '${data.kuota} • ${data.tanggal}'),
        AsesiDetailRow('SK Verifikasi TUK', data.skVerifikasiTuk),
        const SizedBox(height: 12),

        // Link Folder Rekaman Cloud LSP
        if (data.linkFolderRekaman.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Link Folder Rekaman :',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => onLaunchUrl(data.linkFolderRekaman),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.cloud, size: 14, color: Color(0xFF2563EB)),
                      SizedBox(width: 4),
                      Text(
                        'Link Folder Cloud',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: data.linkFolderRekaman));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link Folder Cloud berhasil disalin!'),
                      backgroundColor: Color(0xFF2563EB),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.copy, size: 13, color: Color(0xFF475569)),
                      SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],

        // Field Input: Link Rekaman Asesmen
        const Text(
          'Link Rekaman Asesmen :',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              const Icon(LucideIcons.video, size: 18, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: linkController,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B)),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'https://cloud.lspdigital.id/s/... atau Google Drive',
                    hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Tempel dari Clipboard',
                icon: const Icon(LucideIcons.clipboard, size: 16, color: Color(0xFF64748B)),
                onPressed: onPasteLink,
              ),
              if (linkController.text.isNotEmpty)
                IconButton(
                  tooltip: 'Buka Tautan',
                  icon: const Icon(LucideIcons.external_link, size: 16, color: Color(0xFF2563EB)),
                  onPressed: () => onLaunchUrl(linkController.text.trim()),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Keterangan Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '*Keterangan : Link rekaman bisa menggunakan Link Folder Cloud atau Link Google Drive pribadi, pastikan link dapat diakses oleh asesor dan admin.',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                  height: 1.35,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Rekaman berisi :\n1. Hasil Pekerjaan atau Project Asesi\n2. Rekaman Verifikasi TUK, Rekaman Pra Asesmen, Rekaman Asesmen',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildAk05AsesorCard({
  required BuildContext context,
  required JadwalAK05DetailData data,
  required String linkRekamanText,
  required ValueChanged<String> onLaunchUrl,
}) {
  return FormSectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Asesor Bertugas & Link Rekaman Uji',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${data.daftarAsesor.isNotEmpty ? data.daftarAsesor.length : 1} Asesor',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        const SizedBox(height: 10),

        if (data.daftarAsesor.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. ${data.namaAsesor.isNotEmpty ? data.namaAsesor : "Asesor"}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                if (linkRekamanText.isNotEmpty)
                  InkWell(
                    onTap: () => onLaunchUrl(linkRekamanText.trim()),
                    child: Text(
                      linkRekamanText.trim(),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF2563EB),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else
                  const Text(
                    '(Belum ada link rekaman)',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                  ),
              ],
            ),
          )
        else
          ...data.daftarAsesor.asMap().entries.map((entry) {
            final index = entry.key;
            final as = entry.value;
            final link = as.linkRekaman;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${as.masaAktif} • ${as.noReg}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              as.namaAsesor,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Link Rekaman Asesor
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.link, size: 14, color: Color(0xFF2563EB)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: link.isNotEmpty
                              ? InkWell(
                                  onTap: () => onLaunchUrl(link),
                                  child: Text(
                                    link,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              : const Text(
                                  'Belum ada link rekaman tersimpan',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                        ),
                        if (link.isNotEmpty)
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: link));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Link rekaman berhasil disalin!'),
                                  backgroundColor: Color(0xFF2563EB),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(LucideIcons.copy, size: 14, color: Color(0xFF64748B)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Summary K / BK / Belum
                  Row(
                    children: [
                      Ak05CountChip('K', as.totalK, const Color(0xFF16A34A)),
                      const SizedBox(width: 6),
                      Ak05CountChip('BK', as.totalBk, const Color(0xFFDC2626)),
                      const SizedBox(width: 6),
                      Ak05CountChip('Belum', as.totalBelum, const Color(0xFF94A3B8)),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    ),
  );
}
