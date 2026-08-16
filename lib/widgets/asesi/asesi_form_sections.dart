// ============================================================================
// Asesi Form Sections (APL-01, APL-02, AK-01..AK-05)
//
// Diekstrak dari asesor_detail_asesi_screen.dart agar screen hanya berisi
// state + navigasi form.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../models/asesor_asesi_models.dart';

/// Row label–nilai standar untuk detail asesi.
class AsesiDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const AsesiDetailRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu status header form (judul + badge status).
class FormSectionHeader extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;

  const FormSectionHeader({
    super.key,
    required this.title,
    required this.status,
    this.statusColor = const Color(0xFF059669),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(20),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Container kartu putih standar untuk section form.
class FormSectionCard extends StatelessWidget {
  final Widget child;

  const FormSectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: child,
    );
  }
}

/// Item bukti dokumen (APL-01).
class DocItem extends StatelessWidget {
  final String name;
  final String jenis;
  final bool ada;

  const DocItem({super.key, required this.name, required this.jenis, required this.ada});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            ada ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 16,
            color: ada ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: jenis == 'Wajib' ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              jenis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: jenis == 'Wajib' ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat mini (APL-02).
class MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color textCol;
  final Color bgCol;

  const MiniStat(this.label, this.value, this.textCol, this.bgCol, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textCol,
            ),
          ),
        ],
      ),
    );
  }
}

/// Item unit kompetensi (APL-02).
class UnitItem extends StatelessWidget {
  final APL02UnitItem unit;

  const UnitItem({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final isK = unit.statusKompeten == 'K';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isK ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              unit.statusKompeten,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isK ? const Color(0xFF059669) : const Color(0xFFDC2626),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (unit.kodeUnit.isNotEmpty)
                  Text(
                    unit.kodeUnit,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                Text(
                  unit.judulUnit,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
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

// ── 1. APL-01 ─────────────────────────────────────────────────────────────
class APL01Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const APL01Section({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final apl01 = detailData?.apl01;

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-APL.01 Permohonan Sertifikasi',
            status: apl01?.status ?? 'Terverifikasi',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          AsesiDetailRow('Rekomendasi Admin', apl01?.rekomendasi ?? 'Diterima Sebagai Peserta Asesmen'),
          if (apl01?.catatan.isNotEmpty == true)
            AsesiDetailRow('Catatan', apl01!.catatan),
          if (apl01?.tanggalValidasi.isNotEmpty == true)
            AsesiDetailRow('Tanggal Validasi', apl01!.tanggalValidasi),
          const SizedBox(height: 14),
          const Text(
            'Bukti Kelengkapan Pemohon:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          if (apl01 != null && apl01.buktiDokumen.isNotEmpty)
            ...apl01.buktiDokumen.map((doc) => DocItem(name: doc.nama, jenis: doc.jenis, ada: doc.ada))
          else ...[
            const DocItem(name: 'Pas Foto 3x4 Background Merah', jenis: 'Wajib', ada: true),
            const DocItem(name: 'Kartu Tanda Penduduk (KTP)', jenis: 'Wajib', ada: true),
            const DocItem(name: 'Ijazah Terakhir / Transkrip', jenis: 'Wajib', ada: true),
            const DocItem(name: 'Curriculum Vitae (CV)', jenis: 'Wajib', ada: true),
            const DocItem(name: 'Portofolio / Sertifikat Terkait', jenis: 'Tambahan', ada: true),
          ],
        ],
      ),
    );
  }
}

// ── 2. APL-02 ─────────────────────────────────────────────────────────────
class APL02Section extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const APL02Section({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final apl02 = detailData?.apl02;

    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'FR-APL.02 Asesmen Mandiri',
            status: apl02?.status ?? 'Lengkap',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MiniStat(
                  'Total Unit',
                  '${apl02?.totalUnit ?? 0}',
                  const Color(0xFF2563EB),
                  const Color(0xFFEFF6FF),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MiniStat(
                  'Kompeten [K]',
                  '${apl02?.totalK ?? 0}',
                  const Color(0xFF059669),
                  const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MiniStat(
                  'Belum [BK]',
                  '${apl02?.totalBK ?? 0}',
                  const Color(0xFFDC2626),
                  const Color(0xFFFEF2F2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Daftar Unit Kompetensi:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          if (apl02 != null && apl02.units.isNotEmpty)
            ...apl02.units.map((u) => UnitItem(unit: u))
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Data unit kompetensi telah terverifikasi kompeten pada skema sertifikasi.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
        ],
      ),
    );
  }
}

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
          AsesiDetailRow('Tanggal Asesmen', ak01?.tglAsesmen ?? detailData?.jadwalTanggal ?? '-'),
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
          AsesiDetailRow('Rekomendasi Akhir Asesor', ak05?.rekomendasi ?? detailData?.rekomendasiAsesor ?? 'Kompeten'),
          if (ak05?.tanggalRekomendasi.isNotEmpty == true)
            AsesiDetailRow('Tanggal Rekomendasi', ak05!.tanggalRekomendasi),
          AsesiDetailRow('Pencapaian Unjuk Kerja', ak05?.pencapaian ?? 'Semua kriteria unjuk kerja telah terpenuhi'),
          AsesiDetailRow('Unit yang Belum Kompeten', ak05?.unitBk ?? '-'),
          AsesiDetailRow('Saran Tindak Lanjut', ak05?.saranTindakLanjut ?? 'Pertahankan kompetensi di bidang terkait'),
          AsesiDetailRow('Pemeliharaan Kompetensi', ak05?.peliharaKompetensi ?? 'Mengikuti pelatihan berkelanjutan dan sertifikasi ulang'),
        ],
      ),
    );
  }
}

/// Info pill kecil (icon + teks) pada header card.
class AsesiInfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const AsesiInfoPill({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Kartu header asesi (avatar, nama, no peserta, badge rekomendasi).
class AsesiHeaderCard extends StatelessWidget {
  final String nama;
  final String noPeserta;
  final String nik;
  final String skema;
  final String tuk;
  final String jadwal;
  final String rekomendasi;

  const AsesiHeaderCard({
    super.key,
    required this.nama,
    required this.noPeserta,
    required this.nik,
    required this.skema,
    required this.tuk,
    required this.jadwal,
    required this.rekomendasi,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeBg = const Color(0xFFEFF6FF);
    Color badgeText = const Color(0xFF2563EB);

    if (rekomendasi.toLowerCase().contains('kompeten') &&
        !rekomendasi.toLowerCase().contains('belum')) {
      badgeBg = const Color(0xFFECFDF5);
      badgeText = const Color(0xFF059669);
    } else if (rekomendasi.toLowerCase().contains('belum')) {
      badgeBg = const Color(0xFFFEF2F2);
      badgeText = const Color(0xFFDC2626);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF2563EB),
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No. Peserta: $noPeserta',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rekomendasi,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          AsesiInfoPill(icon: Icons.badge_outlined, text: 'NIK: $nik'),
          const SizedBox(height: 6),
          AsesiInfoPill(icon: LucideIcons.award, text: skema),
          const SizedBox(height: 6),
          AsesiInfoPill(icon: LucideIcons.building, text: tuk),
        ],
      ),
    );
  }
}

/// Kartu informasi utama asesi (TTL, jenis kelamin, alamat, dll).
class AsesiInfoUtamaCard extends StatelessWidget {
  final AsesorAsesiDetailData? detailData;

  const AsesiInfoUtamaCard({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final d = detailData;
    if (d == null) return const SizedBox.shrink();

    final ttl = '${d.tempatLahir.isNotEmpty ? d.tempatLahir : "-"}'
        '${d.tanggalLahir.isNotEmpty ? ", ${d.tanggalLahir}" : ""}';
    final jenisKel = d.jenisKelamin == '1' || d.jenisKelamin.toLowerCase().contains('laki')
        ? 'Laki-Laki'
        : (d.jenisKelamin == '2' || d.jenisKelamin.toLowerCase().contains('perempuan')
            ? 'Perempuan'
            : (d.jenisKelamin.isNotEmpty ? d.jenisKelamin : '-'));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Informasi Utama Asesi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AsesiDetailRow('Tempat, Tanggal Lahir', ttl),
          AsesiDetailRow('Jenis Kelamin', jenisKel),
          AsesiDetailRow('Alamat', d.alamat.isNotEmpty ? d.alamat : '-'),
          AsesiDetailRow('No. Telepon / HP', d.noTelepon.isNotEmpty ? d.noTelepon : '-'),
          AsesiDetailRow('Email', d.email.isNotEmpty ? d.email : '-'),
          AsesiDetailRow('Institusi / Sekolah', d.institusi.isNotEmpty ? d.institusi : '-'),
          AsesiDetailRow('Jadwal Asesmen', d.jadwalNama.isNotEmpty ? d.jadwalNama : '-'),
          AsesiDetailRow('Tanggal Jadwal', d.jadwalTanggal.isNotEmpty ? d.jadwalTanggal : '-'),
          AsesiDetailRow('TUK', d.tukNama.isNotEmpty ? d.tukNama : '-'),
        ],
      ),
    );
  }
}
