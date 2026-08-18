// ============================================================================
// Kartu info asesi: header card & kartu informasi utama (Data Pribadi,
// Data Pekerjaan Sekarang, Data Asesmen).
//
// Diekstrak dari asesi_form_sections.dart agar tiap bagian form asesi
// menjadi modul tersendiri.
// ============================================================================

import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../models/asesor_asesi_models.dart';
import '../../utils/date_format_helper.dart';
import 'asesi_form_common.dart';

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

/// Kartu informasi utama asesi (Data Pribadi, Data Pekerjaan Sekarang, Data Asesmen).
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

    final hasPekerjaan = d.pekerjaan.isNotEmpty ||
        d.organisasi.isNotEmpty ||
        d.jabatan.isNotEmpty ||
        d.alamatCompany.isNotEmpty ||
        d.telpCompany.isNotEmpty ||
        d.emailCompany.isNotEmpty;

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
          const Text(
            'a. Data Pribadi',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          AsesiDetailRow('Tempat, Tanggal Lahir', ttl),
          AsesiDetailRow('Jenis Kelamin', jenisKel),
          AsesiDetailRow('Alamat Domisili', d.alamat.isNotEmpty ? d.alamat : '-'),
          AsesiDetailRow('No. Telepon / HP', d.noTelepon.isNotEmpty ? d.noTelepon : '-'),
          AsesiDetailRow('Email', d.email.isNotEmpty ? d.email : '-'),
          AsesiDetailRow('Pendidikan Terakhir', d.pendidikan.isNotEmpty ? d.pendidikan : '-'),
          AsesiDetailRow('Institusi / Sekolah', d.institusi.isNotEmpty ? d.institusi : '-'),
          if (d.jurusan.isNotEmpty)
            AsesiDetailRow('Jurusan / Prodi', d.jurusan),

          if (hasPekerjaan) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),
            const Text(
              'b. Data Pekerjaan Sekarang',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            if (d.pekerjaan.isNotEmpty)
              AsesiDetailRow('Pekerjaan', d.pekerjaan),
            if (d.organisasi.isNotEmpty)
              AsesiDetailRow('Nama Perusahaan / Institusi', d.organisasi),
            if (d.jabatan.isNotEmpty)
              AsesiDetailRow('Jabatan', d.jabatan),
            if (d.alamatCompany.isNotEmpty)
              AsesiDetailRow('Alamat Perusahaan', d.alamatCompany),
            if (d.telpCompany.isNotEmpty)
              AsesiDetailRow('No. Telp Perusahaan', d.telpCompany),
            if (d.emailCompany.isNotEmpty)
              AsesiDetailRow('Email Perusahaan', d.emailCompany),
            if (d.kodePosCompany.isNotEmpty)
              AsesiDetailRow('Kode Pos', d.kodePosCompany),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          const Text(
            'c. Data Asesmen',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          AsesiDetailRow('Jadwal Asesmen', d.jadwalNama.isNotEmpty ? d.jadwalNama : '-'),
          AsesiDetailRow(
            'Tanggal Jadwal',
            d.jadwalTanggal.isNotEmpty
                ? DateFormatHelper.formatToIndonesian(d.jadwalTanggal)
                : '-',
          ),
          AsesiDetailRow('TUK', d.tukNama.isNotEmpty ? d.tukNama : '-'),
        ],
      ),
    );
  }
}
