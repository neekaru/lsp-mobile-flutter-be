// ============================================================================
// Section form AK-01 .. AK-05 (asesi).
//
// Diekstrak dari asesi_form_sections.dart agar tiap bagian form asesi
// menjadi modul tersendiri.
// ============================================================================

import 'package:material_ui/material_ui.dart';

import '../../models/asesor_asesi_models.dart';
import '../../utils/date_format_helper.dart';
import 'asesi_form_common.dart';

// ── 3. AK-01 ──────────────────────────────────────────────────────────────
class AK01Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const AK01Section({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final ak01 = detailData?.ak01;

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-AK.01 Persetujuan & Kerahasiaan',
            status: ak01?.status ?? 'Disetujui',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          AsesiDetailRow('Pernyataan Asesi', ak01?.persetujuan ?? 'Asesi Menyetujui Pelaksanaan Asesmen Sesuai Prosedur LSP'),
          AsesiDetailRow('TUK Pelaksanaan', ak01?.tuk ?? detailData?.tukNama ?? '-'),
          AsesiDetailRow(
            'Tanggal Asesmen',
            ak01?.tglAsesmen.isNotEmpty == true
                ? DateFormatHelper.formatToIndonesian(ak01!.tglAsesmen)
                : (detailData?.jadwalTanggal.isNotEmpty == true
                    ? DateFormatHelper.formatToIndonesian(detailData!.jadwalTanggal)
                    : '-'),
          ),
          AsesiDetailRow('Status Tanda Tangan', ak01?.tandaTangan == true ? 'Sudah Ditandatangani' : 'Belum Ditandatangani'),
        ],
      ),
    );
  }
}

// ── 4. AK-02 ──────────────────────────────────────────────────────────────
class AK02Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const AK02Section({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final ak02 = detailData?.ak02;

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-AK.02 Rekaman Asesmen',
            status: ak02?.status ?? 'Selesai',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          AsesiDetailRow('Hasil Observasi Langsung', ak02?.hasilObservasi ?? 'Kompeten'),
          AsesiDetailRow('Hasil Uji Praktik / Demonstrasi', ak02?.hasilPraktik ?? 'Kompeten'),
          AsesiDetailRow('Hasil Pertanyaan Lisan', ak02?.hasilLisan ?? 'Kompeten'),
          AsesiDetailRow('Hasil Tes Tertulis / Esai', ak02?.hasilEsai ?? 'Kompeten'),
          if (ak02?.komentarObservasi.isNotEmpty == true)
            AsesiDetailRow('Komentar Asesor', ak02!.komentarObservasi),
        ],
      ),
    );
  }
}

// ── 5. AK-03 ──────────────────────────────────────────────────────────────
class AK03Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const AK03Section({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final ak03 = detailData?.ak03;

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-AK.03 Umpan Balik Asesi',
            status: ak03?.status ?? 'Telah Diisi',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          AsesiDetailRow('Umpan Balik Asesi', ak03?.umpanBalik ?? 'Proses asesmen berjalan sangat baik, objektif dan kondusif.'),
          if (ak03?.catatan.isNotEmpty == true)
            AsesiDetailRow('Catatan Tambahan', ak03!.catatan),
        ],
      ),
    );
  }
}

// ── 6. AK-04 ──────────────────────────────────────────────────────────────
class AK04Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const AK04Section({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final ak04 = detailData?.ak04;

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-AK.04 Banding Asesmen',
            status: ak04?.status ?? 'Tidak Ada Banding',
            statusColor: const Color(0xFF2563EB),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          AsesiDetailRow('Permohonan Banding', ak04?.adaBanding == true ? 'Ada Pengajuan Banding' : 'Tidak Ada Pengajuan Banding'),
          if (ak04?.alasanBanding.isNotEmpty == true && ak04!.alasanBanding != '-')
            AsesiDetailRow('Alasan Banding', ak04.alasanBanding),
        ],
      ),
    );
  }
}

// ── 7. AK-05 ──────────────────────────────────────────────────────────────
class AK05Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const AK05Section({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final ak05 = detailData?.ak05;

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-AK.05 Laporan Asesmen',
            status: ak05?.status ?? 'Selesai',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          AsesiDetailRow('Rekomendasi Akhir Asesor', ak05?.rekomendasi ?? detailData?.rekomendasiAsesor ?? 'Belum Dinilai'),
          AsesiDetailRow(
            'Tanggal Rekomendasi',
            ak05?.tanggalRekomendasi.isNotEmpty == true
                ? DateFormatHelper.formatToIndonesianWithTime(ak05!.tanggalRekomendasi)
                : 'Belum diisi asesor',
          ),
          AsesiDetailRow('Pencapaian Unjuk Kerja', ak05?.pencapaian ?? 'Semua kriteria unjuk kerja telah terpenuhi'),
          AsesiDetailRow('Unit yang Belum Kompeten', ak05?.unitBk ?? '-'),
          AsesiDetailRow('Saran Tindak Lanjut', ak05?.saranTindakLanjut ?? 'Pertahankan kompetensi di bidang terkait'),
          AsesiDetailRow('Pemeliharaan Kompetensi', ak05?.peliharaKompetensi ?? 'Mengikuti pelatihan berkelanjutan dan sertifikasi ulang'),
        ],
      ),
    );
  }
}
