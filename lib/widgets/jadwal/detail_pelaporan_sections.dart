import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../models/admin_laporan_models.dart';

/// Tab Informasi Asessmen — menampilkan detail laporan pelaporan.
class InformasiContent extends StatelessWidget {
  final AdminLaporanDetailData detail;
  final bool isApproved;

  const InformasiContent({
    super.key,
    required this.detail,
    required this.isApproved,
  });

  @override
  Widget build(BuildContext context) {
    final String namaSkema = detail.skemaSertifikasi.isNotEmpty
        ? detail.skemaSertifikasi
        : 'Digital Marketing';
    final String kodeSkema = detail.kodeLaporan.isNotEmpty
        ? detail.kodeLaporan
        : 'JNA - 002';
    final String tuk = detail.tuk.isNotEmpty ? detail.tuk : 'LPK Digital Center';
    final String jenisAsessmen = detail.jenisAsesmen.isNotEmpty
        ? detail.jenisAsesmen
        : 'Offline';
    final String tanggalAsessmen = detail.tanggalPelaksanaan.isNotEmpty
        ? detail.tanggalPelaksanaan
        : '20 Juli 2026';
    final String asesor = detail.namaAsesor.isNotEmpty
        ? detail.namaAsesor
        : 'Karina';
    final String jumlahAsessi = '${detail.ringkasan.totalPeserta} Peserta';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Informasi Asessmen Card Box
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Asessmen',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 14),
              InfoRow(label: 'Nama Skema', value: namaSkema),
              InfoRow(label: 'Kode Skema', value: kodeSkema),
              InfoRow(label: 'TUK', value: tuk),
              InfoRow(label: 'Jenis Asessmen', value: jenisAsessmen),
              InfoRow(label: 'Tanggal Asessmen', value: tanggalAsessmen),
              InfoRow(label: 'Asessor', value: asesor),
              InfoRow(label: 'Jumlah Asessi', value: jumlahAsessi),
            ],
          ),
        ),

        // Status Banner ONLY shown if Disetujui
        if (isApproved) ...[
          const SizedBox(height: 16),
          const GreenStatusBanner(),
        ],
      ],
    );
  }
}

/// Banner status hijau "Laporan Telah Disetujui".
class GreenStatusBanner extends StatelessWidget {
  const GreenStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF34D399),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF10B981),
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Laporan Telah Lengkap',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF065F46),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tidak ada dokumen yang perlu direvisi. Laporan dinyatakan lengkap.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF047857),
                    height: 1.3,
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

/// Baris label + nilai untuk detail laporan.
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab Lampiran — daftar berkas pendukung + kelengkapan laporan asesor.
class LampiranContent extends StatelessWidget {
  final AdminLaporanDetailData detail;
  final bool isApproved;
  final TextEditingController catatanController;
  final Future<void> Function(String link) onOpenLink;

  const LampiranContent({
    super.key,
    required this.detail,
    required this.isApproved,
    required this.catatanController,
    required this.onOpenLink,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = detail.lampiranPendukung.map((item) {
      return {
        'title': item.title.isNotEmpty ? item.title : item.fileName,
        'file': item.fileName.isNotEmpty ? item.fileName : item.fileUrl,
        'url': item.fileUrl,
        'size': item.fileSize,
        'isValid': item.isValid,
      };
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            final bool isValid = item['isValid'] == true;

            return Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: Color(0xFF3B82F6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'].toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      InkWell(
                        onTap: item['url'].toString().isEmpty
                            ? null
                            : () => onOpenLink(item['url'].toString()),
                        child: Text(
                          item['file'].toString(),
                          style: TextStyle(
                            fontSize: 11,
                            color: item['url'].toString().isEmpty
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF2563EB),
                            decoration: item['url'].toString().isEmpty
                                ? TextDecoration.none
                                : TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  item['size'].toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isValid
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isValid ? Icons.check : Icons.close,
                    color: isValid
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                    size: 14,
                  ),
                ),
              ],
            );
          },
        ),

        if (detail.daftarAsesor.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),
          const Text(
            'Kelengkapan Laporan Asesor',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: detail.daftarAsesor.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final asesor = detail.daftarAsesor[index];
              final bool isLengkap = asesor.isComplete == '1';
              final String link = asesor.linkRekaman;

              return Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isLengkap
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      isLengkap ? Icons.person_rounded : Icons.person_outline_rounded,
                      color: isLengkap
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asesor.namaAsesor,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        InkWell(
                          onTap: link.isEmpty ? null : () => onOpenLink(link),
                          child: Text(
                            link.isNotEmpty ? link : 'Belum mengunggah link pelaporan',
                            style: TextStyle(
                              fontSize: 11,
                              color: link.isNotEmpty
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF94A3B8),
                              decoration: link.isNotEmpty
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLengkap
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isLengkap ? 'Lengkap' : 'Belum Lengkap',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isLengkap
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ),

                  if (link.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF3B82F6)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: link));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Link Laporan ${asesor.namaAsesor} disalin!'),
                            backgroundColor: const Color(0xFF3B82F6),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              );
            },
          ),
        ],

        const SizedBox(height: 14),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
        const SizedBox(height: 14),

        if (!isApproved) ...[
          const Text(
            'Catatan Revisi Admin',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: TextField(
              controller: catatanController,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF334155),
                height: 1.4,
              ),
              decoration: const InputDecoration(
                hintText: 'Masukkan catatan revisi...',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ] else ...[
          const GreenStatusBanner(),
        ],
      ],
    );
  }
}

/// Tab Asessi — tabel peserta dengan pencarian nama/no registrasi.
class AsesiContent extends StatelessWidget {
  final AdminLaporanDetailData detail;
  final bool isApproved;
  final TextEditingController asesiSearchController;

  const AsesiContent({
    super.key,
    required this.detail,
    required this.isApproved,
    required this.asesiSearchController,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> rawAsesiList = detail.daftarAsesiDinilai.map((a) {
      return {
        'nama': a.nama,
        'noReg': a.nim,
        'hasil': a.penilaian.toLowerCase().contains('kompeten') || a.penilaian == 'K'
            ? 'Kompeten'
            : 'Belum Kompeten',
      };
    }).toList();

    final String asesiSearchQuery = asesiSearchController.text.trim().toLowerCase();
    final filteredList = rawAsesiList.where((a) {
      if (asesiSearchQuery.isEmpty) return true;
      final nama = a['nama']?.toLowerCase() ?? '';
      final noReg = a['noReg']?.toLowerCase() ?? '';
      return nama.contains(asesiSearchQuery) || noReg.contains(asesiSearchQuery);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input Box: "Cari nama/no registrasi peserta"
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: Color(0xFF94A3B8),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: asesiSearchController,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                  decoration: const InputDecoration(
                    hintText: 'Cari nama/no registrasi peserta',
                    hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Table Header Box (Nama | No Registrasi | Hasil)
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: const [
              Expanded(
                flex: 3,
                child: Text(
                  'Nama',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'No Registrasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Hasil',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // List of Asesi Cards without top gap
        if (filteredList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'Tidak ada peserta yang cocok.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: filteredList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final item = filteredList[index];
              final String nama = item['nama'] ?? '';
              final String noReg = item['noReg'] ?? '';
              final String hasil = item['hasil'] ?? 'Kompeten';
              final bool isKompeten = hasil == 'Kompeten';

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        nama,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        noReg,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isKompeten
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            hasil,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: isKompeten
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

        // Status Banner ONLY shown if Disetujui
        if (isApproved) ...[
          const SizedBox(height: 12),
          const GreenStatusBanner(),
        ],
      ],
    );
  }
}
